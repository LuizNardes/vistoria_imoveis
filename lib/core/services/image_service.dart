import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../errors/app_exceptions.dart';

part 'image_service.g.dart';

@riverpod
ImageService imageService(ImageServiceRef ref) {
  return ImageService();
}

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Abre a câmera ou galeria e retorna o arquivo
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        // Dica de Performance: O próprio OS já pode fazer um resize prévio
        // mas faremos o nosso via compress para garantir consistência entre Android/iOS
        requestFullMetadata: false, 
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);

    } on PlatformException catch (e) {
      // Captura erros de permissão comuns (camera_access_denied, photo_access_denied)
      if (e.code.contains('access') || e.code.contains('permission')) {
        throw ImageException(
          'Permissão negada. Habilite o acesso nas configurações.',
          isPermissionError: true,
        );
      }
      throw ImageException('Erro ao acessar a galeria/câmera: ${e.message}');
    } catch (e) {
      throw ImageException('Erro desconhecido ao selecionar imagem.');
    }
  }

  /// Comprime a imagem para evitar uploads gigantes (Otimização de Banda e Armazenamento)
  Future<File> compressImage(File file) async {
    try {
      // 1. Obter diretório temporário para salvar a versão comprimida
      final tempDir = await getTemporaryDirectory();
      
      // 2. Gerar nome único para não sobrescrever arquivos
      final targetPath = '${tempDir.path}/${_uuid.v4()}.jpg';

      // 3. Executar compressão nativa (C++ por baixo dos panos, muito rápido)
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,       // 70% é o "sweet spot" entre qualidade e tamanho
        minWidth: 1024,    // Redimensiona mantendo aspect ratio
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        throw ImageException('Falha na compressão da imagem.');
      }

      return File(result.path);
    } catch (e) {
      throw ImageException('Erro ao otimizar imagem: $e');
    }
  }
}
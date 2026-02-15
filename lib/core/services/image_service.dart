import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../errors/app_exceptions.dart'; // Ajuste o import conforme necessário

part 'image_service.g.dart';

@riverpod
ImageService imageService(ImageServiceRef ref) {
  return ImageService();
}

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Abre a câmera ou galeria e retorna o arquivo bruto
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        // Dica: requestFullMetadata: false pode acelerar a captura no Android
        requestFullMetadata: false, 
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } on PlatformException catch (e) {
      // Captura negação de permissão
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        throw ImageFailure('Permissão de acesso negada. Verifique as configurações.');
      }
      throw ImageFailure('Erro ao acessar mídia: ${e.message}');
    } catch (e) {
      throw ImageFailure('Erro desconhecido ao selecionar imagem.');
    }
  }

  /// Comprime a imagem para otimizar upload e memória
  /// Reduz de ~5MB para ~150KB
  Future<File> compressImage(File file) async {
    try {
      // 1. Obter diretório temporário para salvar o output
      final tempDir = await getTemporaryDirectory();
      
      // 2. Definir caminho de destino (Source path != Target path obrigatoriamente)
      final targetPath = '${tempDir.path}/${_uuid.v4()}.jpg';

      // 3. Executar compressão nativa
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,       // Equilíbrio ideal qualidade/tamanho
        minWidth: 1024,    // Redimensiona mantendo proporção
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        throw ImageFailure('Falha ao comprimir imagem.');
      }

      return File(result.path);
    } catch (e) {
      throw ImageFailure('Erro na otimização da imagem: $e');
    }
  }
}
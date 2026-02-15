import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/app_exceptions.dart';

part 'storage_repository.g.dart';

@riverpod
StorageRepository storageRepository(StorageRepositoryRef ref) {
  return StorageRepository(FirebaseStorage.instance);
}

class StorageRepository {
  final FirebaseStorage _storage;

  StorageRepository(this._storage);

  /// Upload de arquivo e retorno da URL pública
  /// [path] ex: inspections/123/items/abc/uuid.jpg
  Future<String> uploadImage({
    required File file,
    required String path,
  }) async {
    try {
      // 1. Cria a referência no bucket
      final ref = _storage.ref().child(path);

      // 2. Configura metadados (importante para cache do navegador/app)
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'optimized': 'true'},
      );

      // 3. Executa o upload
      final uploadTask = await ref.putFile(file, metadata);

      // 4. Obtém a URL de download
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Tratamento específico de erros do Firebase
      if (e.code == 'permission-denied') {
        throw ImageFailure('Sem permissão para enviar imagens. Contate o suporte.');
      } else if (e.code == 'retry-limit-exceeded') {
        throw ImageFailure('Conexão instável. Tente novamente.');
      }
      throw ImageFailure('Erro no upload: ${e.message}');
    } catch (e) {
      throw ImageFailure('Erro inesperado ao salvar imagem.');
    }
  }
}
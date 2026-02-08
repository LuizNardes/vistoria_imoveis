import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_repository.g.dart';

@riverpod
StorageRepository storageRepository(StorageRepositoryRef ref) {
  return StorageRepository(FirebaseStorage.instance);
}

class StorageRepository {
  final FirebaseStorage _storage;

  StorageRepository(this._storage);

  /// Faz o upload e retorna a URL pública para salvar no Firestore
  Future<String> uploadImage({
    required File file,
    required String path, // ex: inspections/123/items/abc/foto.jpg
  }) async {
    try {
      // 1. Referência ao caminho no bucket
      final ref = _storage.ref().child(path);

      // 2. Configura metadata (Opcional, mas bom para cache no browser/CDN)
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'compressed': 'true'},
      );

      // 3. Upload Task
      final uploadTask = await ref.putFile(file, metadata);

      // 4. Aguarda finalizar e pega a URL
      // Se falhar, o 'await' lança a exceção do Firebase
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;

    } on FirebaseException catch (e) {
      // Tratamento específico do Firebase
      if (e.code == 'permission-denied') {
        throw Exception('Permissão negada no servidor. Verifique as Security Rules.');
      }
      throw Exception('Erro no upload: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido no upload: $e');
    }
  }
}
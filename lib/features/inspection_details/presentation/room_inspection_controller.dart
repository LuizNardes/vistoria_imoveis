import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

// --- IMPORTS INTERNOS ---
import '../../../../core/services/image_service.dart';
import '../data/inspection_details_repository.dart';
import '../data/storage_repository.dart';
import '../domain/inspection_details_models.dart';

part 'room_inspection_controller.g.dart';

// --- PROVIDER DE LEITURA (STREAM) ---
@riverpod
Stream<List<InspectionItem>> roomItems(
  RoomItemsRef ref,
  String inspectionId,
  String roomId,
) {
  final repo = ref.watch(inspectionDetailsRepositoryProvider);
  return repo.watchItems(inspectionId, roomId);
}

// --- CONTROLLER DE AÇÃO ---
@riverpod
class RoomInspectionController extends _$RoomInspectionController {
  final _uuid = const Uuid();

  @override
  FutureOr<void> build() {
    // Estado inicial
  }

  /// 1. Popula itens padrão se a lista estiver vazia (Seed)
  Future<void> seedItems(String inspectionId, String roomId, String roomName) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    
    try {
      // Verifica se já existem itens (sem usar stream para ser mais rápido)
      final existingItemsStream = repo.watchItems(inspectionId, roomId);
      final existingItems = await existingItemsStream.first;

      if (existingItems.isNotEmpty) {
        return; // Já tem itens, sai da função
      }

      state = const AsyncLoading();

      // Gera os itens em memória usando o método auxiliar
      final List<String> defaultItems = _getDefaultItemsForRoom(roomName);
      
      final itemsToAdd = defaultItems
          .map((itemName) => InspectionItem(
                id: '', // ID será gerado pelo Firestore
                name: itemName,
                condition: ItemCondition.ok,
              ))
          .toList();

      // Salva no banco
      await repo.addItems(inspectionId, roomId, itemsToAdd);
      
      // Reseta o estado para parar o loading
      state = const AsyncValue.data(null);
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 2. Atualiza Status do Item
  Future<void> updateItemStatus(String inspectionId, String roomId, InspectionItem item, ItemCondition newCondition) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    final updatedItem = item.copyWith(condition: newCondition);
    await repo.updateItem(inspectionId, roomId, updatedItem);
  }

  /// 3. Atualiza Observações do Item
  Future<void> updateItemNotes(String inspectionId, String roomId, InspectionItem item, String notes) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    final updatedItem = item.copyWith(notes: notes);
    await repo.updateItem(inspectionId, roomId, updatedItem);
  }

  /// 4. Adiciona Foto
  Future<void> addPhoto({
    required String inspectionId,
    required String roomId,
    required InspectionItem item,
    required ImageSource source,
  }) async {
    // Nota: O estado de loading é gerenciado localmente no Widget para não rebuildar a tela toda.
    
    // 1. Selecionar Imagem
    final File? rawFile = await ref.read(imageServiceProvider).pickImage(source: source);
    if (rawFile == null) return; // Usuário cancelou

    // 2. Comprimir (Isso ocorre em isolate nativo para não travar a UI)
    final File compressedFile = await ref.read(imageServiceProvider).compressImage(rawFile);

    // 3. Definir Caminho no Storage
    // inspections/<id_vistoria>/items/<id_item>/<uuid>.jpg
    final String storagePath = 'inspections/$inspectionId/items/${item.id}/${_uuid.v4()}.jpg';
    
    // 4. Upload
    final String downloadUrl = await ref.read(storageRepositoryProvider).uploadImage(
      file: compressedFile,
      path: storagePath,
    );

    // 5. Atualizar lista localmente (Princípio de Imutabilidade)
    final updatedPhotos = [...item.photos, downloadUrl];
    final updatedItem = item.copyWith(photos: updatedPhotos);

    // 6. Salvar no Firestore
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    await repo.updateItem(inspectionId, roomId, updatedItem);
    
    // O arquivo temporário da compressão é limpo pelo SO eventualmente.
  }

  /// Remove a foto da lista e atualiza o banco
  Future<void> removePhoto({
    required String inspectionId,
    required String roomId,
    required InspectionItem item,
    required String photoUrl,
  }) async {
    // 1. Filtra a lista removendo a URL específica
    final updatedPhotos = item.photos.where((url) => url != photoUrl).toList();
    final updatedItem = item.copyWith(photos: updatedPhotos);

    // 2. Atualiza Firestore
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    await repo.updateItem(inspectionId, roomId, updatedItem);
    
    // Nota: Em um cenário ideal, dispararíamos uma Cloud Function ou chamaríamos
    // o StorageRepository para deletar o arquivo físico para economizar espaço.
  }

  // --- MÉTODOS AUXILIARES (PRIVADOS) ---
  List<String> _getDefaultItemsForRoom(String roomName) {
    final name = roomName.toLowerCase();
    
    if (name.contains('cozinha')) {
      return ['Piso', 'Paredes', 'Teto', 'Pia', 'Torneira', 'Armários', 'Janela', 'Tomadas'];
    } else if (name.contains('banheiro') || name.contains('lavabo')) {
      return ['Piso', 'Azulejos', 'Vaso Sanitário', 'Pia', 'Torneira', 'Chuveiro', 'Box', 'Espelho', 'Porta'];
    } else if (name.contains('quarto') || name.contains('dormitório') || name.contains('suite')) {
      return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Tomadas', 'Interruptores', 'Armários'];
    } else if (name.contains('sala')) {
      return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Tomadas', 'Iluminação'];
    } else if (name.contains('serviço') || name.contains('lavanderia')) {
      return ['Piso', 'Paredes', 'Tanque', 'Torneira', 'Janela', 'Aquecedor', 'Tomadas'];
    }
    
    // Default genérico
    return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Elétrica', 'Hidráulica'];
  }

}
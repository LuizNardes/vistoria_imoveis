import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/image_service.dart';
import '../data/inspection_details_repository.dart';
import '../data/storage_repository.dart';
import '../domain/inspection_details_models.dart';

part 'room_inspection_controller.g.dart';

@riverpod
Stream<List<InspectionItem>> roomItems(
  RoomItemsRef ref,
  String inspectionId,
  String roomId,
) {
  final repo = ref.watch(inspectionDetailsRepositoryProvider);
  return repo.watchItems(inspectionId, roomId);
}

@riverpod
class RoomInspectionController extends _$RoomInspectionController {
  final _uuid = const Uuid();

  @override
  FutureOr<void> build() {}

  // --- RECALCULAR PROGRESSO ---
  Future<void> _updateRoomProgress(String inspectionId, String roomId) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    final items = await repo.watchItems(inspectionId, roomId).first;
    
    final total = items.length;
    // Heurística de conclusão:
    final completed = items.where((i) => 
      i.condition != ItemCondition.ok || 
      (i.notes != null && i.notes!.trim().isNotEmpty) || 
      i.photos.isNotEmpty
    ).length;

    await repo.updateRoomCounters(inspectionId, roomId, total, completed);
  }

  // --- MÉTODOS DE AÇÃO ---

  Future<void> seedItems(String inspectionId, String roomId, String roomName) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    try {
      final existingItemsStream = repo.watchItems(inspectionId, roomId);
      final existingItems = await existingItemsStream.first;

      if (existingItems.isNotEmpty) return;

      state = const AsyncLoading();
      final List<String> defaultItems = _getDefaultItemsForRoom(roomName);
      
      final itemsToAdd = defaultItems.map((itemName) => InspectionItem(
        id: '', 
        name: itemName, 
        condition: ItemCondition.ok,
      )).toList();

      await repo.addItems(inspectionId, roomId, itemsToAdd);
      await _updateRoomProgress(inspectionId, roomId); // Atualiza progresso
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addItem(String inspectionId, String roomId, String itemName) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    final newItem = InspectionItem(id: '', name: itemName, condition: ItemCondition.ok);
    await repo.addItems(inspectionId, roomId, [newItem]);
    await _updateRoomProgress(inspectionId, roomId); // Atualiza progresso
  }

  Future<void> removeItem(String inspectionId, String roomId, String itemId) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    await repo.deleteItem(inspectionId, roomId, itemId);
    await _updateRoomProgress(inspectionId, roomId); // Atualiza progresso
  }

  Future<void> updateItemStatus(String inspectionId, String roomId, InspectionItem item, ItemCondition newCondition) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    final updatedItem = item.copyWith(condition: newCondition);
    await repo.updateItem(inspectionId, roomId, updatedItem);
    await _updateRoomProgress(inspectionId, roomId); // Atualiza progresso
  }

  Future<void> updateItemNotes(String inspectionId, String roomId, InspectionItem item, String notes) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    final updatedItem = item.copyWith(notes: notes);
    await repo.updateItem(inspectionId, roomId, updatedItem);
    await _updateRoomProgress(inspectionId, roomId); // Atualiza progresso
  }

  Future<void> addPhoto({required String inspectionId, required String roomId, required InspectionItem item, required ImageSource source}) async {
    final File? rawFile = await ref.read(imageServiceProvider).pickImage(source: source);
    if (rawFile == null) return;

    final File compressedFile = await ref.read(imageServiceProvider).compressImage(rawFile);
    final String storagePath = 'inspections/$inspectionId/items/${item.id}/${_uuid.v4()}.jpg';
    
    final String downloadUrl = await ref.read(storageRepositoryProvider).uploadImage(
      file: compressedFile,
      path: storagePath,
    );

    final updatedPhotos = [...item.photos, downloadUrl];
    final updatedItem = item.copyWith(photos: updatedPhotos);

    final repo = ref.read(inspectionDetailsRepositoryProvider);
    await repo.updateItem(inspectionId, roomId, updatedItem);
    await _updateRoomProgress(inspectionId, roomId); // Atualiza progresso
  }

  Future<void> removePhoto({required String inspectionId, required String roomId, required InspectionItem item, required String photoUrl}) async {
    final updatedPhotos = item.photos.where((url) => url != photoUrl).toList();
    final updatedItem = item.copyWith(photos: updatedPhotos);

    final repo = ref.read(inspectionDetailsRepositoryProvider);
    await repo.updateItem(inspectionId, roomId, updatedItem);
    await _updateRoomProgress(inspectionId, roomId); // Atualiza progresso
  }

  // --- AUXILIAR ---
  List<String> _getDefaultItemsForRoom(String roomName) {
    final name = roomName.toLowerCase();
    if (name.contains('cozinha')) return ['Piso', 'Paredes', 'Teto', 'Pia', 'Torneira', 'Armários', 'Janela', 'Tomadas'];
    if (name.contains('banheiro') || name.contains('lavabo')) return ['Piso', 'Azulejos', 'Vaso Sanitário', 'Pia', 'Torneira', 'Chuveiro', 'Box', 'Espelho', 'Porta'];
    if (name.contains('quarto') || name.contains('dormitório') || name.contains('suite')) return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Tomadas', 'Interruptores', 'Armários'];
    if (name.contains('sala')) return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Tomadas', 'Iluminação'];
    if (name.contains('serviço') || name.contains('lavanderia')) return ['Piso', 'Paredes', 'Tanque', 'Torneira', 'Janela', 'Aquecedor', 'Tomadas'];
    return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Elétrica', 'Hidráulica'];
  }
}
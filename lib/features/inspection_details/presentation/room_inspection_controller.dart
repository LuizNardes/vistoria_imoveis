import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/inspection_details_repository.dart';
import '../domain/inspection_details_model.dart';

part 'room_inspection_controller.g.dart';

// Provider para ouvir os itens em tempo real
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
  @override
  FutureOr<void> build() {}

  /// Popula o cômodo com itens padrão se estiver vazio
  Future<void> seedItems(String inspectionId, String roomId, String roomName) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    
    // 1. Verifica se já existem itens (para não duplicar)
    // Nota: Em produção, o ideal seria o repo ter um método 'getItemsCount' para ser mais leve via 'count() aggregation'
    final currentItemsStream = repo.watchItems(inspectionId, roomId);
    final currentItems = await currentItemsStream.first;

    if (currentItems.isNotEmpty) return;

    state = const AsyncLoading();

    // 2. Lista de templates baseada no nome (Hardcoded para MVP)
    final List<String> defaultItems = _getDefaultItemsForRoom(roomName);

    // 3. Adiciona item por item (Batch write seria melhor, mas seguiremos o requisito simples)
    state = await AsyncValue.guard(() async {
      for (final itemName in defaultItems) {
        await repo.addItem(inspectionId, roomId, InspectionItem(
          id: '', // Repo gera
          name: itemName,
          condition: ItemCondition.ok, // Padrão começa como OK
        ));
      }
    });
  }

  Future<void> updateItemStatus(String inspectionId, String roomId, InspectionItem item, ItemCondition newCondition) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    final updatedItem = item.copyWith(condition: newCondition);
    await repo.updateItem(inspectionId, roomId, updatedItem);
  }

  Future<void> updateItemNotes(String inspectionId, String roomId, InspectionItem item, String notes) async {
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    final updatedItem = item.copyWith(notes: notes);
    await repo.updateItem(inspectionId, roomId, updatedItem);
  }

  // Helper simples de templates
  List<String> _getDefaultItemsForRoom(String roomName) {
    final name = roomName.toLowerCase();
    if (name.contains('cozinha')) {
      return ['Piso', 'Paredes', 'Teto', 'Pia', 'Torneira', 'Armários', 'Janela'];
    } else if (name.contains('banheiro')) {
      return ['Piso', 'Azulejos', 'Vaso Sanitário', 'Pia', 'Chuveiro', 'Espelho', 'Porta'];
    } else if (name.contains('quarto') || name.contains('dormitório')) {
      return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Tomadas', 'Iluminação'];
    } else if (name.contains('sala')) {
      return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Tomadas', 'Iluminação'];
    }
    // Default genérico
    return ['Piso', 'Paredes', 'Teto', 'Porta', 'Janela', 'Elétrica'];
  }
}
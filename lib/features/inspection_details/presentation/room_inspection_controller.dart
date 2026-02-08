import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

// Imports internos
import '../../../../core/services/image_service.dart';
import '../data/inspection_details_repository.dart';
import '../data/storage_repository.dart';
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
  final _uuid = const Uuid();

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

    /// Adiciona uma foto ao item: Pick -> Compress -> Upload -> Update DB
  Future<void> addPhoto({
    required String inspectionId,
    required String roomId,
    required InspectionItem item,
    required ImageSource source,
  }) async {
    // Não definimos state = AsyncLoading() aqui para não travar a tela inteira.
    // O loading será local no Card do item.
    
    // 1. Selecionar Imagem
    final File? rawFile = await ref.read(imageServiceProvider).pickImage(source: source);
    if (rawFile == null) return; // Usuário cancelou

    // 2. Comprimir (Isso é pesado, ocorre em isolate nativo via lib)
    final File compressedFile = await ref.read(imageServiceProvider).compressImage(rawFile);

    // 3. Upload para o Firebase Storage
    // Caminho: inspections/<id_vistoria>/items/<id_item>/<uuid>.jpg
    final String storagePath = 'inspections/$inspectionId/items/${item.id}/${_uuid.v4()}.jpg';
    
    final String downloadUrl = await ref.read(storageRepositoryProvider).uploadImage(
      file: compressedFile,
      path: storagePath,
    );

    // 4. Atualizar lista localmente (Imutabilidade)
    final updatedPhotos = [...item.photos, downloadUrl];
    final updatedItem = item.copyWith(photos: updatedPhotos);

    // 5. Salvar no Firestore
    final repo = ref.read(inspectionDetailsRepositoryProvider);
    await repo.updateItem(inspectionId, roomId, updatedItem);
    
    // Opcional: Limpar arquivo temporário se necessário, 
    // mas o SO geralmente limpa o cache.
  }

  Future<void> removePhoto({
    required String inspectionId,
    required String roomId,
    required InspectionItem item,
    required String photoUrl,
  }) async {
    // 1. Filtra a lista removendo a URL
    final updatedPhotos = item.photos.where((url) => url != photoUrl).toList();
    final updatedItem = item.copyWith(photos: updatedPhotos);

    // 2. Atualiza Firestore
    // Nota: Em um app real, deveríamos deletar do Storage também para não deixar lixo.
    // Isso pode ser feito aqui ou via Cloud Function (trigger onUpdate).
    final repo = ref.read(inspectionDetailsRepositoryProvider);
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
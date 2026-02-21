import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vistoria_imoveis/features/inspections/data/inspections_repository.dart';
import 'package:vistoria_imoveis/features/inspections/domain/inspection.dart';
import '../data/inspection_details_repository.dart';
import '../domain/inspection_details_models.dart';

part 'inspection_details_controller.g.dart';

// 1. Provider para Listar os Cômodos (Stream)
@riverpod
Stream<List<InspectionRoom>> inspectionRooms(
  InspectionRoomsRef ref,
  String inspectionId,
) {
  final repository = ref.watch(inspectionDetailsRepositoryProvider);
  return repository.watchRooms(inspectionId);
}

// 2. Controller para Ações (Adicionar/Remover)
@riverpod
class InspectionDetailsController extends _$InspectionDetailsController {
  @override
  FutureOr<void> build() {
    // Estado inicial vazio (idle)
  }

  Future<void> addRoom(String inspectionId, String name) async {
    final repository = ref.read(inspectionDetailsRepositoryProvider);
    
    // Define estado de loading para travar UI se necessário
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final newRoom = InspectionRoom(
        id: '', // O Firestore vai gerar o ID real
        name: name,
        completedItems: 0,
        totalItems: 0,
      );
      
      await repository.addRoom(inspectionId, newRoom);
    });
  }

  Future<void> updateInspectionStatus(String inspectionId, InspectionStatus status) async {
    final repo = ref.read(inspectionsRepositoryProvider);
    await repo.updateStatus(inspectionId, status);
  }

  Future<void> deleteRoom(String inspectionId, String roomId) async {
    final repository = ref.read(inspectionDetailsRepositoryProvider);
    
    try {
      await repository.deleteRoom(inspectionId, roomId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
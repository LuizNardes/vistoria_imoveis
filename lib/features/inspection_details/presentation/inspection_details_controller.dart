import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/inspection_details_repository.dart';
import '../domain/inspection_details_model.dart';

part 'inspection_details_controller.g.dart';

// --- DATA PROVIDER (Leitura) ---
// Este provider conecta o Stream do repositório ao ciclo de vida do Riverpod.
// O 'keepAlive: true' é opcional, mas útil se o usuário entrar e sair da tela frequentemente.
@riverpod
Stream<List<InspectionRoom>> inspectionRooms(
  InspectionRoomsRef ref,
  String inspectionId,
) {
  final repository = ref.watch(inspectionDetailsRepositoryProvider);
  return repository.watchRooms(inspectionId);
}

// --- ACTION CONTROLLER (Escrita) ---
@riverpod
class InspectionDetailsController extends _$InspectionDetailsController {
  @override
  FutureOr<void> build() {
    // Estado inicial vazio (Idle)
  }

  Future<void> addRoom(String inspectionId, String name) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(inspectionDetailsRepositoryProvider);
      await repository.addRoom(inspectionId, name);
    });
  }

  // Opcional: Delete
  Future<void> deleteRoom(String inspectionId, String roomId) async {
    // Implementação futura se necessário
  }
}
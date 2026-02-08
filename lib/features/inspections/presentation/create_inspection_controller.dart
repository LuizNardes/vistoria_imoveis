import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../../inspections/data/inspections_repository.dart';
import '../../inspections/domain/inspection.dart';

part 'create_inspection_controller.g.dart';

@riverpod
class CreateInspectionController extends _$CreateInspectionController {
  @override
  FutureOr<void> build() {
    // O estado inicial é "void" (sem dados), representando "Idle" (Ocioso).
    // Não precisamos carregar nada ao iniciar essa tela.
  }

  Future<void> submit({
    required String clientName,
    required String address,
    required DateTime date,
  }) async {
    // 1. Defina o estado como Loading para a UI mostrar o spinner
    state = const AsyncLoading();

    // 2. Execute a lógica protegida por AsyncValue.guard
    // Isso captura exceções automaticamente e coloca no estado AsyncError
    state = await AsyncValue.guard(() async {
      final user = ref.read(firebaseAuthProvider).currentUser;
      
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      // Cria a entidade de domínio (Factory helper que criamos antes)
      final inspection = Inspection.create(
        userId: user.uid,
        clientName: clientName,
        address: address,
        date: date,
      );

      // Chama o repositório
      await ref.read(inspectionsRepositoryProvider).createInspection(inspection);
    });
  }
}
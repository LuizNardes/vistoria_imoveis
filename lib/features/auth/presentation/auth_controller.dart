import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart'; // Ajuste o import se necessário

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Estado inicial não faz nada
  }

  Future<void> loginWithGoogle() async {
    // Trava a tela com loading enquanto tenta logar
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithGoogle();
    });
  }
}
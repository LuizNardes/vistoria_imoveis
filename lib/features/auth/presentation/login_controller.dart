import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {
    // Estado inicial vazio (idle)
  }

  Future<void> login(String email, String password) async {
    // Define estado como Loading
    state = const AsyncLoading();
    
    // Executa o login e captura erros automaticamente no AsyncValue
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password)
    );
  }
}
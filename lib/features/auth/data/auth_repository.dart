import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Esta linha é crucial para o code generation funcionar
part 'auth_repository.g.dart';

/// 1. Provider da Instância do FirebaseAuth
/// Útil para testes (mocking) e injeção de dependência.
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// 2. Provider do Repositório
/// Cria e fornece a instância do AuthRepository.
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  // Observa o provider da instância do Firebase para injetar no repositório
  final auth = ref.watch(firebaseAuthProvider);
  return AuthRepository(auth);
}

/// 3. Provider do Stream de Estado
/// Expõe o fluxo de estado do usuário (Logado/Deslogado) para a UI ou Router ouvir.
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}

/// Classe responsável pela interação direta com o Firebase Auth
class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  // Getter para o Stream de mudanças de estado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Método de Login
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // O Firebase lança exceções (FirebaseAuthException) que trataremos na UI/Controller
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Método de Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
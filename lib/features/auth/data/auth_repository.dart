import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';


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
  static bool _isGoogleInitialized = false;

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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Usa a instância Singleton (Nova API)
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      
      // 2. Inicialização obrigatória
      if (!_isGoogleInitialized) {
        await googleSignIn.initialize();
        _isGoogleInitialized = true;
      }
      
      // 3. Usa authenticate() em vez de signIn()
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      
      if (googleUser == null) return null; // Usuário cancelou ou fechou a janela

      // 4. Pega o idToken (agora é síncrono, SEM o 'await')
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 5. Solicita o accessToken separadamente usando o novo authorizationClient
      final authorization = await googleUser.authorizationClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      // 6. Cria a credencial para o Firebase juntando as duas partes
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: authorization?.accessToken,
      );

      // 7. Faz o login definitivo no Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Erro ao fazer login com o Google: $e');
    }
  }
}
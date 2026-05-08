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

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmailAndPassword(String name, String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await userCredential.user?.updateDisplayName(name);
  }

  String? get currentUserEmail => _auth.currentUser?.email;

  bool get isGoogleUser =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'google.com') ?? false;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception('Usuário não autenticado');
    final credential = EmailAuthProvider.credential(email: user.email!, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    if (!_isGoogleInitialized) {
      await googleSignIn.initialize();
      _isGoogleInitialized = true;
    }
    final googleUser = await googleSignIn.authenticate();
    if (googleUser == null) throw Exception('Autenticação com Google cancelada');
    final googleAuth = googleUser.authentication;
    final authorization = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: authorization?.accessToken,
    );
    await _auth.currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    await user.delete();
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
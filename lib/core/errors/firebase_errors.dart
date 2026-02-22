import 'package:firebase_auth/firebase_auth.dart';

String getFirebaseAuthErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está registado. Por favor, inicie sessão.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'E-mail ou palavra-passe incorretos.';
      case 'weak-password':
        return 'A palavra-passe é muito fraca. Utilize pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada pelo administrador.';
      default:
        return 'Ocorreu um erro de autenticação. Tente novamente.';
    }
  }
  return 'Ocorreu um erro inesperado. Verifique a sua ligação à internet.';
}
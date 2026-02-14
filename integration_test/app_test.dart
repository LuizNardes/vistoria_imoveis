import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vistoria_imoveis/firebase_options.dart';
import 'package:vistoria_imoveis/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Deve iniciar o app e exibir a tela de Login', (tester) async {
    // 1. Inicializa o Firebase (necessário pois não estamos chamando o main original)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      debugPrint('Firebase já inicializado ou erro: $e');
    }

    // 2. Carrega o Widget do App manualmente
    await tester.pumpWidget(
      const ProviderScope(
        child: VistoriaApp(),
      ),
    );

    // 3. Aguarda as animações e o carregamento inicial (Splash, etc)
    await tester.pumpAndSettle();

    // 4. Verificações
    // Procura por campos de texto (Email/Senha)
    final inputFields = find.byType(TextFormField);
    
    // Se falhar, imprime a árvore para ajudar no debug
    if (inputFields.evaluate().isEmpty) {
      debugPrint("ALERTA: Nenhum TextFormField encontrado na tela.");
      debugDumpApp();
    }

    expect(inputFields, findsAtLeastNWidgets(1), reason: 'Deveria haver pelo menos 1 campo de texto (Email/Senha)');

    // Procura pelo botão de entrar
    final loginButton = find.byWidgetPredicate(
      (widget) => widget is ElevatedButton || widget is FilledButton || widget is OutlinedButton
    );

    expect(loginButton, findsOneWidget, reason: 'Botão de Login não encontrado');
  });
}
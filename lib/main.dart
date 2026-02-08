import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // 1. Garante que a engine do Flutter esteja pronta antes de código nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase com a configuração da plataforma específica
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Executa o App envolto no ProviderScope (Mandatório para Riverpod)
  runApp(
    const ProviderScope(
      child: VistoriaApp(),
    ),
  );
}

class VistoriaApp extends ConsumerWidget {
  const VistoriaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Vistoria de Imóveis',
      debugShowCheckedModeBanner: false,
      
      // Configuração de Tema (Placeholder para lib/core/theme)
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Configuração do GoRouter
      routerConfig: router, 
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/offline_banner.dart';
import 'shared/widgets/custom_error_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Intercepta erros de construção de Widgets (Substitui Red Screen of Death)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorScreen(details: details);
  };

  // 2. Garante inicialização da Engine
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Configura Crashlytics para erros do Flutter (Tela vermelha / Widgets)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 5. Configura Crashlytics para erros Assíncronos (Futures, Streams fora da árvore de widgets)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 5. Executa o App
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
      title: 'Vistoria Imóveis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return OfflineBannerWrapper(child: child ?? const SizedBox());
      },
    );
  }
}
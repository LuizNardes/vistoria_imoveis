import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Imports das telas
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/inspections/presentation/create_inspection_screen.dart';
import '../../features/inspection_details/presentation/inspection_details_screen.dart';
import '../../features/inspection_details/presentation/room_inspection_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  // Observa o stream de Auth para reconstruir/redirecionar
  final authStream = ref.watch(authStateChangesProvider.stream);
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // Este listenable faz o router reagir a mudanças no stream (Log in / Log out)
    refreshListenable: GoRouterRefreshStream(authStream),

    routes: [
      // 1. Rota Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 2. Rota Home
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // 3. Rota Criar Vistoria
      GoRoute(
        path: '/create-inspection',
        builder: (context, state) => const CreateInspectionScreen(),
      ),

      // 4. Rota Detalhes da Vistoria (PAI)
      GoRoute(
        path: '/inspection/:inspectionId',
        builder: (context, state) {
          final inspectionId = state.pathParameters['inspectionId']!;
          return InspectionDetailsScreen(inspectionId: inspectionId);
        },
        // --- SUB-ROTAS (Aninhadas) ---
        routes: [
          GoRoute(
            // Sub-rota NÃO TEM barra "/" no início
            path: 'room/:roomId', 
            builder: (context, state) {
              final inspectionId = state.pathParameters['inspectionId']!;
              final roomId = state.pathParameters['roomId']!;
              
              // Se você estiver passando o objeto 'room' via extra na tela anterior,
              // pode descomentar abaixo:
              // final room = state.extra as InspectionRoom?;

              return RoomInspectionScreen(
                inspectionId: inspectionId,
                roomId: roomId,
              );
            },
          ),
        ],
      ),
    ],

    // Lógica de Guarda (Redirecionamento)
    redirect: (context, state) {
      if (authState.isLoading) return null;
      
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
  );
}

/// Classe utilitária para converter Stream em Listenable para o GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
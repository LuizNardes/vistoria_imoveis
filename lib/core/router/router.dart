import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vistoria_imoveis/features/auth/presentation/register_screen.dart';
import 'package:vistoria_imoveis/features/inspection_details/domain/inspection_details_models.dart';

// Imports das telas
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/inspections/presentation/create_inspection_screen.dart';
import '../../features/inspection_details/presentation/inspection_details_screen.dart';
import '../../features/inspection_details/presentation/room_inspection_screen.dart';
import '../../features/reports/presentation/report_preview_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  // Observa o stream de Auth para reconstruir/redirecionar
  final authStream = ref.watch(authStateChangesProvider.stream);
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    
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
        routes: [
          GoRoute(
            path: 'room/:roomId',
            builder: (context, state) {
              final inspectionId = state.pathParameters['inspectionId']!;
              final roomId = state.pathParameters['roomId']!;
              final roomData = state.extra as InspectionRoom?;
              return RoomInspectionScreen(
                inspectionId: inspectionId,
                roomId: roomId,
                roomName: roomData?.name,
              );
            },
          ),
        ],
      ),

      // 5. Rota Preview do Relatório
      GoRoute(
        path: '/report-preview/:inspectionId',
        builder: (context, state) {
          final inspectionId = state.pathParameters['inspectionId']!;
          return ReportPreviewScreen(inspectionId: inspectionId);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],

    redirect: (context, state) {
      if (authState.isLoading) return null;
      
      final isLoggedIn = authState.valueOrNull != null;
      
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
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
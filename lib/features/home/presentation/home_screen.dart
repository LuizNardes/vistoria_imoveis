import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../../inspections/data/inspections_repository.dart';

import '../../../shared/widgets/inspection_card.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos o Stream de vistorias
    final inspectionsAsync = ref.watch(inspectionsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Vistorias'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      
      // O when trata os 3 estados possíveis do Stream: Loading, Error, Data
      body: inspectionsAsync.when(
        loading: () => const InspectionListSkeleton(),
        error: (err, stack) => Center(
          child: Text('Erro ao carregar: $err'),
        ),
        data: (inspections) {
          // Empty State
          if (inspections.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.assignment,
              title: 'Nenhuma vistoria agendada',
              message: 'Comece clicando em "Nova Vistoria" abaixo.',
            );
          }

          // Lista de Cards
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final inspection = inspections[index];
              return InspectionCard(
                inspection: inspection,
                onTap: () => context.push('/inspection/${inspection.id}')
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-inspection'),
        icon: const Icon(Icons.add),
        label: const Text('Nova Vistoria'),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/data/auth_repository.dart';
import '../../inspections/data/inspections_repository.dart';
import '../../inspections/domain/inspection.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erro ao carregar: $err'),
        ),
        data: (inspections) {
          // Empty State
          if (inspections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma vistoria agendada',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Lista de Cards
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final inspection = inspections[index];
              return _InspectionCard(inspection: inspection);
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

// Extraímos o Card para um Widget separado para manter o código limpo
class _InspectionCard extends ConsumerWidget {
  final Inspection inspection;

  const _InspectionCard({required this.inspection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dismissible(
      key: Key(inspection.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        // Opcional: Adicionar diálogo de confirmação aqui
        return true; 
      },
      onDismissed: (direction) {
        // Chama o repositório para deletar
        ref.read(inspectionsRepositoryProvider).deleteInspection(inspection.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${inspection.clientName} removido')),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          onTap: () {
            context.push('/inspection/${inspection.id}');
          },
          title: Text(
            inspection.clientName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(inspection.address)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(dateFormat.format(inspection.date)),
                ],
              ),
            ],
          ),
          trailing: _StatusChip(status: inspection.status),
        ),
      ),
    );
  }
}

// Widget auxiliar para colorir o Status
class _StatusChip extends StatelessWidget {
  final InspectionStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case InspectionStatus.scheduled:
        color = Colors.blue;
        label = 'Agendada';
        break;
      case InspectionStatus.inProgress:
        color = Colors.orange;
        label = 'Em Progresso';
        break;
      case InspectionStatus.done:
        color = Colors.green;
        label = 'Concluída';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
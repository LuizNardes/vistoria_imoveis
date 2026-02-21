import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'inspection_details_controller.dart';
import '../domain/inspection_details_models.dart';
import '../../inspections/data/inspections_repository.dart';
import '../../inspections/domain/inspection.dart';

class InspectionDetailsScreen extends ConsumerWidget {
  final String inspectionId;

  const InspectionDetailsScreen({
    super.key,
    required this.inspectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ouve o Stream de cômodos em tempo real
    final roomsAsync = ref.watch(inspectionRoomsProvider(inspectionId));
    
    // 1. Escuta a Vistoria atual
    final inspectionAsync = ref.watch(singleInspectionProvider(inspectionId));

    // 2. Regra de Negócio: Se abriu a tela e está "Agendada", muda para "Em Andamento" automaticamente
    ref.listen(singleInspectionProvider(inspectionId), (previous, next) {
      next.whenData((inspection) {
        if (inspection.status == InspectionStatus.scheduled) {
          ref.read(inspectionDetailsControllerProvider.notifier)
             .updateInspectionStatus(inspectionId, InspectionStatus.inProgress);
        }
      });
    });

    // Ouve o estado do controller para erros de adição (SnackBar)
    ref.listen(inspectionDetailsControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar cômodo: ${state.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cômodos da Vistoria'),
        centerTitle: true,
        actions: [
          // Botão de Gerar Relatório
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Gerar Relatório',
            onPressed: () {
              // Navega para a tela de preview
              context.push('/report-preview/$inspectionId');
            },
          ),
        ],
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum cômodo cadastrado.\nToque no + para começar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _RoomCard(inspectionId: inspectionId, room: room);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoomDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      
      // 3. BARRA INFERIOR DE CONCLUSÃO
      bottomNavigationBar: inspectionAsync.whenOrNull(
        data: (inspection) {
          // Só mostra o botão se NÃO estiver concluída
          if (inspection.status != InspectionStatus.done) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    minimumSize: const Size.fromHeight(50), // Botão largo
                  ),
                  onPressed: () => _confirmFinish(context, ref),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Finalizar Vistoria', style: TextStyle(fontSize: 16)),
                ),
              ),
            );
          }
          // Se já estiver concluída, exibe um aviso visual
          return Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(16.0),
            child: const SafeArea(
              child: Text(
                'Esta vistoria já foi concluída.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Cômodo'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Ex: Cozinha, Banheiro Suite...',
            labelText: 'Nome do Cômodo',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // Chama o controller para adicionar
                ref.read(inspectionDetailsControllerProvider.notifier)
                   .addRoom(inspectionId, nameController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmação para finalizar
  void _confirmFinish(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Vistoria?'),
        content: const Text('Após finalizar, você poderá gerar o PDF final. Deseja marcar como concluída?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Voltar')),
          FilledButton(
            onPressed: () {
              ref.read(inspectionDetailsControllerProvider.notifier)
                 .updateInspectionStatus(inspectionId, InspectionStatus.done);
              Navigator.pop(ctx);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends ConsumerWidget {
  final String inspectionId;
  final InspectionRoom room;

  const _RoomCard({required this.inspectionId, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(room.id),
      direction: DismissDirection.endToStart, // Deslizar da direita para a esquerda
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        // Exibe um diálogo de confirmação antes de apagar
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir Cômodo?'),
            content: Text('Tem certeza que deseja remover "${room.name}" e todos os seus itens? Esta ação não pode ser desfeita.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Chama o controller para apagar no backend
        ref.read(inspectionDetailsControllerProvider.notifier)
           .deleteRoom(inspectionId, room.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${room.name} removido.')),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.meeting_room,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            room.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${room.completedItems} de ${room.totalItems} itens verificados',
            style: TextStyle(
              // Muda a cor para verde se estiver tudo completo
              color: (room.totalItems > 0 && room.completedItems == room.totalItems) 
                  ? Colors.green[700] 
                  : Colors.grey[600],
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(
              '/inspection/$inspectionId/room/${room.id}',
              extra: room,
            );
          },
        ),
      ),
    );
  }
}
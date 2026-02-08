import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'inspection_details_controller.dart';
import '../domain/inspection_details_model.dart';

class InspectionDetailsScreen extends ConsumerWidget {
  final String inspectionId;

  const InspectionDetailsScreen({
    super.key,
    required this.inspectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(inspectionRoomsProvider(inspectionId));

    ref.listen(inspectionDetailsControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${next.error}'), backgroundColor: Colors.red),
        );
      } else if (!next.isLoading && !next.hasError && previous?.isLoading == true) {
        // Se parou de carregar e não tem erro, fechamos o dialog
        Navigator.of(context).pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cômodo adicionado!')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cômodos da Vistoria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Gerar Relatório',
            onPressed: () {
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
                'Nenhum cômodo adicionado.\nToque em "+" para começar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _RoomCard(
                room: room, 
                onTap: () {
                  // Navegação para os itens do cômodo (Criaremos na Fase 4)
                  context.push('/inspection/$inspectionId/room/${room.id}');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoomDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Cômodo'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Ex: Cozinha, Banheiro Social',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            // Usamos Consumer aqui para o botão reagir ao loading do controller
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(inspectionDetailsControllerProvider);
                return FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          if (nameController.text.trim().isNotEmpty) {
                            ref
                                .read(inspectionDetailsControllerProvider.notifier)
                                .addRoom(inspectionId, nameController.text.trim());
                          }
                        },
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text('Adicionar'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _RoomCard extends StatelessWidget {
  final InspectionRoom room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(room.name[0].toUpperCase()),
        ),
        title: Text(
          room.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${room.completedItems} de ${room.totalItems} itens verificados',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
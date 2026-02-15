import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'inspection_details_controller.dart';
import '../domain/inspection_details_models.dart';

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
}

class _RoomCard extends StatelessWidget {
  final String inspectionId;
  final InspectionRoom room;

  const _RoomCard({required this.inspectionId, required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
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
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navegação para os itens do cômodo (Rota aninhada ou direta)
          context.push(
            '/inspection/$inspectionId/room/${room.id}',
            extra: room, // Passamos o objeto inteiro para pegar o nome na próxima tela
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports corretos
import 'room_inspection_controller.dart';
import 'widgets/inspection_item_card.dart';

class RoomInspectionScreen extends ConsumerStatefulWidget {
  final String inspectionId;
  final String roomId;
  final String? roomName; // Adicionado para receber o nome (ex: "Cozinha")

  const RoomInspectionScreen({
    super.key,
    required this.inspectionId,
    required this.roomId,
    this.roomName,
  });

  @override
  ConsumerState<RoomInspectionScreen> createState() => _RoomInspectionScreenState();
}

class _RoomInspectionScreenState extends ConsumerState<RoomInspectionScreen> {
  @override
  void initState() {
    super.initState();
    
    // Dispara a criação dos itens padrão baseada no nome do cômodo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomInspectionControllerProvider.notifier).seedItems(
            widget.inspectionId,
            widget.roomId,
            widget.roomName ?? 'Cômodo', // Usa o nome real aqui!
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(roomInspectionControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final itemsStream = ref.watch(roomItemsProvider(widget.inspectionId, widget.roomId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName ?? 'Itens do Cômodo'),
      ),
      body: itemsStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.playlist_add_check, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('O checklist está vazio.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(roomInspectionControllerProvider.notifier).seedItems(
                        widget.inspectionId, widget.roomId, widget.roomName ?? 'Cômodo',
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Gerar Itens Padrão'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remover Item?'),
                      content: Text('Tem certeza que deseja remover "${item.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Remover'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  ref.read(roomInspectionControllerProvider.notifier)
                     .removeItem(widget.inspectionId, widget.roomId, item.id);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InspectionItemCard(
                    inspectionId: widget.inspectionId,
                    roomId: widget.roomId,
                    item: item,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Novo Item'),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Item de Vistoria'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Ex: Ar Condicionado',
            labelText: 'Nome do Item',
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
                ref.read(roomInspectionControllerProvider.notifier)
                   .addItem(widget.inspectionId, widget.roomId, nameController.text.trim());
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
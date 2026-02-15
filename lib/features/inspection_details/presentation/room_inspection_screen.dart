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
            content: Text('Erro ao criar itens: ${state.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Detalhes', onPressed: () {
              print(state.error); // Veja no terminal
              print(state.stackTrace);
            }),
          ),
        );
      }
    });

    // Ouve a lista de itens do banco
    final itemsStream = ref.watch(roomItemsProvider(widget.inspectionId, widget.roomId));

    return Scaffold(
      appBar: AppBar(
        // Mostra o nome do cômodo no topo (ex: "Cozinha")
        title: Text(widget.roomName ?? 'Itens do Cômodo'),
      ),
      body: itemsStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (items) {
          // SE A LISTA ESTIVER VAZIA:
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.playlist_add_check, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'O checklist está vazio.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    // BOTÃO DE RESGATE
                    FilledButton.icon(
                      onPressed: () {
                        ref.read(roomInspectionControllerProvider.notifier).seedItems(
                              widget.inspectionId,
                              widget.roomId,
                              widget.roomName ?? 'Cômodo',
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Gerar Itens Padrão'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InspectionItemCard(
                inspectionId: widget.inspectionId,
                roomId: widget.roomId,
                item: item,
              );
            },
          );
        },
      ),
    );
  }
}
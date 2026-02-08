import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'room_inspection_controller.dart';
import 'widgets/inspection_item_card.dart';

class RoomInspectionScreen extends ConsumerStatefulWidget {
  final String inspectionId;
  final String roomId;

  const RoomInspectionScreen({
    super.key,
    required this.inspectionId,
    required this.roomId,
  });

  @override
  ConsumerState<RoomInspectionScreen> createState() => _RoomInspectionScreenState();
}

class _RoomInspectionScreenState extends ConsumerState<RoomInspectionScreen> {
  @override
  void initState() {
    super.initState();
    // Dispara o seed "fire and forget". 
    // Usamos addPostFrameCallback para evitar erros de build se o provider tentar atualizar algo síncrono.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Idealmente passaríamos o Nome do Cômodo vindo da rota ou buscado no provider,
      // aqui vou assumir um valor genérico ou que você ajuste a rota para passar 'roomName'
      // Para simplificar, vou buscar o nome dentro do controller se necessário, 
      // mas aqui vou mandar "Cômodo" genérico ou passar via argumento extra se você tiver.
      // Assumindo que você ajustará o router para passar 'roomName' ou buscará no repo.
      
      // *Correção Rápida:* Vamos apenas chamar o seed. O controller decide o nome ou busca.
      // Para este exemplo, passei "Cômodo Genérico" mas recomendo passar o nome real via argumento da rota.
      ref.read(roomInspectionControllerProvider.notifier).seedItems(
            widget.inspectionId,
            widget.roomId,
            "Cômodo", // TODO: Receber via construtor para seedar corretamente (ex: Cozinha)
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(roomItemsProvider(widget.inspectionId, widget.roomId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist'),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (items) {
          if (items.isEmpty) {
            // Estado de loading do Seed ou realmente vazio
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Espaço para FAB se tiver
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
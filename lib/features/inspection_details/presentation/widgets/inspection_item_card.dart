import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/inspection_details_model.dart';
import '../room_inspection_controller.dart';

class InspectionItemCard extends ConsumerStatefulWidget {
  final String inspectionId;
  final String roomId;
  final InspectionItem item;

  const InspectionItemCard({
    super.key,
    required this.inspectionId,
    required this.roomId,
    required this.item,
  });

  @override
  ConsumerState<InspectionItemCard> createState() => _InspectionItemCardState();
}

class _InspectionItemCardState extends ConsumerState<InspectionItemCard> {
  late TextEditingController _notesController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.notes);
  }

  @override
  void didUpdateWidget(covariant InspectionItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza o texto se vier mudança externa (mas cuidado para não sobrescrever enquanto digita)
    if (oldWidget.item.notes != widget.item.notes && 
        !_notesController.selection.isValid) { // Só atualiza se não estiver focado/digitando
      _notesController.text = widget.item.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Lógica do Debouncer: Salva apenas quando o usuário para de digitar
  void _onNotesChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      ref.read(roomInspectionControllerProvider.notifier).updateItemNotes(
            widget.inspectionId,
            widget.roomId,
            widget.item,
            value,
          );
    });
  }

  Color _getStatusColor(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.ok: return Colors.green;
      case ItemCondition.damaged: return Colors.red;
      case ItemCondition.repairNeeded: return Colors.orange;
      case ItemCondition.notApplicable: return Colors.grey;
    }
  }

  IconData _getStatusIcon(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.ok: return Icons.check_circle;
      case ItemCondition.damaged: return Icons.cancel;
      case ItemCondition.repairNeeded: return Icons.warning_amber_rounded;
      case ItemCondition.notApplicable: return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(widget.item.condition);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(_getStatusIcon(widget.item.condition), color: color, size: 32),
        title: Text(
          widget.item.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          widget.item.condition == ItemCondition.ok ? 'Tudo certo' : 'Requer atenção',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          // 1. Seletor de Status (Segmented Button)
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ItemCondition>(
              segments: const [
                ButtonSegment(value: ItemCondition.ok, icon: Icon(Icons.check), label: Text('OK')),
                ButtonSegment(value: ItemCondition.damaged, icon: Icon(Icons.close), label: Text('Ruim')),
                ButtonSegment(value: ItemCondition.notApplicable, label: Text('N/A')),
              ],
              selected: {widget.item.condition},
              onSelectionChanged: (Set<ItemCondition> newSelection) {
                ref.read(roomInspectionControllerProvider.notifier).updateItemStatus(
                      widget.inspectionId,
                      widget.roomId,
                      widget.item,
                      newSelection.first,
                    );
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 2. Campo de Observações
          TextFormField(
            controller: _notesController,
            onChanged: _onNotesChanged,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observações',
              hintText: 'Descreva avarias ou detalhes...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_note),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Placeholder de Fotos
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.grey),
                  Text('Fotos (Próxima Fase)', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
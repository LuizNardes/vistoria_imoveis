import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart'; // Adicionado
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Adicionado
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
  bool _isUploading = false; // Estado local de loading para UX fluida

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.notes);
  }

  @override
  void didUpdateWidget(covariant InspectionItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.notes != widget.item.notes && !_notesController.selection.isValid) {
      _notesController.text = widget.item.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // --- LÓGICA DE FOTOS ---

  Future<void> _handleAddPhoto(ImageSource source) async {
    Navigator.pop(context); // Fecha o BottomSheet
    setState(() => _isUploading = true); // Inicia spinner local

    try {
      await ref.read(roomInspectionControllerProvider.notifier).addPhoto(
            inspectionId: widget.inspectionId,
            roomId: widget.roomId,
            item: widget.item,
            source: source,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar foto: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false); // Para spinner
    }
  }

  void _handleRemovePhoto(String url) {
    ref.read(roomInspectionControllerProvider.notifier).removePhoto(
          inspectionId: widget.inspectionId,
          roomId: widget.roomId,
          item: widget.item,
          photoUrl: url,
        );
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => _handleAddPhoto(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => _handleAddPhoto(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
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
    final color = _getStatusColor(widget.item.condition); // Helper existente

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        // ... (Leading, Title, Subtitle, ChildrenPadding mantidos) ...
        leading: Icon(_getStatusIcon(widget.item.condition), color: color, size: 32),
        title: Text(widget.item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(widget.item.condition.name), // Simplificado para exemplo
        childrenPadding: const EdgeInsets.all(16),
        
        children: [
          // 1. Segmented Button (Mantido)
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ItemCondition>(
              segments: const [
                ButtonSegment(value: ItemCondition.ok, label: Text('OK')),
                ButtonSegment(value: ItemCondition.damaged, label: Text('Ruim')),
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
            ),
          ),
          
          const SizedBox(height: 16),

          // 2. Campo de Observações (Mantido)
          TextFormField(
            controller: _notesController,
            onChanged: _onNotesChanged, // Helper existente
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observações',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_note),
            ),
          ),

          const SizedBox(height: 16),

          // 3. NOVA SEÇÃO DE FOTOS
          SizedBox(
            height: 90, // Altura fixa para o carrossel
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // A. Lista de fotos existentes
                ...widget.item.photos.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        // A imagem
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        // O botão de deletar (X)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _handleRemovePhoto(url),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // B. Loading Indicator (se estiver subindo foto neste item)
                if (_isUploading)
                  Container(
                    width: 90,
                    height: 90,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),

                // C. Botão de Adicionar
                InkWell(
                  onTap: _isUploading ? null : _showSourcePicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
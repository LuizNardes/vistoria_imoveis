import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Imports dos Models e Controller
import '../../domain/inspection_details_models.dart';
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
  // Estado local para feedback visual imediato sem rebuildar a lista inteira
  bool _isUploading = false;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.notes);
  }

  // Garante que o controller de texto atualize se o item mudar externamente
  @override
  void didUpdateWidget(covariant InspectionItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.notes != oldWidget.item.notes && 
        widget.item.notes != _notesController.text) {
        _notesController.text = widget.item.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // --- AÇÕES ---

  Future<void> _handleAddPhoto(ImageSource source) async {
    Navigator.pop(context); // Fecha o BottomSheet
    setState(() => _isUploading = true); // Inicia Spinner

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
      if (mounted) setState(() => _isUploading = false); // Para Spinner
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

  // --- UI HELPERS ---
  
  Color _getStatusColor(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.ok: return Colors.green;
      case ItemCondition.damaged: return Colors.red;
      case ItemCondition.repairNeeded: return Colors.orange;
      case ItemCondition.notApplicable: return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(widget.item.condition);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.circle, color: color, size: 24),
        title: Text(widget.item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          // 1. Selector de Status (SegmentedButton ou Dropdown - simplificado aqui)
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ItemCondition>(
              segments: const [
                ButtonSegment(value: ItemCondition.ok, label: Text('OK')),
                ButtonSegment(value: ItemCondition.damaged, label: Text('Avariado')),
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

          // 2. Campo de Observações
          TextFormField(
            controller: _notesController,
            onChanged: (val) {
                // Implementar debounce aqui se desejar
                ref.read(roomInspectionControllerProvider.notifier).updateItemNotes(
                  widget.inspectionId, widget.roomId, widget.item, val
                );
            },
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observações',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),

          const SizedBox(height: 16),

          // 3. ÁREA DE FOTOS (Horizontal List)
          SizedBox(
            height: 90, 
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // A. Fotos Existentes
                ...widget.item.photos.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        // Imagem
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 80, height: 80, color: Colors.grey[200],
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        // Botão Remover (X)
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

                // B. Loading Indicator (Placeholder enquanto sobe)
                if (_isUploading)
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),

                // C. Botão Adicionar Foto
                InkWell(
                  onTap: _isUploading ? null : _showSourcePicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
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
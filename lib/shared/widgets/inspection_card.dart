import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../features/inspections/domain/inspection.dart';

class InspectionCard extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const InspectionCard({
    super.key,
    required this.inspection,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    return Card(
      elevation: 2, // Sombra suave
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias, // Garante que o ripple effect respeite a borda
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: Nome e Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      inspection.clientName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(context, inspection.status),
                ],
              ),
              const SizedBox(height: 8),
              
              // Endereço com Ícone
              Row(
                children: [
                  Icon(Icons.location_on_outlined, 
                       size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      inspection.address,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Data e Divisor
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, 
                       size: 16, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(inspection.date),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0); // Animação Suave
  }

  Widget _buildStatusBadge(BuildContext context, InspectionStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case InspectionStatus.scheduled:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        label = 'Agendada';
        break;
      case InspectionStatus.inProgress:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        label = 'Em Andamento';
        break;
      case InspectionStatus.done:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        label = 'Concluída';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // Pill shape
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
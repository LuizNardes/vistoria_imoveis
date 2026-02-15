import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

// Imports
import '../data/report_repository.dart';
import '../domain/pdf_generator_service.dart';

class ReportPreviewScreen extends ConsumerWidget {
  final String inspectionId;

  const ReportPreviewScreen({super.key, required this.inspectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Busca os dados agregados
    final fullDataAsync = ref.watch(fullInspectionProvider(inspectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pré-visualizar Relatório'),
      ),
      body: fullDataAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Coletando dados e baixando fotos...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Text('Erro ao gerar relatório: $err'),
        ),
        data: (data) {
          // 2. Exibe o Preview do PDF
          return PdfPreview(
            // Nome do arquivo ao salvar/compartilhar
            pdfFileName: 'vistoria_${DateFormat('yyyyMMdd').format(data.inspection.date)}.pdf',
            canChangeOrientation: false,
            canDebug: false,
            
            // Função que gera os bytes do PDF
            build: (format) {
              return ref.read(pdfGeneratorServiceProvider).generateInspectionReport(
                inspection: data.inspection,
                rooms: data.rooms,
                itemsByRoom: data.itemsByRoom,
              );
            },
          );
        },
      ),
    );
  }
}
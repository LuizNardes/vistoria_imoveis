import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

// Imports
import '../data/report_repository.dart';
import '../domain/pdf_generator_service.dart';

class ReportPreviewScreen extends ConsumerWidget {
  final String inspectionId;

  const ReportPreviewScreen({
    super.key,
    required this.inspectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o provider que carrega todos os dados
    final fullDataAsync = ref.watch(fullInspectionProvider(inspectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Relatório'),
      ),
      body: fullDataAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Compilando dados e baixando fotos..."),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Text('Erro ao gerar relatório: $error'),
        ),
        data: (data) {
          // Formata o nome do arquivo: vistoria_2023-10-25_ClienteNome.pdf
          final dateStr = DateFormat('yyyy-MM-dd').format(data.inspection.date);
          final safeClientName = data.inspection.clientName.replaceAll(RegExp(r'[^\w\s]+'), '');
          final fileName = 'vistoria_${dateStr}_$safeClientName.pdf';

          return PdfPreview(
            // Configurações da UI de Preview
            maxPageWidth: 700,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            
            // Nome do arquivo sugerido ao compartilhar/salvar
            pdfFileName: fileName,

            // Função que gera os bytes (chama nosso Service)
            build: (format) {
              return ref.read(pdfGeneratorServiceProvider).generateInspectionReport(
                    data.inspection,
                    data.rooms,
                    data.itemsByRoom,
                  );
            },
          );
        },
      ),
    );
  }
}
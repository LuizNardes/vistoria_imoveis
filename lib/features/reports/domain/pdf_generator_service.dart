import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Imports dos seus Models (Ajuste conforme seu projeto)
import '../../inspection_details/domain/inspection_details_models.dart';
// Vamos assumir que existe um model Inspection também
import '../../inspections/domain/inspection.dart'; 

part 'pdf_generator_service.g.dart';

@riverpod
PdfGeneratorService pdfGeneratorService(PdfGeneratorServiceRef ref) {
  return PdfGeneratorService();
}

class PdfGeneratorService {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Gera o relatório completo em PDF
  Future<Uint8List> generateInspectionReport({
    required Inspection inspection,
    required List<InspectionRoom> rooms,
    required Map<String, List<InspectionItem>> itemsByRoom,
  }) async {
    final pdf = pw.Document();

    // 1. Carregar Fontes (Opcional: usar fontes padrão Helvetica)
    // Para ícones de check/x, usamos a fonte padrão do sistema se necessário, 
    // mas aqui usaremos texto simples para garantir compatibilidade.
    final theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.openSansRegular(),
      bold: await PdfGoogleFonts.openSansBold(),
    );

    // 2. Capa (Página Única)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (context) {
          return _buildCoverPage(inspection, rooms, itemsByRoom);
        },
      ),
    );

    // 3. Conteúdo por Cômodo (MultiPage para permitir quebra de página)
    // PREPARAÇÃO DE DADOS:
    // O PDF não suporta async/await dentro do build. 
    // Precisamos baixar as imagens ANTES de desenhar a página do cômodo.
    
    for (final room in rooms) {
      final items = itemsByRoom[room.id] ?? [];
      
      if (items.isEmpty) continue;

      // 3.1 Download das Imagens deste cômodo em paralelo
      final roomImages = await _downloadRoomImages(items);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          header: (context) => _buildHeader(inspection),
          footer: (context) => _buildFooter(context),
          build: (context) {
            return [
              // Título do Cômodo
              pw.Header(
                level: 1,
                child: pw.Text(room.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              
              pw.SizedBox(height: 10),

              // Tabela de Itens
              _buildItemsTable(items),

              pw.SizedBox(height: 20),

              // Seção de Fotos (se houver)
              if (roomImages.isNotEmpty) ...[
                pw.Header(
                  level: 2,
                  child: pw.Text("Evidências Fotográficas - ${room.name}", 
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                ),
                pw.SizedBox(height: 10),
                _buildPhotoGrid(roomImages),
                pw.SizedBox(height: 20),
              ]
            ];
          },
        ),
      );
    }

    // 4. Página de Assinaturas (Final)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (context) => _buildSignaturesPage(),
      ),
    );

    return pdf.save();
  }

  // --- WIDGETS DE PÁGINA ---

  pw.Widget _buildCoverPage(
    Inspection inspection, 
    List<InspectionRoom> rooms, 
    Map<String, List<InspectionItem>> itemsByRoom
  ) {
    // Cálculo simples de resumo
    int totalItems = 0;
    int totalIssues = 0;
    
    for(var items in itemsByRoom.values) {
      totalItems += items.length;
      totalIssues += items.where((i) => i.condition != ItemCondition.ok && i.condition != ItemCondition.notApplicable).length;
    }

    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text("TERMO DE VISTORIA DE IMÓVEL", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 40),
          pw.Divider(),
          pw.SizedBox(height: 20),
          _buildInfoRow("Cliente", inspection.clientName), // Ajuste conforme seu model
          _buildInfoRow("Endereço", inspection.address),
          _buildInfoRow("Data da Vistoria", _dateFormat.format(inspection.date)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 40),
          pw.Text("Resumo da Inspeção", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text("Total de Cômodos: ${rooms.length}"),
          pw.Text("Total de Itens Verificados: $totalItems"),
          pw.Text("Itens com Avarias/Reparos: $totalIssues", style: pw.TextStyle(color: PdfColors.red)),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(List<InspectionItem> items) {
    return pw.Table.fromTextArray(
      headers: ['Item', 'Condição', 'Observações'],
      columnWidths: {
        0: const pw.FlexColumnWidth(2), // Item
        1: const pw.FlexColumnWidth(1), // Condição
        2: const pw.FlexColumnWidth(3), // Obs
      },
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
      },
      data: items.map((item) {
        return [
          item.name,
          _formatCondition(item.condition),
          item.notes ?? '-',
        ];
      }).toList(),
    );
  }

  pw.Widget _buildPhotoGrid(List<pw.MemoryImage> images) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: images.map((image) {
        return pw.Container(
          width: 150, // Ajuste para caber 3 por linha em A4 (A4 width ~595 pts - margens)
          height: 150,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            children: [
              pw.Expanded(
                child: pw.Image(image, fit: pw.BoxFit.cover),
              ),
            ]
          )
        );
      }).toList(),
    );
  }

  pw.Widget _buildSignaturesPage() {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              children: [
                pw.Container(width: 200, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),
                pw.Text("Vistoriador Responsável"),
              ],
            ),
            pw.Column(
              children: [
                pw.Container(width: 200, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),
                pw.Text("Cliente / Locatário"),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 50),
      ],
    );
  }

  pw.Widget _buildHeader(Inspection inspection) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Text(
        "Vistoria: ${inspection.address} - ${_dateFormat.format(inspection.date)}",
        style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10),
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        "Página ${context.pageNumber} de ${context.pagesCount}",
        style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10),
      ),
    );
  }

  // --- HELPERS ---

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          pw.Text(value),
        ],
      ),
    );
  }

  String _formatCondition(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.ok: return "OK";
      case ItemCondition.damaged: return "Avariado";
      case ItemCondition.repairNeeded: return "Reparo";
      case ItemCondition.dirty: return "Sujo";
      case ItemCondition.notApplicable: return "N/A";
    }
  }

  // --- LÓGICA DE DOWNLOAD ---

  /// Baixa todas as fotos de uma lista de itens em paralelo
  Future<List<pw.MemoryImage>> _downloadRoomImages(List<InspectionItem> items) async {
    // 1. Extrair todas as URLs de todos os itens do cômodo
    final List<String> allUrls = [];
    for (var item in items) {
      allUrls.addAll(item.photos);
    }

    if (allUrls.isEmpty) return [];

    // 2. Baixar em paralelo (Future.wait)
    final futures = allUrls.map((url) => _downloadImage(url));
    final results = await Future.wait(futures);

    // 3. Filtrar falhas (nulls)
    return results.whereType<pw.MemoryImage>().toList();
  }

  Future<pw.MemoryImage?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
      return null;
    } catch (e) {
      // Falha silenciosa ou log
      // print("Erro ao baixar imagem PDF: $e");
      return null;
    }
  }
}
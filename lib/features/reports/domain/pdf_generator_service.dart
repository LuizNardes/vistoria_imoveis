import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Imports do Domínio
import '../../inspections/domain/inspection.dart';
import '../../inspection_details/domain/inspection_details_models.dart';

part 'pdf_generator_service.g.dart';

@riverpod
PdfGeneratorService pdfGeneratorService(PdfGeneratorServiceRef ref) {
  return PdfGeneratorService();
}

class PdfGeneratorService {
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Gera o PDF binário pronto para compartilhar ou imprimir
  Future<Uint8List> generateInspectionReport(
    Inspection inspection,
    List<InspectionRoom> rooms,
    Map<String, List<InspectionItem>> itemsByRoom,
  ) async {
    final pdf = pw.Document();

    // 1. Pré-carregar imagens (Otimização de Performance)
    // Precisamos baixar todas as fotos antes de iniciar o desenho do PDF,
    // pois o widget system do PDF é síncrono.
    final imageCache = await _downloadAllImages(itemsByRoom);

    // 2. Configurar Estilos Básicos
    final baseStyle = pw.TextStyle(font: pw.Font.helvetica(), fontSize: 10);
    final titleStyle = pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 18);
    final headerStyle = pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 12);

    // 3. Construir o Documento
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        
        // --- RODAPÉ (Paginação) ---
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: baseStyle.copyWith(color: PdfColors.grey),
            ),
          );
        },

        build: (context) {
          return [
            // --- CAPA ---
            _buildCover(inspection, titleStyle, headerStyle, baseStyle),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // --- LOOP DE CÔMODOS ---
            ...rooms.map((room) {
              final items = itemsByRoom[room.id] ?? [];
              
              // Se o cômodo não tiver itens, pulamos ou mostramos aviso
              if (items.isEmpty) return pw.Container();

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do Cômodo
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(5),
                    color: PdfColors.grey200,
                    child: pw.Text(room.name, style: headerStyle),
                  ),
                  pw.SizedBox(height: 10),

                  // Tabela de Itens
                  _buildItemsTable(items, baseStyle),
                  
                  pw.SizedBox(height: 10),

                  // Galeria de Fotos do Cômodo
                  _buildPhotoGallery(items, imageCache),

                  pw.SizedBox(height: 20), // Espaço entre cômodos
                ],
              );
            }).toList(),

            pw.SizedBox(height: 40),

            // --- ASSINATURAS ---
            _buildSignatures(baseStyle),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // --- WIDGETS AUXILIARES DO PDF ---

  pw.Widget _buildCover(
    Inspection inspection,
    pw.TextStyle titleStyle,
    pw.TextStyle headerStyle,
    pw.TextStyle baseStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text('Termo de Vistoria de Imóvel', style: titleStyle),
        ),
        pw.SizedBox(height: 30),
        
        // Dados do Imóvel
        pw.Text('Dados da Vistoria:', style: headerStyle),
        pw.SizedBox(height: 5),
        pw.Bullet(text: 'Cliente: ${inspection.clientName}'),
        pw.Bullet(text: 'Endereço: ${inspection.address}'),
        pw.Bullet(text: 'Data: ${_dateFormat.format(inspection.date)}'),
        pw.Bullet(text: 'Status: ${_translateStatus(inspection.status)}'),
      ],
    );
  }

  pw.Widget _buildItemsTable(List<InspectionItem> items, pw.TextStyle baseStyle) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headerStyle: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
      cellStyle: baseStyle,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      columnWidths: {
        0: const pw.FlexColumnWidth(2), // Item
        1: const pw.FlexColumnWidth(1), // Condição
        2: const pw.FlexColumnWidth(2), // Obs
      },
      headers: ['Item', 'Condição', 'Observações'],
      data: items.map((item) {
        return [
          item.name,
          _translateCondition(item.condition),
          item.notes ?? '-',
        ];
      }).toList(),
    );
  }

  pw.Widget _buildPhotoGallery(
    List<InspectionItem> items,
    Map<String, Uint8List> imageCache,
  ) {
    // Filtrar itens que têm fotos e cujas fotos foram baixadas com sucesso
    final photosWidgets = <pw.Widget>[];

    for (var item in items) {
      for (var url in item.photos) {
        final imageBytes = imageCache[url];
        if (imageBytes != null) {
          photosWidgets.add(
            pw.Column(
              children: [
                pw.Container(
                  height: 100,
                  width: 100,
                  child: pw.Image(
                    pw.MemoryImage(imageBytes),
                    fit: pw.BoxFit.cover,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  item.name, // Legenda com nome do item
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
              ],
            ),
          );
        }
      }
    }

    if (photosWidgets.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Evidências Fotográficas:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.SizedBox(height: 5),
        pw.GridView(
          crossAxisCount: 3,
          childAspectRatio: 1,
          children: photosWidgets,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ],
    );
  }

  pw.Widget _buildSignatures(pw.TextStyle baseStyle) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 5),
            pw.Text('Assinatura do Vistoriador', style: baseStyle),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 5),
            pw.Text('Assinatura do Cliente', style: baseStyle),
          ],
        ),
      ],
    );
  }

  // --- LÓGICA DE DOWNLOAD (HELPER) ---

  /// Baixa todas as imagens em paralelo e retorna um Map<URL, Bytes>
  Future<Map<String, Uint8List>> _downloadAllImages(
      Map<String, List<InspectionItem>> itemsByRoom) async {
    final Map<String, Uint8List> cache = {};
    final List<String> allUrls = [];

    // 1. Coletar todas as URLs únicas
    itemsByRoom.forEach((_, items) {
      for (var item in items) {
        allUrls.addAll(item.photos);
      }
    });

    // 2. Download em Paralelo (Future.wait)
    // Usamos um Set para evitar baixar a mesma foto duplicada (se houver)
    final uniqueUrls = allUrls.toSet().toList();
    
    final futures = uniqueUrls.map((url) async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return MapEntry(url, response.bodyBytes);
        }
      } catch (e) {
        // Falha silenciosa: a imagem apenas não aparecerá no relatório
        print('Erro ao baixar imagem $url: $e');
      }
      return null;
    });

    final results = await Future.wait(futures);

    // 3. Preencher o Cache
    for (var entry in results) {
      if (entry != null) {
        cache[entry.key] = entry.value;
      }
    }

    return cache;
  }

  // --- TRADUTORES ---
  
  String _translateStatus(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.scheduled: return 'Agendada';
      case InspectionStatus.inProgress: return 'Em Andamento';
      case InspectionStatus.done: return 'Finalizada';
    }
  }

  String _translateCondition(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.ok: return 'OK';
      case ItemCondition.damaged: return 'Avariado';
      case ItemCondition.repairNeeded: return 'Reparo Nec.';
      case ItemCondition.notApplicable: return 'N/A';
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Imports dos Models
import '../../inspection_details/domain/inspection_details_models.dart';
import '../../inspections/domain/inspection.dart'; 

part 'report_repository.g.dart';

// --- DATA CLASS (DTO) ---
class FullInspectionData {
  final Inspection inspection;
  final List<InspectionRoom> rooms;
  final Map<String, List<InspectionItem>> itemsByRoom;

  FullInspectionData({
    required this.inspection,
    required this.rooms,
    required this.itemsByRoom,
  });
}

// --- PROVIDER ---
@riverpod
ReportRepository reportRepository(ReportRepositoryRef ref) {
  return ReportRepository(FirebaseFirestore.instance);
}

// --- REPOSITORY ---
class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository(this._firestore);

  Future<FullInspectionData> fetchFullInspection(String inspectionId) async {
    // 1. Buscar dados da Vistoria (Cabeçalho)
    final inspectionDoc = await _firestore.collection('inspections').doc(inspectionId).get();
    
    if (!inspectionDoc.exists) {
      throw Exception("Vistoria não encontrada no banco de dados.");
    }
    
    // Usa a fábrica blindada que criamos acima
    final inspection = Inspection.fromFirestore(inspectionDoc); 

    // 2. Buscar TODOS os Cômodos
    final roomsSnapshot = await _firestore
        .collection('inspections')
        .doc(inspectionId)
        .collection('rooms')
        .orderBy('name')
        .get();

    final rooms = roomsSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      // Garante que o nome do cômodo nunca seja nulo
      if (data['name'] == null) data['name'] = 'Cômodo sem nome';
      return InspectionRoom.fromJson(data);
    }).toList();

    // 3. Buscar Itens
    final itemsFutures = rooms.map((room) async {
      final itemsSnapshot = await _firestore
          .collection('inspections')
          .doc(inspectionId)
          .collection('rooms')
          .doc(room.id)
          .collection('items')
          .orderBy('name')
          .get();

      final items = itemsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // --- PROTEÇÃO EXTRA PARA OS ITENS ---
        // Se algum campo obrigatório do item estiver null no banco, consertamos aqui
        if (data['name'] == null) data['name'] = 'Item sem nome';
        
        // Se notes for null, o fromJson do InspectionItem já deve aceitar (String?),
        // mas se a condition vier errada, pode quebrar.
        // O enum @JsonEnum geralmente cuida disso, mas se der erro no item, avise.
        
        return InspectionItem.fromJson(data);
      }).toList();

      return MapEntry(room.id, items);
    });

    final itemsEntries = await Future.wait(itemsFutures);
    final itemsByRoom = Map.fromEntries(itemsEntries);

    return FullInspectionData(
      inspection: inspection,
      rooms: rooms,
      itemsByRoom: itemsByRoom,
    );
  }
}

// --- CONTROLLER/PROVIDER DE DADOS ---
@riverpod
Future<FullInspectionData> fullInspection(FullInspectionRef ref, String inspectionId) {
  return ref.watch(reportRepositoryProvider).fetchFullInspection(inspectionId);
}
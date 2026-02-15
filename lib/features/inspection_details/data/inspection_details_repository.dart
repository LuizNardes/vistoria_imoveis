import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/inspection_details_models.dart';

part 'inspection_details_repository.g.dart';

@riverpod
InspectionDetailsRepository inspectionDetailsRepository(
    InspectionDetailsRepositoryRef ref) {
  return InspectionDetailsRepository(FirebaseFirestore.instance);
}

class InspectionDetailsRepository {
  final FirebaseFirestore _firestore;

  InspectionDetailsRepository(this._firestore);

  // --- HELPERS (Tipagem Forte) ---

  /// Referência para a coleção de Cômodos
  CollectionReference<InspectionRoom> _roomsRef(String inspectionId) {
    return _firestore
        .collection('inspections')
        .doc(inspectionId)
        .collection('rooms')
        .withConverter<InspectionRoom>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data() ?? {};
        data['id'] = snapshot.id;
        return InspectionRoom.fromJson(data);
      },
      // CORREÇÃO: Usamos 'value' dinâmico e fazemos cast para evitar o erro de subtype
      toFirestore: (value, _) {
        final room = value as InspectionRoom; 
        final map = room.toJson();
        map.remove('id');
        return map.cast<String, Object?>();
      },
    );
  }

  /// Referência para a coleção de Itens
  CollectionReference<InspectionItem> _itemsRef(
      String inspectionId, String roomId) {
    return _firestore
        .collection('inspections/$inspectionId/rooms/$roomId/items')
        .withConverter<InspectionItem>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data() ?? {};
        data['id'] = snapshot.id;
        return InspectionItem.fromJson(data);
      },
      // CORREÇÃO: Cast explícito aqui também
      toFirestore: (value, _) {
        final item = value as InspectionItem;
        final map = item.toJson();
        map.remove('id');
        
        // Se estiver null (criação), define o timestamp
        if (map['updatedAt'] == null) {
          map['updatedAt'] = FieldValue.serverTimestamp();
        }
        
        return map.cast<String, Object?>();
      },
    );
  }

  // --- MÉTODOS PÚBLICOS ---

  /// 1. Monitorar lista de Cômodos
  Stream<List<InspectionRoom>> watchRooms(String inspectionId) {
    return _roomsRef(inspectionId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// 2. Adicionar um Cômodo
  Future<String> addRoom(String inspectionId, InspectionRoom room) async {
    final docRef = await _roomsRef(inspectionId).add(room);
    return docRef.id;
  }

  /// 3. Monitorar itens de um cômodo específico
  Stream<List<InspectionItem>> watchItems(
      String inspectionId, String roomId) {
    return _itemsRef(inspectionId, roomId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// 4. Adicionar itens em Lote (Batch Write)
  Future<void> addItems(
      String inspectionId, String roomId, List<InspectionItem> items) async {
    final batch = _firestore.batch();
    
    // CORREÇÃO CRÍTICA: 
    // Usamos uma referência "crua" (sem converter) para o Batch.
    // Isso permite passar um Map<String, dynamic> diretamente, evitando
    // conflitos de tipo e permitindo o uso de FieldValue.serverTimestamp().
    final rawCollectionRef = _firestore.collection('inspections/$inspectionId/rooms/$roomId/items');

    for (final item in items) {
      final docRef = rawCollectionRef.doc(); // Gera ID
      
      final map = item.toJson();
      map.remove('id');
      map['updatedAt'] = FieldValue.serverTimestamp(); // Funciona perfeitamente no Map cru

      batch.set(docRef, map);
    }

    await batch.commit();
  }

  /// 5. Atualizar um item
  Future<void> updateItem(
      String inspectionId, String roomId, InspectionItem item) async {
    final itemToUpdate = item.copyWith(updatedAt: DateTime.now());
    
    // Aqui usamos a referência tipada pois estamos passando o objeto 'itemToUpdate'
    await _itemsRef(inspectionId, roomId)
        .doc(item.id)
        .set(itemToUpdate, SetOptions(merge: true));
  }
}
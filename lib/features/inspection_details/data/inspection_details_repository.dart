import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/inspection_details_model.dart';

part 'inspection_details_repository.g.dart';

@riverpod
InspectionDetailsRepository inspectionDetailsRepository(
    InspectionDetailsRepositoryRef ref) {
  return InspectionDetailsRepository(FirebaseFirestore.instance);
}

class InspectionDetailsRepository {
  final FirebaseFirestore _firestore;

  InspectionDetailsRepository(this._firestore);

  // --- HELPERS DE COLEÇÃO ---
  
  // Acesso à sub-coleção 'rooms' de uma vistoria
  CollectionReference<InspectionRoom> _roomsRef(String inspectionId) {
    return _firestore
        .collection('inspections')
        .doc(inspectionId)
        .collection('rooms')
        .withConverter<InspectionRoom>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data() ?? {};
        // Injeta o ID do documento no modelo
        data['id'] = snapshot.id; 
        return InspectionRoom.fromJson(data);
      },
      toFirestore: (room, _) {
        // Remove o ID para não duplicar no banco (já é a chave do doc)
        final map = room.toJson();
        map.remove('id'); 
        return map;
      },
    );
  }

  // Acesso à sub-coleção 'items' de um cômodo
  CollectionReference<InspectionItem> _itemsRef(
      String inspectionId, String roomId) {
    return _roomsRef(inspectionId)
        .doc(roomId)
        .collection('items')
        .withConverter<InspectionItem>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data() ?? {};
        data['id'] = snapshot.id;
        return InspectionItem.fromJson(data);
      },
      toFirestore: (item, _) {
        final map = item.toJson();
        map.remove('id');
        return map;
      },
    );
  }

  // --- MÉTODOS ---

  // 1. Monitorar Cômodos
  Stream<List<InspectionRoom>> watchRooms(String inspectionId) {
    return _roomsRef(inspectionId)
        .orderBy('name') // Ordenação alfabética padrão
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // 2. Adicionar Cômodo (E inicializar itens padrão se necessário)
  Future<void> addRoom(String inspectionId, String name) async {
    final roomRef = _roomsRef(inspectionId).doc(); // Gera ID automático
    
    // Cria o cômodo zerado
    final newRoom = InspectionRoom(
      id: roomRef.id,
      name: name,
      totalItems: 0,
      completedItems: 0,
    );

    // Dica de Engenharia: Em um app real, aqui você provavelmente
    // adicionaria uma lista de itens padrão (ex: se for "Cozinha", adiciona "Pia", "Fogão")
    // usando um Batch Write. Por enquanto, seguiremos o requisito simples.
    
    await roomRef.set(newRoom);
  }

  // 3. Monitorar Itens de um Cômodo
  Stream<List<InspectionItem>> watchItems(String inspectionId, String roomId) {
    return _itemsRef(inspectionId, roomId)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // 4. Atualizar Item (Condição, Notas, Fotos)
  Future<void> addItem(
    String inspectionId, String roomId, InspectionItem item) async {
    final itemRef = _itemsRef(inspectionId, roomId).doc(); // Gera ID automático
    
    // Cria o item com ID gerado automaticamente
    final newItem = item.copyWith(id: itemRef.id);
    
    await itemRef.set(newItem);
  }

  Future<void> updateItem(
    String inspectionId, String roomId, InspectionItem item) async {
    final itemRef = _itemsRef(inspectionId, roomId).doc(item.id);
    await itemRef.set(item);
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../domain/inspection.dart';

part 'inspections_repository.g.dart';

@riverpod
InspectionsRepository inspectionsRepository(InspectionsRepositoryRef ref) {
  return InspectionsRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance, // Ou ref.watch(firebaseAuthProvider)
  );
}

class InspectionsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  InspectionsRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  // Getter privado para a collection tipada
  // Isso remove a necessidade de fazer .fromJson e .toJson manualmente em cada método
  CollectionReference<Inspection> get _inspectionsRef {
    return _firestore.collection('inspections').withConverter<Inspection>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            if (data == null) throw Exception("Documento vazio");
            // Garante que o ID do documento seja o ID do objeto
            return Inspection.fromJson({...data, 'id': snapshot.id});
          },
          toFirestore: (inspection, _) {
            // Remove o ID do map para não duplicar dado (o ID já é a chave do doc)
            // Mas mantém os converters rodando
            final map = inspection.toJson();
            map.remove('id'); 
            return map;
          },
        );
  }

  // --- CRUD METHODS ---

  Future<void> createInspection(Inspection inspection) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não autenticado");

    // Lógica de ID: Se vier vazio, gera um UUID v4.
    // Também forçamos o userId atual por segurança.
    final String docId = inspection.id.isEmpty ? _uuid.v4() : inspection.id;
    
    final inspectionToSave = inspection.copyWith(
      id: docId,
      userId: user.uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Usamos .set com o ID específico
    await _inspectionsRef.doc(docId).set(inspectionToSave);
  }

  Stream<List<Inspection>> watchInspections() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _inspectionsRef
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteInspection(String id) async {
    await _inspectionsRef.doc(id).delete();
  }

  Future<void> updateStatus(String id, InspectionStatus status) async {
    // Atualiza status e data de atualização
    // Note que aqui precisamos passar o Map direto pois é um update parcial,
    // ou usar o copyWith + set(Merge). Update parcial é mais eficiente.
    await _inspectionsRef.doc(id).update({
      'status': status.name, // Grava a string do enum ('scheduled', etc)
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

  @riverpod
  Stream<List<Inspection>> inspectionsList(InspectionsListRef ref) {
    final repository = ref.watch(inspectionsRepositoryProvider);
    return repository.watchInspections(); 
  }
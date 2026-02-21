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
    auth: FirebaseAuth.instance,
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

  CollectionReference<Inspection> get _inspectionsRef {
    return _firestore.collection('inspections').withConverter<Inspection>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            if (data == null) throw Exception("Documento vazio");
            return Inspection.fromJson({...data, 'id': snapshot.id});
          },
          toFirestore: (inspection, _) {
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

    final String docId = inspection.id.isEmpty ? _uuid.v4() : inspection.id;
    
    final inspectionToSave = inspection.copyWith(
      id: docId,
      userId: user.uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

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
    await _inspectionsRef.doc(id).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<Inspection> watchInspection(String id) {
    return _inspectionsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) throw Exception("Vistoria não encontrada");
      return doc.data()!;
    });
  }
}

@riverpod
Stream<List<Inspection>> inspectionsList(InspectionsListRef ref) {
  final repository = ref.watch(inspectionsRepositoryProvider);
  return repository.watchInspections(); 
}

  @riverpod
Stream<Inspection> singleInspection(SingleInspectionRef ref, String id) {
  final repository = ref.watch(inspectionsRepositoryProvider);
  return repository.watchInspection(id);
}
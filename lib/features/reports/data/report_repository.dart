import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Imports dos Models
import '../../inspections/domain/inspection.dart';
import '../../inspection_details/domain/inspection_details_models.dart';

part 'report_repository.g.dart';

/// Classe DTO (Data Transfer Object) para agrupar tudo
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

@riverpod
Future<FullInspectionData> fullInspection(FullInspectionRef ref, String inspectionId) async {
  final firestore = FirebaseFirestore.instance;

  // 1. Buscamos a Inspeção e os Cômodos em paralelo (Primeiro nível)
  // Nota: Precisamos replicar os converters ou instanciar manualmente para manter a tipagem.
  // Para simplificar neste agregador, faremos a conversão manual rápida baseada nos models.
  
  final inspectionFuture = firestore.collection('inspections').doc(inspectionId).get();
  final roomsFuture = firestore.collection('inspections').doc(inspectionId).collection('rooms').orderBy('name').get();

  final results = await Future.wait([inspectionFuture, roomsFuture]);

  final inspectionSnap = results[0] as DocumentSnapshot<Map<String, dynamic>>;
  final roomsSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;

  if (!inspectionSnap.exists) {
    throw Exception("Vistoria não encontrada");
  }

  // Converter Inspeção
  // Adiciona ID manualmente pois o fromJson espera
  final inspection = Inspection.fromJson({...inspectionSnap.data()!, 'id': inspectionSnap.id});

  // Converter Cômodos
  final rooms = roomsSnap.docs.map((doc) {
    return InspectionRoom.fromJson({...doc.data(), 'id': doc.id});
  }).toList();

  // 2. Buscamos os Itens de TODOS os cômodos em paralelo (Segundo nível)
  // Criamos uma lista de Futures, onde cada Future busca os itens de um quarto
  final itemsFutures = rooms.map((room) async {
    final itemsSnap = await firestore
        .collection('inspections')
        .doc(inspectionId)
        .collection('rooms')
        .doc(room.id)
        .collection('items')
        .orderBy('name')
        .get();

    final items = itemsSnap.docs.map((doc) {
      return InspectionItem.fromJson({...doc.data(), 'id': doc.id});
    }).toList();

    return MapEntry(room.id, items);
  });

  // Aguarda todos os downloads de itens finalizarem
  final itemsEntries = await Future.wait(itemsFutures);
  final itemsByRoom = Map.fromEntries(itemsEntries);

  return FullInspectionData(
    inspection: inspection,
    rooms: rooms,
    itemsByRoom: itemsByRoom,
  );
}
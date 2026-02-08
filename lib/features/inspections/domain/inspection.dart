import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection.freezed.dart';
part 'inspection.g.dart';

// --- ENUMS ---
enum InspectionStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('inProgress')
  inProgress,
  @JsonValue('done')
  done,
}

// --- CONVERTERS ---
// O Firestore retorna Timestamp, mas o Dart usa DateTime.
// Este converter faz a ponte automática durante a serialização.
class FirestoreTimestampConverter implements JsonConverter<DateTime, Object> {
  const FirestoreTimestampConverter();

  @override
  DateTime fromJson(Object json) {
    // Trata tanto Timestamp quanto casos onde o dado vem como String (se mockado)
    if (json is Timestamp) {
      return json.toDate();
    }
    return DateTime.parse(json as String);
  }

  @override
  Object toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}

// --- ENTITY ---
@freezed
class Inspection with _$Inspection {
  // O construtor privado é necessário para getters customizados se houver
  const Inspection._();

  // @JsonSerializable(explicitToJson: true) // Útil se tiver objetos aninhados complexos
  const factory Inspection({
    required String id,
    required String userId,
    required String clientName,
    required String address,
    
    @FirestoreTimestampConverter() 
    required DateTime date,
    
    @Default(InspectionStatus.scheduled) 
    InspectionStatus status,
    
    @FirestoreTimestampConverter() 
    required DateTime createdAt,
    
    @FirestoreTimestampConverter() 
    required DateTime updatedAt,
  }) = _Inspection;

  factory Inspection.fromJson(Map<String, dynamic> json) =>
      _$InspectionFromJson(json);
      
  // Helper para criar uma inspeção nova "limpa" antes de ter ID
  factory Inspection.create({
    required String userId,
    required String clientName,
    required String address,
    required DateTime date,
  }) {
    final now = DateTime.now();
    return Inspection(
      id: '', // Será gerado no repositório/UUID
      userId: userId,
      clientName: clientName,
      address: address,
      date: date,
      status: InspectionStatus.scheduled,
      createdAt: now,
      updatedAt: now,
    );
  }
}
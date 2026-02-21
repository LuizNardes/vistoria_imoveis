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
class FirestoreTimestampConverter implements JsonConverter<DateTime, Object?> {
  const FirestoreTimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json == null) return DateTime.now(); // Proteção contra null
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    return DateTime.now();
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}

// --- ENTITY ---
@freezed
class Inspection with _$Inspection {
  const Inspection._();

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

  factory Inspection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Inspection(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      clientName: (data['clientName'] as String?) ?? 'Cliente não informado', 
      address: (data['address'] as String?) ?? 'Endereço não informado',

      date: _parseDate(data['date']),
      
      status: _parseStatus(data['status']),
      
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }
  
  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static InspectionStatus _parseStatus(dynamic value) {
    return InspectionStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => InspectionStatus.scheduled,
    );
  }

  factory Inspection.create({
    required String userId,
    required String clientName,
    required String address,
    required DateTime date,
  }) {
    final now = DateTime.now();
    return Inspection(
      id: '', 
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
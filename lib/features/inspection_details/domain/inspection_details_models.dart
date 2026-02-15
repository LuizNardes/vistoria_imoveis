import 'package:cloud_firestore/cloud_firestore.dart'; // Necessário para Timestamp
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_details_models.freezed.dart';
part 'inspection_details_models.g.dart';

// --- CONVERTERS ---
// Isso converte o Timestamp do Firestore para DateTime do Dart automaticamente
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    return null;
  }

  @override
  Object? toJson(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
}

// --- ENUM ---
@JsonEnum(valueField: 'value')
enum ItemCondition {
  @JsonValue('ok')
  ok('ok'),
  @JsonValue('damaged')
  damaged('damaged'),
  @JsonValue('repair_needed')
  repairNeeded('repair_needed'),
  @JsonValue('not_applicable')
  notApplicable('not_applicable');

  final String value;
  const ItemCondition(this.value);
}

// --- ITEM DA VISTORIA ---
@freezed
class InspectionItem with _$InspectionItem {
  const InspectionItem._();

  const factory InspectionItem({
    required String id,
    required String name,
    @Default(ItemCondition.ok) ItemCondition condition,
    String? notes,
    @Default([]) List<String> photos,
    
    // --- CAMPO ADICIONADO ---
    @TimestampConverter() DateTime? updatedAt, 
    // ------------------------
    
  }) = _InspectionItem;

  factory InspectionItem.fromJson(Map<String, dynamic> json) =>
      _$InspectionItemFromJson(json);
}

// --- CÔMODO DA VISTORIA ---
@freezed
class InspectionRoom with _$InspectionRoom {
  const InspectionRoom._();

  const factory InspectionRoom({
    required String id,
    required String name,
    @Default(0) int completedItems,
    @Default(0) int totalItems,
  }) = _InspectionRoom;

  factory InspectionRoom.fromJson(Map<String, dynamic> json) =>
      _$InspectionRoomFromJson(json);
}
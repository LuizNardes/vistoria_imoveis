import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_details_model.freezed.dart';
part 'inspection_details_model.g.dart';

// --- ENUM ---
@JsonEnum(valueField: 'value')
enum ItemCondition {
  ok('ok'),
  damaged('damaged'),
  repairNeeded('repair_needed'),
  notApplicable('not_applicable');

  final String value;
  const ItemCondition(this.value);
}

// --- ITEM DA VISTORIA ---
@freezed
class InspectionItem with _$InspectionItem {
  const InspectionItem._(); // Necessário para getters customizados

  const factory InspectionItem({
    required String id,
    required String name,
    @Default(ItemCondition.ok) ItemCondition condition,
    String? notes,
    @Default([]) List<String> photos,
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
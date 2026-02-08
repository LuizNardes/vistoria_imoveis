// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionItemImpl _$$InspectionItemImplFromJson(Map<String, dynamic> json) =>
    _$InspectionItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      condition:
          $enumDecodeNullable(_$ItemConditionEnumMap, json['condition']) ??
              ItemCondition.ok,
      notes: json['notes'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$InspectionItemImplToJson(
        _$InspectionItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'condition': _$ItemConditionEnumMap[instance.condition]!,
      'notes': instance.notes,
      'photos': instance.photos,
    };

const _$ItemConditionEnumMap = {
  ItemCondition.ok: 'ok',
  ItemCondition.damaged: 'damaged',
  ItemCondition.repairNeeded: 'repair_needed',
  ItemCondition.notApplicable: 'not_applicable',
};

_$InspectionRoomImpl _$$InspectionRoomImplFromJson(Map<String, dynamic> json) =>
    _$InspectionRoomImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      completedItems: (json['completedItems'] as num?)?.toInt() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$InspectionRoomImplToJson(
        _$InspectionRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'completedItems': instance.completedItems,
      'totalItems': instance.totalItems,
    };

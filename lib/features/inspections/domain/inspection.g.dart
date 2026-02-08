// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionImpl _$$InspectionImplFromJson(Map<String, dynamic> json) =>
    _$InspectionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      clientName: json['clientName'] as String,
      address: json['address'] as String,
      date:
          const FirestoreTimestampConverter().fromJson(json['date'] as Object),
      status: $enumDecodeNullable(_$InspectionStatusEnumMap, json['status']) ??
          InspectionStatus.scheduled,
      createdAt: const FirestoreTimestampConverter()
          .fromJson(json['createdAt'] as Object),
      updatedAt: const FirestoreTimestampConverter()
          .fromJson(json['updatedAt'] as Object),
    );

Map<String, dynamic> _$$InspectionImplToJson(_$InspectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'clientName': instance.clientName,
      'address': instance.address,
      'date': const FirestoreTimestampConverter().toJson(instance.date),
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'createdAt':
          const FirestoreTimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const FirestoreTimestampConverter().toJson(instance.updatedAt),
    };

const _$InspectionStatusEnumMap = {
  InspectionStatus.scheduled: 'scheduled',
  InspectionStatus.inProgress: 'inProgress',
  InspectionStatus.done: 'done',
};

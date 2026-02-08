// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InspectionItem _$InspectionItemFromJson(Map<String, dynamic> json) {
  return _InspectionItem.fromJson(json);
}

/// @nodoc
mixin _$InspectionItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ItemCondition get condition => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<String> get photos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InspectionItemCopyWith<InspectionItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionItemCopyWith<$Res> {
  factory $InspectionItemCopyWith(
          InspectionItem value, $Res Function(InspectionItem) then) =
      _$InspectionItemCopyWithImpl<$Res, InspectionItem>;
  @useResult
  $Res call(
      {String id,
      String name,
      ItemCondition condition,
      String? notes,
      List<String> photos});
}

/// @nodoc
class _$InspectionItemCopyWithImpl<$Res, $Val extends InspectionItem>
    implements $InspectionItemCopyWith<$Res> {
  _$InspectionItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? condition = null,
    Object? notes = freezed,
    Object? photos = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as ItemCondition,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InspectionItemImplCopyWith<$Res>
    implements $InspectionItemCopyWith<$Res> {
  factory _$$InspectionItemImplCopyWith(_$InspectionItemImpl value,
          $Res Function(_$InspectionItemImpl) then) =
      __$$InspectionItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      ItemCondition condition,
      String? notes,
      List<String> photos});
}

/// @nodoc
class __$$InspectionItemImplCopyWithImpl<$Res>
    extends _$InspectionItemCopyWithImpl<$Res, _$InspectionItemImpl>
    implements _$$InspectionItemImplCopyWith<$Res> {
  __$$InspectionItemImplCopyWithImpl(
      _$InspectionItemImpl _value, $Res Function(_$InspectionItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? condition = null,
    Object? notes = freezed,
    Object? photos = null,
  }) {
    return _then(_$InspectionItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as ItemCondition,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InspectionItemImpl extends _InspectionItem {
  const _$InspectionItemImpl(
      {required this.id,
      required this.name,
      this.condition = ItemCondition.ok,
      this.notes,
      final List<String> photos = const []})
      : _photos = photos,
        super._();

  factory _$InspectionItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InspectionItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final ItemCondition condition;
  @override
  final String? notes;
  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  String toString() {
    return 'InspectionItem(id: $id, name: $name, condition: $condition, notes: $notes, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, condition, notes,
      const DeepCollectionEquality().hash(_photos));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InspectionItemImplCopyWith<_$InspectionItemImpl> get copyWith =>
      __$$InspectionItemImplCopyWithImpl<_$InspectionItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InspectionItemImplToJson(
      this,
    );
  }
}

abstract class _InspectionItem extends InspectionItem {
  const factory _InspectionItem(
      {required final String id,
      required final String name,
      final ItemCondition condition,
      final String? notes,
      final List<String> photos}) = _$InspectionItemImpl;
  const _InspectionItem._() : super._();

  factory _InspectionItem.fromJson(Map<String, dynamic> json) =
      _$InspectionItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  ItemCondition get condition;
  @override
  String? get notes;
  @override
  List<String> get photos;
  @override
  @JsonKey(ignore: true)
  _$$InspectionItemImplCopyWith<_$InspectionItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InspectionRoom _$InspectionRoomFromJson(Map<String, dynamic> json) {
  return _InspectionRoom.fromJson(json);
}

/// @nodoc
mixin _$InspectionRoom {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get completedItems => throw _privateConstructorUsedError;
  int get totalItems => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InspectionRoomCopyWith<InspectionRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionRoomCopyWith<$Res> {
  factory $InspectionRoomCopyWith(
          InspectionRoom value, $Res Function(InspectionRoom) then) =
      _$InspectionRoomCopyWithImpl<$Res, InspectionRoom>;
  @useResult
  $Res call({String id, String name, int completedItems, int totalItems});
}

/// @nodoc
class _$InspectionRoomCopyWithImpl<$Res, $Val extends InspectionRoom>
    implements $InspectionRoomCopyWith<$Res> {
  _$InspectionRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? completedItems = null,
    Object? totalItems = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      completedItems: null == completedItems
          ? _value.completedItems
          : completedItems // ignore: cast_nullable_to_non_nullable
              as int,
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InspectionRoomImplCopyWith<$Res>
    implements $InspectionRoomCopyWith<$Res> {
  factory _$$InspectionRoomImplCopyWith(_$InspectionRoomImpl value,
          $Res Function(_$InspectionRoomImpl) then) =
      __$$InspectionRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int completedItems, int totalItems});
}

/// @nodoc
class __$$InspectionRoomImplCopyWithImpl<$Res>
    extends _$InspectionRoomCopyWithImpl<$Res, _$InspectionRoomImpl>
    implements _$$InspectionRoomImplCopyWith<$Res> {
  __$$InspectionRoomImplCopyWithImpl(
      _$InspectionRoomImpl _value, $Res Function(_$InspectionRoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? completedItems = null,
    Object? totalItems = null,
  }) {
    return _then(_$InspectionRoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      completedItems: null == completedItems
          ? _value.completedItems
          : completedItems // ignore: cast_nullable_to_non_nullable
              as int,
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InspectionRoomImpl extends _InspectionRoom {
  const _$InspectionRoomImpl(
      {required this.id,
      required this.name,
      this.completedItems = 0,
      this.totalItems = 0})
      : super._();

  factory _$InspectionRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$InspectionRoomImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final int completedItems;
  @override
  @JsonKey()
  final int totalItems;

  @override
  String toString() {
    return 'InspectionRoom(id: $id, name: $name, completedItems: $completedItems, totalItems: $totalItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.completedItems, completedItems) ||
                other.completedItems == completedItems) &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, completedItems, totalItems);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InspectionRoomImplCopyWith<_$InspectionRoomImpl> get copyWith =>
      __$$InspectionRoomImplCopyWithImpl<_$InspectionRoomImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InspectionRoomImplToJson(
      this,
    );
  }
}

abstract class _InspectionRoom extends InspectionRoom {
  const factory _InspectionRoom(
      {required final String id,
      required final String name,
      final int completedItems,
      final int totalItems}) = _$InspectionRoomImpl;
  const _InspectionRoom._() : super._();

  factory _InspectionRoom.fromJson(Map<String, dynamic> json) =
      _$InspectionRoomImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get completedItems;
  @override
  int get totalItems;
  @override
  @JsonKey(ignore: true)
  _$$InspectionRoomImplCopyWith<_$InspectionRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

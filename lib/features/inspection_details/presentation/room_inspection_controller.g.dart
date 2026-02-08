// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_inspection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomItemsHash() => r'518e1b1870b3d1c472e4d7304046c6bdd2f06d07';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [roomItems].
@ProviderFor(roomItems)
const roomItemsProvider = RoomItemsFamily();

/// See also [roomItems].
class RoomItemsFamily extends Family<AsyncValue<List<InspectionItem>>> {
  /// See also [roomItems].
  const RoomItemsFamily();

  /// See also [roomItems].
  RoomItemsProvider call(
    String inspectionId,
    String roomId,
  ) {
    return RoomItemsProvider(
      inspectionId,
      roomId,
    );
  }

  @override
  RoomItemsProvider getProviderOverride(
    covariant RoomItemsProvider provider,
  ) {
    return call(
      provider.inspectionId,
      provider.roomId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'roomItemsProvider';
}

/// See also [roomItems].
class RoomItemsProvider
    extends AutoDisposeStreamProvider<List<InspectionItem>> {
  /// See also [roomItems].
  RoomItemsProvider(
    String inspectionId,
    String roomId,
  ) : this._internal(
          (ref) => roomItems(
            ref as RoomItemsRef,
            inspectionId,
            roomId,
          ),
          from: roomItemsProvider,
          name: r'roomItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roomItemsHash,
          dependencies: RoomItemsFamily._dependencies,
          allTransitiveDependencies: RoomItemsFamily._allTransitiveDependencies,
          inspectionId: inspectionId,
          roomId: roomId,
        );

  RoomItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.inspectionId,
    required this.roomId,
  }) : super.internal();

  final String inspectionId;
  final String roomId;

  @override
  Override overrideWith(
    Stream<List<InspectionItem>> Function(RoomItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomItemsProvider._internal(
        (ref) => create(ref as RoomItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        inspectionId: inspectionId,
        roomId: roomId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<InspectionItem>> createElement() {
    return _RoomItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomItemsProvider &&
        other.inspectionId == inspectionId &&
        other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inspectionId.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoomItemsRef on AutoDisposeStreamProviderRef<List<InspectionItem>> {
  /// The parameter `inspectionId` of this provider.
  String get inspectionId;

  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<InspectionItem>>
    with RoomItemsRef {
  _RoomItemsProviderElement(super.provider);

  @override
  String get inspectionId => (origin as RoomItemsProvider).inspectionId;
  @override
  String get roomId => (origin as RoomItemsProvider).roomId;
}

String _$roomInspectionControllerHash() =>
    r'4e14f00317d32e4718054cc02d9c24d4c91f8e95';

/// See also [RoomInspectionController].
@ProviderFor(RoomInspectionController)
final roomInspectionControllerProvider =
    AutoDisposeAsyncNotifierProvider<RoomInspectionController, void>.internal(
  RoomInspectionController.new,
  name: r'roomInspectionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomInspectionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RoomInspectionController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

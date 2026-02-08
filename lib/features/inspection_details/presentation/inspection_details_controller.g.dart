// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_details_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inspectionRoomsHash() => r'fe393e765fbfe0aedd38f3611299f1f731c136f2';

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

/// See also [inspectionRooms].
@ProviderFor(inspectionRooms)
const inspectionRoomsProvider = InspectionRoomsFamily();

/// See also [inspectionRooms].
class InspectionRoomsFamily extends Family<AsyncValue<List<InspectionRoom>>> {
  /// See also [inspectionRooms].
  const InspectionRoomsFamily();

  /// See also [inspectionRooms].
  InspectionRoomsProvider call(
    String inspectionId,
  ) {
    return InspectionRoomsProvider(
      inspectionId,
    );
  }

  @override
  InspectionRoomsProvider getProviderOverride(
    covariant InspectionRoomsProvider provider,
  ) {
    return call(
      provider.inspectionId,
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
  String? get name => r'inspectionRoomsProvider';
}

/// See also [inspectionRooms].
class InspectionRoomsProvider
    extends AutoDisposeStreamProvider<List<InspectionRoom>> {
  /// See also [inspectionRooms].
  InspectionRoomsProvider(
    String inspectionId,
  ) : this._internal(
          (ref) => inspectionRooms(
            ref as InspectionRoomsRef,
            inspectionId,
          ),
          from: inspectionRoomsProvider,
          name: r'inspectionRoomsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inspectionRoomsHash,
          dependencies: InspectionRoomsFamily._dependencies,
          allTransitiveDependencies:
              InspectionRoomsFamily._allTransitiveDependencies,
          inspectionId: inspectionId,
        );

  InspectionRoomsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.inspectionId,
  }) : super.internal();

  final String inspectionId;

  @override
  Override overrideWith(
    Stream<List<InspectionRoom>> Function(InspectionRoomsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InspectionRoomsProvider._internal(
        (ref) => create(ref as InspectionRoomsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        inspectionId: inspectionId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<InspectionRoom>> createElement() {
    return _InspectionRoomsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InspectionRoomsProvider &&
        other.inspectionId == inspectionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inspectionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InspectionRoomsRef on AutoDisposeStreamProviderRef<List<InspectionRoom>> {
  /// The parameter `inspectionId` of this provider.
  String get inspectionId;
}

class _InspectionRoomsProviderElement
    extends AutoDisposeStreamProviderElement<List<InspectionRoom>>
    with InspectionRoomsRef {
  _InspectionRoomsProviderElement(super.provider);

  @override
  String get inspectionId => (origin as InspectionRoomsProvider).inspectionId;
}

String _$inspectionDetailsControllerHash() =>
    r'6edf9f0a80d6123aa4b702dde0ce4dbf35afc692';

/// See also [InspectionDetailsController].
@ProviderFor(InspectionDetailsController)
final inspectionDetailsControllerProvider = AutoDisposeAsyncNotifierProvider<
    InspectionDetailsController, void>.internal(
  InspectionDetailsController.new,
  name: r'inspectionDetailsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inspectionDetailsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InspectionDetailsController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

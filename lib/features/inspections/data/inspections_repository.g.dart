// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspections_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inspectionsRepositoryHash() =>
    r'c120810bdd37d980af26859c5b23901003f3eb05';

/// See also [inspectionsRepository].
@ProviderFor(inspectionsRepository)
final inspectionsRepositoryProvider =
    AutoDisposeProvider<InspectionsRepository>.internal(
  inspectionsRepository,
  name: r'inspectionsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inspectionsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InspectionsRepositoryRef
    = AutoDisposeProviderRef<InspectionsRepository>;
String _$inspectionsListHash() => r'05da09b5c38ce8092bd079b4bf6dc81a92b1e4c2';

/// See also [inspectionsList].
@ProviderFor(inspectionsList)
final inspectionsListProvider =
    AutoDisposeStreamProvider<List<Inspection>>.internal(
  inspectionsList,
  name: r'inspectionsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inspectionsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InspectionsListRef = AutoDisposeStreamProviderRef<List<Inspection>>;
String _$singleInspectionHash() => r'b080cf9d26439c1622a3e4e19ce9648ca730b008';

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

/// See also [singleInspection].
@ProviderFor(singleInspection)
const singleInspectionProvider = SingleInspectionFamily();

/// See also [singleInspection].
class SingleInspectionFamily extends Family<AsyncValue<Inspection>> {
  /// See also [singleInspection].
  const SingleInspectionFamily();

  /// See also [singleInspection].
  SingleInspectionProvider call(
    String id,
  ) {
    return SingleInspectionProvider(
      id,
    );
  }

  @override
  SingleInspectionProvider getProviderOverride(
    covariant SingleInspectionProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'singleInspectionProvider';
}

/// See also [singleInspection].
class SingleInspectionProvider extends AutoDisposeStreamProvider<Inspection> {
  /// See also [singleInspection].
  SingleInspectionProvider(
    String id,
  ) : this._internal(
          (ref) => singleInspection(
            ref as SingleInspectionRef,
            id,
          ),
          from: singleInspectionProvider,
          name: r'singleInspectionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$singleInspectionHash,
          dependencies: SingleInspectionFamily._dependencies,
          allTransitiveDependencies:
              SingleInspectionFamily._allTransitiveDependencies,
          id: id,
        );

  SingleInspectionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Stream<Inspection> Function(SingleInspectionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SingleInspectionProvider._internal(
        (ref) => create(ref as SingleInspectionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Inspection> createElement() {
    return _SingleInspectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SingleInspectionProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SingleInspectionRef on AutoDisposeStreamProviderRef<Inspection> {
  /// The parameter `id` of this provider.
  String get id;
}

class _SingleInspectionProviderElement
    extends AutoDisposeStreamProviderElement<Inspection>
    with SingleInspectionRef {
  _SingleInspectionProviderElement(super.provider);

  @override
  String get id => (origin as SingleInspectionProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

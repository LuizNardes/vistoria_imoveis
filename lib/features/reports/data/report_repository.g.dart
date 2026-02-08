// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fullInspectionHash() => r'd256b23e5b5389e77f85dd30d1ca83be29be3fe5';

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

/// See also [fullInspection].
@ProviderFor(fullInspection)
const fullInspectionProvider = FullInspectionFamily();

/// See also [fullInspection].
class FullInspectionFamily extends Family<AsyncValue<FullInspectionData>> {
  /// See also [fullInspection].
  const FullInspectionFamily();

  /// See also [fullInspection].
  FullInspectionProvider call(
    String inspectionId,
  ) {
    return FullInspectionProvider(
      inspectionId,
    );
  }

  @override
  FullInspectionProvider getProviderOverride(
    covariant FullInspectionProvider provider,
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
  String? get name => r'fullInspectionProvider';
}

/// See also [fullInspection].
class FullInspectionProvider
    extends AutoDisposeFutureProvider<FullInspectionData> {
  /// See also [fullInspection].
  FullInspectionProvider(
    String inspectionId,
  ) : this._internal(
          (ref) => fullInspection(
            ref as FullInspectionRef,
            inspectionId,
          ),
          from: fullInspectionProvider,
          name: r'fullInspectionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fullInspectionHash,
          dependencies: FullInspectionFamily._dependencies,
          allTransitiveDependencies:
              FullInspectionFamily._allTransitiveDependencies,
          inspectionId: inspectionId,
        );

  FullInspectionProvider._internal(
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
    FutureOr<FullInspectionData> Function(FullInspectionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FullInspectionProvider._internal(
        (ref) => create(ref as FullInspectionRef),
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
  AutoDisposeFutureProviderElement<FullInspectionData> createElement() {
    return _FullInspectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FullInspectionProvider &&
        other.inspectionId == inspectionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inspectionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FullInspectionRef on AutoDisposeFutureProviderRef<FullInspectionData> {
  /// The parameter `inspectionId` of this provider.
  String get inspectionId;
}

class _FullInspectionProviderElement
    extends AutoDisposeFutureProviderElement<FullInspectionData>
    with FullInspectionRef {
  _FullInspectionProviderElement(super.provider);

  @override
  String get inspectionId => (origin as FullInspectionProvider).inspectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

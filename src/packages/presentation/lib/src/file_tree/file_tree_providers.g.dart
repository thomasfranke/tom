// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_tree_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads everything a space holds.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package: it names what it needs and cannot see
/// what satisfies it.

@ProviderFor(listSpaceEntries)
final listSpaceEntriesProvider = ListSpaceEntriesProvider._();

/// Reads everything a space holds.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package: it names what it needs and cannot see
/// what satisfies it.

final class ListSpaceEntriesProvider
    extends
        $FunctionalProvider<
          ListSpaceEntriesUseCase,
          ListSpaceEntriesUseCase,
          ListSpaceEntriesUseCase
        >
    with $Provider<ListSpaceEntriesUseCase> {
  /// Reads everything a space holds.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package: it names what it needs and cannot see
  /// what satisfies it.
  ListSpaceEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listSpaceEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listSpaceEntriesHash();

  @$internal
  @override
  $ProviderElement<ListSpaceEntriesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListSpaceEntriesUseCase create(Ref ref) {
    return listSpaceEntries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListSpaceEntriesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListSpaceEntriesUseCase>(value),
    );
  }
}

String _$listSpaceEntriesHash() => r'c840d7fbbfe56b482df4fe01a254a1629950b649';

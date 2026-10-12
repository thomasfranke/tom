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

/// Creates a folder where the explorer menu's `New folder` asks.

@ProviderFor(createFolder)
final createFolderProvider = CreateFolderProvider._();

/// Creates a folder where the explorer menu's `New folder` asks.

final class CreateFolderProvider
    extends
        $FunctionalProvider<
          CreateFolderUseCase,
          CreateFolderUseCase,
          CreateFolderUseCase
        >
    with $Provider<CreateFolderUseCase> {
  /// Creates a folder where the explorer menu's `New folder` asks.
  CreateFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createFolderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createFolderHash();

  @$internal
  @override
  $ProviderElement<CreateFolderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateFolderUseCase create(Ref ref) {
    return createFolder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateFolderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateFolderUseCase>(value),
    );
  }
}

String _$createFolderHash() => r'b69a8df5ec65d20a702cf1586f2be79f9ffa68da';

/// Shows a folder in the platform's file manager — the space's from the
/// explorer, the repository's from the git column.

@ProviderFor(revealFolder)
final revealFolderProvider = RevealFolderProvider._();

/// Shows a folder in the platform's file manager — the space's from the
/// explorer, the repository's from the git column.

final class RevealFolderProvider
    extends
        $FunctionalProvider<
          RevealFolderUseCase,
          RevealFolderUseCase,
          RevealFolderUseCase
        >
    with $Provider<RevealFolderUseCase> {
  /// Shows a folder in the platform's file manager — the space's from the
  /// explorer, the repository's from the git column.
  RevealFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revealFolderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$revealFolderHash();

  @$internal
  @override
  $ProviderElement<RevealFolderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RevealFolderUseCase create(Ref ref) {
    return revealFolder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RevealFolderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RevealFolderUseCase>(value),
    );
  }
}

String _$revealFolderHash() => r'9e28bebdf6548130c253e5e7459b3a729b1417b6';

/// Creates a markdown document where the explorer's `+` was pressed.

@ProviderFor(createDocument)
final createDocumentProvider = CreateDocumentProvider._();

/// Creates a markdown document where the explorer's `+` was pressed.

final class CreateDocumentProvider
    extends
        $FunctionalProvider<
          CreateDocumentUseCase,
          CreateDocumentUseCase,
          CreateDocumentUseCase
        >
    with $Provider<CreateDocumentUseCase> {
  /// Creates a markdown document where the explorer's `+` was pressed.
  CreateDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createDocumentHash();

  @$internal
  @override
  $ProviderElement<CreateDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateDocumentUseCase create(Ref ref) {
    return createDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateDocumentUseCase>(value),
    );
  }
}

String _$createDocumentHash() => r'ed54287e0bd8b8a83f04e589c7a55484549acb77';

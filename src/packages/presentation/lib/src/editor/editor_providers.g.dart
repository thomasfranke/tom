// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads a document's source off the disk.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(readDocument)
final readDocumentProvider = ReadDocumentProvider._();

/// Reads a document's source off the disk.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class ReadDocumentProvider
    extends
        $FunctionalProvider<
          ReadDocumentUseCase,
          ReadDocumentUseCase,
          ReadDocumentUseCase
        >
    with $Provider<ReadDocumentUseCase> {
  /// Reads a document's source off the disk.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  ReadDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readDocumentHash();

  @$internal
  @override
  $ProviderElement<ReadDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadDocumentUseCase create(Ref ref) {
    return readDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadDocumentUseCase>(value),
    );
  }
}

String _$readDocumentHash() => r'67451dad96922ca9d240e8d62aaabf2032500249';

/// Reads a file that is not markdown, finding out whether it is text
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).

@ProviderFor(readFile)
final readFileProvider = ReadFileProvider._();

/// Reads a file that is not markdown, finding out whether it is text
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).

final class ReadFileProvider
    extends
        $FunctionalProvider<ReadFileUseCase, ReadFileUseCase, ReadFileUseCase>
    with $Provider<ReadFileUseCase> {
  /// Reads a file that is not markdown, finding out whether it is text
  /// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  ReadFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readFileHash();

  @$internal
  @override
  $ProviderElement<ReadFileUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReadFileUseCase create(Ref ref) {
    return readFile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadFileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadFileUseCase>(value),
    );
  }
}

String _$readFileHash() => r'fd5d7ebffe536990cea04edc1555de71d9479d5c';

/// Reads a deleted file as the last commit left it.

@ProviderFor(readCommittedFile)
final readCommittedFileProvider = ReadCommittedFileProvider._();

/// Reads a deleted file as the last commit left it.

final class ReadCommittedFileProvider
    extends
        $FunctionalProvider<
          ReadCommittedFileUseCase,
          ReadCommittedFileUseCase,
          ReadCommittedFileUseCase
        >
    with $Provider<ReadCommittedFileUseCase> {
  /// Reads a deleted file as the last commit left it.
  ReadCommittedFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readCommittedFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readCommittedFileHash();

  @$internal
  @override
  $ProviderElement<ReadCommittedFileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadCommittedFileUseCase create(Ref ref) {
    return readCommittedFile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadCommittedFileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadCommittedFileUseCase>(value),
    );
  }
}

String _$readCommittedFileHash() => r'fc976a3522d439f74e61afeb4a6a374a37e98f65';

/// Compares a file that is not markdown against its base, line by line.

@ProviderFor(diffLines)
final diffLinesProvider = DiffLinesProvider._();

/// Compares a file that is not markdown against its base, line by line.

final class DiffLinesProvider
    extends
        $FunctionalProvider<
          DiffLinesUseCase,
          DiffLinesUseCase,
          DiffLinesUseCase
        >
    with $Provider<DiffLinesUseCase> {
  /// Compares a file that is not markdown against its base, line by line.
  DiffLinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diffLinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diffLinesHash();

  @$internal
  @override
  $ProviderElement<DiffLinesUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DiffLinesUseCase create(Ref ref) {
    return diffLines(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiffLinesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiffLinesUseCase>(value),
    );
  }
}

String _$diffLinesHash() => r'8590ceed08810615717163304a935e154c31e35b';

/// Writes the buffer back to the file it came from.

@ProviderFor(saveDocument)
final saveDocumentProvider = SaveDocumentProvider._();

/// Writes the buffer back to the file it came from.

final class SaveDocumentProvider
    extends
        $FunctionalProvider<
          SaveDocumentUseCase,
          SaveDocumentUseCase,
          SaveDocumentUseCase
        >
    with $Provider<SaveDocumentUseCase> {
  /// Writes the buffer back to the file it came from.
  SaveDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveDocumentHash();

  @$internal
  @override
  $ProviderElement<SaveDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveDocumentUseCase create(Ref ref) {
    return saveDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveDocumentUseCase>(value),
    );
  }
}

String _$saveDocumentHash() => r'2dde8a7605fc307dd4f20aac1cfe31fa7a0c5e31';

/// Reads a branch's pull request draft, seeding it the first time.

@ProviderFor(openPullRequestDraft)
final openPullRequestDraftProvider = OpenPullRequestDraftProvider._();

/// Reads a branch's pull request draft, seeding it the first time.

final class OpenPullRequestDraftProvider
    extends
        $FunctionalProvider<
          OpenPullRequestDraftUseCase,
          OpenPullRequestDraftUseCase,
          OpenPullRequestDraftUseCase
        >
    with $Provider<OpenPullRequestDraftUseCase> {
  /// Reads a branch's pull request draft, seeding it the first time.
  OpenPullRequestDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openPullRequestDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openPullRequestDraftHash();

  @$internal
  @override
  $ProviderElement<OpenPullRequestDraftUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpenPullRequestDraftUseCase create(Ref ref) {
    return openPullRequestDraft(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenPullRequestDraftUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenPullRequestDraftUseCase>(value),
    );
  }
}

String _$openPullRequestDraftHash() =>
    r'56c02463738557704f647ad0aa7eb60ece4ec4c1';

/// Reads the preferences file: the same use case as [readDocument], over the
/// app's own folder rather than the space
/// (`docs/product/preferences/where-it-is-stored/doc.md`).

@ProviderFor(readPreferencesFile)
final readPreferencesFileProvider = ReadPreferencesFileProvider._();

/// Reads the preferences file: the same use case as [readDocument], over the
/// app's own folder rather than the space
/// (`docs/product/preferences/where-it-is-stored/doc.md`).

final class ReadPreferencesFileProvider
    extends
        $FunctionalProvider<
          ReadDocumentUseCase,
          ReadDocumentUseCase,
          ReadDocumentUseCase
        >
    with $Provider<ReadDocumentUseCase> {
  /// Reads the preferences file: the same use case as [readDocument], over the
  /// app's own folder rather than the space
  /// (`docs/product/preferences/where-it-is-stored/doc.md`).
  ReadPreferencesFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readPreferencesFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readPreferencesFileHash();

  @$internal
  @override
  $ProviderElement<ReadDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadDocumentUseCase create(Ref ref) {
    return readPreferencesFile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadDocumentUseCase>(value),
    );
  }
}

String _$readPreferencesFileHash() =>
    r'a37713436883797f467ced617698f8342f2ee33f';

/// Writes the preferences file back, as [saveDocument] over the app's folder.

@ProviderFor(savePreferencesFile)
final savePreferencesFileProvider = SavePreferencesFileProvider._();

/// Writes the preferences file back, as [saveDocument] over the app's folder.

final class SavePreferencesFileProvider
    extends
        $FunctionalProvider<
          SaveDocumentUseCase,
          SaveDocumentUseCase,
          SaveDocumentUseCase
        >
    with $Provider<SaveDocumentUseCase> {
  /// Writes the preferences file back, as [saveDocument] over the app's folder.
  SavePreferencesFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savePreferencesFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savePreferencesFileHash();

  @$internal
  @override
  $ProviderElement<SaveDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveDocumentUseCase create(Ref ref) {
    return savePreferencesFile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveDocumentUseCase>(value),
    );
  }
}

String _$savePreferencesFileHash() =>
    r'0d91b82fcbcaaa12a48afedf76ddf80c3c0acf67';

/// Writes a pull request draft back: the same use case as [saveDocument],
/// over the drafts folder rather than the space (Decision 33).

@ProviderFor(saveDraft)
final saveDraftProvider = SaveDraftProvider._();

/// Writes a pull request draft back: the same use case as [saveDocument],
/// over the drafts folder rather than the space (Decision 33).

final class SaveDraftProvider
    extends
        $FunctionalProvider<
          SaveDocumentUseCase,
          SaveDocumentUseCase,
          SaveDocumentUseCase
        >
    with $Provider<SaveDocumentUseCase> {
  /// Writes a pull request draft back: the same use case as [saveDocument],
  /// over the drafts folder rather than the space (Decision 33).
  SaveDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveDraftHash();

  @$internal
  @override
  $ProviderElement<SaveDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveDocumentUseCase create(Ref ref) {
    return saveDraft(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveDocumentUseCase>(value),
    );
  }
}

String _$saveDraftHash() => r'23163a505bee6242f14ae45f5c5ae7a0d340f88b';

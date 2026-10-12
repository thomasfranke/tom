// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads what the machine remembers.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(readPreferences)
final readPreferencesProvider = ReadPreferencesProvider._();

/// Reads what the machine remembers.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class ReadPreferencesProvider
    extends
        $FunctionalProvider<
          ReadPreferencesUseCase,
          ReadPreferencesUseCase,
          ReadPreferencesUseCase
        >
    with $Provider<ReadPreferencesUseCase> {
  /// Reads what the machine remembers.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  ReadPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readPreferencesHash();

  @$internal
  @override
  $ProviderElement<ReadPreferencesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadPreferencesUseCase create(Ref ref) {
    return readPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadPreferencesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadPreferencesUseCase>(value),
    );
  }
}

String _$readPreferencesHash() => r'05134235a781842bf73101945f2e15acc71cffe4';

/// Writes a choice back.

@ProviderFor(writePreferences)
final writePreferencesProvider = WritePreferencesProvider._();

/// Writes a choice back.

final class WritePreferencesProvider
    extends
        $FunctionalProvider<
          WritePreferencesUseCase,
          WritePreferencesUseCase,
          WritePreferencesUseCase
        >
    with $Provider<WritePreferencesUseCase> {
  /// Writes a choice back.
  WritePreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writePreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writePreferencesHash();

  @$internal
  @override
  $ProviderElement<WritePreferencesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WritePreferencesUseCase create(Ref ref) {
    return writePreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WritePreferencesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WritePreferencesUseCase>(value),
    );
  }
}

String _$writePreferencesHash() => r'3ff99e97daedea2b130ae8883dfa480a1c833cef';

/// Where the preferences file is, relative to the folder the composition
/// root keeps it in — the path the editor reads it at, and its tab's name.

@ProviderFor(preferencesFile)
final preferencesFileProvider = PreferencesFileProvider._();

/// Where the preferences file is, relative to the folder the composition
/// root keeps it in — the path the editor reads it at, and its tab's name.

final class PreferencesFileProvider
    extends
        $FunctionalProvider<
          SpaceRelativePathValueObject,
          SpaceRelativePathValueObject,
          SpaceRelativePathValueObject
        >
    with $Provider<SpaceRelativePathValueObject> {
  /// Where the preferences file is, relative to the folder the composition
  /// root keeps it in — the path the editor reads it at, and its tab's name.
  PreferencesFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesFileHash();

  @$internal
  @override
  $ProviderElement<SpaceRelativePathValueObject> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SpaceRelativePathValueObject create(Ref ref) {
    return preferencesFile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceRelativePathValueObject value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceRelativePathValueObject>(value),
    );
  }
}

String _$preferencesFileHash() => r'f3ee5596ff1a7ae68a5f5aebc35a20f021fd4c5f';

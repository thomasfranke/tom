// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commands_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads which commands `git-approvals.json` allows.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(readApprovals)
final readApprovalsProvider = ReadApprovalsProvider._();

/// Reads which commands `git-approvals.json` allows.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class ReadApprovalsProvider
    extends
        $FunctionalProvider<
          ReadApprovalsUseCase,
          ReadApprovalsUseCase,
          ReadApprovalsUseCase
        >
    with $Provider<ReadApprovalsUseCase> {
  /// Reads which commands `git-approvals.json` allows.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  ReadApprovalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readApprovalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readApprovalsHash();

  @$internal
  @override
  $ProviderElement<ReadApprovalsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadApprovalsUseCase create(Ref ref) {
    return readApprovals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadApprovalsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadApprovalsUseCase>(value),
    );
  }
}

String _$readApprovalsHash() => r'bfd15fcb4c5ec767c921dae0de47d7c4df7d1056';

/// Writes `true` beside one command's key.

@ProviderFor(allowCommand)
final allowCommandProvider = AllowCommandProvider._();

/// Writes `true` beside one command's key.

final class AllowCommandProvider
    extends
        $FunctionalProvider<
          AllowCommandUseCase,
          AllowCommandUseCase,
          AllowCommandUseCase
        >
    with $Provider<AllowCommandUseCase> {
  /// Writes `true` beside one command's key.
  AllowCommandProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allowCommandProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allowCommandHash();

  @$internal
  @override
  $ProviderElement<AllowCommandUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AllowCommandUseCase create(Ref ref) {
    return allowCommand(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AllowCommandUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AllowCommandUseCase>(value),
    );
  }
}

String _$allowCommandHash() => r'64441898b51f94a417a5cb126118a3bf0162fcab';

/// Lists every command the app can run in the file, before it is opened.

@ProviderFor(seedApprovals)
final seedApprovalsProvider = SeedApprovalsProvider._();

/// Lists every command the app can run in the file, before it is opened.

final class SeedApprovalsProvider
    extends
        $FunctionalProvider<
          SeedApprovalsUseCase,
          SeedApprovalsUseCase,
          SeedApprovalsUseCase
        >
    with $Provider<SeedApprovalsUseCase> {
  /// Lists every command the app can run in the file, before it is opened.
  SeedApprovalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seedApprovalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seedApprovalsHash();

  @$internal
  @override
  $ProviderElement<SeedApprovalsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SeedApprovalsUseCase create(Ref ref) {
    return seedApprovals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeedApprovalsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeedApprovalsUseCase>(value),
    );
  }
}

String _$seedApprovalsHash() => r'e5d8163001f4f00c939560b51adc2ec21d500949';

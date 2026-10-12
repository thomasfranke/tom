// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Starts the person's shell for a space.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(startTerminal)
final startTerminalProvider = StartTerminalProvider._();

/// Starts the person's shell for a space.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class StartTerminalProvider
    extends
        $FunctionalProvider<
          StartTerminalUseCase,
          StartTerminalUseCase,
          StartTerminalUseCase
        >
    with $Provider<StartTerminalUseCase> {
  /// Starts the person's shell for a space.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  StartTerminalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startTerminalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startTerminalHash();

  @$internal
  @override
  $ProviderElement<StartTerminalUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StartTerminalUseCase create(Ref ref) {
    return startTerminal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartTerminalUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartTerminalUseCase>(value),
    );
  }
}

String _$startTerminalHash() => r'ef151054d7f54455a1f73663e2149cc1534a53ce';

/// The person's home folder, which the terminal's head spells `~`
/// ([terminalPlaceOf]); null, the default, spells every folder in full.

@ProviderFor(homeFolder)
final homeFolderProvider = HomeFolderProvider._();

/// The person's home folder, which the terminal's head spells `~`
/// ([terminalPlaceOf]); null, the default, spells every folder in full.

final class HomeFolderProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The person's home folder, which the terminal's head spells `~`
  /// ([terminalPlaceOf]); null, the default, spells every folder in full.
  HomeFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeFolderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeFolderHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return homeFolder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$homeFolderHash() => r'cbe3b56302cbf57224c065c71b05e05b59ad592a';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads the commits that touched one document.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use cases it needs and cannot see that a process answers them.

@ProviderFor(readFileHistory)
final readFileHistoryProvider = ReadFileHistoryProvider._();

/// Reads the commits that touched one document.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use cases it needs and cannot see that a process answers them.

final class ReadFileHistoryProvider
    extends
        $FunctionalProvider<
          ReadFileHistoryUseCase,
          ReadFileHistoryUseCase,
          ReadFileHistoryUseCase
        >
    with $Provider<ReadFileHistoryUseCase> {
  /// Reads the commits that touched one document.
  ///
  /// Declared here and **overridden by the composition root**: this package
  /// names the use cases it needs and cannot see that a process answers them.
  ReadFileHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readFileHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readFileHistoryHash();

  @$internal
  @override
  $ProviderElement<ReadFileHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadFileHistoryUseCase create(Ref ref) {
    return readFileHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadFileHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadFileHistoryUseCase>(value),
    );
  }
}

String _$readFileHistoryHash() => r'8d6594bca9feb3fd88a3843d1c601aa5a4e12a4d';

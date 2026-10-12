// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'git_reading_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads where the repository stands and writes it into
/// [SpaceSessionState.git] and [SpaceSessionState.merge], for everyone who
/// draws from it.
///
/// **Kept alive, and made to exist by the shell**, never by the git column:
/// the column is built only while it is showing, and a reading that lived
/// there left a space opened with it shut with no git at all. Everything
/// that writes to the repository ends in [refresh], so what the window
/// believes has one source and one way to mend.

@ProviderFor(GitReadingNotifier)
final gitReadingProvider = GitReadingNotifierProvider._();

/// Reads where the repository stands and writes it into
/// [SpaceSessionState.git] and [SpaceSessionState.merge], for everyone who
/// draws from it.
///
/// **Kept alive, and made to exist by the shell**, never by the git column:
/// the column is built only while it is showing, and a reading that lived
/// there left a space opened with it shut with no git at all. Everything
/// that writes to the repository ends in [refresh], so what the window
/// believes has one source and one way to mend.
final class GitReadingNotifierProvider
    extends $NotifierProvider<GitReadingNotifier, GitReadingState> {
  /// Reads where the repository stands and writes it into
  /// [SpaceSessionState.git] and [SpaceSessionState.merge], for everyone who
  /// draws from it.
  ///
  /// **Kept alive, and made to exist by the shell**, never by the git column:
  /// the column is built only while it is showing, and a reading that lived
  /// there left a space opened with it shut with no git at all. Everything
  /// that writes to the repository ends in [refresh], so what the window
  /// believes has one source and one way to mend.
  GitReadingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gitReadingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gitReadingNotifierHash();

  @$internal
  @override
  GitReadingNotifier create() => GitReadingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GitReadingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GitReadingState>(value),
    );
  }
}

String _$gitReadingNotifierHash() =>
    r'86bae46ea227b6d33349a41166a704f309d5e237';

/// Reads where the repository stands and writes it into
/// [SpaceSessionState.git] and [SpaceSessionState.merge], for everyone who
/// draws from it.
///
/// **Kept alive, and made to exist by the shell**, never by the git column:
/// the column is built only while it is showing, and a reading that lived
/// there left a space opened with it shut with no git at all. Everything
/// that writes to the repository ends in [refresh], so what the window
/// believes has one source and one way to mend.

abstract class _$GitReadingNotifier extends $Notifier<GitReadingState> {
  GitReadingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GitReadingState, GitReadingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GitReadingState, GitReadingState>,
              GitReadingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

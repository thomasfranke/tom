// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where unexpected errors go: a no-op until a module overrides it
/// ([Decision 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).

@ProviderFor(observability)
final observabilityProvider = ObservabilityProvider._();

/// Where unexpected errors go: a no-op until a module overrides it
/// ([Decision 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).

final class ObservabilityProvider
    extends $FunctionalProvider<Observability, Observability, Observability>
    with $Provider<Observability> {
  /// Where unexpected errors go: a no-op until a module overrides it
  /// ([Decision 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
  ObservabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'observabilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$observabilityHash();

  @$internal
  @override
  $ProviderElement<Observability> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Observability create(Ref ref) {
    return observability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Observability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Observability>(value),
    );
  }
}

String _$observabilityHash() => r'e73188f30469fceda69cec07b25f099649d1118b';

/// Where every process the app runs is written down: the commands panel's
/// own list, kept for the session ([Decision
/// 36](../../../../../docs/technical/decisions/036-every-command-is-written-down.md)).

@ProviderFor(commandLog)
final commandLogProvider = CommandLogProvider._();

/// Where every process the app runs is written down: the commands panel's
/// own list, kept for the session ([Decision
/// 36](../../../../../docs/technical/decisions/036-every-command-is-written-down.md)).

final class CommandLogProvider
    extends $FunctionalProvider<CommandLog, CommandLog, CommandLog>
    with $Provider<CommandLog> {
  /// Where every process the app runs is written down: the commands panel's
  /// own list, kept for the session ([Decision
  /// 36](../../../../../docs/technical/decisions/036-every-command-is-written-down.md)).
  CommandLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commandLogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commandLogHash();

  @$internal
  @override
  $ProviderElement<CommandLog> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommandLog create(Ref ref) {
    return commandLog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommandLog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommandLog>(value),
    );
  }
}

String _$commandLogHash() => r'dc3f05ddf45ac790dfc50e69d4618462f74687a7';

/// What git and `gh` ask before they start: the same list, so a command is
/// one row before and after it runs ([Decision
/// 38](../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).

@ProviderFor(commandGate)
final commandGateProvider = CommandGateProvider._();

/// What git and `gh` ask before they start: the same list, so a command is
/// one row before and after it runs ([Decision
/// 38](../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).

final class CommandGateProvider
    extends $FunctionalProvider<CommandGate, CommandGate, CommandGate>
    with $Provider<CommandGate> {
  /// What git and `gh` ask before they start: the same list, so a command is
  /// one row before and after it runs ([Decision
  /// 38](../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
  CommandGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commandGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commandGateHash();

  @$internal
  @override
  $ProviderElement<CommandGate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommandGate create(Ref ref) {
    return commandGate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommandGate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommandGate>(value),
    );
  }
}

String _$commandGateHash() => r'cd3f98e4db3ba09d961acb36d9ffdfb5555681fe';

/// Reading and writing files.

@ProviderFor(filesystem)
final filesystemProvider = FilesystemProvider._();

/// Reading and writing files.

final class FilesystemProvider
    extends $FunctionalProvider<Filesystem, Filesystem, Filesystem>
    with $Provider<Filesystem> {
  /// Reading and writing files.
  FilesystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filesystemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filesystemHash();

  @$internal
  @override
  $ProviderElement<Filesystem> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Filesystem create(Ref ref) {
    return filesystem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Filesystem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Filesystem>(value),
    );
  }
}

String _$filesystemHash() => r'1a4248bf6a67aa5d464587e1e0c9e525093b0be0';

/// How to get a git client for a folder.
///
/// App lifetime, but what it builds is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([composition](../../../../../docs/technical/runtime/composition.md)).

@ProviderFor(gitClientFor)
final gitClientForProvider = GitClientForProvider._();

/// How to get a git client for a folder.
///
/// App lifetime, but what it builds is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([composition](../../../../../docs/technical/runtime/composition.md)).

final class GitClientForProvider
    extends $FunctionalProvider<GitClientFor, GitClientFor, GitClientFor>
    with $Provider<GitClientFor> {
  /// How to get a git client for a folder.
  ///
  /// App lifetime, but what it builds is per folder: a client holds the
  /// directory its commands run in and the queue that serializes them
  /// ([composition](../../../../../docs/technical/runtime/composition.md)).
  GitClientForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gitClientForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gitClientForHash();

  @$internal
  @override
  $ProviderElement<GitClientFor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GitClientFor create(Ref ref) {
    return gitClientFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GitClientFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GitClientFor>(value),
    );
  }
}

String _$gitClientForHash() => r'e92f5fb0737757b510ea2fdab63c6e6b9b297ced';

/// What this platform calls its folders.

@ProviderFor(platformPaths)
final platformPathsProvider = PlatformPathsProvider._();

/// What this platform calls its folders.

final class PlatformPathsProvider
    extends $FunctionalProvider<PlatformPaths, PlatformPaths, PlatformPaths>
    with $Provider<PlatformPaths> {
  /// What this platform calls its folders.
  PlatformPathsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformPathsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformPathsHash();

  @$internal
  @override
  $ProviderElement<PlatformPaths> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlatformPaths create(Ref ref) {
    return platformPaths(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlatformPaths value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlatformPaths>(value),
    );
  }
}

String _$platformPathsHash() => r'e68b7ff10e441ba5eb21d528dbcb654f27baef16';

/// The folder this platform keeps the app's own files in.
///
/// The throw is deliberate and belongs here: a machine that names no folder
/// for an app's files is one TOM cannot run on, and deciding that is the
/// composition root's call, not a capability's.

@ProviderFor(applicationData)
final applicationDataProvider = ApplicationDataProvider._();

/// The folder this platform keeps the app's own files in.
///
/// The throw is deliberate and belongs here: a machine that names no folder
/// for an app's files is one TOM cannot run on, and deciding that is the
/// composition root's call, not a capability's.

final class ApplicationDataProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The folder this platform keeps the app's own files in.
  ///
  /// The throw is deliberate and belongs here: a machine that names no folder
  /// for an app's files is one TOM cannot run on, and deciding that is the
  /// composition root's call, not a capability's.
  ApplicationDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationDataHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return applicationData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$applicationDataHash() => r'5a67aec18564b3f68e4f42152fa1d0736294810b';

/// Per-machine preferences, one JSON file in the platform's app-data folder.

@ProviderFor(settings)
final settingsProvider = SettingsProvider._();

/// Per-machine preferences, one JSON file in the platform's app-data folder.

final class SettingsProvider
    extends $FunctionalProvider<Settings, Settings, Settings>
    with $Provider<Settings> {
  /// Per-machine preferences, one JSON file in the platform's app-data folder.
  SettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  $ProviderElement<Settings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Settings create(Ref ref) {
    return settings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Settings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Settings>(value),
    );
  }
}

String _$settingsHash() => r'7a7a97ce6ce449489408f533b5ab9ddd78174f26';

/// How to reach the preferences file as a document: the same documents,
/// rooted in the folder the settings store writes it in, whatever space is
/// open (`docs/product/preferences/where-it-is-stored/doc.md`).

@ProviderFor(preferencesFolderFor)
final preferencesFolderForProvider = PreferencesFolderForProvider._();

/// How to reach the preferences file as a document: the same documents,
/// rooted in the folder the settings store writes it in, whatever space is
/// open (`docs/product/preferences/where-it-is-stored/doc.md`).

final class PreferencesFolderForProvider
    extends
        $FunctionalProvider<
          DocumentRepositoryFor,
          DocumentRepositoryFor,
          DocumentRepositoryFor
        >
    with $Provider<DocumentRepositoryFor> {
  /// How to reach the preferences file as a document: the same documents,
  /// rooted in the folder the settings store writes it in, whatever space is
  /// open (`docs/product/preferences/where-it-is-stored/doc.md`).
  PreferencesFolderForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesFolderForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesFolderForHash();

  @$internal
  @override
  $ProviderElement<DocumentRepositoryFor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepositoryFor create(Ref ref) {
    return preferencesFolderFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepositoryFor>(value),
    );
  }
}

String _$preferencesFolderForHash() =>
    r'ebdc100ce933ca42aa2624cd8ea945700bccbdc1';

/// Which commands may run without asking: `git-approvals.json`, wherever
/// the preferences file is kept — so a run with its own folder has its own
/// list too.

@ProviderFor(approvalsRepository)
final approvalsRepositoryProvider = ApprovalsRepositoryProvider._();

/// Which commands may run without asking: `git-approvals.json`, wherever
/// the preferences file is kept — so a run with its own folder has its own
/// list too.

final class ApprovalsRepositoryProvider
    extends
        $FunctionalProvider<
          ApprovalsRepository,
          ApprovalsRepository,
          ApprovalsRepository
        >
    with $Provider<ApprovalsRepository> {
  /// Which commands may run without asking: `git-approvals.json`, wherever
  /// the preferences file is kept — so a run with its own folder has its own
  /// list too.
  ApprovalsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'approvalsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$approvalsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApprovalsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApprovalsRepository create(Ref ref) {
    return approvalsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApprovalsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApprovalsRepository>(value),
    );
  }
}

String _$approvalsRepositoryHash() =>
    r'd68d44cc73be876ba1e0036da335ef534ea1567c';

/// The platform's file manager and terminal.

@ProviderFor(desktopRepository)
final desktopRepositoryProvider = DesktopRepositoryProvider._();

/// The platform's file manager and terminal.

final class DesktopRepositoryProvider
    extends
        $FunctionalProvider<
          DesktopRepository,
          DesktopRepository,
          DesktopRepository
        >
    with $Provider<DesktopRepository> {
  /// The platform's file manager and terminal.
  DesktopRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'desktopRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$desktopRepositoryHash();

  @$internal
  @override
  $ProviderElement<DesktopRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DesktopRepository create(Ref ref) {
    return desktopRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DesktopRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DesktopRepository>(value),
    );
  }
}

String _$desktopRepositoryHash() => r'6da7708161a2637ba18b7a89ea35815759cee5ab';

/// The person's own shell, in a pseudo-terminal the plugin opens ([Decision
/// 37](../../../../../docs/technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).
///
/// No `CommandLog`: what somebody types into their shell is not what TOM ran.

@ProviderFor(terminalRepository)
final terminalRepositoryProvider = TerminalRepositoryProvider._();

/// The person's own shell, in a pseudo-terminal the plugin opens ([Decision
/// 37](../../../../../docs/technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).
///
/// No `CommandLog`: what somebody types into their shell is not what TOM ran.

final class TerminalRepositoryProvider
    extends
        $FunctionalProvider<
          TerminalRepository,
          TerminalRepository,
          TerminalRepository
        >
    with $Provider<TerminalRepository> {
  /// The person's own shell, in a pseudo-terminal the plugin opens ([Decision
  /// 37](../../../../../docs/technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).
  ///
  /// No `CommandLog`: what somebody types into their shell is not what TOM ran.
  TerminalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'terminalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$terminalRepositoryHash();

  @$internal
  @override
  $ProviderElement<TerminalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TerminalRepository create(Ref ref) {
    return terminalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TerminalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TerminalRepository>(value),
    );
  }
}

String _$terminalRepositoryHash() =>
    r'6f9c679ae7d3f7c058202027a32b728c3f1a0393';

/// The GitHub logins the machine's `gh`, git and `ssh` already hold.

@ProviderFor(credentials)
final credentialsProvider = CredentialsProvider._();

/// The GitHub logins the machine's `gh`, git and `ssh` already hold.

final class CredentialsProvider
    extends $FunctionalProvider<Credentials, Credentials, Credentials>
    with $Provider<Credentials> {
  /// The GitHub logins the machine's `gh`, git and `ssh` already hold.
  CredentialsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialsHash();

  @$internal
  @override
  $ProviderElement<Credentials> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Credentials create(Ref ref) {
    return credentials(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Credentials value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Credentials>(value),
    );
  }
}

String _$credentialsHash() => r'e616c8b03fc7c1864993d65c2317629fe46a79e1';

/// GitHub's API, asked through `gh` ([Decision
/// 35](../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).

@ProviderFor(githubApi)
final githubApiProvider = GithubApiProvider._();

/// GitHub's API, asked through `gh` ([Decision
/// 35](../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).

final class GithubApiProvider
    extends $FunctionalProvider<GithubApi, GithubApi, GithubApi>
    with $Provider<GithubApi> {
  /// GitHub's API, asked through `gh` ([Decision
  /// 35](../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
  GithubApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'githubApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$githubApiHash();

  @$internal
  @override
  $ProviderElement<GithubApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GithubApi create(Ref ref) {
    return githubApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GithubApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GithubApi>(value),
    );
  }
}

String _$githubApiHash() => r'1a03b9e1618ad1159ca4165f8c046d19e31bb83e';

/// How to reach the machine's GitHub accounts for a space, from its
/// repository.

@ProviderFor(githubAccountsFor)
final githubAccountsForProvider = GithubAccountsForProvider._();

/// How to reach the machine's GitHub accounts for a space, from its
/// repository.

final class GithubAccountsForProvider
    extends
        $FunctionalProvider<
          GithubAccountRepositoryFor,
          GithubAccountRepositoryFor,
          GithubAccountRepositoryFor
        >
    with $Provider<GithubAccountRepositoryFor> {
  /// How to reach the machine's GitHub accounts for a space, from its
  /// repository.
  GithubAccountsForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'githubAccountsForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$githubAccountsForHash();

  @$internal
  @override
  $ProviderElement<GithubAccountRepositoryFor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GithubAccountRepositoryFor create(Ref ref) {
    return githubAccountsFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GithubAccountRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GithubAccountRepositoryFor>(value),
    );
  }
}

String _$githubAccountsForHash() => r'facac31659786c2c6aef9666f0d963875a8e5f83';

/// How to reach a space's pull requests on its host: `gh`, run from the
/// repository, as the account's own token ([Decision
/// 35](../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).

@ProviderFor(pullRequestHostFor)
final pullRequestHostForProvider = PullRequestHostForProvider._();

/// How to reach a space's pull requests on its host: `gh`, run from the
/// repository, as the account's own token ([Decision
/// 35](../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).

final class PullRequestHostForProvider
    extends
        $FunctionalProvider<
          PullRequestHostRepositoryFor,
          PullRequestHostRepositoryFor,
          PullRequestHostRepositoryFor
        >
    with $Provider<PullRequestHostRepositoryFor> {
  /// How to reach a space's pull requests on its host: `gh`, run from the
  /// repository, as the account's own token ([Decision
  /// 35](../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
  PullRequestHostForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pullRequestHostForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pullRequestHostForHash();

  @$internal
  @override
  $ProviderElement<PullRequestHostRepositoryFor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PullRequestHostRepositoryFor create(Ref ref) {
    return pullRequestHostFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PullRequestHostRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PullRequestHostRepositoryFor>(value),
    );
  }
}

String _$pullRequestHostForHash() =>
    r'd2f38719ccbc625172b2957081e958713be45ddd';

/// The person's home folder: where git and the credential helper are asked
/// with no space open, so they answer from the global config alone.

@ProviderFor(userHome)
final userHomeProvider = UserHomeProvider._();

/// The person's home folder: where git and the credential helper are asked
/// with no space open, so they answer from the global config alone.

final class UserHomeProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The person's home folder: where git and the credential helper are asked
  /// with no space open, so they answer from the global config alone.
  UserHomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userHomeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userHomeHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return userHome(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userHomeHash() => r'7432698f64a07bd5a5aecca9bdd7f27bf5d427b5';

/// The folders spaces are made of.

@ProviderFor(spaceRepository)
final spaceRepositoryProvider = SpaceRepositoryProvider._();

/// The folders spaces are made of.

final class SpaceRepositoryProvider
    extends
        $FunctionalProvider<SpaceRepository, SpaceRepository, SpaceRepository>
    with $Provider<SpaceRepository> {
  /// The folders spaces are made of.
  SpaceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<SpaceRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpaceRepository create(Ref ref) {
    return spaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceRepository>(value),
    );
  }
}

String _$spaceRepositoryHash() => r'6fd24995c6baf79245228f8b7c1bd58f7d20393c';

/// The spaces Home offers to go back to.

@ProviderFor(recentSpacesRepository)
final recentSpacesRepositoryProvider = RecentSpacesRepositoryProvider._();

/// The spaces Home offers to go back to.

final class RecentSpacesRepositoryProvider
    extends
        $FunctionalProvider<
          RecentSpacesRepository,
          RecentSpacesRepository,
          RecentSpacesRepository
        >
    with $Provider<RecentSpacesRepository> {
  /// The spaces Home offers to go back to.
  RecentSpacesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSpacesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSpacesRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecentSpacesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecentSpacesRepository create(Ref ref) {
    return recentSpacesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecentSpacesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecentSpacesRepository>(value),
    );
  }
}

String _$recentSpacesRepositoryHash() =>
    r'5661f76eeb1090b4ec05139ce031b53221146bbf';

/// What the machine remembers about how the app looks and speaks.

@ProviderFor(preferencesRepository)
final preferencesRepositoryProvider = PreferencesRepositoryProvider._();

/// What the machine remembers about how the app looks and speaks.

final class PreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          PreferencesRepository,
          PreferencesRepository,
          PreferencesRepository
        >
    with $Provider<PreferencesRepository> {
  /// What the machine remembers about how the app looks and speaks.
  PreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PreferencesRepository create(Ref ref) {
    return preferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesRepository>(value),
    );
  }
}

String _$preferencesRepositoryHash() =>
    r'0217eb3736b7493b0faac01f5bd4a22943107db0';

/// How to reach the documents of a space.
///
/// A repository is per space and the space is picked at runtime, so what is
/// app-wide is the way to build one.

@ProviderFor(documentRepositoryFor)
final documentRepositoryForProvider = DocumentRepositoryForProvider._();

/// How to reach the documents of a space.
///
/// A repository is per space and the space is picked at runtime, so what is
/// app-wide is the way to build one.

final class DocumentRepositoryForProvider
    extends
        $FunctionalProvider<
          DocumentRepositoryFor,
          DocumentRepositoryFor,
          DocumentRepositoryFor
        >
    with $Provider<DocumentRepositoryFor> {
  /// How to reach the documents of a space.
  ///
  /// A repository is per space and the space is picked at runtime, so what is
  /// app-wide is the way to build one.
  DocumentRepositoryForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentRepositoryForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentRepositoryForHash();

  @$internal
  @override
  $ProviderElement<DocumentRepositoryFor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepositoryFor create(Ref ref) {
    return documentRepositoryFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepositoryFor>(value),
    );
  }
}

String _$documentRepositoryForHash() =>
    r'd00a4b14beb0fc0ee5be2402c68ce4ae8ccd1ab9';

/// How to reach the pull request drafts of a space: the same documents,
/// rooted in `<git directory>/tom/pull-request/` instead of the space
/// ([Decision 33](../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).

@ProviderFor(pullRequestDraftsFor)
final pullRequestDraftsForProvider = PullRequestDraftsForProvider._();

/// How to reach the pull request drafts of a space: the same documents,
/// rooted in `<git directory>/tom/pull-request/` instead of the space
/// ([Decision 33](../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).

final class PullRequestDraftsForProvider
    extends
        $FunctionalProvider<
          DocumentRepositoryFor,
          DocumentRepositoryFor,
          DocumentRepositoryFor
        >
    with $Provider<DocumentRepositoryFor> {
  /// How to reach the pull request drafts of a space: the same documents,
  /// rooted in `<git directory>/tom/pull-request/` instead of the space
  /// ([Decision 33](../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
  PullRequestDraftsForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pullRequestDraftsForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pullRequestDraftsForHash();

  @$internal
  @override
  $ProviderElement<DocumentRepositoryFor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepositoryFor create(Ref ref) {
    return pullRequestDraftsFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepositoryFor>(value),
    );
  }
}

String _$pullRequestDraftsForHash() =>
    r'84523c497fcb046cde2b81e19bebb9a25a176f3c';

/// How to reach git for a space; per space for the same reason
/// [documentRepositoryFor] is.
///
/// A space with no repository is never asked about — presentation gates on
/// `hasRepository` — so its folder here only keeps a slip honest: git there
/// answers *not a repository*.

@ProviderFor(gitRepositoryFor)
final gitRepositoryForProvider = GitRepositoryForProvider._();

/// How to reach git for a space; per space for the same reason
/// [documentRepositoryFor] is.
///
/// A space with no repository is never asked about — presentation gates on
/// `hasRepository` — so its folder here only keeps a slip honest: git there
/// answers *not a repository*.

final class GitRepositoryForProvider
    extends
        $FunctionalProvider<
          GitRepositoryFor,
          GitRepositoryFor,
          GitRepositoryFor
        >
    with $Provider<GitRepositoryFor> {
  /// How to reach git for a space; per space for the same reason
  /// [documentRepositoryFor] is.
  ///
  /// A space with no repository is never asked about — presentation gates on
  /// `hasRepository` — so its folder here only keeps a slip honest: git there
  /// answers *not a repository*.
  GitRepositoryForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gitRepositoryForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gitRepositoryForHash();

  @$internal
  @override
  $ProviderElement<GitRepositoryFor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GitRepositoryFor create(Ref ref) {
    return gitRepositoryFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GitRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GitRepositoryFor>(value),
    );
  }
}

String _$gitRepositoryForHash() => r'797fd20c62352bfc46a49611ca6f3fab215aaca9';

/// How to reach the search index of a space.
///
/// One index per space and the same one every time, because an index holds
/// an open database and a fresh one would be empty — which is a search that
/// silently finds nothing. Closed with the app, since it is in memory
/// ([search](../../../../../docs/technical/runtime/search.md)).

@ProviderFor(searchRepositoryFor)
final searchRepositoryForProvider = SearchRepositoryForProvider._();

/// How to reach the search index of a space.
///
/// One index per space and the same one every time, because an index holds
/// an open database and a fresh one would be empty — which is a search that
/// silently finds nothing. Closed with the app, since it is in memory
/// ([search](../../../../../docs/technical/runtime/search.md)).

final class SearchRepositoryForProvider
    extends
        $FunctionalProvider<
          SearchRepositoryFor,
          SearchRepositoryFor,
          SearchRepositoryFor
        >
    with $Provider<SearchRepositoryFor> {
  /// How to reach the search index of a space.
  ///
  /// One index per space and the same one every time, because an index holds
  /// an open database and a fresh one would be empty — which is a search that
  /// silently finds nothing. Closed with the app, since it is in memory
  /// ([search](../../../../../docs/technical/runtime/search.md)).
  SearchRepositoryForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryForHash();

  @$internal
  @override
  $ProviderElement<SearchRepositoryFor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchRepositoryFor create(Ref ref) {
    return searchRepositoryFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepositoryFor>(value),
    );
  }
}

String _$searchRepositoryForHash() =>
    r'95c0a90021096ad1ab5a18ece4688e85ad18a853';

/// What splits a document into blocks.

@ProviderFor(blockReader)
final blockReaderProvider = BlockReaderProvider._();

/// What splits a document into blocks.

final class BlockReaderProvider
    extends
        $FunctionalProvider<BlockReaderPort, BlockReaderPort, BlockReaderPort>
    with $Provider<BlockReaderPort> {
  /// What splits a document into blocks.
  BlockReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockReaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockReaderHash();

  @$internal
  @override
  $ProviderElement<BlockReaderPort> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BlockReaderPort create(Ref ref) {
    return blockReader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlockReaderPort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlockReaderPort>(value),
    );
  }
}

String _$blockReaderHash() => r'cc3900403c3cedc679d2a596f456b0289f048cbc';

/// What tells two versions of a document apart, block by block.

@ProviderFor(blockDiffer)
final blockDifferProvider = BlockDifferProvider._();

/// What tells two versions of a document apart, block by block.

final class BlockDifferProvider
    extends
        $FunctionalProvider<
          BlockDifferService,
          BlockDifferService,
          BlockDifferService
        >
    with $Provider<BlockDifferService> {
  /// What tells two versions of a document apart, block by block.
  BlockDifferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockDifferProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockDifferHash();

  @$internal
  @override
  $ProviderElement<BlockDifferService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BlockDifferService create(Ref ref) {
    return blockDiffer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlockDifferService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlockDifferService>(value),
    );
  }
}

String _$blockDifferHash() => r'ac9901d4e6782f9392343d3247255351f91b8588';

/// What tells two versions of a file apart, line by line.

@ProviderFor(lineDiffer)
final lineDifferProvider = LineDifferProvider._();

/// What tells two versions of a file apart, line by line.

final class LineDifferProvider
    extends
        $FunctionalProvider<
          LineDifferService,
          LineDifferService,
          LineDifferService
        >
    with $Provider<LineDifferService> {
  /// What tells two versions of a file apart, line by line.
  LineDifferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineDifferProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineDifferHash();

  @$internal
  @override
  $ProviderElement<LineDifferService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LineDifferService create(Ref ref) {
    return lineDiffer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineDifferService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineDifferService>(value),
    );
  }
}

String _$lineDifferHash() => r'697f4a7b48cf2d580ee8b125fb6b94bf087cf01a';

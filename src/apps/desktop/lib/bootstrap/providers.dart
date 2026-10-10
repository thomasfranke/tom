/// The object graph, wired.
library;

import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_desktop/bootstrap/bundled_faces_pdf_exporter.dart';
import 'package:tom_desktop/bootstrap/flutter_pty_pseudo_terminal_process_impl.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';

part 'providers.g.dart';

/// Where unexpected errors go: a no-op until a module overrides it
/// ([Decision 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
@Riverpod(keepAlive: true)
Observability observability(Ref ref) => const _SilentObservabilityImpl();

/// Where every process the app runs is written down: the commands panel's
/// own list, kept for the session ([Decision
/// 36](../../../../../docs/technical/decisions/036-every-command-is-written-down.md)).
@Riverpod(keepAlive: true)
CommandLog commandLog(Ref ref) => ref.watch(commandsProvider.notifier);

/// What git and `gh` ask before they start: the same list, so a command is
/// one row before and after it runs ([Decision
/// 38](../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
@Riverpod(keepAlive: true)
CommandGate commandGate(Ref ref) => ref.watch(commandsProvider.notifier);

/// Reading and writing files.
@Riverpod(keepAlive: true)
Filesystem filesystem(Ref ref) => const DartIoFilesystemImpl();

/// How to get a git client for a folder.
///
/// App lifetime, but what it builds is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([composition](../../../../../docs/technical/runtime/composition.md)).
@Riverpod(keepAlive: true)
GitClientFor gitClientFor(Ref ref) {
  final CommandLog log = ref.watch(commandLogProvider);
  final CommandGate gate = ref.watch(commandGateProvider);
  return (String folder) => DartIoGitClientImpl(
    workingDirectory: folder,
    commandLog: log,
    commandGate: gate,
  );
}

/// What this platform calls its folders.
@Riverpod(keepAlive: true)
PlatformPaths platformPaths(Ref ref) => const DartIoPlatformPathsImpl();

/// The preferences file's name, in the platform's app-data folder.
const String preferencesFileName = 'preferences.json';

/// Every command that asks the gate, by key, in the order the file lists
/// them: git's, then `gh`'s, then what reads a login — gathered here because
/// only the composition root sees every capability.
final List<String> gatedCommandKeys = List<String>.unmodifiable(<String>[
  for (final CommandKey key in <CommandKey>[
    ...GitCommandKeyEnum.values,
    ...GithubCommandKeyEnum.values,
    ...CredentialsCommandKeyEnum.values,
  ])
    key.template,
]);

/// The folder this platform keeps the app's own files in.
///
/// The throw is deliberate and belongs here: a machine that names no folder
/// for an app's files is one TOM cannot run on, and deciding that is the
/// composition root's call, not a capability's.
@Riverpod(keepAlive: true)
String applicationData(Ref ref) => switch (ref
    .watch(platformPathsProvider)
    .applicationData()) {
  Success<String, PlatformPathsFailure>(value: final String folder) => folder,
  Failure<String, PlatformPathsFailure>(
    failure: final PlatformPathsFailure failure,
  ) =>
    throw StateError('TOM cannot start on this machine: $failure'),
};

/// Per-machine preferences, one JSON file in the platform's app-data folder.
@Riverpod(keepAlive: true)
Settings settings(Ref ref) => JsonFileSettingsImpl(
  filesystem: ref.watch(filesystemProvider),
  path: '${ref.watch(applicationDataProvider)}/$preferencesFileName',
);

/// The file [settings] keeps, wherever that is — the real app-data folder,
/// or a run's own — read from the store so the two can never disagree.
File _fileOf(Settings settings) => switch (settings) {
  JsonFileSettingsImpl(:final String path) => File(path),
  _ => throw StateError('the preferences are kept in no file: $settings'),
};

/// How to reach the preferences file as a document: the same documents,
/// rooted in the folder the settings store writes it in, whatever space is
/// open (`docs/product/preferences/where-it-is-stored/doc.md`).
@Riverpod(keepAlive: true)
DocumentRepositoryFor preferencesFolderFor(Ref ref) {
  final DocumentRepositoryImpl folder = DocumentRepositoryImpl(
    documents: DocumentDataSource(filesystem: ref.watch(filesystemProvider)),
    root: _fileOf(ref.watch(settingsProvider)).parent.path,
  );
  return (SpaceEntity _) => folder;
}

/// Which commands may run without asking: `git-approvals.json`, wherever
/// the preferences file is kept — so a run with its own folder has its own
/// list too.
@Riverpod(keepAlive: true)
ApprovalsRepository approvalsRepository(Ref ref) => ApprovalsRepositoryImpl(
  source: ApprovalsDataSource(
    filesystem: ref.watch(filesystemProvider),
    path:
        '${_fileOf(ref.watch(settingsProvider)).parent.path}'
        '${Platform.pathSeparator}${ApprovalsRepository.fileName}',
  ),
  keys: gatedCommandKeys,
);

/// The platform's file manager and terminal.
@Riverpod(keepAlive: true)
DesktopRepository desktopRepository(Ref ref) => DesktopRepositoryImpl(
  source: DesktopDataSource(
    shell: DartIoDesktopShellImpl(commandLog: ref.watch(commandLogProvider)),
  ),
);

/// The person's own shell, in a pseudo-terminal the plugin opens ([Decision
/// 37](../../../../../docs/technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).
///
/// No `CommandLog`: what somebody types into their shell is not what TOM ran.
@Riverpod(keepAlive: true)
TerminalRepository terminalRepository(Ref ref) => TerminalRepositoryImpl(
  source: TerminalDataSource(
    terminal: LoginShellPseudoTerminalImpl(
      spawn: FlutterPtyPseudoTerminalProcessImpl.spawn,
    ),
  ),
);

/// The GitHub logins the machine's `gh`, git and `ssh` already hold.
@Riverpod(keepAlive: true)
Credentials credentials(Ref ref) => CommandLineCredentialsImpl(
  commandLog: ref.watch(commandLogProvider),
  commandGate: ref.watch(commandGateProvider),
);

/// GitHub's API, asked through `gh` ([Decision
/// 35](../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
@Riverpod(keepAlive: true)
GithubApi githubApi(Ref ref) => GhCliGithubApiImpl(
  commandLog: ref.watch(commandLogProvider),
  commandGate: ref.watch(commandGateProvider),
);

/// The machine's GitHub accounts as git's credential helper sees them from
/// [folder] — a repository may have a helper of its own.
GithubAccountRepository _githubAccountsIn(Ref ref, String folder) =>
    GithubAccountRepositoryImpl(
      credentials: CredentialsDataSource(
        credentials: ref.watch(credentialsProvider),
        folder: folder,
      ),
      api: GithubApiDataSource(api: ref.watch(githubApiProvider)),
    );

/// How to reach the machine's GitHub accounts for a space, from its
/// repository.
@Riverpod(keepAlive: true)
GithubAccountRepositoryFor githubAccountsFor(Ref ref) {
  final Credentials held = ref.watch(credentialsProvider);
  final GithubApiDataSource api = GithubApiDataSource(
    api: ref.watch(githubApiProvider),
  );
  return (SpaceEntity space) => GithubAccountRepositoryImpl(
    credentials: CredentialsDataSource(
      credentials: held,
      folder: space.repositoryRoot ?? space.root,
    ),
    api: api,
  );
}

/// How to reach a space's pull requests on its host: `gh`, run from the
/// repository, as the account's own token ([Decision
/// 35](../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
@Riverpod(keepAlive: true)
PullRequestHostRepositoryFor pullRequestHostFor(Ref ref) {
  final Credentials held = ref.watch(credentialsProvider);
  final GithubApiDataSource api = GithubApiDataSource(
    api: ref.watch(githubApiProvider),
  );
  return (SpaceEntity space) => PullRequestHostRepositoryImpl(
    tokens: GithubTokenReader(
      credentials: CredentialsDataSource(
        credentials: held,
        folder: space.repositoryRoot ?? space.root,
      ),
    ),
    api: api,
    folder: space.repositoryRoot ?? space.root,
  );
}

/// The person's home folder: where git and the credential helper are asked
/// with no space open, so they answer from the global config alone.
@Riverpod(keepAlive: true)
String userHome(Ref ref) =>
    Platform.environment['HOME'] ??
    Platform.environment['USERPROFILE'] ??
    Directory.systemTemp.path;

/// The folders spaces are made of.
@Riverpod(keepAlive: true)
SpaceRepository spaceRepository(Ref ref) => SpaceRepositoryImpl(
  spaces: SpaceDataSource(
    filesystem: ref.watch(filesystemProvider),
    gitClientFor: ref.watch(gitClientForProvider),
  ),
);

/// The spaces Home offers to go back to.
@Riverpod(keepAlive: true)
RecentSpacesRepository recentSpacesRepository(Ref ref) =>
    RecentSpacesRepositoryImpl(
      recents: RecentSpacesDataSource(settings: ref.watch(settingsProvider)),
      observability: ref.watch(observabilityProvider),
    );

/// What the machine remembers about how the app looks and speaks.
@Riverpod(keepAlive: true)
PreferencesRepository preferencesRepository(Ref ref) =>
    PreferencesRepositoryImpl(
      source: PreferencesDataSource(settings: ref.watch(settingsProvider)),
    );

/// How to reach the documents of a space.
///
/// A repository is per space and the space is picked at runtime, so what is
/// app-wide is the way to build one.
@Riverpod(keepAlive: true)
DocumentRepositoryFor documentRepositoryFor(Ref ref) {
  final DocumentDataSource documents = DocumentDataSource(
    filesystem: ref.watch(filesystemProvider),
  );
  return (SpaceEntity space) =>
      DocumentRepositoryImpl(documents: documents, root: space.root);
}

/// How to reach the pull request drafts of a space: the same documents,
/// rooted in `<git directory>/tom/pull-request/` instead of the space
/// ([Decision 33](../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
@Riverpod(keepAlive: true)
DocumentRepositoryFor pullRequestDraftsFor(Ref ref) {
  final DocumentDataSource documents = DocumentDataSource(
    filesystem: ref.watch(filesystemProvider),
  );
  final GitRepositoryFor gitFor = ref.watch(gitRepositoryForProvider);
  return (SpaceEntity space) =>
      PullRequestDraftRepositoryImpl(git: gitFor(space), documents: documents);
}

/// How to reach git for a space; per space for the same reason
/// [documentRepositoryFor] is.
///
/// A space with no repository is never asked about — presentation gates on
/// `hasRepository` — so its folder here only keeps a slip honest: git there
/// answers *not a repository*.
@Riverpod(keepAlive: true)
GitRepositoryFor gitRepositoryFor(Ref ref) {
  final GitClientFor clients = ref.watch(gitClientForProvider);
  return (SpaceEntity space) => GitRepositoryImpl(
    git: GitDataSource(client: clients(space.repositoryRoot ?? space.root)),
  );
}

/// How to reach the search index of a space.
///
/// One index per space and the same one every time, because an index holds
/// an open database and a fresh one would be empty — which is a search that
/// silently finds nothing. Closed with the app, since it is in memory
/// ([search](../../../../../docs/technical/runtime/search.md)).
@Riverpod(keepAlive: true)
SearchRepositoryFor searchRepositoryFor(Ref ref) {
  final DocumentDataSource documents = DocumentDataSource(
    filesystem: ref.watch(filesystemProvider),
  );
  final Map<String, SearchDataSource> indexes = <String, SearchDataSource>{};
  ref.onDispose(() {
    for (final SearchDataSource held in indexes.values) {
      held.index.dispose();
    }
  });
  return (SpaceEntity space) => SearchRepositoryImpl(
    search: indexes.putIfAbsent(
      space.root,
      () => SearchDataSource(index: Sqlite3SearchIndexImpl()),
    ),
    documents: documents,
    space: space,
  );
}

/// What splits a document into blocks.
@Riverpod(keepAlive: true)
BlockReaderPort blockReader(Ref ref) => const MarkdownBlockReaderImpl(
  markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
);

/// What tells two versions of a document apart, block by block.
@Riverpod(keepAlive: true)
BlockDifferService blockDiffer(Ref ref) => const BlockDifferService(
  aligner: TextDifferBlockAlignerImpl(
    differ: TextDifferDataSource(differ: DiffutilTextDifferImpl()),
  ),
);

/// What tells two versions of a file apart, line by line.
@Riverpod(keepAlive: true)
LineDifferService lineDiffer(Ref ref) => const LineDifferService(
  aligner: TextDifferLineAlignerImpl(
    differ: TextDifferDataSource(differ: DiffutilTextDifferImpl()),
  ),
);

/// The overrides that turn the contracts above into the app's own wiring.
///
/// `tom_presentation` declares the use cases it needs and cannot see what
/// satisfies them; this is the one place that does.
List<Override> appOverrides = <Override>[
  openSpaceProvider.overrideWith(
    (Ref ref) => OpenSpaceUseCase(
      spaces: ref.watch(spaceRepositoryProvider),
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  listRecentSpacesProvider.overrideWith(
    (Ref ref) => ListRecentSpacesUseCase(
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  forgetRecentSpaceProvider.overrideWith(
    (Ref ref) => ForgetRecentSpaceUseCase(
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readRecentBranchProvider.overrideWith(
    (Ref ref) => ReadRecentBranchUseCase(
      branches: RecentBranchRepositoryImpl(
        branches: RecentBranchDataSource(
          gitClientFor: ref.watch(gitClientForProvider),
        ),
        observability: ref.watch(observabilityProvider),
      ),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  // One clone for the app: before it there is no space to hang it from.
  cloneRepositoryProvider.overrideWith(
    (Ref ref) => CloneRepositoryUseCase(
      cloner: GitCloneRepositoryImpl(
        git: GitCloneDataSource(
          gitClientFor: ref.watch(gitClientForProvider),
          filesystem: ref.watch(filesystemProvider),
        ),
      ),
      openSpace: ref.watch(openSpaceProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  listSpaceEntriesProvider.overrideWith(
    (Ref ref) => ListSpaceEntriesUseCase(
      spaces: ref.watch(spaceRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readPreferencesProvider.overrideWith(
    (Ref ref) => ReadPreferencesUseCase(
      preferences: ref.watch(preferencesRepositoryProvider),
    ),
  ),
  writePreferencesProvider.overrideWith(
    (Ref ref) => WritePreferencesUseCase(
      preferences: ref.watch(preferencesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  preferencesFileProvider.overrideWith(
    (Ref ref) => SpaceRelativePathValueObject(
      _fileOf(ref.watch(settingsProvider)).uri.pathSegments.last,
    ),
  ),
  readPreferencesFileProvider.overrideWith(
    (Ref ref) => ReadDocumentUseCase(
      documentsFor: ref.watch(preferencesFolderForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  savePreferencesFileProvider.overrideWith(
    (Ref ref) => SaveDocumentUseCase(
      documentsFor: ref.watch(preferencesFolderForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readApprovalsProvider.overrideWith(
    (Ref ref) =>
        ReadApprovalsUseCase(approvals: ref.watch(approvalsRepositoryProvider)),
  ),
  allowCommandProvider.overrideWith(
    (Ref ref) => AllowCommandUseCase(
      approvals: ref.watch(approvalsRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  seedApprovalsProvider.overrideWith(
    (Ref ref) => SeedApprovalsUseCase(
      approvals: ref.watch(approvalsRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readDocumentProvider.overrideWith(
    (Ref ref) => ReadDocumentUseCase(
      documentsFor: ref.watch(documentRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readFileProvider.overrideWith(
    (Ref ref) => ReadFileUseCase(
      documentsFor: ref.watch(documentRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readCommittedFileProvider.overrideWith(
    (Ref ref) => ReadCommittedFileUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  diffLinesProvider.overrideWith(
    (Ref ref) => DiffLinesUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      differ: ref.watch(lineDifferProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  saveDocumentProvider.overrideWith(
    (Ref ref) => SaveDocumentUseCase(
      documentsFor: ref.watch(documentRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  createDocumentProvider.overrideWith(
    (Ref ref) => CreateDocumentUseCase(
      documentsFor: ref.watch(documentRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  createFolderProvider.overrideWith(
    (Ref ref) => CreateFolderUseCase(
      spaces: ref.watch(spaceRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  revealFolderProvider.overrideWith(
    (Ref ref) => RevealFolderUseCase(
      desktop: ref.watch(desktopRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  discardAllChangesProvider.overrideWith(
    (Ref ref) => DiscardAllChangesUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  discardChangeProvider.overrideWith(
    (Ref ref) => DiscardChangeUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  openTerminalProvider.overrideWith(
    (Ref ref) => OpenTerminalUseCase(
      desktop: ref.watch(desktopRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  startTerminalProvider.overrideWith(
    (Ref ref) => StartTerminalUseCase(
      terminals: ref.watch(terminalRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  homeFolderProvider.overrideWith((Ref ref) => ref.watch(userHomeProvider)),
  splitDocumentProvider.overrideWith(
    (Ref ref) => SplitDocumentUseCase(
      blocks: ref.watch(blockReaderProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  diffDocumentProvider.overrideWith(
    (Ref ref) => DiffDocumentUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      blocks: ref.watch(blockReaderProvider),
      differ: ref.watch(blockDifferProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readGitStatusProvider.overrideWith(
    (Ref ref) => ReadGitStatusUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  stageChangesProvider.overrideWith(
    (Ref ref) => StageChangesUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      documentsFor: ref.watch(documentRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  commitChangesProvider.overrideWith(
    (Ref ref) => CommitChangesUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  fetchRemoteProvider.overrideWith(
    (Ref ref) => FetchRemoteUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  pullRemoteProvider.overrideWith(
    (Ref ref) => PullRemoteUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readMergeStateProvider.overrideWith(
    (Ref ref) => ReadMergeStateUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  abortPullProvider.overrideWith(
    (Ref ref) => AbortPullUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  pushRemoteProvider.overrideWith(
    (Ref ref) => PushRemoteUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  listBranchesProvider.overrideWith(
    (Ref ref) => ListBranchesUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  switchBranchProvider.overrideWith(
    (Ref ref) => SwitchBranchUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readDiffBaseProvider.overrideWith(
    (Ref ref) => ReadDiffBaseUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readFileHistoryProvider.overrideWith(
    (Ref ref) => ReadFileHistoryUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readVersionProvider.overrideWith(
    (Ref ref) => ReadVersionUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  indexSpaceProvider.overrideWith(
    (Ref ref) => IndexSpaceUseCase(
      spaces: ref.watch(spaceRepositoryProvider),
      searchFor: ref.watch(searchRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  indexDocumentProvider.overrideWith(
    (Ref ref) => IndexDocumentUseCase(
      searchFor: ref.watch(searchRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  searchSpaceProvider.overrideWith(
    (Ref ref) => SearchSpaceUseCase(
      searchFor: ref.watch(searchRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  openPullRequestDraftProvider.overrideWith(
    (Ref ref) => OpenPullRequestDraftUseCase(
      draftsFor: ref.watch(pullRequestDraftsForProvider),
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  saveDraftProvider.overrideWith(
    (Ref ref) => SaveDocumentUseCase(
      documentsFor: ref.watch(pullRequestDraftsForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readPullRequestTargetProvider.overrideWith(
    (Ref ref) => ReadPullRequestTargetUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readBranchProposalProvider.overrideWith(
    (Ref ref) => ReadBranchProposalUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readBranchOverviewProvider.overrideWith(
    (Ref ref) => ReadBranchOverviewUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      blocks: ref.watch(blockReaderProvider),
      differ: ref.watch(blockDifferProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readOpenPullRequestProvider.overrideWith(
    (Ref ref) => ReadOpenPullRequestUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      accountsFor: ref.watch(githubAccountsForProvider),
      hostFor: ref.watch(pullRequestHostForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  createPullRequestProvider.overrideWith(
    (Ref ref) => CreatePullRequestUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      accountsFor: ref.watch(githubAccountsForProvider),
      hostFor: ref.watch(pullRequestHostForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  openUrlProvider.overrideWith(
    (Ref ref) => OpenUrlUseCase(
      desktop: ref.watch(desktopRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readAccountProvider.overrideWith(
    (Ref ref) => ReadAccountUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      accountsFor: ref.watch(githubAccountsForProvider),
      machineGit: GitRepositoryImpl(
        git: GitDataSource(
          client: ref.watch(gitClientForProvider)(ref.watch(userHomeProvider)),
        ),
      ),
      machineAccounts: _githubAccountsIn(ref, ref.watch(userHomeProvider)),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  chooseAccountProvider.overrideWith(
    (Ref ref) => ChooseAccountUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  exportDocumentProvider.overrideWith(
    (Ref ref) => ExportDocumentUseCase(
      exports: ExportRepositoryImpl(
        source: ExportDataSource(
          exporters: <ExporterFormatEnum, DocumentExporter>{
            ExporterFormatEnum.pdf: BundledFacesPdfExporter(),
            ExporterFormatEnum.html: const MarkdownHtmlDocumentExporterImpl(),
          },
          filesystem: ref.watch(filesystemProvider),
        ),
      ),
      observability: ref.watch(observabilityProvider),
    ),
  ),
];

/// The default [Observability]: discards everything, which is the point.
final class _SilentObservabilityImpl implements Observability {
  const _SilentObservabilityImpl();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}

/// The composition root's graph: every use case the presentation asks for is
/// built from the real repositories, and the seams the wiring owns keep
/// their promises.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late Directory temp;
  late ProviderContainer container;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('tom_providers_');
    container = ProviderContainer(
      overrides: <Override>[
        ...appOverrides,
        settingsProvider.overrideWith(
          (Ref ref) => JsonFileSettingsImpl(
            filesystem: ref.watch(filesystemProvider),
            path: '${temp.path}/app/preferences.json',
          ),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      temp.deleteSync(recursive: true);
    });
  });

  test('every use case the presentation reads is built by the root', () {
    final Map<String, (Object?, Matcher)> built = <String, (Object?, Matcher)>{
      'openSpace': (container.read(openSpaceProvider), isA<OpenSpaceUseCase>()),
      'listRecent': (
        container.read(listRecentSpacesProvider),
        isA<ListRecentSpacesUseCase>(),
      ),
      'forgetRecent': (
        container.read(forgetRecentSpaceProvider),
        isA<ForgetRecentSpaceUseCase>(),
      ),
      'readRecentBranch': (
        container.read(readRecentBranchProvider),
        isA<ReadRecentBranchUseCase>(),
      ),
      'clone': (
        container.read(cloneRepositoryProvider),
        isA<CloneRepositoryUseCase>(),
      ),
      'listEntries': (
        container.read(listSpaceEntriesProvider),
        isA<ListSpaceEntriesUseCase>(),
      ),
      'readPreferences': (
        container.read(readPreferencesProvider),
        isA<ReadPreferencesUseCase>(),
      ),
      'writePreferences': (
        container.read(writePreferencesProvider),
        isA<WritePreferencesUseCase>(),
      ),
      'readPreferencesFile': (
        container.read(readPreferencesFileProvider),
        isA<ReadDocumentUseCase>(),
      ),
      'savePreferencesFile': (
        container.read(savePreferencesFileProvider),
        isA<SaveDocumentUseCase>(),
      ),
      'readApprovals': (
        container.read(readApprovalsProvider),
        isA<ReadApprovalsUseCase>(),
      ),
      'allowCommand': (
        container.read(allowCommandProvider),
        isA<AllowCommandUseCase>(),
      ),
      'seedApprovals': (
        container.read(seedApprovalsProvider),
        isA<SeedApprovalsUseCase>(),
      ),
      'readDocument': (
        container.read(readDocumentProvider),
        isA<ReadDocumentUseCase>(),
      ),
      'readFile': (container.read(readFileProvider), isA<ReadFileUseCase>()),
      'readCommittedFile': (
        container.read(readCommittedFileProvider),
        isA<ReadCommittedFileUseCase>(),
      ),
      'diffLines': (container.read(diffLinesProvider), isA<DiffLinesUseCase>()),
      'saveDocument': (
        container.read(saveDocumentProvider),
        isA<SaveDocumentUseCase>(),
      ),
      'createDocument': (
        container.read(createDocumentProvider),
        isA<CreateDocumentUseCase>(),
      ),
      'createFolder': (
        container.read(createFolderProvider),
        isA<CreateFolderUseCase>(),
      ),
      'revealFolder': (
        container.read(revealFolderProvider),
        isA<RevealFolderUseCase>(),
      ),
      'discardAll': (
        container.read(discardAllChangesProvider),
        isA<DiscardAllChangesUseCase>(),
      ),
      'discardChange': (
        container.read(discardChangeProvider),
        isA<DiscardChangeUseCase>(),
      ),
      'openTerminal': (
        container.read(openTerminalProvider),
        isA<OpenTerminalUseCase>(),
      ),
      'startTerminal': (
        container.read(startTerminalProvider),
        isA<StartTerminalUseCase>(),
      ),
      'splitDocument': (
        container.read(splitDocumentProvider),
        isA<SplitDocumentUseCase>(),
      ),
      'diffDocument': (
        container.read(diffDocumentProvider),
        isA<DiffDocumentUseCase>(),
      ),
      'readGitStatus': (
        container.read(readGitStatusProvider),
        isA<ReadGitStatusUseCase>(),
      ),
      'stageChanges': (
        container.read(stageChangesProvider),
        isA<StageChangesUseCase>(),
      ),
      'commitChanges': (
        container.read(commitChangesProvider),
        isA<CommitChangesUseCase>(),
      ),
      'fetchRemote': (
        container.read(fetchRemoteProvider),
        isA<FetchRemoteUseCase>(),
      ),
      'pullRemote': (
        container.read(pullRemoteProvider),
        isA<PullRemoteUseCase>(),
      ),
      'readMergeState': (
        container.read(readMergeStateProvider),
        isA<ReadMergeStateUseCase>(),
      ),
      'abortPull': (container.read(abortPullProvider), isA<AbortPullUseCase>()),
      'pushRemote': (
        container.read(pushRemoteProvider),
        isA<PushRemoteUseCase>(),
      ),
      'listBranches': (
        container.read(listBranchesProvider),
        isA<ListBranchesUseCase>(),
      ),
      'switchBranch': (
        container.read(switchBranchProvider),
        isA<SwitchBranchUseCase>(),
      ),
      'readDiffBase': (
        container.read(readDiffBaseProvider),
        isA<ReadDiffBaseUseCase>(),
      ),
      'readFileHistory': (
        container.read(readFileHistoryProvider),
        isA<ReadFileHistoryUseCase>(),
      ),
      'readVersion': (
        container.read(readVersionProvider),
        isA<ReadVersionUseCase>(),
      ),
      'indexSpace': (
        container.read(indexSpaceProvider),
        isA<IndexSpaceUseCase>(),
      ),
      'indexDocument': (
        container.read(indexDocumentProvider),
        isA<IndexDocumentUseCase>(),
      ),
      'searchSpace': (
        container.read(searchSpaceProvider),
        isA<SearchSpaceUseCase>(),
      ),
      'openDraft': (
        container.read(openPullRequestDraftProvider),
        isA<OpenPullRequestDraftUseCase>(),
      ),
      'saveDraft': (
        container.read(saveDraftProvider),
        isA<SaveDocumentUseCase>(),
      ),
      'readTarget': (
        container.read(readPullRequestTargetProvider),
        isA<ReadPullRequestTargetUseCase>(),
      ),
      'readProposal': (
        container.read(readBranchProposalProvider),
        isA<ReadBranchProposalUseCase>(),
      ),
      'readOverview': (
        container.read(readBranchOverviewProvider),
        isA<ReadBranchOverviewUseCase>(),
      ),
      'readOpenPullRequest': (
        container.read(readOpenPullRequestProvider),
        isA<ReadOpenPullRequestUseCase>(),
      ),
      'createPullRequest': (
        container.read(createPullRequestProvider),
        isA<CreatePullRequestUseCase>(),
      ),
      'checkForUpdates': (
        container.read(checkForUpdatesProvider),
        isA<CheckForUpdatesUseCase>(),
      ),
      'openUrl': (container.read(openUrlProvider), isA<OpenUrlUseCase>()),
      'readAccount': (
        container.read(readAccountProvider),
        isA<ReadAccountUseCase>(),
      ),
      'chooseAccount': (
        container.read(chooseAccountProvider),
        isA<ChooseAccountUseCase>(),
      ),
      'exportDocument': (
        container.read(exportDocumentProvider),
        isA<ExportDocumentUseCase>(),
      ),
    };

    for (final MapEntry<String, (Object?, Matcher)> entry in built.entries) {
      expect(entry.value.$1, entry.value.$2, reason: entry.key);
    }
  });

  test(
    'the preferences file is addressed by its own name, beside the store',
    () {
      expect(
        container.read(preferencesFileProvider).value,
        preferencesFileName,
      );
      expect(
        container.read(homeFolderProvider),
        container.read(userHomeProvider),
      );
    },
  );

  test('the window closes through the app-wide closer', () {
    expect(
      container.read(windowCloserProvider),
      same(container.read(desktopWindowCloserProvider)),
    );
  });

  test('one git client per folder, kept', () {
    final GitClientFor clients = container.read(gitClientForProvider);
    expect(clients('/a'), same(clients('/a')));
    expect(clients('/a'), isNot(same(clients('/b'))));
  });

  test('the approvals list lives beside the preferences file', () async {
    expect(container.read(approvalsRepositoryProvider), isNotNull);
    expect(
      gatedCommandKeys,
      containsAll(<String>[
        for (final CommandKey key in GitCommandKeyEnum.values) key.template,
      ]),
    );
    expect(gatedCommandKeys.toSet(), hasLength(gatedCommandKeys.length));
  });

  test(
    'a repository for a folder with no repository falls back to the root',
    () {
      final SpaceEntity space = SpaceEntity(
        root: temp.path,
        repositoryRoot: null,
        name: 'loose',
      );
      expect(container.read(gitRepositoryForProvider)(space), isNotNull);
      expect(container.read(documentRepositoryForProvider)(space), isNotNull);
      expect(container.read(searchRepositoryForProvider)(space), isNotNull);
      expect(container.read(githubAccountsForProvider)(space), isNotNull);
      expect(container.read(pullRequestHostForProvider)(space), isNotNull);
      expect(container.read(pullRequestDraftsForProvider)(space), isNotNull);
      expect(
        container.read(pullRequestDraftsForProvider)(space),
        same(container.read(pullRequestDraftsForProvider)(space)),
      );
    },
  );

  test('the machine is asked for its git once and it is remembered', () async {
    final Directory folder = Directory('${temp.path}/plain')..createSync();
    final String path = folder.resolveSymbolicLinksSync();
    container.listen(commandsProvider, (_, _) {});
    final OpenSpaceUseCase open = container.read(openSpaceProvider);

    expect(await open.open(path), isA<Success<SpaceEntity, AppFailure>>());
    expect(await open.open(path), isA<Success<SpaceEntity, AppFailure>>());

    final int asked = container
        .read(commandsProvider)
        .rows
        .where((CommandRow row) => row.record.arguments.contains('--version'))
        .length;
    expect(asked, 1, reason: 'the second opening reuses what was said');
  });

  test('the app-wide capabilities are all built', () {
    expect(container.read(recentSpacesRepositoryProvider), isNotNull);
    expect(container.read(preferencesRepositoryProvider), isNotNull);
    expect(container.read(blockReaderProvider), isNotNull);
    expect(container.read(blockDifferProvider), isNotNull);
    expect(container.read(lineDifferProvider), isNotNull);
    expect(container.read(desktopRepositoryProvider), isNotNull);
    expect(container.read(terminalRepositoryProvider), isNotNull);
    expect(container.read(observabilityProvider), isNotNull);
    expect(container.read(commandLogProvider), isNotNull);
    expect(container.read(commandGateProvider), isNotNull);
    expect(container.read(platformPathsProvider), isNotNull);
  });

  test('the silent observability swallows what it is given', () async {
    await container
        .read(observabilityProvider)
        .capture(StateError('x'), StackTrace.current, layer: 'test');
  });
}

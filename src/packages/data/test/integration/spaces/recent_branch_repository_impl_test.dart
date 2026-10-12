/// A recent space's branch against real repositories, because the question
/// is what git says about a folder nobody has open.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String base;
  late _Observability observability;
  late RecentBranchRepositoryImpl repository;

  /// Runs git directly, to arrange what the repository is then asked about.
  void git(List<String> arguments, {required String inside}) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: inside,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  /// A repository at [path] on `main`, with one commit.
  void initRepository(String path) {
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', '.'], inside: path);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], inside: path);
    File('$path/a.md').writeAsStringSync('# A\n');
    git(<String>['add', 'a.md'], inside: path);
    git(<String>[
      '-c',
      'user.name=Test',
      '-c',
      'user.email=test@example.com',
      '-c',
      'commit.gpgsign=false',
      'commit',
      '--quiet',
      '--message',
      'Add A',
    ], inside: path);
  }

  /// The branch the repository reads for [folder].
  Future<BranchNameValueObject?> branchOf(String folder) async {
    final Result<BranchNameValueObject?, Never> read = await repository
        .branchOf(
          RecentSpaceEntity(
            root: folder,
            name: 'docs',
            lastOpened: DateTime.utc(2026, 10, 8),
          ),
        );
    return (read as Success<BranchNameValueObject?, Never>).value;
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_recent_branch_');
    base = tempDir.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    observability = _Observability();
    repository = RecentBranchRepositoryImpl(
      branches: RecentBranchDataSource(
        gitClientFor: (String folder) =>
            DartIoGitClientImpl(workingDirectory: folder),
      ),
      observability: observability,
    );
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('names the branch the folder was left on', () async {
    initRepository('$base/repo');
    git(<String>[
      'switch',
      '--quiet',
      '--create',
      'feat/notes',
    ], inside: '$base/repo');

    expect(await branchOf('$base/repo'), BranchNameValueObject('feat/notes'));
  });

  test('names it for a space below the repository root', () async {
    initRepository('$base/repo');
    Directory('$base/repo/docs').createSync();

    expect(await branchOf('$base/repo/docs'), BranchNameValueObject('main'));
  });

  test('is nothing on a detached HEAD', () async {
    initRepository('$base/repo');
    git(<String>['switch', '--quiet', '--detach'], inside: '$base/repo');

    expect(await branchOf('$base/repo'), isNull);
    expect(observability.captured, isEmpty);
  });

  test(
    'is nothing, and no failure, for a folder that is no repository',
    () async {
      Directory('$base/plain').createSync();

      expect(await branchOf('$base/plain'), isNull);
      expect(observability.captured, isEmpty);
    },
  );

  test('is nothing, and no failure, for a folder that is gone', () async {
    expect(await branchOf('$base/gone'), isNull);
    expect(observability.captured, isEmpty);
  });

  test('is nothing, and nothing to record, when the person says no', () async {
    initRepository('$base/repo');
    repository = RecentBranchRepositoryImpl(
      branches: RecentBranchDataSource(
        gitClientFor: (String folder) => DartIoGitClientImpl(
          workingDirectory: folder,
          commandGate: const _Refusing(),
        ),
      ),
      observability: observability,
    );

    expect(await branchOf('$base/repo'), isNull);
    expect(observability.captured, isEmpty);
  });
}

/// A gate that says no to everything.
final class _Refusing implements CommandGate, CommandPlan {
  const _Refusing();

  @override
  CommandPlan plan(List<CommandRequest> commands) => this;

  @override
  Future<CommandVerdict> next() async => const CommandVerdict.denied();

  @override
  void close() {}
}

/// An [Observability] that remembers what it was handed.
final class _Observability implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}

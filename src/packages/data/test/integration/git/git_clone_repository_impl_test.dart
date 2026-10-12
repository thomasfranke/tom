/// [GitCloneRepositoryImpl] over a real [DartIoGitClientImpl] and a real bare
/// repository, where git's progress lines and the parser meet.
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
  late String remotePath;
  late GitCloneRepositoryImpl repository;

  /// Runs git directly, to arrange the remote.
  void git(List<String> arguments, String inside) {
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

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_git_clone_');
    base = tempDir.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    final String seed = '$base/seed';
    remotePath = '$base/remote.git';
    Directory(seed).createSync();
    git(<String>['init', '--quiet', '.'], seed);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], seed);
    File('$seed/index.md').writeAsStringSync('# Docs\n');
    git(<String>['add', 'index.md'], seed);
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
      'Start',
    ], seed);
    git(<String>['clone', '--quiet', '--bare', seed, remotePath], base);
    repository = GitCloneRepositoryImpl(
      git: GitCloneDataSource(
        gitClientFor: (String folder) =>
            DartIoGitClientImpl(workingDirectory: folder),
        filesystem: const DartIoFilesystemImpl(),
      ),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('clones, reporting the stages it passes through in order', () async {
    final List<CloneProgressValueObject> heard = <CloneProgressValueObject>[];

    final Result<void, GitFailure> cloned = await repository.clone(
      url: 'file://$remotePath',
      destination: '$base/docs',
      onProgress: heard.add,
    );

    expect(cloned, isA<Success<void, GitFailure>>());
    expect(File('$base/docs/index.md').readAsStringSync(), '# Docs\n');
    expect(heard.first.stage, CloneStageEnum.starting);
    final List<int> order = heard
        .map((CloneProgressValueObject p) => p.stage.index)
        .toList();
    expect(order, orderedEquals(<int>[...order]..sort()));
  });

  test('an address with nothing there is GitRemoteNotFound', () async {
    final Result<void, GitFailure> cloned = await repository.clone(
      url: 'file://$base/nowhere.git',
      destination: '$base/docs',
    );

    expect(
      (cloned as Failure<void, GitFailure>).failure,
      isA<GitRemoteNotFound>(),
    );
  });

  group('a clone that fails leaves nothing behind', () {
    late ServerSocket silent;
    late List<Socket> held;
    late String stalled;

    /// A clone that waits a second for a remote that never answers, so git
    /// is killed with its folder already made and cannot clean up itself.
    GitCloneRepositoryImpl impatient() => GitCloneRepositoryImpl(
      git: GitCloneDataSource(
        gitClientFor: (String folder) => DartIoGitClientImpl(
          workingDirectory: folder,
          networkTimeout: const Duration(seconds: 1),
        ),
        filesystem: const DartIoFilesystemImpl(),
      ),
    );

    setUp(() async {
      silent = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      held = <Socket>[];
      silent.listen(held.add);
      stalled = 'http://127.0.0.1:${silent.port}/docs.git';
      File('$base/kept.md').writeAsStringSync('# Kept\n');
    });

    tearDown(() async {
      for (final Socket socket in held) {
        socket.destroy();
      }
      await silent.close();
    });

    test('git killed mid-clone leaves its folder, so the cleanup is '
        'ours', () async {
      final Result<void, GitClientFailure> cloned = await DartIoGitClientImpl(
        workingDirectory: '$base/docs',
        networkTimeout: const Duration(seconds: 1),
      ).clone(stalled);

      expect(
        (cloned as Failure<void, GitClientFailure>).failure,
        isA<GitClientTimedOut>(),
      );
      expect(Directory('$base/docs/.git').existsSync(), isTrue);
    });

    test('removes the folder it made, and nothing beside it', () async {
      final Result<void, GitFailure> cloned = await impatient().clone(
        url: stalled,
        destination: '$base/docs',
      );

      expect((cloned as Failure<void, GitFailure>).failure, isA<GitTimedOut>());
      expect(Directory('$base/docs').existsSync(), isFalse);
      expect(File('$base/kept.md').readAsStringSync(), '# Kept\n');
      expect(Directory(remotePath).existsSync(), isTrue);
    });

    test('empties a folder that was empty, and keeps it', () async {
      Directory('$base/docs').createSync();

      await impatient().clone(url: stalled, destination: '$base/docs');

      expect(Directory('$base/docs').existsSync(), isTrue);
      expect(Directory('$base/docs').listSync(), isEmpty);
      expect(File('$base/kept.md').existsSync(), isTrue);
    });

    test('leaves a folder that already held something as it was', () async {
      File('$base/docs/notes.md').createSync(recursive: true);

      final Result<void, GitFailure> cloned = await repository.clone(
        url: 'file://$remotePath',
        destination: '$base/docs',
      );

      expect(
        (cloned as Failure<void, GitFailure>).failure,
        isA<GitCloneDestinationTaken>(),
      );
      expect(
        Directory('$base/docs')
            .listSync()
            .map((FileSystemEntity e) => e.path.replaceAll(r'\', '/'))
            .toList(),
        <String>['$base/docs/notes.md'],
      );
    });
  });
}

/// Opening a folder with the stack wired as the composition root wires it,
/// the only test that fails when the pieces are each correct and do not fit.
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String base;
  late String preferences;
  late SpaceRepository spaces;
  late RecentSpacesRepository recents;

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

  String initRepository(String name) {
    final String path = '$base/$name';
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', '.'], inside: path);
    return path;
  }

  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_end_to_end_');
    base = tempDir.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    preferences = '$base/support/preferences.json';
    // Exactly the graph `providers.dart` builds, with nothing faked.
    const Filesystem filesystem = DartIoFilesystemImpl();
    spaces = SpaceRepositoryImpl(
      spaces: SpaceDataSource(
        filesystem: filesystem,
        gitClientFor: (String folder) =>
            DartIoGitClientImpl(workingDirectory: folder),
      ),
    );
    recents = RecentSpacesRepositoryImpl(
      recents: RecentSpacesDataSource(
        settings: JsonFileSettingsImpl(
          filesystem: filesystem,
          path: preferences,
        ),
      ),
      observability: const _Observability(),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('a folder becomes a space, and is remembered on disk', () async {
    final String repoPath = initRepository('app');
    Directory('$repoPath/docs').createSync();

    final SpaceEntity space = valueOf(await spaces.open('$repoPath/docs'));
    valueOf(await recents.remember(space));

    expect(space.root, '$repoPath/docs');
    expect(space.repositoryRoot, repoPath);
    expect(space.name, 'docs');

    // A second repository over the same file is what a restart looks like.
    final RecentSpacesRepository reopened = RecentSpacesRepositoryImpl(
      recents: RecentSpacesDataSource(
        settings: JsonFileSettingsImpl(
          filesystem: const DartIoFilesystemImpl(),
          path: preferences,
        ),
      ),
      observability: const _Observability(),
    );
    final List<RecentSpaceEntity> remembered = valueOf(await reopened.list());
    expect(remembered.single.root, '$repoPath/docs');
    expect(remembered.single.name, 'docs');
  });

  test('the preferences file is one a person could read', () async {
    final String repoPath = initRepository('app');

    valueOf(await recents.remember(valueOf(await spaces.open(repoPath))));

    final Object? stored = jsonDecode(File(preferences).readAsStringSync());
    expect(stored, isA<Map<String, Object?>>());
    expect((stored! as Map<String, Object?>).keys, contains('spaces.recent'));
  });

  test('a folder outside any repository is refused, and not remembered', () {
    final String loose = '$base/loose';
    Directory(loose).createSync();

    expect(
      spaces.open(loose),
      completion(isA<Failure<SpaceEntity, AppFailure>>()),
    );
    expect(File(preferences).existsSync(), isFalse);
  });

  test('nothing is written until something is actually stored', () {
    expect(File(preferences).existsSync(), isFalse);
  });
}

/// An [Observability] that keeps nothing.
final class _Observability implements Observability {
  const _Observability();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}

/// [DartIoPlatformPathsImpl] on this machine: the environment the process
/// really has, and a settings file written under the folder it names.
library;

import 'dart:io';
import 'dart:isolate';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory home;

  setUp(() {
    home = Directory.systemTemp.createTempSync('tom_platform_paths_');
  });

  tearDown(() => home.deleteSync(recursive: true));

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// This machine's own variables, with the home directory moved to [home]
  /// so nothing is written where a person's copy of the app reads.
  Map<String, String> movedHome() => <String, String>{
    ...Platform.environment,
    'HOME': home.path,
    'USERPROFILE': home.path,
    'APPDATA': '${home.path}${Platform.pathSeparator}Roaming',
  }..remove('XDG_CONFIG_HOME');

  group('with nothing handed in', () {
    test('answers an absolute folder named for the application', () {
      final String folder = valueOf(
        const DartIoPlatformPathsImpl().applicationData(),
      );

      expect(File(folder).isAbsolute, isTrue);
      expect(folder.split(RegExp(r'[/\\]')).last, 'tom');
    });

    test('never creates the folder it names', () {
      final DartIoPlatformPathsImpl paths = DartIoPlatformPathsImpl(
        environment: movedHome(),
      );

      final String folder = valueOf(paths.applicationData());

      expect(Directory(folder).existsSync(), isFalse);
      expect(home.listSync(), isEmpty);
    });
  });

  group('the folder it names', () {
    test('is under the home directory of this machine\'s own platform', () {
      final String folder = valueOf(
        DartIoPlatformPathsImpl(environment: movedHome()).applicationData(),
      );

      expect(folder, startsWith(home.path));
      if (Platform.isMacOS) {
        expect(folder, '${home.path}/Library/Application Support/tom');
      }
    });

    test('is one the settings store can write under and read back from, '
        'whatever the path holds', () async {
      final String folder = valueOf(
        DartIoPlatformPathsImpl(environment: movedHome()).applicationData(),
      );
      final String path = '$folder${Platform.pathSeparator}preferences.json';
      JsonFileSettingsImpl store() => JsonFileSettingsImpl(
        filesystem: const DartIoFilesystemImpl(),
        path: path,
      );

      valueOf(
        await store().write('app.preferences', <String, Object?>{
          'theme': 'dark',
        }),
      );

      expect(File(path).existsSync(), isTrue);
      expect(valueOf(await store().read('app.preferences')), <String, Object?>{
        'theme': 'dark',
      });
    });

    for (final String platform in <String>['macos', 'linux']) {
      test('for $platform is writable on a disk that spells paths this '
          'way', () async {
        final String folder = valueOf(
          DartIoPlatformPathsImpl(
            operatingSystem: platform,
            environment: <String, String>{'HOME': home.path},
          ).applicationData(),
        );
        final JsonFileSettingsImpl store = JsonFileSettingsImpl(
          filesystem: const DartIoFilesystemImpl(),
          path: '$folder/preferences.json',
        );

        valueOf(await store.write('theme', 'dark'));

        expect(valueOf(await store.read('theme')), 'dark');
        expect(Directory(folder).existsSync(), isTrue);
      }, skip: Platform.isWindows ? 'a POSIX path' : false);
    }

    test(
      'under a configuration home with a space and an accent is writable',
      () async {
        final String folder = valueOf(
          DartIoPlatformPathsImpl(
            operatingSystem: 'linux',
            environment: <String, String>{
              'HOME': '/nobody',
              'XDG_CONFIG_HOME': '${home.path}/Configuração local',
            },
          ).applicationData(),
        );
        final JsonFileSettingsImpl store = JsonFileSettingsImpl(
          filesystem: const DartIoFilesystemImpl(),
          path: '$folder/preferences.json',
        );

        valueOf(await store.write('theme', 'dark'));

        expect(folder, '${home.path}/Configuração local/tom');
        expect(valueOf(await store.read('theme')), 'dark');
      },
      skip: Platform.isWindows ? 'a POSIX path' : false,
    );
  });

  group('a process started with no home at all', () {
    // The environment is the dependency, so the failure is provoked the only
    // real way there is: a second process that is handed none.
    test(
      'is told the machine names no home directory',
      () async {
        final Uri? packages = Isolate.packageConfigSync;
        final File script = File('${home.path}/ask.dart')
          ..writeAsStringSync(r'''
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  final Result<String, PlatformPathsFailure> answer =
      const DartIoPlatformPathsImpl().applicationData();
  print(switch (answer) {
    Success<String, PlatformPathsFailure>(value: final String value) =>
      'folder: $value',
    Failure<String, PlatformPathsFailure>(
      failure: final PlatformPathsFailure failure,
    ) =>
      'failure: ${failure.runtimeType} ${failure.description}',
  });
}
''');

        final ProcessResult asked = await Process.run(
          Platform.resolvedExecutable,
          <String>['--packages=${packages!.toFilePath()}', script.path],
          environment: const <String, String>{},
          includeParentEnvironment: false,
        );

        expect(asked.stderr, isEmpty);
        expect(
          '${asked.stdout}'.trim(),
          allOf(startsWith('failure:'), contains('no home directory')),
        );
      },
      skip: Platform.isWindows
          ? 'Windows hands every process its variables back'
          : false,
    );
  });
}

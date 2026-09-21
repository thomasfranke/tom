/// Where each platform keeps an application's files.
///
/// Unit, and with the platform passed in: two of the three branches are
/// unreachable on whatever machine runs the suite, which is the most common
/// way a path bug ships — it works for whoever wrote it and nobody else.
library;

import 'package:test/test.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  String directoryOn(
    String platform, {
    Map<String, String> environment = const <String, String>{
      'HOME': '/Users/ada',
    },
    String application = 'tom',
  }) => applicationSupportDirectory(
    application: application,
    operatingSystem: platform,
    environment: environment,
  );

  group('macOS', () {
    test('is Application Support under the home directory', () {
      expect(
        directoryOn('macos'),
        '/Users/ada/Library/Application Support/tom',
      );
    });
  });

  group('Windows', () {
    test('is APPDATA when the machine names one', () {
      expect(
        directoryOn(
          'windows',
          environment: const <String, String>{
            'APPDATA': r'C:\Users\ada\AppData\Roaming',
          },
        ),
        r'C:\Users\ada\AppData\Roaming\tom',
      );
    });

    test('falls back to the usual place under the profile', () {
      expect(
        directoryOn(
          'windows',
          environment: const <String, String>{'USERPROFILE': r'C:\Users\ada'},
        ),
        r'C:\Users\ada\AppData\Roaming\tom',
      );
    });

    test('an empty APPDATA is the same as none', () {
      expect(
        directoryOn(
          'windows',
          environment: const <String, String>{
            'APPDATA': '',
            'USERPROFILE': r'C:\Users\ada',
          },
        ),
        r'C:\Users\ada\AppData\Roaming\tom',
      );
    });
  });

  group('Linux and everything else', () {
    test('honours XDG_CONFIG_HOME', () {
      expect(
        directoryOn(
          'linux',
          environment: const <String, String>{
            'XDG_CONFIG_HOME': '/home/ada/.config',
            'HOME': '/home/ada',
          },
        ),
        '/home/ada/.config/tom',
      );
    });

    test('falls back to ~/.config', () {
      expect(
        directoryOn(
          'linux',
          environment: const <String, String>{'HOME': '/home/ada'},
        ),
        '/home/ada/.config/tom',
      );
    });

    test('an empty XDG_CONFIG_HOME is the same as none', () {
      expect(
        directoryOn(
          'linux',
          environment: const <String, String>{
            'XDG_CONFIG_HOME': '',
            'HOME': '/home/ada',
          },
        ),
        '/home/ada/.config/tom',
      );
    });

    test('an unknown platform is treated as Linux', () {
      // Better than refusing to start: the XDG layout is the convention
      // every Unix that is not macOS follows.
      expect(
        directoryOn(
          'fuchsia',
          environment: const <String, String>{'HOME': '/home/ada'},
        ),
        '/home/ada/.config/tom',
      );
    });
  });

  group('a machine with no home directory', () {
    test('is a machine this app cannot run on', () {
      // Thrown rather than modelled: there is no state to show a user whose
      // operating system names nowhere to put a file.
      expect(
        () => directoryOn('linux', environment: const <String, String>{}),
        throwsStateError,
      );
    });

    test('on Windows too', () {
      expect(
        () => directoryOn('windows', environment: const <String, String>{}),
        throwsStateError,
      );
    });
  });

  group('the application name', () {
    test('is the last segment, on every platform', () {
      expect(directoryOn('macos', application: 'other'), endsWith('/other'));
      expect(
        directoryOn(
          'windows',
          environment: const <String, String>{'APPDATA': r'C:\AppData'},
          application: 'other',
        ),
        endsWith(r'\other'),
      );
    });
  });
}

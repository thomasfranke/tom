/// What an end-to-end run has to replace: the native dialogs, the
/// preferences, the browser, and the machine's own GitHub logins.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/export/save_location_picker.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// A module that answers the folder dialog and keeps its own preferences.
///
/// A module like any other ([Decision
/// 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)),
/// so every run drives the extension point too. No test can drive a native
/// panel, and the real preferences hold the developer's own recent spaces.
class E2eModuleImpl implements TomModule {
  /// Answers the picker with [folder] — null is the user cancelling — and
  /// stores preferences at [settingsPath]; [withGh] puts the run's own `gh`
  /// on the machine.
  const E2eModuleImpl({
    required this.settingsPath,
    this.folder,
    this.withGh = false,
  });

  /// What the picker answers, or null to cancel.
  final String? folder;

  /// Where this scenario's preferences live — never the real ones.
  final String settingsPath;

  /// Whether the machine has a `gh` holding a login: the run's own script,
  /// which answers from files and reaches no network ([_fakeGh]).
  final bool withGh;

  /// Where an address the app opened is written, one per line, instead of
  /// reaching a browser.
  static String openedPath(String settingsPath) =>
      '${File(settingsPath).parent.path}/opened-urls.txt';

  /// Where the run's `gh` keeps the pull request it opened, wiped with the
  /// scenario's preferences and kept across a relaunch.
  static String githubPath(String settingsPath) =>
      '${File(settingsPath).parent.path}/machine/github';

  @override
  String get id => 'tom.e2e';

  @override
  List<PanelDescriptor> get panels => const <PanelDescriptor>[];

  @override
  List<Override> get overrides => <Override>[
    folderPickerProvider.overrideWithValue(() async => folder),
    // Beside the scenario's preferences, so an export lands in a folder the
    // run owns and a scenario can open what was written.
    saveLocationPickerProvider.overrideWithValue(
      (String suggestedName, ExportFormatEnum format) async =>
          '${File(settingsPath).parent.path}/$suggestedName',
    ),
    settingsProvider.overrideWith(
      (Ref ref) => JsonFileSettingsImpl(
        filesystem: ref.watch(filesystemProvider),
        path: settingsPath,
      ),
    ),
    // A browser opened by a run is a window on whoever runs it; the address
    // is written down instead, for the robot to read.
    desktopRepositoryProvider.overrideWith(
      (Ref ref) => _RecordingDesktop(
        File(openedPath(settingsPath)),
        DesktopRepositoryImpl(
          source: DesktopDataSource(
            shell: DartIoDesktopShellImpl(
              commandLog: ref.watch(commandLogProvider),
            ),
          ),
        ),
      ),
    ),
    // The developer's own `gh`, keychain and SSH key are out of reach: a
    // `PATH` holding git alone, an empty home, no system config.
    credentialsProvider.overrideWith(
      (Ref ref) => CommandLineCredentialsImpl(
        environment: _bareMachine(
          File(settingsPath).parent.path,
          withGh: withGh,
        ),
        includeParentEnvironment: false,
        commandLog: ref.watch(commandLogProvider),
        commandGate: ref.watch(commandGateProvider),
      ),
    ),
    // And GitHub is never reached: either no `gh` at all, or the run's own.
    if (withGh)
      githubApiProvider.overrideWith(
        (Ref ref) => GhCliGithubApiImpl(
          environment: _bareMachine(
            File(settingsPath).parent.path,
            withGh: true,
          ),
          includeParentEnvironment: false,
          commandLog: ref.watch(commandLogProvider),
          commandGate: ref.watch(commandGateProvider),
        ),
      )
    else
      githubApiProvider.overrideWithValue(const _OfflineGithubApi()),
  ];
}

/// A machine with git and nothing else, built under [folder]: a `bin` with
/// one link to the real git, and a home whose config is empty — plus the
/// run's own `gh` when [withGh].
Map<String, String> _bareMachine(String folder, {bool withGh = false}) {
  final Directory bin = Directory('$folder/machine/bin')
    ..createSync(recursive: true);
  final File gh = File('${bin.path}/gh');
  if (withGh) {
    gh.writeAsStringSync(
      _fakeGh.trimLeft().replaceAll('@STATE@', '$folder/machine/github'),
    );
    Process.runSync('chmod', <String>['+x', gh.path]);
  } else if (gh.existsSync()) {
    gh.deleteSync();
  }
  final Directory home = Directory('$folder/machine/home')
    ..createSync(recursive: true);
  final File config = File('${home.path}/.gitconfig')..writeAsStringSync('');
  final Link git = Link('${bin.path}/git');
  if (!git.existsSync()) {
    final String real =
        (Process.runSync('which', <String>['git']).stdout as String).trim();
    git.createSync(real);
  }
  return <String, String>{
    'PATH': bin.path,
    'HOME': home.path,
    'GIT_CONFIG_NOSYSTEM': '1',
    'GIT_CONFIG_GLOBAL': config.path,
  };
}

/// The run's `gh`: one login, a token that opens nothing, `gh api` a 404,
/// and one pull request — `#123`, kept in `@STATE@` once `pr create` ran.
///
/// A script rather than a fake [GithubApi], so the real implementation's
/// process, environment, input and working folder are what the run drives.
/// Written with its leading newline trimmed, so `#!` is the first line.
const String _fakeGh = r'''
#!/bin/sh
PATH=/usr/bin:/bin
state='@STATE@'
mkdir -p "$state"
echo "$*" >> "$state/asked.log"
case "$1 $2" in
  'auth status')
    echo '{"hosts":{"github.com":[{"login":"tom-e2e","active":true}]}}' ;;
  'auth token')
    echo 'gho_e2e000000000000000000000000000000000000' ;;
  'pr list')
    if [ -f "$state/opened.json" ]; then cat "$state/opened.json"
    else echo '[]'; fi ;;
  'pr create')
    title=''
    previous=''
    for argument in "$@"; do
      [ "$previous" = '--title' ] && title="$argument"
      previous="$argument"
    done
    cat > "$state/body.md"
    printf '[{"number":123,"url":"https://github.com/acme/docs/pull/123","title":"%s"}]\n' "$title" > "$state/opened.json"
    echo 'https://github.com/acme/docs/pull/123' ;;
  *)
    echo 'gh: Not Found (HTTP 404)' >&2
    exit 1 ;;
esac
''';

/// The desktop, writing down the addresses it would have opened.
final class _RecordingDesktop implements DesktopRepository {
  _RecordingDesktop(this.opened, this._real);

  final File opened;

  final DesktopRepository _real;

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async {
    opened.writeAsStringSync('$address\n', mode: FileMode.append);
    return const Success<void, AppFailure>(null);
  }

  @override
  Future<Result<void, AppFailure>> reveal(String folder) =>
      _real.reveal(folder);

  @override
  Future<Result<void, AppFailure>> openTerminal(String folder) =>
      _real.openTerminal(folder);
}

/// GitHub, out of reach.
final class _OfflineGithubApi implements GithubApi {
  const _OfflineGithubApi();

  @override
  Future<Result<String, GithubApiFailure>> repository(
    String path, {
    required String token,
  }) async => const Failure<String, GithubApiFailure>(
    GithubApiUnreachable('an end-to-end run reaches no network'),
  );

  @override
  Future<Result<String, GithubApiFailure>> openPullRequests(
    String folder, {
    required String repository,
    required String head,
    required String token,
  }) async => const Failure<String, GithubApiFailure>(
    GithubApiUnreachable('an end-to-end run reaches no network'),
  );

  @override
  Future<Result<String, GithubApiFailure>> createPullRequest(
    String folder, {
    required String repository,
    required String base,
    required String head,
    required String title,
    required String body,
    required String token,
  }) async => const Failure<String, GithubApiFailure>(
    GithubApiUnreachable('an end-to-end run reaches no network'),
  );
}

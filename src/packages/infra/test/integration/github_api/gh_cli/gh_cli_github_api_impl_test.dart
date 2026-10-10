/// [GhCliGithubApiImpl] against a real process: a `gh` of the test's own,
/// a shell script that writes down what reached it — the real one would
/// reach GitHub.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory machine;
  late Directory clone;

  setUp(() {
    machine = Directory.systemTemp.createTempSync('tom_gh_test_');
    clone = Directory('${machine.path}/clone')..createSync();
    final File gh = File('${machine.path}/bin/gh')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '#!/bin/sh\n'
        'PATH=/usr/bin:/bin\n'
        'out="${machine.path}/asked"\n'
        'pwd > "\$out.folder"\n'
        'printf "%s" "\$GH_TOKEN" > "\$out.token"\n'
        'cat > "\$out.input"\n'
        'case "\$2" in\n'
        '  list) echo "[]" ;;\n'
        '  create) echo "https://github.com/acme/docs/pull/7" ;;\n'
        'esac\n',
      );
    Process.runSync('chmod', <String>['+x', gh.path]);
  });

  tearDown(() => machine.deleteSync(recursive: true));

  GhCliGithubApiImpl api() => GhCliGithubApiImpl(
    environment: <String, String>{'PATH': '${machine.path}/bin'},
    includeParentEnvironment: false,
  );

  String asked(String what) =>
      File('${machine.path}/asked.$what').readAsStringSync().trim();

  test('a pull request is created from the clone, the body on the input, '
      'the token in the environment', () async {
    final Result<String, GithubApiFailure> created = await api()
        .createPullRequest(
          clone.path,
          repository: 'acme/docs',
          base: 'main',
          head: 'feat/x',
          title: 'Release notes',
          body: 'Why it exists — in “quotes”.\n',
          token: 'tok-secret',
        );

    expect(
      (created as Success<String, GithubApiFailure>).value,
      'https://github.com/acme/docs/pull/7',
    );
    expect(asked('input'), 'Why it exists — in “quotes”.');
    expect(asked('token'), 'tok-secret');
    expect(
      File(asked('folder')).resolveSymbolicLinksSync(),
      clone.resolveSymbolicLinksSync(),
    );
  });

  test('the open ones are listed from the clone', () async {
    final Result<String, GithubApiFailure> listed = await api()
        .openPullRequests(
          clone.path,
          repository: 'acme/docs',
          head: 'feat/x',
          token: 'tok-secret',
        );

    expect((listed as Success<String, GithubApiFailure>).value.trim(), '[]');
  });

  test('without gh there is nobody to ask', () async {
    final GhCliGithubApiImpl none = GhCliGithubApiImpl(
      environment: <String, String>{'PATH': clone.path},
      includeParentEnvironment: false,
    );

    final Result<String, GithubApiFailure> listed = await none.openPullRequests(
      clone.path,
      repository: 'acme/docs',
      head: 'feat/x',
      token: 'tok-secret',
    );

    expect(
      (listed as Failure<String, GithubApiFailure>).failure,
      const GithubApiUnavailable('gh'),
    );
  });
}

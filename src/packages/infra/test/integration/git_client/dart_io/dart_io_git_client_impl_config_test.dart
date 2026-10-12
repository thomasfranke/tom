/// [DartIoGitClientImpl] under the settings a person already has in their
/// own `~/.gitconfig`: each one is written by the test into [GitWorld]'s
/// global file, because the client runs under the person's configuration and
/// must read the same thing whoever set what.
///
/// A sibling of `dart_io_git_client_impl_test.dart` (decision T3).
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../../support/git_world.dart';

void main() {
  late GitWorld world;
  late DartIoGitClientImpl client;

  setUp(() {
    world = GitWorld()..seed();
    client = world.client();
  });

  tearDown(() => world.dispose());

  List<String> fields(String text) => text
      .split(GitClient.nulSeparator)
      .where((String f) => f.isNotEmpty)
      .toList();

  /// A topic branch one file ahead of `main`, for the diffs.
  void aheadOfMain() {
    world.git(<String>['switch', '--quiet', '--create', 'topic']);
    world.commitFile('docs/new.md', '# New\n', message: 'Add new');
  }

  group('diff.relative=true', () {
    setUp(() {
      world.configure('[diff]\n\trelative = true\n');
      aheadOfMain();
    });

    test('numstat from a folder below the root still names the root\'s '
        'paths', () async {
      final DartIoGitClientImpl below = world.client(
        inside: '${world.repo}/docs',
      );

      expect(
        fields(valueOf(await below.diffNumstat('main'))),
        contains('1\t0\tdocs/new.md'),
      );
    });

    test('name-status does too, and sees what is outside the folder', () async {
      world.commitFile('top.md', '# Top\n', message: 'Add top');
      final DartIoGitClientImpl below = world.client(
        inside: '${world.repo}/docs',
      );

      final List<String> all = fields(
        valueOf(await below.diffNameStatus('main')),
      );

      expect(all, containsAllInOrder(<String>['A', 'docs/new.md']));
      expect(all, containsAllInOrder(<String>['A', 'top.md']));
    });
  });

  group('log.showSignature=true', () {
    test('adds nothing to the six fields', () async {
      world.configure('[log]\n\tshowSignature = true\n');

      final List<String> records = valueOf(await client.log())
          .split(GitClient.recordSeparator)
          .where((String r) => r.trim().isNotEmpty)
          .toList();

      expect(records, hasLength(1));
      expect(records.single.split(GitClient.unitSeparator), hasLength(6));
    });
  });

  group('status.showUntrackedFiles=no', () {
    test('does not hide a new document from the changes list', () async {
      world.configure('[status]\n\tshowUntrackedFiles = no\n');
      world.write('docs/draft.md', '# Draft\n');

      expect(
        valueOf(await client.status()),
        contains('? docs/draft.md'),
        reason: 'the client asks for every untracked file, whatever is set',
      );
    });
  });

  group('core.quotepath', () {
    for (final String setting in <String>['true', 'false']) {
      test('$setting leaves a name outside ASCII unquoted', () async {
        world.configure('[core]\n\tquotepath = $setting\n');
        world.commitFile('notas de versão é.md', 'one\n', message: 'Add notes');
        aheadOfMain();
        world.commitFile('日本語.md', 'x\n', message: 'Add japanese');
        world.write('açaí.md', 'x\n');

        expect(valueOf(await client.status()), contains('? açaí.md'));
        expect(
          fields(valueOf(await client.diffNameStatus('main'))),
          contains('日本語.md'),
        );
        expect(valueOf(await client.show('HEAD', '日本語.md')), 'x\n');
      });
    }
  });

  group('colour', () {
    // Every colour switch git has, forced on: a reader that parsed escape
    // sequences into a name or a sha would break.
    const String always =
        '[color]\n\tui = always\n[color "status"]\n\tbranch = red\n'
        '[color "branch"]\n\tcurrent = green\n\tlocal = blue\n'
        '[color "diff"]\n\tnew = green\n';

    test('colours none of what the client reads', () async {
      world.configure(always);
      aheadOfMain();
      world.write('docs/draft.md', '# Draft\n');

      final List<String> outputs = <String>[
        valueOf(await client.status()),
        valueOf(await client.log()),
        valueOf(await client.branches()),
        valueOf(await client.branchStandings()),
        valueOf(await client.diffNumstat('main')),
        valueOf(await client.diffNameStatus('main')),
        valueOf(await client.show('HEAD', 'docs/new.md')),
        valueOf(await client.head()),
        valueOf(await client.currentBranch()),
      ];

      for (final String output in outputs) {
        expect(output, isNot(contains('\x1b')), reason: output);
      }
    });
  });

  group('core.autocrlf', () {
    test('true: HEAD holds LF for a file the disk holds as CRLF', () async {
      world.configure('[core]\n\tautocrlf = true\n');
      world.commitFile('crlf.md', 'one\r\ntwo\r\n', message: 'Add crlf');
      world.write('crlf.md', 'one\r\ntwo\r\n');

      expect(valueOf(await client.show('HEAD', 'crlf.md')), 'one\ntwo\n');
      expect(
        valueOf(await client.showBytes('HEAD', 'crlf.md')),
        Uint8List.fromList('one\ntwo\n'.codeUnits),
      );
      expect(
        valueOf(await client.status()),
        isNot(contains('crlf.md')),
        reason: 'the disk and the commit agree once the line ends are read',
      );
    });

    test('input: the commit is LF whatever the disk had', () async {
      world.configure('[core]\n\tautocrlf = input\n');
      world.commitFile('crlf.md', 'one\r\ntwo\r\n', message: 'Add crlf');

      expect(valueOf(await client.show('HEAD', 'crlf.md')), 'one\ntwo\n');
    });

    test('unset: the commit keeps the CRLF it was given', () async {
      world.commitFile('crlf.md', 'one\r\ntwo\r\n', message: 'Add crlf');

      expect(valueOf(await client.show('HEAD', 'crlf.md')), 'one\r\ntwo\r\n');
    });

    test('true: what was staged is LF too', () async {
      world.configure('[core]\n\tautocrlf = true\n');
      world.write('crlf.md', 'one\r\n');
      world.git(<String>['add', 'crlf.md']);

      expect(
        String.fromCharCodes(valueOf(await client.showStagedBytes('crlf.md'))),
        'one\n',
      );
    });
  });

  group('diff.renames', () {
    test('copies still counts a move as a deletion and an addition', () async {
      world.configure('[diff]\n\trenames = copies\n');
      world.commitFile(
        'old.md',
        'same text\nin the file\n',
        message: 'Add old',
      );
      world.git(<String>['switch', '--quiet', '--create', 'topic']);
      world.git(<String>['mv', 'old.md', 'new.md']);
      world.git(<String>['commit', '--quiet', '--message', 'Move']);

      final List<String> all = fields(
        valueOf(await client.diffNameStatus('main')),
      );

      expect(all, containsAllInOrder(<String>['D', 'old.md']));
      expect(all, containsAllInOrder(<String>['A', 'new.md']));
    });
  });

  group('i18n.logOutputEncoding', () {
    // A person who keeps their log in Latin-1 would read an author as
    // mojibake, because the client decodes git's output as UTF-8.
    test('does not change how an author is read', () async {
      world.configure('[i18n]\n\tlogOutputEncoding = ISO-8859-1\n');
      world.write('b.md', '# B\n');
      world.git(<String>['add', 'b.md']);
      world.git(<String>[
        'commit',
        '--quiet',
        '--message',
        'Add B',
        '--author',
        'José Açaí <jose@example.com>',
      ]);

      final String first = valueOf(
        await client.log(limit: 1),
      ).split(GitClient.unitSeparator)[1];

      expect(first, 'José Açaí');
    });
  });

  group('commit.cleanup', () {
    test('strip does not take a markdown heading out of the message', () async {
      world.configure('[commit]\n\tcleanup = strip\n');
      world.write('b.md', '# B\n');
      world.git(<String>['add', 'b.md']);

      await client.commit('# Title\n\nBody');

      expect(
        world
            .git(<String>['log', '-1', '--format=%B'])
            .stdout
            .toString()
            .trim(),
        '# Title\n\nBody',
      );
    });
  });

  group('the person\'s ignore file', () {
    test(
      'keeps an ignored file out of the changes list, as in the terminal',
      () async {
        final File ignore = File('${world.base}/ignore')
          ..writeAsStringSync('scratch.md\n');
        world.configure('[core]\n\texcludesFile = ${ignore.path}\n');
        world.write('scratch.md', 'x\n');
        world.write('real.md', 'x\n');

        final String status = valueOf(await client.status());

        expect(status, contains('? real.md'));
        expect(status, isNot(contains('scratch.md')));
      },
    );
  });

  group('an alias with the name of a command', () {
    test(
      'does not replace the command',
      () async {
        world.configure('[alias]\n\tstatus = log\n\tlog = status\n');

        expect(valueOf(await client.status()), contains('# branch.head main'));
        expect(valueOf(await client.log()), contains('Add A'));
      },
      skip: Platform.isWindows ? 'not run on Windows' : false,
    );
  });
}

/// [DartIoGitClientImpl] against a git that only says what a test scripted:
/// the commands it builds, the exits it reads as answers, the failures it
/// types, its timeouts and its queue. The real binary is the integration
/// suite's.
library;

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../../support/scripted_process.dart';

void main() {
  late Directory folder;
  late List<StartedCall> calls;
  late Said Function(List<String> arguments) script;
  late ProcessException? startError;
  late List<CommandRecord> written;
  late int inFlight;
  late int mostInFlight;

  setUp(() {
    folder = Directory.systemTemp.createTempSync('tom_git_unit_');
    calls = <StartedCall>[];
    script = (List<String> _) => const Said();
    startError = null;
    written = <CommandRecord>[];
    inFlight = 0;
    mostInFlight = 0;
  });

  tearDown(() => folder.deleteSync(recursive: true));

  DartIoGitClientImpl client({
    Duration timeout = const Duration(seconds: 5),
    Duration networkTimeout = const Duration(seconds: 5),
    CommandGate gate = const OpenCommandGateImpl(),
    String? path,
    String executable = 'git',
    Map<String, String> environment = const <String, String>{},
  }) => DartIoGitClientImpl(
    workingDirectory: path ?? folder.path,
    timeout: timeout,
    networkTimeout: networkTimeout,
    commandLog: _Kept(written),
    commandGate: gate,
    executable: executable,
    environment: environment,
    startProcess:
        (
          String program,
          List<String> arguments, {
          String? workingDirectory,
          Map<String, String>? environment,
        }) async {
          if (startError case final ProcessException error) {
            throw error;
          }
          calls.add(
            StartedCall(program, arguments, workingDirectory, environment),
          );
          inFlight++;
          if (inFlight > mostInFlight) {
            mostInFlight = inFlight;
          }
          final ScriptedProcess process = ScriptedProcess(script(arguments));
          unawaited(process.exitCode.then((int _) => inFlight--));
          return process;
        },
  );

  T ok<T, F extends AppFailure>(Result<T, F> result) =>
      (result as Success<T, F>).value;

  GitClientFailure bad<T>(Result<T, GitClientFailure> result) =>
      (result as Failure<T, GitClientFailure>).failure;

  Said fail(String stderr, {int exit = 128, String out = ''}) =>
      Said(exit: exit, err: stderr, out: out);

  group('how git is started', () {
    test('in the folder, with the pinned environment on top of the '
        "caller's and the executable the client was given", () async {
      script = (List<String> _) => const Said(out: 'git version 2.45.0\n');

      final Result<String, GitClientFailure> said = await client(
        executable: '/opt/git',
        environment: <String, String>{'LC_ALL': 'xx', 'HOME': '/h'},
      ).version();

      expect(ok(said), 'git version 2.45.0');
      final StartedCall call = calls.single;
      expect(call.executable, '/opt/git');
      expect(call.arguments, <String>['--version']);
      expect(call.workingDirectory, folder.path);
      expect(call.environment!['GIT_TERMINAL_PROMPT'], '0');
      expect(call.environment!['GIT_ASKPASS'], '');
      expect(call.environment!['GIT_OPTIONAL_LOCKS'], '0');
      expect(call.environment!['LC_ALL'], 'xx');
      expect(call.environment!['HOME'], '/h');
    });

    test('a command is written down once, git first, with its exit', () async {
      script = (List<String> _) => const Said(out: '/repo\n');

      await client().repositoryRoot();

      expect(written.single.executable, 'git');
      expect(written.single.arguments, <String>[
        'rev-parse',
        '--show-toplevel',
      ]);
      expect(written.single.exitCode, 0);
    });

    test(
      'no git on the PATH, in a folder that exists, is a missing binary',
      () async {
        startError = const ProcessException('git', <String>[], 'nope', 2);

        final Result<String, GitClientFailure> said = await client().status();

        expect(bad(said), isA<GitClientExecutableNotFound>());
        expect(written.single.ran, isFalse);
      },
    );

    test(
      'a folder that is gone is not a repository, not a missing git',
      () async {
        startError = const ProcessException('git', <String>[], 'nope', 2);

        final Result<String, GitClientFailure> said = await client(
          path: '${folder.path}/gone',
        ).status();

        expect(bad(said), isA<GitClientNotARepository>());
      },
    );

    test('a clone that cannot start has no folder to blame', () async {
      startError = const ProcessException('git', <String>[], 'nope', 2);

      final Result<void, GitClientFailure> said = await client().clone(
        'https://example.com/a.git',
      );

      expect(bad(said), isA<GitClientExecutableNotFound>());
    });

    test('what is not valid UTF-8 is decoded, never thrown', () async {
      script = (List<String> _) =>
          const Said(outBytes: <int>[0x6f, 0x6b, 0xff, 0x0a]);

      final Result<String, GitClientFailure> said = await client().status();

      expect(ok(said), startsWith('ok'));
    });
  });

  group('the gate', () {
    test('a refused command never starts and says which one', () async {
      final Result<String, GitClientFailure> said = await client(
        gate: _Gate(allows: false),
      ).status();

      expect(bad(said), isA<GitClientCommandDenied>());
      expect(calls, isEmpty);
    });

    test('an approved command hands its ticket to the record', () async {
      await client(gate: _Gate(ticket: 9)).status();

      expect(written.single.ticket, 9);
    });

    test('a plan of two is declared once, and a failure closes it', () async {
      final _Gate gate = _Gate();
      script = (List<String> arguments) =>
          arguments.first == 'reset' ? fail('fatal: boom') : const Said();

      final Result<void, GitClientFailure> said = await client(
        gate: gate,
      ).discardAll();

      expect(bad(said), isA<GitClientCommandFailed>());
      expect(
        gate.planned.single.map((CommandRequest r) => r.arguments.first),
        <String>['reset', 'restore'],
      );
      expect(gate.closed, 1);
      expect(calls.length, 1);
    });

    test('a refusal in the middle of identity closes its plan', () async {
      final _Gate gate = _Gate(allows: false);

      final Result<String, GitClientFailure> said = await client(
        gate: gate,
      ).identity();

      expect(bad(said), isA<GitClientCommandDenied>());
      expect(gate.closed, 1);
    });
  });

  group('failures are told apart by what git says', () {
    final Map<String, Type> cases = <String, Type>{
      'fatal: not a git repository (or any of the parent directories)':
          GitClientNotARepository,
      'remote: Authentication failed for x': GitClientAuthenticationFailed,
      'fatal: could not read Username for x': GitClientAuthenticationFailed,
      'fatal: unable to access x: Could not resolve host: x':
          GitClientNetworkUnavailable,
      'fatal: No configured push destination.': GitClientNoRemote,
      'remote: error: GH006: Protected branch update failed':
          GitClientBranchProtected,
      ' ! [rejected] main -> main (non-fast-forward)': GitClientPushRejected,
      'fatal: something else entirely': GitClientCommandFailed,
    };
    for (final MapEntry<String, Type> entry in cases.entries) {
      test('"${entry.key}" is a ${entry.value}', () async {
        script = (List<String> _) => fail(entry.key);

        final Result<void, GitClientFailure> said = await client().push();

        expect(bad(said).runtimeType.toString(), contains('${entry.value}'));
      });
    }

    test(
      'a command failure keeps the line, the exit and git\'s words',
      () async {
        script = (List<String> _) => fail('fatal: nope', exit: 7);

        final GitClientFailure failure = bad(await client().fetch());

        expect(failure, isA<GitClientCommandFailed>());
        final GitClientCommandFailed failed = failure as GitClientCommandFailed;
        expect(failed.command, 'git fetch');
        expect(failed.exitCode, 7);
        expect(failed.stderr, 'fatal: nope');
      },
    );

    test('a merge that would overwrite lists the paths behind a tab', () async {
      script = (List<String> _) => fail(
        'error: Your local changes to the following files would be '
        'overwritten by merge:\n\ta.md\n\tdir/b.md\nPlease commit.',
      );

      final GitClientFailure failure = bad(await client().pull());

      expect((failure as GitClientLocalChangesOverwritten).paths, <String>[
        'a.md',
        'dir/b.md',
      ]);
    });

    test('a conflict is named by what the index says is unmerged', () async {
      script = (List<String> arguments) => arguments.contains('--diff-filter=U')
          ? const Said(out: 'a.md\u0000sub/b.md\u0000')
          : fail(
              'Automatic merge failed; fix conflicts',
              exit: 1,
              out: 'CONFLICT (content): Merge conflict in other.md\n',
            );

      final GitClientFailure failure = bad(await client().pull());

      expect((failure as GitClientMergeConflict).conflictedPaths, <String>[
        'a.md',
        'sub/b.md',
      ]);
    });

    test(
      'when the index cannot be asked, the message\'s paths stand',
      () async {
        script = (List<String> arguments) =>
            arguments.contains('--diff-filter=U')
            ? fail('fatal: no')
            : fail(
                'Automatic merge failed; fix conflicts',
                exit: 1,
                out: 'CONFLICT (content): Merge conflict in other.md\n',
              );

        final GitClientFailure failure = bad(await client().pull());

        expect((failure as GitClientMergeConflict).conflictedPaths, <String>[
          'other.md',
        ]);
      },
    );

    test('a refused index question leaves the message\'s paths', () async {
      int asked = 0;
      final _Gate gate = _Gate(
        verdict: () => ++asked == 1
            ? const CommandVerdict.run()
            : const CommandVerdict.denied(),
      );
      script = (List<String> _) => fail(
        'Automatic merge failed',
        exit: 1,
        out: 'CONFLICT (content): Merge conflict in x.md\n',
      );

      final GitClientFailure failure = bad(await client(gate: gate).pull());

      expect((failure as GitClientMergeConflict).conflictedPaths, <String>[
        'x.md',
      ]);
    });
  });

  group('time', () {
    test(
      'a local command that outlives its limit is killed and typed',
      () async {
        script = (List<String> _) => const Said(hang: true);

        final GitClientFailure failure = bad(
          await client(timeout: const Duration(milliseconds: 40)).status(),
        );

        expect(failure, isA<GitClientTimedOut>());
        expect((failure as GitClientTimedOut).timeout.inMilliseconds, 40);
        expect(written.single.exitCode, isNull);
      },
    );

    test('a remote command has the network limit, not the local one', () async {
      script = (List<String> _) => const Said(hang: true);

      final GitClientFailure failure = bad(
        await client(
          timeout: const Duration(milliseconds: 5),
          networkTimeout: const Duration(milliseconds: 60),
        ).fetch(),
      );

      expect((failure as GitClientTimedOut).timeout.inMilliseconds, 60);
    });

    test(
      'a clone is timed by its silence, so progress keeps it alive',
      () async {
        script = (List<String> _) => const Said(
          errLines: <String>['Receiving 1', 'Receiving 2', 'Receiving 3'],
        );
        final List<String> heard = <String>[];

        final Result<void, GitClientFailure> said = await client(
          networkTimeout: const Duration(milliseconds: 200),
        ).clone('https://example.com/a.git', onProgress: heard.add);

        expect(said, isA<Success<void, GitClientFailure>>());
        expect(heard, <String>['Receiving 1', 'Receiving 2', 'Receiving 3']);
      },
    );

    test('a clone that goes quiet is killed', () async {
      script = (List<String> _) =>
          const Said(hang: true, errLines: <String>['Receiving 1']);

      final Result<void, GitClientFailure> said = await client(
        networkTimeout: const Duration(milliseconds: 60),
      ).clone('https://example.com/a.git');

      expect(bad(said), isA<GitClientTimedOut>());
    });
  });

  group('the queue', () {
    test('two commands on one folder never run together', () async {
      script = (List<String> _) => const Said();
      final DartIoGitClientImpl first = client();
      final DartIoGitClientImpl second = client();

      await Future.wait(<Future<Object>>[
        first.status(),
        second.status(),
        first.head(),
      ]);

      expect(calls.length, 3);
      expect(mostInFlight, 1);
    });

    test('a failure does not stop the commands behind it', () async {
      int n = 0;
      script = (List<String> _) => ++n == 1 ? fail('fatal: x') : const Said();
      final DartIoGitClientImpl git = client();

      final List<Result<String, GitClientFailure>> all = await Future.wait(
        <Future<Result<String, GitClientFailure>>>[git.status(), git.status()],
      );

      expect(all.first, isA<Failure<String, GitClientFailure>>());
      expect(all.last, isA<Success<String, GitClientFailure>>());
    });
  });

  group('clone', () {
    test(
      'runs outside any folder, refuses ext:: and guards the address',
      () async {
        await client().clone('https://example.com/a.git');

        final StartedCall call = calls.single;
        expect(call.workingDirectory, isNull);
        expect(call.arguments, <String>[
          '-c',
          'protocol.ext.allow=never',
          'clone',
          '--progress',
          '--',
          'https://example.com/a.git',
          Directory(folder.path).absolute.path,
        ]);
      },
    );

    test('a taken destination is its own failure', () async {
      script = (List<String> _) => fail(
        "fatal: destination path 'x' already exists and is not an empty "
        'directory.',
      );

      final GitClientFailure failure = bad(await client().clone('u'));

      expect(failure, isA<GitClientDestinationTaken>());
    });

    test('an address with no repository is a remote not found', () async {
      script = (List<String> _) =>
          fail("fatal: repository 'https://x/y.git/' not found");

      expect(bad(await client().clone('u')), isA<GitClientRemoteNotFound>());
    });

    test('git calling a wrong address a missing remote is the same', () async {
      script = (List<String> _) =>
          fail("fatal: 'x' does not appear to be a git repository");

      expect(bad(await client().clone('u')), isA<GitClientRemoteNotFound>());
    });

    test('another failure passes through', () async {
      script = (List<String> _) => fail('fatal: could not read Username');

      expect(
        bad(await client().clone('u')),
        isA<GitClientAuthenticationFailed>(),
      );
    });
  });

  group('reads', () {
    test('status, branches and the standings build their arguments', () async {
      await client().status();
      await client().branches();
      await client().branchStandings();

      expect(calls[0].arguments, <String>[
        'status',
        '--porcelain=v2',
        '--branch',
        '--untracked-files=all',
        '-z',
      ]);
      expect(calls[1].arguments.first, 'branch');
      expect(calls[1].arguments.last, startsWith('--format=%(refname:short)'));
      expect(
        calls[2].arguments,
        containsAllInOrder(<String>[
          'for-each-ref',
          'refs/heads',
          'refs/remotes',
        ]),
      );
    });

    test('an unborn HEAD has no standings, which is an answer', () async {
      script = (List<String> _) => fail("fatal: failed to find 'HEAD'");

      expect(ok(await client().branchStandings()), '');
    });

    test('another failure of the standings stays one', () async {
      script = (List<String> _) => fail('fatal: other');

      expect(
        bad(await client().branchStandings()),
        isA<GitClientCommandFailed>(),
      );
    });

    test('log builds a path, a limit and a range', () async {
      await client().log(path: 'a b.md', limit: 5, since: 'abc');
      await client().log();

      expect(calls[0].arguments.sublist(2), <String>[
        '--follow',
        '--max-count=5',
        'abc..HEAD',
        '--',
        ':(top,literal)a b.md',
      ]);
      expect(calls[1].arguments.length, 2);
    });

    test('an unborn branch has an empty log', () async {
      script = (List<String> _) => fail(
        "fatal: your current branch 'main' does not have any commits yet",
      );

      expect(ok(await client().log()), '');
    });

    test('another log failure stays a failure', () async {
      script = (List<String> _) => fail('fatal: bad');

      expect(bad(await client().log()), isA<GitClientCommandFailed>());
    });

    test('the repository root and the version are trimmed', () async {
      script = (List<String> _) => const Said(out: ' /r \n');

      expect(ok(await client().repositoryRoot()), '/r');
    });

    test('a failing version stays a failure', () async {
      script = (List<String> _) => fail('x');

      expect(bad(await client().version()), isA<GitClientCommandFailed>());
      expect(
        bad(await client().repositoryRoot()),
        isA<GitClientCommandFailed>(),
      );
    });

    test('diffs are asked from the fork point, root-relative', () async {
      await client().diffNumstat('main');
      await client().diffNameStatus('main');

      expect(calls[0].arguments, <String>[
        '-c',
        'diff.relative=false',
        'diff',
        '--numstat',
        '-z',
        '--no-renames',
        'main...HEAD',
      ]);
      expect(calls[1].arguments[3], '--name-status');
    });

    test('merge-base trims, and no common ancestor is an answer', () async {
      script = (List<String> _) => const Said(out: 'abc\n');
      expect(ok(await client().mergeBase('main')), 'abc');

      script = (List<String> _) => const Said(exit: 1);
      expect(ok(await client().mergeBase('main')), '');
      expect(written.last.answers, contains(1));

      script = (List<String> _) => fail('fatal: bad');
      expect(
        bad(await client().mergeBase('main')),
        isA<GitClientCommandFailed>(),
      );
    });

    test('a revision resolves, or does not, or git is not there', () async {
      expect(ok(await client().resolves('x')), isTrue);
      expect(calls.last.arguments.last, 'x^{commit}');

      script = (List<String> _) => const Said(exit: 1);
      expect(ok(await client().resolves('x')), isFalse);

      script = (List<String> _) => fail('fatal: not a git repository');
      expect(bad(await client().resolves('x')), isA<GitClientNotARepository>());
    });

    test('remote url trims; no origin is an answer', () async {
      script = (List<String> _) => const Said(out: 'u\n');
      expect(ok(await client().remoteUrl()), 'u');

      script = (List<String> _) =>
          fail("error: No such remote 'origin'", exit: 2);
      expect(ok(await client().remoteUrl()), '');
      expect(written.last.answers, contains(2));

      script = (List<String> _) => fail('fatal: other');
      expect(bad(await client().remoteUrl()), isA<GitClientCommandFailed>());
    });

    test('the current branch, or none when detached', () async {
      script = (List<String> _) => const Said(out: 'feat/x\n');
      expect(ok(await client().currentBranch()), 'feat/x');

      script = (List<String> _) => const Said(exit: 1);
      expect(ok(await client().currentBranch()), '');

      script = (List<String> _) => fail('fatal: x');
      expect(
        bad(await client().currentBranch()),
        isA<GitClientCommandFailed>(),
      );
    });

    test('HEAD trims, and an unborn branch has none', () async {
      script = (List<String> _) => const Said(out: 'sha\n');
      expect(ok(await client().head()), 'sha');

      script = (List<String> _) => const Said(exit: 1);
      expect(ok(await client().head()), '');

      script = (List<String> _) => fail('fatal: x');
      expect(bad(await client().head()), isA<GitClientCommandFailed>());
    });

    test('the commits counted, or nothing for an unborn branch', () async {
      script = (List<String> arguments) => arguments.first == 'rev-list'
          ? const Said(out: '12\n')
          : const Said(out: 'sha\n');
      expect(ok(await client().commitCount()), 12);

      script = (List<String> _) => const Said(exit: 1);
      expect(ok(await client().commitCount()), 0);

      script = (List<String> arguments) => arguments.first == 'rev-list'
          ? const Said(out: 'many\n')
          : const Said(out: 'sha\n');
      expect(bad(await client().commitCount()), isA<GitClientCommandFailed>());

      script = (List<String> arguments) => arguments.first == 'rev-list'
          ? fail('fatal: x')
          : const Said(out: 'sha\n');
      expect(bad(await client().commitCount()), isA<GitClientCommandFailed>());

      script = (List<String> _) => fail('fatal: x');
      expect(bad(await client().commitCount()), isA<GitClientCommandFailed>());
    });

    test('the commits upstream since a point, or since ever', () async {
      script = (List<String> _) => const Said(out: '3\n');
      expect(ok(await client().upstreamCommitsSince('abc')), 3);
      expect(calls.last.arguments.last, 'abc..@{upstream}');

      await client().upstreamCommitsSince('');
      expect(calls.last.arguments.last, '@{upstream}');

      script = (List<String> _) => const Said(out: 'x');
      expect(
        bad(await client().upstreamCommitsSince('')),
        isA<GitClientCommandFailed>(),
      );

      script = (List<String> _) => fail('fatal: no upstream');
      expect(
        bad(await client().upstreamCommitsSince('')),
        isA<GitClientCommandFailed>(),
      );
    });
  });

  group('configuration', () {
    test(
      'identity joins the name and the email with the unit separator',
      () async {
        script = (List<String> arguments) =>
            Said(out: arguments.last == 'user.name' ? 'Ana\n' : 'a@x.org\n');

        expect(
          ok(await client().identity()),
          'Ana${GitClient.unitSeparator}a@x.org',
        );
      },
    );

    test('an unset key is empty, not a failure', () async {
      script = (List<String> _) => const Said(exit: 1);

      expect(ok(await client().identity()), GitClient.unitSeparator);
      expect(ok(await client().githubAccount()), '');
      expect(ok(await client().branchBase('feat/x')), '');
      expect(calls.last.arguments, <String>[
        'config',
        '--local',
        '--get',
        'branch.feat/x.tomBase',
      ]);
    });

    test('a failing email read fails the identity', () async {
      script = (List<String> arguments) => arguments.last == 'user.email'
          ? fail('fatal: not a git repository')
          : const Said(out: 'Ana\n');

      expect(bad(await client().identity()), isA<GitClientNotARepository>());
    });

    test('the account and the base are written to the local config', () async {
      await client().recordGithubAccount('ana');
      await client().recordBranchBase('feat/x', 'main');

      expect(calls[0].arguments, <String>[
        'config',
        '--local',
        'tom.githubAccount',
        'ana',
      ]);
      expect(calls[1].arguments, <String>[
        'config',
        '--local',
        'branch.feat/x.tomBase',
        'main',
      ]);
    });

    test(
      'the default branch is origin/HEAD, with the prefix dropped',
      () async {
        script = (List<String> _) => const Said(out: 'origin/trunk\n');
        expect(ok(await client().defaultBranch()), 'trunk');

        script = (List<String> _) => const Said(out: 'dev\n');
        expect(ok(await client().defaultBranch()), 'dev');
      },
    );

    test(
      'without origin/HEAD it guesses main, then master, then none',
      () async {
        script = (List<String> arguments) => arguments.first == 'symbolic-ref'
            ? const Said(exit: 1)
            : const Said();
        expect(ok(await client().defaultBranch()), 'main');

        script = (List<String> arguments) =>
            arguments.first == 'symbolic-ref' ||
                arguments.last == 'refs/remotes/origin/main'
            ? const Said(exit: 1)
            : const Said();
        expect(ok(await client().defaultBranch()), 'master');

        script = (List<String> _) => const Said(exit: 1);
        expect(ok(await client().defaultBranch()), '');
      },
    );

    test('a failure that is not "nothing says" is not guessed past', () async {
      script = (List<String> _) => fail('fatal: not a git repository');
      expect(
        bad(await client().defaultBranch()),
        isA<GitClientNotARepository>(),
      );

      script = (List<String> _) => fail('fatal: x', exit: 2);
      expect(
        bad(await client().defaultBranch()),
        isA<GitClientCommandFailed>(),
      );
      expect(calls.length, 2);
    });

    test('a refusal while guessing stops the guessing', () async {
      int asked = 0;
      final _Gate gate = _Gate(
        verdict: () => ++asked <= 2
            ? const CommandVerdict.run()
            : const CommandVerdict.denied(),
      );
      script = (List<String> _) => const Said(exit: 1);

      expect(
        bad(await client(gate: gate).defaultBranch()),
        isA<GitClientCommandDenied>(),
      );

      final _Gate first = _Gate(allows: false);
      expect(
        bad(await client(gate: first).defaultBranch()),
        isA<GitClientCommandDenied>(),
      );
    });
  });

  group('showing a version', () {
    test(
      'a path missing from the revision is its own failure and an answer',
      () async {
        script = (List<String> _) =>
            fail("fatal: path 'a.md' does not exist in 'abc'");

        final GitClientFailure failure = bad(
          await client().show('abc', 'a.md'),
        );

        expect(failure, isA<GitClientPathNotInRevision>());
        expect(written.single.answers, contains(128));
      },
    );

    test('the bytes come back whole, and the staged ones too', () async {
      script = (List<String> _) => const Said(outBytes: <int>[1, 2, 0xff]);

      expect(ok(await client().showBytes('abc', 'a.md')), <int>[1, 2, 0xff]);
      expect(calls.last.arguments, <String>['show', 'abc:a.md']);
      expect(ok(await client().showStagedBytes('a.md')), <int>[1, 2, 0xff]);
      expect(calls.last.arguments, <String>['show', ':a.md']);
    });

    test('an unborn HEAD is "no earlier version" in the bytes too', () async {
      script = (List<String> _) => fail("fatal: invalid object name 'HEAD'.");

      expect(
        bad(await client().showBytes('HEAD', 'a.md')),
        isA<GitClientPathNotInRevision>(),
      );
      expect(
        bad(await client().showStagedBytes('a.md')),
        isA<GitClientPathNotInRevision>(),
      );
    });

    test('another failure of the bytes stays a failure', () async {
      script = (List<String> _) => fail('fatal: bad object abc');

      expect(
        bad(await client().showBytes('abc', 'a.md')),
        isA<GitClientCommandFailed>(),
      );
    });

    test('text is decoded', () async {
      script = (List<String> _) => const Said(out: 'olá');

      expect(ok(await client().show('abc', 'a.md')), 'olá');
    });
  });

  group('writes', () {
    test('stage and discard use top-level literal pathspecs', () async {
      await client().stage(<String>['a.md', 'b[1].md']);
      await client().discardUnstaged(<String>['a.md']);
      await client().discardSinceCommit(<String>['a.md']);

      expect(calls[0].arguments, <String>[
        'add',
        '--',
        ':(top,literal)a.md',
        ':(top,literal)b[1].md',
      ]);
      expect(calls[1].arguments, <String>[
        'restore',
        '--worktree',
        '--',
        ':(top,literal)a.md',
      ]);
      expect(calls[2].arguments.take(4), <String>[
        'restore',
        '--staged',
        '--worktree',
        '--source=HEAD',
      ]);
    });

    test('discarding everything resets, then restores from the top', () async {
      await client().discardAll();

      expect(calls.map((StartedCall c) => c.line), <String>[
        'reset --quiet',
        'restore --worktree -- :/',
      ]);
    });

    test('unstaging nothing asks nothing', () async {
      expect(
        await client().unstage(<String>[]),
        isA<Success<void, GitClientFailure>>(),
      );
      expect(calls, isEmpty);
    });

    test(
      'unstaging asks restore; before the first commit it takes the index',
      () async {
        await client().unstage(<String>['a.md']);
        expect(calls.single.arguments.take(3), <String>[
          'restore',
          '--staged',
          '--',
        ]);

        calls.clear();
        script = (List<String> arguments) => arguments.first == 'restore'
            ? fail("fatal: could not resolve 'HEAD'")
            : const Said();
        final Result<void, GitClientFailure> said = await client().unstage(
          <String>['a.md'],
        );

        expect(said, isA<Success<void, GitClientFailure>>());
        expect(calls.last.arguments.take(3), <String>[
          'rm',
          '--cached',
          '--quiet',
        ]);
      },
    );

    test('another unstaging failure stays one', () async {
      script = (List<String> _) => fail('fatal: other');

      expect(
        bad(await client().unstage(<String>['a'])),
        isA<GitClientCommandFailed>(),
      );
    });

    test('commit keeps the whitespace of the message', () async {
      await client().commit('# Title\n\nbody');

      expect(calls.single.arguments, <String>[
        'commit',
        '--cleanup=whitespace',
        '--message',
        '# Title\n\nbody',
      ]);
    });

    test(
      'branches are made and switched; a dash is never switched to',
      () async {
        await client().createBranch('feat/x');
        await client().switchBranch('feat/x');
        final Result<void, GitClientFailure> dashed = await client()
            .switchBranch('-x');

        expect(calls[0].line, 'switch --create feat/x');
        expect(calls[1].line, 'switch -- feat/x');
        expect(calls.length, 2);
        expect((bad(dashed) as GitClientCommandFailed).exitCode, 128);
      },
    );

    test('fetch, pull, push and publish take the network limit', () async {
      await client().fetch();
      await client().pull();
      await client().push();
      await client().publish('feat/x');

      expect(calls.map((StartedCall c) => c.line), <String>[
        'fetch',
        'pull --no-rebase',
        'push',
        'push --set-upstream origin feat/x',
      ]);
    });

    test('abort merge asks git', () async {
      await client().abortMerge();

      expect(calls.single.line, 'merge --abort');
    });
  });

  group('deleting what was never committed', () {
    test('a path in HEAD is refused and nothing is deleted', () async {
      script = (List<String> _) => const Said(out: 'a.md\u0000');

      final GitClientFailure failure = bad(
        await client().deleteUncommitted(<String>['a.md', 'b.md']),
      );

      expect((failure as GitClientPathCommitted).paths, <String>['a.md']);
      expect(calls.length, 1);
    });

    test(
      'nothing committed removes it from the index, then the disk',
      () async {
        await client().deleteUncommitted(<String>['a.md']);

        expect(calls.map((StartedCall c) => c.arguments.first), <String>[
          'ls-tree',
          'rm',
          'clean',
        ]);
        expect(calls[1].arguments, containsAll(<String>['--cached', '-f']));
        expect(calls[2].arguments, containsAll(<String>['-f', '-x']));
      },
    );

    test('an unborn HEAD is nothing committed', () async {
      script = (List<String> arguments) => arguments.first == 'ls-tree'
          ? fail('fatal: Not a valid object name HEAD')
          : const Said();

      final Result<void, GitClientFailure> said = await client()
          .deleteUncommitted(<String>['a.md']);

      expect(said, isA<Success<void, GitClientFailure>>());
      expect(calls.length, 3);
      expect(written.first.answers, contains(128));
    });

    test('another failure of the question stops it', () async {
      script = (List<String> _) => fail('fatal: not a git repository');

      expect(
        bad(await client().deleteUncommitted(<String>['a.md'])),
        isA<GitClientNotARepository>(),
      );
      expect(calls.length, 1);
    });

    test('a failure while removing stops before the clean', () async {
      script = (List<String> arguments) =>
          arguments.first == 'rm' ? fail('fatal: x') : const Said();

      expect(
        bad(await client().deleteUncommitted(<String>['a.md'])),
        isA<GitClientCommandFailed>(),
      );
      expect(calls.last.arguments.first, 'rm');
    });
  });

  group('the merge in progress', () {
    test('MERGE_HEAD present or absent', () async {
      script = (List<String> _) => const Said(out: 'sha\n');
      expect(ok(await client().mergeInProgress()), isTrue);

      script = (List<String> _) => const Said();
      expect(ok(await client().mergeInProgress()), isFalse);

      script = (List<String> _) => const Said(exit: 1);
      expect(ok(await client().mergeInProgress()), isFalse);

      script = (List<String> _) => fail('fatal: not a git repository');
      expect(
        bad(await client().mergeInProgress()),
        isA<GitClientNotARepository>(),
      );
    });

    test(
      'the message is read from where git says, relative or absolute',
      () async {
        File('${folder.path}/MERGE_MSG').writeAsStringSync('Merge x\n');

        script = (List<String> _) => const Said(out: 'MERGE_MSG\n');
        expect(ok(await client().mergeMessage()), 'Merge x\n');

        script = (List<String> _) => Said(out: '${folder.path}/MERGE_MSG\n');
        expect(ok(await client().mergeMessage()), 'Merge x\n');
      },
    );

    test('no message file is no merge', () async {
      script = (List<String> _) => const Said(out: 'MERGE_MSG\n');

      expect(ok(await client().mergeMessage()), '');
    });

    test('a message that cannot be read is empty too', () async {
      Directory('${folder.path}/MERGE_MSG').createSync();
      script = (List<String> _) => const Said(out: 'MERGE_MSG\n');

      expect(ok(await client().mergeMessage()), '');
    });

    test('git failing to locate it fails the read', () async {
      script = (List<String> _) => fail('fatal: not a git repository');

      expect(
        bad(await client().mergeMessage()),
        isA<GitClientNotARepository>(),
      );
    });
  });

  group('the git directory', () {
    test('a relative answer is resolved against the folder', () async {
      script = (List<String> _) => const Said(out: '.git\n');

      expect(
        ok(await client().gitDirectory()),
        '${Directory.fromUri(Uri.directory(folder.path)).path}/.git'.replaceAll(
          '//',
          '/',
        ),
      );
    });

    test('an absolute answer stands, without its trailing separator', () async {
      script = (List<String> _) => const Said(out: '/elsewhere/.git/\n');

      expect(ok(await client().gitDirectory()), '/elsewhere/.git');
    });

    test('a failure stays one', () async {
      script = (List<String> _) => fail('fatal: not a git repository');

      expect(
        bad(await client().gitDirectory()),
        isA<GitClientNotARepository>(),
      );
    });
  });
}

final class _Kept implements CommandLog {
  _Kept(this.records);

  final List<CommandRecord> records;

  @override
  void record(CommandRecord record) => records.add(record);
}

final class _Gate implements CommandGate, CommandPlan {
  _Gate({this.allows = true, this.ticket, this.verdict});

  final bool allows;
  final int? ticket;
  final CommandVerdict Function()? verdict;
  final List<List<CommandRequest>> planned = <List<CommandRequest>>[];
  int closed = 0;

  @override
  CommandPlan plan(List<CommandRequest> commands) {
    planned.add(commands);
    return this;
  }

  @override
  Future<CommandVerdict> next() async =>
      verdict?.call() ??
      (allows
          ? CommandVerdict.run(ticket: ticket)
          : const CommandVerdict.denied());

  @override
  void close() => closed++;
}

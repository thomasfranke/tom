/// [GhCliGithubApiImpl] against a `gh` that only records: a test that asked
/// the real one would reach GitHub.
library;

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late List<List<String>> arguments;
  late List<Map<String, String>> environments;
  late List<String?> inputs;
  late List<String?> folders;
  late ProcessResult answer;
  late Exception? thrown;
  late List<CommandRecord> written;
  late _Gate gate;

  setUp(() {
    arguments = <List<String>>[];
    environments = <Map<String, String>>[];
    inputs = <String?>[];
    folders = <String?>[];
    answer = ProcessResult(0, 0, '{"permissions":{}}', '');
    thrown = null;
    written = <CommandRecord>[];
    gate = _Gate();
  });

  GhCliGithubApiImpl api() => GhCliGithubApiImpl(
    commandLog: _Kept(written),
    commandGate: gate,
    run:
        (
          String executable,
          List<String> given, {
          required Map<String, String> environment,
          String? input,
          String? workingDirectory,
        }) async {
          if (thrown case final Exception error) {
            throw error;
          }
          arguments.add(<String>[executable, ...given]);
          environments.add(environment);
          inputs.add(input);
          folders.add(workingDirectory);
          return answer;
        },
  );

  Future<Result<String, GithubApiFailure>> create() => api().createPullRequest(
    '/code/app',
    repository: 'acme/docs',
    base: 'main',
    head: 'feat/x',
    title: 'Release notes',
    body: 'Why it exists.\n',
    token: 'tok-secret',
  );

  group('pull requests', () {
    test('the open ones from a branch are listed from the clone', () async {
      answer = ProcessResult(0, 0, '[]\n', '');

      final Result<String, GithubApiFailure> listed = await api()
          .openPullRequests(
            '/code/app',
            repository: 'acme/docs',
            head: 'feat/x',
            token: 'tok-secret',
          );

      expect((listed as Success<String, GithubApiFailure>).value, '[]\n');
      expect(arguments.single, <String>[
        'gh',
        'pr',
        'list',
        '--repo',
        'github.com/acme/docs',
        '--head',
        'feat/x',
        '--state',
        'open',
        '--json',
        'number,url,title',
      ]);
      expect(folders.single, '/code/app');
      expect(environments.single['GH_TOKEN'], 'tok-secret');
    });

    test(
      'one is created with its body on the input, never an argument',
      () async {
        answer = ProcessResult(
          0,
          0,
          'https://github.com/acme/docs/pull/123\n',
          '',
        );

        final Result<String, GithubApiFailure> created = await create();

        expect(
          (created as Success<String, GithubApiFailure>).value,
          'https://github.com/acme/docs/pull/123',
        );
        expect(arguments.single, <String>[
          'gh',
          'pr',
          'create',
          '--repo',
          'github.com/acme/docs',
          '--base',
          'main',
          '--head',
          'feat/x',
          '--title',
          'Release notes',
          '--body-file',
          '-',
        ]);
        expect(inputs.single, 'Why it exists.\n');
        expect(folders.single, '/code/app');
        expect(arguments.single.join(' '), isNot(contains('tok-secret')));
      },
    );

    test('one that already exists is named with its address', () async {
      answer = ProcessResult(
        0,
        1,
        '',
        'a pull request for branch "feat/x" into branch "main" already '
            'exists:\nhttps://github.com/acme/docs/pull/12\n',
      );

      expect(
        (await create() as Failure<String, GithubApiFailure>).failure,
        const GithubApiPullRequestExists(
          'https://github.com/acme/docs/pull/12',
        ),
      );
    });

    test('any other refusal is what gh said', () async {
      answer = ProcessResult(
        0,
        1,
        '',
        'pull request create failed: GraphQL: No commits between main and '
            'feat/x (createPullRequest)\n',
      );

      expect(
        (await create() as Failure<String, GithubApiFailure>).failure,
        isA<GithubApiOperationFailed>(),
      );
      expect(written.single.exitCode, 1);
    });
  });

  Future<GithubApiFailure> failureOf() async =>
      (await api().repository('acme/docs', token: 'tok-secret')
              as Failure<String, GithubApiFailure>)
          .failure;

  test('a repository is asked of gh api, the body handed back', () async {
    final Result<String, GithubApiFailure> result = await api().repository(
      'acme/docs',
      token: 'tok-secret',
    );

    expect(
      (result as Success<String, GithubApiFailure>).value,
      '{"permissions":{}}',
    );
    expect(arguments.single, <String>[
      'gh',
      'api',
      '--hostname',
      'github.com',
      'repos/acme/docs',
    ]);
  });

  test(
    'the token travels in the environment and never as an argument',
    () async {
      await api().repository('acme/docs', token: 'tok-secret');

      expect(environments.single['GH_TOKEN'], 'tok-secret');
      expect(arguments.single.join(' '), isNot(contains('tok-secret')));
    },
  );

  test("each of gh's refusals has its own name", () async {
    answer = ProcessResult(0, 1, '', 'gh: Not Found (HTTP 404)\n');
    expect(await failureOf(), const GithubApiNotFound());

    answer = ProcessResult(0, 1, '', 'gh: Bad credentials (HTTP 401)\n');
    expect(await failureOf(), const GithubApiRefused(401));

    answer = ProcessResult(
      0,
      1,
      '',
      'error connecting to api.github.com\ncheck your internet connection',
    );
    expect(await failureOf(), isA<GithubApiUnreachable>());

    answer = ProcessResult(0, 1, '', 'gh: Server Error (HTTP 502)');
    expect(await failureOf(), isA<GithubApiOperationFailed>());
  });

  test('without gh there is nobody to ask', () async {
    thrown = const ProcessException('gh', <String>[], 'not found', 2);

    expect(await failureOf(), const GithubApiUnavailable('gh'));
  });

  test('a gh that outlives its time is out of reach', () async {
    thrown = TimeoutException('killed');

    expect(await failureOf(), isA<GithubApiUnreachable>());
  });

  group('the command log', () {
    test('writes the request down, and no token anywhere in it', () async {
      await api().repository('acme/docs', token: 'tok-secret');

      final CommandRecord record = written.single;
      expect(
        record.commandLine,
        'gh api --hostname github.com repos/acme/docs',
      );
      expect(record.exitCode, 0);
      expect(
        '${record.commandLine} ${record.output}',
        isNot(contains('tok-secret')),
      );
    });

    test('a refusal is written down with what gh said', () async {
      answer = ProcessResult(0, 1, '', 'gh: Not Found (HTTP 404)\n');

      await failureOf();

      expect(written.single.exitCode, 1);
      expect(written.single.output, 'gh: Not Found (HTTP 404)');
    });

    test('a gh not installed is written down as never run', () async {
      thrown = const ProcessException('gh', <String>[], 'not found', 2);

      await failureOf();

      expect(written.single.ran, isFalse);
    });

    test('a gh that never answered is written down unfinished', () async {
      thrown = TimeoutException('killed');

      await failureOf();

      expect(written.single.exitCode, isNull);
    });
  });

  group('the gate', () {
    test('is asked before gh starts, by key, with no token in sight', () async {
      await api().repository('acme/docs', token: 'tok-secret');

      final CommandRequest asked = gate.asked.single;
      expect(asked.key, 'gh api --hostname <host> repos/<repository>');
      expect(asked.isWrite, isFalse);
      expect(asked.commandLine, 'gh api --hostname github.com repos/acme/docs');
      expect(asked.toString(), isNot(contains('tok-secret')));
      expect(written.single.ticket, 7);
    });

    test('opening a pull request is the one that writes', () async {
      await create();

      expect(
        gate.asked.single.key,
        GithubCommandKeyEnum.createPullRequest.template,
      );
      expect(gate.asked.single.isWrite, isTrue);
    });

    test('a refused request never starts gh, and is not an error', () async {
      gate.allows = false;

      final GithubApiFailure refused =
          (await create() as Failure<String, GithubApiFailure>).failure;

      expect(refused, isA<GithubApiCommandDenied>());
      expect(refused.isDenial, isTrue);
      expect(arguments, isEmpty);
      expect(written, isEmpty);
    });

    test('no two keys are the same, and each is a gh command', () {
      final List<String> templates = GithubCommandKeyEnum.values
          .map((GithubCommandKeyEnum it) => it.template)
          .toList();

      expect(templates, everyElement(startsWith('gh ')));
      expect(templates.toSet(), hasLength(templates.length));
    });
  });
}

final class _Kept implements CommandLog {
  _Kept(this.records);

  final List<CommandRecord> records;

  @override
  void record(CommandRecord record) => records.add(record);
}

/// A gate that says yes or no to everything, and remembers what it was asked.
final class _Gate implements CommandGate, CommandPlan {
  final List<CommandRequest> asked = <CommandRequest>[];
  bool allows = true;

  @override
  CommandPlan plan(List<CommandRequest> commands) {
    asked.addAll(commands);
    return this;
  }

  @override
  Future<CommandVerdict> next() async => allows
      ? const CommandVerdict.run(ticket: 7)
      : const CommandVerdict.denied();

  @override
  void close() {}
}

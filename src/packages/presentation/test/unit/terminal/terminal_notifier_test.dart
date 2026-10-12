/// [TerminalNotifier]: a shell starts the first time the tab is drawn and
/// not before, there is one per space, and it ends with the space.
library;

import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Terminals terminals;
  late ProviderContainer container;

  const TerminalSizeValueObject size = TerminalSizeValueObject(
    columns: 80,
    rows: 24,
  );
  final SpaceEntity docs = SpaceEntity(
    root: '/work/app/docs',
    repositoryRoot: '/work/app',
    name: 'docs',
  );
  final SpaceEntity site = SpaceEntity(
    root: '/work/site',
    repositoryRoot: '/work/site',
    name: 'site',
  );

  setUp(() {
    terminals = _Terminals();
    container = ProviderContainer(
      overrides: <Override>[
        startTerminalProvider.overrideWithValue(
          StartTerminalUseCase(
            terminals: terminals,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Kept listened to, the way the panel keeps it.
    container.listen(terminalProvider, (_, _) {});
  });

  TerminalNotifier terminal() => container.read(terminalProvider.notifier);
  TerminalState state() => container.read(terminalProvider);
  void open(SpaceEntity space) =>
      container.read(spaceSessionProvider.notifier).open(space);

  test('starts nothing until the tab is drawn', () async {
    open(docs);
    await pumpEventQueue();

    expect(state(), const TerminalState.initial());
    expect(terminals.started, isEmpty);
  });

  test('the first drawing starts the shell, at the repository root', () async {
    open(docs);

    await terminal().show(size);

    expect(terminals.started.single.folder, '/work/app');
    expect(
      state(),
      const TerminalState.running(shell: 'zsh', folder: '/work/app'),
    );
  });

  test('a later drawing resizes it rather than starting another', () async {
    open(docs);
    await terminal().show(size);

    await terminal().show(const TerminalSizeValueObject(columns: 120, rows: 9));

    expect(terminals.started, hasLength(1));
    expect(terminals.started.single.sizes, <TerminalSizeValueObject>[
      const TerminalSizeValueObject(columns: 120, rows: 9),
    ]);
  });

  test('keeps what the shell drew, for the next panel', () async {
    open(docs);
    await terminal().show(size);
    final List<String> streamed = <String>[];
    final StreamSubscription<String> reading = terminal().output.listen(
      streamed.add,
    );
    addTearDown(reading.cancel);

    terminals.started.single.draw(r'docs % ');
    terminals.started.single.draw('git status\r\n');
    await pumpEventQueue();

    expect(terminal().transcript, 'docs % git status\r\n');
    expect(streamed, <String>['docs % ', 'git status\r\n']);
  });

  test('keeps at most its share, dropping the oldest first', () async {
    open(docs);
    await terminal().show(size);
    final String chunk = 'x' * (TerminalNotifier.kept ~/ 2);

    terminals.started.single
      ..draw('first')
      ..draw(chunk)
      ..draw(chunk);
    await pumpEventQueue();

    expect(terminal().transcript, '$chunk$chunk');
  });

  test('typing reaches the shell', () async {
    open(docs);
    await terminal().show(size);

    terminal().write('git status\r');

    expect(terminals.started.single.typed, <String>['git status\r']);
  });

  test('another space ends this shell, and starts none of its own', () async {
    open(docs);
    await terminal().show(size);
    final _Session first = terminals.started.single..draw('docs % ');
    await pumpEventQueue();

    open(site);
    await pumpEventQueue();

    expect(first.closed, isTrue);
    expect(state(), const TerminalState.initial());
    expect(terminal().transcript, isEmpty);
    expect(terminals.started, hasLength(1));
  });

  test('closing the space ends the shell', () async {
    open(docs);
    await terminal().show(size);

    container.read(spaceSessionProvider.notifier).close();
    await pumpEventQueue();

    expect(terminals.started.single.closed, isTrue);
  });

  test('a shell that answers after its space was left is ended', () async {
    terminals.hold = Completer<void>();
    open(docs);
    final Future<void> showing = terminal().show(size);

    open(site);
    terminals.hold!.complete();
    await showing;
    await pumpEventQueue();

    expect(terminals.started.single.closed, isTrue);
    expect(state(), const TerminalState.initial());
  });

  test('a shell that exits says so, and the next key starts another', () async {
    open(docs);
    await terminal().show(size);

    terminals.started.single.end(130);
    await pumpEventQueue();

    expect(
      state(),
      const TerminalState.exited(shell: 'zsh', folder: '/work/app', code: 130),
    );

    terminal().write('x');
    await pumpEventQueue();

    expect(terminals.started, hasLength(2));
    expect(terminals.started.last.typed, isEmpty);
    expect(state(), isA<TerminalRunning>());
  });

  test('a shell that would not start is a failure', () async {
    terminals.refuse = true;
    open(docs);

    await terminal().show(size);

    expect(state(), isA<TerminalFailed>());
  });

  group('the place it names', () {
    test('spells the home folder ~', () {
      expect(
        terminalPlaceOf('/Users/ana/work/docs', '/Users/ana'),
        '~/work/docs',
      );
      expect(terminalPlaceOf('/Users/ana', '/Users/ana/'), '~');
      expect(terminalPlaceOf(r'C:\Users\ana\docs', r'C:\Users\ana'), r'~\docs');
    });

    test('leaves a folder outside it, or a sibling sharing its name', () {
      expect(terminalPlaceOf('/srv/docs', '/Users/ana'), '/srv/docs');
      expect(
        terminalPlaceOf('/Users/anabel/x', '/Users/ana'),
        '/Users/anabel/x',
      );
      expect(terminalPlaceOf('/srv/docs', null), '/srv/docs');
    });
  });
}

final class _Terminals implements TerminalRepository {
  final List<_Session> started = <_Session>[];
  Completer<void>? hold;
  bool refuse = false;

  @override
  Future<Result<TerminalSessionPort, AppFailure>> start(
    String folder,
    TerminalSizeValueObject size,
  ) async {
    if (refuse) {
      return const Failure<TerminalSessionPort, AppFailure>(
        UnexpectedFailure('no pty'),
      );
    }
    final _Session session = _Session(folder);
    started.add(session);
    await hold?.future;
    return Success<TerminalSessionPort, AppFailure>(session);
  }
}

final class _Session implements TerminalSessionPort {
  _Session(this.folder);

  final StreamController<String> _output = StreamController<String>();
  final Completer<int> _exit = Completer<int>();
  final List<String> typed = <String>[];
  final List<TerminalSizeValueObject> sizes = <TerminalSizeValueObject>[];
  bool closed = false;

  void draw(String text) => _output.add(text);

  void end(int code) => _exit.complete(code);

  @override
  final String folder;

  @override
  String get shell => 'zsh';

  @override
  Stream<String> get output => _output.stream;

  @override
  Future<int> get exited => _exit.future;

  @override
  void write(String input) => typed.add(input);

  @override
  void resize(TerminalSizeValueObject size) => sizes.add(size);

  @override
  void close() => closed = true;
}

final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}

/// [TerminalRepositoryImpl] over a pseudo-terminal that is a fake: the bytes
/// become text, typing becomes bytes, and a shell is killed once at most.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _FakeTerminal terminal;
  late TerminalRepositoryImpl repository;

  setUp(() {
    terminal = _FakeTerminal();
    repository = TerminalRepositoryImpl(
      source: TerminalDataSource(terminal: terminal),
    );
  });

  Future<TerminalSessionPort> started({String folder = '/work/docs'}) async {
    final Result<TerminalSessionPort, AppFailure> result = await repository
        .start(folder, const TerminalSizeValueObject(columns: 80, rows: 24));
    return switch (result) {
      Success<TerminalSessionPort, AppFailure>(
        value: final TerminalSessionPort session,
      ) =>
        session,
      Failure<TerminalSessionPort, AppFailure>() => throw StateError('$result'),
    };
  }

  test('starts the shell in the folder, at the size asked', () async {
    final TerminalSessionPort session = await started();

    expect(terminal.asked, <String>['/work/docs 80x24']);
    expect(session.folder, '/work/docs');
  });

  test('names the shell by its executable, without `.exe`', () async {
    terminal.executable = '/bin/zsh';
    expect((await started()).shell, 'zsh');

    terminal.executable = r'C:\Windows\System32\cmd.exe';
    expect((await started()).shell, 'cmd');
  });

  test('a character split across two chunks arrives whole', () async {
    final TerminalSessionPort session = await started();
    final List<String> read = <String>[];
    final StreamSubscription<String> reading = session.output.listen(read.add);
    addTearDown(reading.cancel);
    final Uint8List bytes = Uint8List.fromList(utf8.encode('ação'));

    terminal.process.send(bytes.sublist(0, 2));
    terminal.process.send(bytes.sublist(2));
    await pumpEventQueue();

    expect(read.join(), 'ação');
  });

  test('typing reaches the shell as UTF-8', () async {
    final TerminalSessionPort session = await started();

    session.write('é\r');

    expect(utf8.decode(terminal.process.written.single), 'é\r');
  });

  test('a new size reaches the shell', () async {
    final TerminalSessionPort session = await started();

    session.resize(const TerminalSizeValueObject(columns: 120, rows: 9));

    expect(terminal.process.sizes, <(int, int)>[(120, 9)]);
  });

  test('closing kills the shell once', () async {
    final TerminalSessionPort session = await started();

    session
      ..close()
      ..close();

    expect(terminal.process.kills, 1);
  });

  test('a shell that ended is not killed, nor written to', () async {
    final TerminalSessionPort session = await started();
    terminal.process.end(0);

    expect(await session.exited, 0);
    session
      ..write('ls\r')
      ..close();

    expect(terminal.process.kills, 0);
    expect(terminal.process.written, isEmpty);
  });

  test("the capability's failure passes through", () async {
    terminal.failure = const PseudoTerminalUnavailable('/bin/zsh');

    final Result<TerminalSessionPort, AppFailure> result = await repository
        .start('/work', const TerminalSizeValueObject(columns: 80, rows: 24));

    expect(
      result,
      isA<Failure<TerminalSessionPort, AppFailure>>().having(
        (Failure<TerminalSessionPort, AppFailure> it) => it.failure,
        'failure',
        const PseudoTerminalUnavailable('/bin/zsh'),
      ),
    );
  });
}

final class _FakeTerminal implements PseudoTerminal {
  final List<String> asked = <String>[];
  String executable = '/bin/zsh';
  PseudoTerminalFailure? failure;
  late _FakeProcess process;

  @override
  Future<Result<PseudoTerminalProcess, PseudoTerminalFailure>> start({
    required String folder,
    required int columns,
    required int rows,
  }) async {
    asked.add('$folder ${columns}x$rows');
    if (failure case final PseudoTerminalFailure refused) {
      return Failure<PseudoTerminalProcess, PseudoTerminalFailure>(refused);
    }
    process = _FakeProcess(executable);
    return Success<PseudoTerminalProcess, PseudoTerminalFailure>(process);
  }
}

final class _FakeProcess implements PseudoTerminalProcess {
  _FakeProcess(this.executable);

  final StreamController<Uint8List> _output = StreamController<Uint8List>();
  final Completer<int> _exit = Completer<int>();
  final List<Uint8List> written = <Uint8List>[];
  final List<(int, int)> sizes = <(int, int)>[];
  int kills = 0;

  @override
  final String executable;

  void send(Uint8List bytes) => _output.add(bytes);

  void end(int code) {
    _exit.complete(code);
    unawaited(_output.close());
  }

  @override
  Stream<Uint8List> get output => _output.stream;

  @override
  Future<int> get exitCode => _exit.future;

  @override
  void kill() => kills++;

  @override
  void resize(int columns, int rows) => sizes.add((columns, rows));

  @override
  void write(Uint8List data) => written.add(data);
}

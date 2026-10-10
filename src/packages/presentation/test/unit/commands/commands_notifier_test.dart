import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  CommandsNotifier commands() => container.read(commandsProvider.notifier);

  CommandsState state() => container.read(commandsProvider);

  CommandRecord ran(String argument, {int? exitCode = 0}) => CommandRecord.of(
    executable: 'git',
    arguments: <String>[argument],
    startedAt: DateTime(2026, 10, 8),
    duration: const Duration(milliseconds: 12),
    exitCode: exitCode,
    stdout: 'password=hunter2',
  );

  test('starts empty', () {
    expect(state().rows, isEmpty);
    expect(state().total, 0);
  });

  test('is the log the capabilities write to', () {
    final CommandLog log = commands()..record(ran('status'));

    expect(log, isA<CommandsNotifier>());

    expect(state().rows.single.record.arguments, <String>['status']);
  });

  test('keeps the rows in the order they ran, newest last', () {
    commands()
      ..record(ran('status'))
      ..record(ran('fetch'));

    expect(
      state().rows.map((CommandRow it) => it.record.arguments.single),
      <String>['status', 'fetch'],
    );
    expect(state().rows.map((CommandRow it) => it.id), <int>[0, 1]);
  });

  test('what reaches it has already lost its secrets', () {
    commands().record(ran('credential'));

    expect(state().rows.single.record.output, CommandRecord.hidden);
  });

  test('keeps the last five hundred, and counts every one', () {
    for (int i = 0; i < CommandsNotifier.kept + 20; i++) {
      commands().record(ran('$i'));
    }

    expect(state().rows, hasLength(CommandsNotifier.kept));
    expect(state().rows.first.record.arguments.single, '20');
    expect(state().rows.first.id, 20);
    expect(state().total, CommandsNotifier.kept + 20);
  });

  test('a row dropped off the top is no longer open', () {
    commands()
      ..record(ran('first'))
      ..toggle(0);
    for (int i = 0; i < CommandsNotifier.kept; i++) {
      commands().record(ran('$i'));
    }

    expect(state().expanded, isEmpty);
  });

  test('a row opens onto its output and closes again', () {
    commands()
      ..record(ran('status'))
      ..toggle(0);
    expect(state().expanded, <int>{0});

    commands().toggle(0);
    expect(state().expanded, isEmpty);
  });

  group('showing the command that failed', () {
    test('opens the last failure and asks the panel to go to it', () {
      commands()
        ..record(ran('fetch', exitCode: 128))
        ..record(ran('push', exitCode: 1))
        ..record(ran('status'));

      expect(commands().revealLastFailure(), isTrue);

      expect(state().revealing, 1);
      expect(state().expanded, <int>{1});
    });

    test('the last failure of the kind asked for, past later ones', () {
      commands()
        ..record(ran('fetch', exitCode: 128))
        ..record(ran('config', exitCode: 1));

      expect(
        commands().revealLastFailure(
          (CommandRecord it) => it.arguments.contains('fetch'),
        ),
        isTrue,
      );
      expect(state().revealing, 0);
    });

    test('an exit asked for as an answer is not a failure to show', () {
      commands()
        ..record(ran('fetch', exitCode: 128))
        ..record(
          CommandRecord.of(
            executable: 'git',
            arguments: const <String>['config', '--get', 'user.name'],
            startedAt: DateTime(2026, 10, 8),
            duration: Duration.zero,
            exitCode: 1,
            answers: const <int>{1},
          ),
        );

      expect(commands().revealLastFailure(), isTrue);
      expect(state().revealing, 0);
    });

    test('a command that never ended counts as a failure', () {
      commands().record(ran('fetch', exitCode: null));

      expect(commands().revealLastFailure(), isTrue);
      expect(state().revealing, 0);
    });

    test('with nothing failed there is nothing to show', () {
      commands().record(ran('status'));

      expect(commands().revealLastFailure(), isFalse);
      expect(state().revealing, isNull);
    });

    test('the panel says when it got there', () {
      commands()
        ..record(ran('fetch', exitCode: 1))
        ..revealLastFailure()
        ..revealed();

      expect(state().revealing, isNull);
      expect(state().expanded, <int>{0});
    });
  });
}

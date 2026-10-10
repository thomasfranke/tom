/// One process the app ran, as it ran, with every secret taken out.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/src/command_request.dart';
import 'package:tom_core/src/command_stage_enum.dart';

part 'command_record.freezed.dart';

/// A program, its arguments, when it started, how long it took, how it ended
/// and what it printed.
///
/// Built through [CommandRecord.of], the one place a secret is taken out, so
/// nothing a [CommandLog](command_log.dart) holds can carry one: the
/// environment is never read, and a line that looks like a credential is
/// replaced whole (`docs/product/workspace/commands/doc.md`).
@freezed
abstract class CommandRecord with _$CommandRecord {
  /// Creates a record exactly as given; capabilities use [CommandRecord.of].
  const factory CommandRecord({
    /// The program, as it was asked for — `git`, `gh`, `open`.
    required String executable,

    /// Its arguments, one entry per argument.
    required List<String> arguments,

    /// When it was started.
    required DateTime startedAt,

    /// How long it ran, start to end.
    required Duration duration,

    /// What it exited with, or null when it never ended on its own — not
    /// started, or killed for taking too long.
    int? exitCode,

    /// What it printed, standard output then standard error.
    @Default('') String output,

    /// The exit codes the caller asked for as answers rather than errors —
    /// `git config --get` of a key nobody set is 1, and that is the answer.
    @Default(<int>{}) Set<int> answers,

    /// False when the program could not even be started — not installed, or
    /// a folder it could not run in.
    @Default(true) bool ran,

    /// Where it is between asked for and ended; ended, for a record written
    /// once the process is over — which every one was before commands could
    /// wait.
    @Default(CommandStageEnum.ended) CommandStageEnum stage,

    /// What the gate that let it through knows it by, or null when nothing
    /// waited: how a record finds the row that was already there for it.
    int? ticket,
  }) = _CommandRecord;

  /// The record of [request] before it has started: asked [at], waiting.
  factory CommandRecord.asked(CommandRequest request, {required DateTime at}) =>
      CommandRecord(
        executable: request.executable,
        arguments: request.arguments,
        startedAt: at,
        duration: Duration.zero,
        stage: CommandStageEnum.waiting,
      );

  /// Builds the record a capability hands its log: [stdout] and [stderr]
  /// joined, cut to [outputLines] lines each and read line by line for
  /// anything secret.
  ///
  /// [secretOutput] is for the two programs whose whole answer is a
  /// credential — `git credential fill` and `gh auth token` — whose standard
  /// output is never kept, whatever it looks like.
  factory CommandRecord.of({
    required String executable,
    required List<String> arguments,
    required DateTime startedAt,
    required Duration duration,
    int? exitCode,
    String stdout = '',
    String stderr = '',
    bool secretOutput = false,
    Set<int> answers = const <int>{},
    bool ran = true,
    int? ticket,
  }) => CommandRecord(
    executable: executable,
    arguments: shownArguments(arguments),
    startedAt: startedAt,
    duration: duration,
    exitCode: exitCode,
    answers: answers,
    ran: ran,
    ticket: ticket,
    output: <String>[
      if (secretOutput && stdout.trim().isNotEmpty)
        hidden
      else
        _shownOutput(stdout),
      _shownOutput(stderr),
    ].where((String part) => part.isNotEmpty).join('\n'),
  );

  const CommandRecord._();

  /// What stands where a secret was.
  static const String hidden = '••••';

  /// How many lines of each stream are kept: a `git show` of a long document
  /// is the document, and five hundred of those are not a list.
  static const int outputLines = 200;

  /// Whether the caller took how it ended as an error: no exit at all, or a
  /// non-zero one it did not ask for as an answer. Never true of a command
  /// that has not ended, nor of one somebody refused.
  bool get failed =>
      stage == CommandStageEnum.ended &&
      (exitCode == null || (exitCode != 0 && !answers.contains(exitCode)));

  /// Whether it exited non-zero as an answer the caller expected — neither a
  /// success nor a failure.
  bool get answered =>
      stage == CommandStageEnum.ended &&
      exitCode != null &&
      exitCode != 0 &&
      answers.contains(exitCode);

  /// The command as a line a terminal would run: an argument holding a space
  /// or a quote is put in single quotes, so a copied line is the same
  /// command.
  String get commandLine => lineOf(executable, arguments);

  /// [executable] and [arguments] as one line, quoted as [commandLine] is.
  static String lineOf(String executable, List<String> arguments) =>
      <String>[executable, ...arguments].map(_quoted).join(' ');

  /// [arguments] as they may be shown: a password or a token taken out, a
  /// control character spelled the way git's own formats spell it.
  static List<String> shownArguments(List<String> arguments) =>
      List<String>.unmodifiable(arguments.map(_shownArgument));

  /// A line holding a password, a token or an authorisation, which is
  /// replaced whole rather than cut, because where a secret ends is a guess.
  static final RegExp _secretLine = RegExp(
    r'password=|oauth|authorization:|gh[opsu]_[A-Za-z0-9]+|github_pat_\w+',
    caseSensitive: false,
  );

  /// The password of an address that carries one — `https://me:pw@host`.
  static final RegExp _addressPassword = RegExp(
    r'([a-z][a-z0-9+.-]*://[^/:@\s]+):[^@/\s]+@',
    caseSensitive: false,
  );

  /// A token anywhere in an argument.
  static final RegExp _token = RegExp(r'gh[opsu]_[A-Za-z0-9]+|github_pat_\w+');

  /// A character a terminal would not print: git's `-z` and format
  /// separators.
  static final RegExp _control = RegExp('[\u0000-\u0008\u000b-\u001f]');

  /// What a terminal can type without quoting.
  static final RegExp _plain = RegExp(r'^[A-Za-z0-9_@%+=:,./^~-]+$');

  /// [argument] with a password or a token taken out, and a control
  /// character spelled the way git's own formats spell it (`%x1f`).
  static String _shownArgument(String argument) => argument
      .replaceAllMapped(_addressPassword, (Match it) => '${it[1]}:$hidden@')
      .replaceAll(_token, hidden)
      .replaceAllMapped(
        _control,
        (Match it) =>
            '%x${it[0]!.codeUnitAt(0).toRadixString(16).padLeft(2, '0')}',
      );

  /// [stream] as lines a person can read, secrets replaced and cut to
  /// [outputLines].
  static String _shownOutput(String stream) {
    final List<String> lines = stream
        .replaceAll(RegExp('[\u0000\u001e]'), '\n')
        .replaceAll(_control, ' ')
        .trimRight()
        .split('\n');
    if (lines.length == 1 && lines.single.trim().isEmpty) {
      return '';
    }
    return <String>[
      for (final String line in lines.take(outputLines))
        _secretLine.hasMatch(line) ? hidden : line,
      if (lines.length > outputLines) '…',
    ].join('\n');
  }

  static String _quoted(String argument) => _plain.hasMatch(argument)
      ? argument
      : "'${argument.replaceAll("'", r"'\''")}'";
}

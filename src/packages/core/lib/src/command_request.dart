/// What a capability says about a command before it runs it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/src/command_record.dart';

part 'command_request.freezed.dart';

/// The name a capability gives one of the commands it can run.
///
/// An enum per capability implements it, so everything the app can run is
/// enumerable and a list of what is allowed can hold every one.
abstract interface class CommandKey {
  /// The command as the program receives it, flags included, with a
  /// placeholder — `<file>`, `<branch>` — where a value goes.
  ///
  /// Flags are part of it because one subcommand does a safe thing and a
  /// destructive one: `restore --staged` against `restore --worktree`.
  String get template;

  /// Whether it changes the repository, the remote or the host, rather than
  /// only reading them.
  bool get isWrite;
}

/// One command about to run: its [key], and the line it will be run as.
///
/// Built through [CommandRequest.of], which takes the secrets out the way
/// [CommandRecord.of] does, so no gate can be handed one.
@freezed
abstract class CommandRequest with _$CommandRequest {
  /// Creates a request exactly as given; capabilities use
  /// [CommandRequest.of].
  const factory CommandRequest({
    /// The command's template, [CommandKey.template].
    required String key,

    /// The program, as it will be asked for.
    required String executable,

    /// Its arguments as they may be shown, one entry per argument.
    required List<String> arguments,

    /// Whether it writes, [CommandKey.isWrite].
    required bool isWrite,
  }) = _CommandRequest;

  /// The request for running [executable] with [arguments] as [key].
  factory CommandRequest.of({
    required CommandKey key,
    required String executable,
    required List<String> arguments,
  }) => CommandRequest(
    key: key.template,
    executable: executable,
    arguments: CommandRecord.shownArguments(arguments),
    isWrite: key.isWrite,
  );

  const CommandRequest._();

  /// The command as a line a terminal would run.
  String get commandLine => CommandRecord.lineOf(executable, arguments);
}

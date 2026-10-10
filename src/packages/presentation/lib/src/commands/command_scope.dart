/// The action a command is asked for inside, carried without telling git.
library;

import 'dart:async';

import 'package:tom_presentation/src/commands/command_action_enum.dart';

/// One run of an action: every command asked inside it is one plan.
///
/// A zone value, because the capabilities that ask sit four layers below
/// and may not learn a product word ([Decision 38](../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
/// **Read in one place — `CommandsNotifier` — and nowhere below
/// presentation**; an object per run, so two pushes are two plans.
final class CommandScope {
  CommandScope._(this.action);

  /// What the run is called.
  final CommandActionEnum action;

  static final Object _zoneKey = Object();

  /// Runs [body] as [action]. Wrap the use-case call and nothing after it:
  /// what is read again once it ends is another action, not this one's tail.
  static Future<T> run<T>(
    CommandActionEnum action,
    Future<T> Function() body,
  ) => runZoned(
    body,
    zoneValues: <Object, Object>{_zoneKey: CommandScope._(action)},
  );

  /// The run the caller is inside, or null outside any.
  static CommandScope? get current => Zone.current[_zoneKey] as CommandScope?;
}

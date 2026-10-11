/// Every process the app ran this session, and every one waiting to.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/commands/command_row.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/commands/commands_providers.dart';
import 'package:tom_presentation/src/commands/commands_state.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/preferences/preferences_notifier.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';
import 'package:tom_presentation/src/workspace/workspace_notifier.dart';

part 'commands_notifier.g.dart';

/// The [CommandLog] the capabilities write to, the [CommandGate] they ask,
/// and the one list the panel reads — a command is the same row before and
/// after it runs ([Decision 36](../../../../../../docs/technical/decisions/036-every-command-is-written-down.md),
/// [Decision 38](../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
///
/// **Automatic asks nobody and lists a command once it ended**, as before
/// there was a gate. In Semi-automatic a command the file allows runs at
/// once and says so; in Manual every one waits. Commands asked together, or
/// inside one [CommandScope], are one plan, approved top down.
///
/// Kept alive for the window's life and **never written to disk**: a file
/// would be a second place a command's output could leak from.
@Riverpod(keepAlive: true)
class CommandsNotifier extends _$CommandsNotifier
    implements CommandLog, CommandGate {
  /// How many rows are kept; the oldest that are over go first.
  static const int kept = 500;

  /// The bottom panel's id, here because the list opens it by itself when
  /// a command starts waiting — the one time it does.
  static const String panel = 'tom.commands';

  /// What each row not yet over is waited on through, by [CommandRow.id].
  final Map<int, Completer<CommandVerdict>> _verdicts =
      <int, Completer<CommandVerdict>>{};

  /// The rows whose capability stands at the gate, ready to start.
  final Set<int> _reached = <int>{};

  /// The rows the person said `Run` to.
  final Set<int> _approved = <int>{};

  /// The plan each action's run was given.
  final Expando<int> _planOfScope = Expando<int>();

  /// The plans a refusal stopped: what is asked in them later never runs.
  final Set<int> _stopped = <int>{};

  int _plans = 0;
  int _reconsidering = 0;
  bool _followsMode = false;

  @override
  CommandsState build() {
    _followsMode = false;
    // Leaving a space cancels what waits there: a command approved later
    // would run against a repository nobody is looking at any more.
    ref
      ..listen<SpaceEntity?>(
        spaceSessionProvider.select(
          (SpaceSessionState? session) => session?.space,
        ),
        (SpaceEntity? _, SpaceEntity? _) => _cancelWaiting(),
      )
      ..onDispose(() {
        for (final Completer<CommandVerdict> verdict in _verdicts.values) {
          verdict.complete(const CommandVerdict.denied());
        }
        _verdicts.clear();
      });
    return const CommandsState();
  }

  @override
  void record(CommandRecord record) {
    // A process can end after the window has gone; nobody is listing it.
    if (!ref.mounted) {
      return;
    }
    final int? ticket = record.ticket;
    if (ticket != null &&
        state.rows.any((CommandRow row) => row.id == ticket)) {
      // The row was already there, waiting or running: it becomes this.
      state = state.copyWith(
        rows: List<CommandRow>.unmodifiable(<CommandRow>[
          for (final CommandRow row in state.rows)
            row.id == ticket ? row.copyWith(record: record) : row,
        ]),
      );
      return;
    }
    _append(<CommandRow>[CommandRow(id: state.total, record: record)]);
  }

  @override
  CommandPlan plan(List<CommandRequest> commands) =>
      _AskedPlan(this, _admit(commands, CommandScope.current));

  /// Lets the waiting row [id] start. Nothing for a row that waits behind
  /// another, or is not waiting at all.
  void run(int id) {
    if (_approvable(id) != null) {
      _approved.add(id);
      _settle();
    }
  }

  /// Refuses the waiting row [id]: it is denied, every command still
  /// waiting in its plan is cancelled, and what already ran stays ran.
  void deny(int id) {
    final CommandRow? row = _approvable(id);
    if (row == null) {
      return;
    }
    _stopped.add(row.plan!);
    _end(<int, CommandStageEnum>{
      for (final CommandRow other in state.rows)
        if (other.plan == row.plan && other.stage == CommandStageEnum.waiting)
          other.id: other.id == id
              ? CommandStageEnum.denied
              : CommandStageEnum.cancelled,
    });
  }

  /// `Always allow` on the waiting row [id]: runs it and writes `true`
  /// beside its key — in Semi-automatic. **In Manual nothing runs**: the
  /// list is not consulted there, so the press raises a question instead
  /// ([CommandsState.pendingSwitch]), answered by [switchToSemiAndAllow] or
  /// [stayInManual].
  Future<void> alwaysAllow(int id) async {
    final CommandRow? row = _approvable(id);
    if (row == null) {
      return;
    }
    if (ref.read(preferencesProvider).gitApprovals ==
        GitApprovalModeEnum.manual) {
      state = state.copyWith(pendingSwitch: id);
      return;
    }
    await _allow(row);
  }

  /// Answers the question [alwaysAllow] raised with yes: the mode becomes
  /// Semi-automatic, the command is allowed from now on, and it runs. Every
  /// other command stays `false`, so what else waits keeps waiting.
  Future<void> switchToSemiAndAllow() async {
    final int? id = state.pendingSwitch;
    final CommandRow? row = id == null ? null : _approvable(id);
    state = state.copyWith(pendingSwitch: null);
    if (row == null) {
      return;
    }
    ref
        .read(preferencesProvider.notifier)
        .chooseGitApprovals(GitApprovalModeEnum.semi);
    await _allow(row);
  }

  /// Answers the question with no: the mode stays Manual and the command
  /// keeps waiting, its three answers still offered.
  void stayInManual() => state = state.copyWith(pendingSwitch: null);

  /// Judges what waits again, by the mode and the file as they are now —
  /// after the mode changed, or the file was saved by hand.
  ///
  /// **Automatic runs everything that waits**, in its order. Semi-automatic
  /// runs what the file allows and leaves the rest waiting. Manual leaves
  /// everything waiting, a command the file had allowed and that had not
  /// started included. What is running, ran or was refused is never touched.
  Future<void> reconsider() async {
    if (!ref.exists(preferencesProvider)) {
      return;
    }
    final int generation = ++_reconsidering;
    final GitApprovalModeEnum mode = ref.read(preferencesProvider).gitApprovals;
    final ApprovalsValueObject list = mode == GitApprovalModeEnum.semi
        ? await ref.read(readApprovalsProvider).read()
        : ApprovalsValueObject.none;
    if (!ref.mounted || generation != _reconsidering) {
      return;
    }
    bool allowed(CommandRow row) => switch (mode) {
      GitApprovalModeEnum.automatic => true,
      GitApprovalModeEnum.semi => list.allows(row.key ?? ''),
      GitApprovalModeEnum.manual => false,
    };
    state = state.copyWith(
      rows: List<CommandRow>.unmodifiable(<CommandRow>[
        for (final CommandRow row in state.rows)
          row.stage == CommandStageEnum.waiting && row.plan != null
              ? row.copyWith(isAllowed: allowed(row))
              : row,
      ]),
    );
    _settle();
  }

  /// Opens the row [id] onto its output, or closes it.
  void toggle(int id) => state = state.copyWith(
    expanded: state.expanded.contains(id)
        ? (<int>{...state.expanded}..remove(id))
        : <int>{...state.expanded, id},
  );

  /// Opens the last command that failed — the last [matching] one, when
  /// given — and asks the panel to scroll to it: what a failure's `Show the
  /// command` does. False when none did.
  ///
  /// [matching] because a failure is not always the last: reading git runs
  /// commands whose ordinary answer is an exit 1, `git config --get` of a key
  /// nobody set among them.
  bool revealLastFailure([bool Function(CommandRecord record)? matching]) {
    final CommandRow? failed = state.rows
        .where(
          (CommandRow row) =>
              row.record.failed && (matching?.call(row.record) ?? true),
        )
        .lastOrNull;
    if (failed == null) {
      return false;
    }
    state = state.copyWith(
      expanded: <int>{...state.expanded, failed.id},
      revealing: failed.id,
    );
    return true;
  }

  /// Says the panel has scrolled to the row it was asked for.
  void revealed() => state = state.copyWith(revealing: null);

  /// The rows [commands] were given — null where nothing has to wait — once
  /// the mode and the file have said who is asked.
  Future<List<int?>> _admit(
    List<CommandRequest> commands,
    CommandScope? scope,
  ) async {
    final List<int?> unasked = List<int?>.filled(commands.length, null);
    final GitApprovalModeEnum mode = await _mode();
    if (!ref.mounted || mode == GitApprovalModeEnum.automatic) {
      return unasked;
    }
    final ApprovalsValueObject list = mode == GitApprovalModeEnum.semi
        ? await ref.read(readApprovalsProvider).read()
        : ApprovalsValueObject.none;
    if (!ref.mounted) {
      return unasked;
    }
    final int plan = scope == null
        ? _plans++
        : (_planOfScope[scope] ??= _plans++);
    // A plan somebody already said no to: what it asks next never runs.
    final bool stopped = _stopped.contains(plan);
    final DateTime now = DateTime.now();
    final List<CommandRow> asked = <CommandRow>[
      for (final (int at, CommandRequest command) in commands.indexed)
        CommandRow(
          id: state.total + at,
          record: CommandRecord.asked(command, at: now).copyWith(
            stage: stopped
                ? CommandStageEnum.cancelled
                : CommandStageEnum.waiting,
          ),
          plan: plan,
          action: scope?.action,
          key: command.key,
          isWrite: command.isWrite,
          isAllowed: list.allows(command.key),
        ),
    ];
    if (!stopped) {
      for (final CommandRow row in asked) {
        _verdicts[row.id] = Completer<CommandVerdict>();
      }
    }
    _append(asked);
    // A command waiting where nobody looks is an app that seems hung.
    if (!stopped && asked.any((CommandRow row) => !row.isAllowed)) {
      ref.read(workspaceProvider.notifier).showBottomPanel(panel);
    }
    return <int?>[for (final CommandRow row in asked) row.id];
  }

  /// Who approves, once the stored preferences have been read — and from
  /// the first question on, a change of mode is followed.
  ///
  /// Asked here and not in `build`, so a window that runs nothing through
  /// this gate never needs the preferences wired.
  Future<GitApprovalModeEnum> _mode() async {
    final PreferencesNotifier preferences = ref.read(
      preferencesProvider.notifier,
    );
    if (!_followsMode) {
      _followsMode = true;
      ref.listen(
        preferencesProvider.select(
          (PreferencesValueObject it) => it.gitApprovals,
        ),
        (GitApprovalModeEnum? _, GitApprovalModeEnum _) =>
            unawaited(reconsider()),
      );
    }
    await preferences.loaded;
    return ref.mounted
        ? ref.read(preferencesProvider).gitApprovals
        : GitApprovalModeEnum.automatic;
  }

  /// What the capability standing at row [id] waits on: run at once where
  /// nothing waits, denied where the row was cancelled before it got here.
  Future<CommandVerdict> _verdictOn(int? id) {
    if (id == null) {
      return Future<CommandVerdict>.value(const CommandVerdict.run());
    }
    final Completer<CommandVerdict>? verdict = _verdicts[id];
    if (verdict == null) {
      return Future<CommandVerdict>.value(const CommandVerdict.denied());
    }
    _reached.add(id);
    _settle();
    return verdict.future;
  }

  /// Starts every waiting command whose capability is at the gate and that
  /// may run: the list allows it, or the person said so.
  void _settle() {
    final Set<int> starting = <int>{
      for (final CommandRow row in state.rows)
        if (row.stage == CommandStageEnum.waiting &&
            _reached.contains(row.id) &&
            (row.isAllowed || _approved.contains(row.id)))
          row.id,
    };
    if (starting.isEmpty) {
      return;
    }
    final DateTime now = DateTime.now();
    state = state.copyWith(
      rows: List<CommandRow>.unmodifiable(<CommandRow>[
        for (final CommandRow row in state.rows)
          starting.contains(row.id)
              ? row.copyWith(
                  record: row.record.copyWith(
                    stage: CommandStageEnum.running,
                    startedAt: now,
                  ),
                )
              : row,
      ]),
    );
    for (final int id in starting) {
      _reached.remove(id);
      _approved.remove(id);
      _verdicts.remove(id)?.complete(CommandVerdict.run(ticket: id));
    }
  }

  /// Runs [row], writes `true` beside its key, and judges what else waits
  /// by the file as it now is — the same command asked twice runs twice.
  Future<void> _allow(CommandRow row) async {
    _approved.add(row.id);
    _settle();
    final String? key = row.key;
    if (key == null) {
      return;
    }
    // A file that cannot be written costs the "always", never the run.
    await ref.read(allowCommandProvider).allow(key);
    if (!ref.mounted) {
      return;
    }
    // The list's own tab, when it is open, is told the file changed.
    if (ref
            .read(spaceSessionProvider)
            ?.appFiles
            .contains(PreferencesNotifier.approvalsFile) ??
        false) {
      await ref
          .read(editorProvider.notifier)
          .appFileChanged(PreferencesNotifier.approvalsFile);
    }
    await reconsider();
  }

  /// Cancels the rows of [ids] still waiting: their plan ended early.
  void _cancel(List<int?> ids) {
    if (ref.mounted) {
      _end(<int, CommandStageEnum>{
        for (final CommandRow row in state.rows)
          if (ids.contains(row.id) && row.stage == CommandStageEnum.waiting)
            row.id: CommandStageEnum.cancelled,
      });
    }
  }

  /// Cancels everything that waits.
  void _cancelWaiting() => _end(<int, CommandStageEnum>{
    for (final CommandRow row in state.rows)
      if (row.stage == CommandStageEnum.waiting)
        row.id: CommandStageEnum.cancelled,
  });

  /// Puts each row of [stages] in the stage given — denied or cancelled —
  /// and answers whoever waits on it with a refusal.
  void _end(Map<int, CommandStageEnum> stages) {
    if (stages.isEmpty) {
      return;
    }
    state = state.copyWith(
      rows: List<CommandRow>.unmodifiable(<CommandRow>[
        for (final CommandRow row in state.rows)
          switch (stages[row.id]) {
            final CommandStageEnum stage => row.copyWith(
              record: row.record.copyWith(stage: stage),
            ),
            null => row,
          },
      ]),
      pendingSwitch: stages.containsKey(state.pendingSwitch)
          ? null
          : state.pendingSwitch,
    );
    for (final int id in stages.keys) {
      _reached.remove(id);
      _approved.remove(id);
      _verdicts.remove(id)?.complete(const CommandVerdict.denied());
    }
  }

  /// The waiting row [id] when it is the one of its plan that can be
  /// answered now, or null.
  CommandRow? _approvable(int id) {
    final CommandRow? row = state.rows
        .where((CommandRow it) => it.id == id)
        .firstOrNull;
    return row != null && state.isApprovable(row) ? row : null;
  }

  /// Adds [added] at the end, dropping the oldest rows that are over when
  /// there are more than [kept] — never one that still waits or runs.
  void _append(List<CommandRow> added) {
    final List<CommandRow> rows = <CommandRow>[...state.rows, ...added];
    for (int at = 0; rows.length > kept && at < rows.length;) {
      if (rows[at].stage.isOver) {
        rows.removeAt(at);
      } else {
        at++;
      }
    }
    final Set<int> held = <int>{for (final CommandRow row in rows) row.id};
    state = state.copyWith(
      rows: List<CommandRow>.unmodifiable(rows),
      total: state.total + added.length,
      expanded: state.expanded.intersection(held),
    );
  }
}

/// The commands one method declared together, each waited on in turn.
final class _AskedPlan implements CommandPlan {
  _AskedPlan(this._gate, this._rows);

  final CommandsNotifier _gate;

  /// The row each command was given, null where nothing has to wait.
  final Future<List<int?>> _rows;

  int _next = 0;

  @override
  Future<CommandVerdict> next() async {
    final int at = _next++;
    return _gate._verdictOn((await _rows)[at]);
  }

  @override
  void close() => unawaited(_rows.then(_gate._cancel));
}

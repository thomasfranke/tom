// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commands_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(CommandsNotifier)
final commandsProvider = CommandsNotifierProvider._();

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
final class CommandsNotifierProvider
    extends $NotifierProvider<CommandsNotifier, CommandsState> {
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
  CommandsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commandsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commandsNotifierHash();

  @$internal
  @override
  CommandsNotifier create() => CommandsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommandsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommandsState>(value),
    );
  }
}

String _$commandsNotifierHash() => r'eeeacc0d0648a76fd3adbf9e9becb999c04b6a24';

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

abstract class _$CommandsNotifier extends $Notifier<CommandsState> {
  CommandsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CommandsState, CommandsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CommandsState, CommandsState>,
              CommandsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

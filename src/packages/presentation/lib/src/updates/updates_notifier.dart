/// Drives the update check: asked for, never on its own.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/preferences/preferences_notifier.dart';
import 'package:tom_presentation/src/updates/updates_providers.dart';
import 'package:tom_presentation/src/updates/updates_state.dart';

part 'updates_notifier.g.dart';

/// What the host last said about a newer TOM
/// (`docs/product/about/doc.md`).
///
/// Kept alive: the gear's dot and the status bar read it from the window,
/// long before anybody opens the dialog. It asks on its own only when the
/// person ticked `Check for updates when TOM opens` — once, for the
/// preference as the store first held it.
@Riverpod(keepAlive: true)
class UpdatesNotifier extends _$UpdatesNotifier {
  /// Compares the latest release with the running one.
  CheckForUpdatesUseCase get checkForUpdates =>
      ref.read(checkForUpdatesProvider);

  bool _askedAtOpening = false;

  @override
  UpdatesState build() {
    final bool published = ref.watch(releasesPublishedProvider);
    if (!published) {
      return const UpdatesState.noRelease();
    }
    unawaited(Future<void>.microtask(_askAtOpening));
    return const UpdatesState.idle();
  }

  /// Waits for the store to be read, then asks once if it says to.
  Future<void> _askAtOpening() async {
    await ref.read(preferencesProvider.notifier).loaded;
    if (!ref.mounted || _askedAtOpening) {
      return;
    }
    _askedAtOpening = true;
    if (ref.read(preferencesProvider).checkingForUpdates) {
      await check();
    }
  }

  /// Asks the host, saying so while it does.
  Future<void> check() async {
    if (state is UpdatesAsking || state is UpdatesNoRelease) {
      return;
    }
    state = const UpdatesState.asking();
    final Result<UpdateAnswerValueObject, AppFailure> answer =
        await checkForUpdates.check(ref.read(runningVersionProvider));
    if (!ref.mounted) {
      return;
    }
    state = switch (answer) {
      Success<UpdateAnswerValueObject, AppFailure>(
        value: UpdateNewer(:final ReleaseValueObject release),
      ) =>
        UpdatesState.newer(
          version: release.version.text,
          notesUrl: release.notesUrl,
        ),
      Success<UpdateAnswerValueObject, AppFailure>(value: UpdateNoRelease()) =>
        const UpdatesState.noRelease(),
      Success<UpdateAnswerValueObject, AppFailure>() => UpdatesState.upToDate(
        DateTime.now(),
      ),
      Failure<UpdateAnswerValueObject, AppFailure>() =>
        const UpdatesState.failed(),
    };
  }
}

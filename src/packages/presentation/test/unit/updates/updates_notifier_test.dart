import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Updates updates;
  late _Preferences preferences;

  ProviderContainer make({bool published = true}) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        releasesPublishedProvider.overrideWithValue(published),
        runningVersionProvider.overrideWithValue(
          const AppVersionValueObject(major: 1, minor: 0),
        ),
        checkForUpdatesProvider.overrideWithValue(
          CheckForUpdatesUseCase(
            updates: updates,
            observability: const _Silent(),
          ),
        ),
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: preferences),
        ),
        writePreferencesProvider.overrideWithValue(
          WritePreferencesUseCase(
            preferences: preferences,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen<UpdatesState>(updatesProvider, (_, _) {});
    return container;
  }

  setUp(() {
    updates = _Updates();
    preferences = _Preferences();
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('before a first release the state is no release, and nothing is '
      'asked', () async {
    final ProviderContainer c = make(published: false);
    await settle();

    expect(c.read(updatesProvider), isA<UpdatesNoRelease>());
    await c.read(updatesProvider.notifier).check();
    expect(updates.asked, 0);
  });

  test('with the preference off nothing leaves the machine', () async {
    preferences.held = const PreferencesValueObject(checkingForUpdates: false);
    final ProviderContainer c = make();
    await settle();
    await settle();

    expect(updates.asked, 0);
    expect(c.read(updatesProvider), isA<UpdatesIdle>());
  });

  test('by default, with nothing chosen, it asks once, at opening', () async {
    updates.release = _release('v1.2.0');
    final ProviderContainer c = make();
    await settle();
    await settle();
    await settle();

    expect(updates.asked, 1);
    expect(c.read(updatesProvider), isA<UpdatesNewer>());
  });

  test('asking says so while it does, and up to date says when', () async {
    // The check at opening is on by default; these start from a state the
    // person asked for by hand.
    preferences.held = const PreferencesValueObject(checkingForUpdates: false);
    final ProviderContainer c = make();
    await settle();
    updates
      ..release = _release('v1.0.0')
      ..hold = Completer<void>();

    final Future<void> asking = c.read(updatesProvider.notifier).check();
    await settle();
    expect(c.read(updatesProvider), isA<UpdatesAsking>());
    updates.hold!.complete();
    await asking;

    expect(c.read(updatesProvider), isA<UpdatesUpToDate>());
  });

  test('a newer release is named with its page', () async {
    preferences.held = const PreferencesValueObject(checkingForUpdates: false);
    final ProviderContainer c = make();
    await settle();
    updates.release = _release('v1.3.0');

    await c.read(updatesProvider.notifier).check();

    expect(
      c.read(updatesProvider),
      const UpdatesState.newer(
        version: '1.3.0',
        notesUrl: 'https://example.com/v1.3.0',
      ),
    );
  });

  test('a host that did not answer leaves no old answer', () async {
    preferences.held = const PreferencesValueObject(checkingForUpdates: false);
    final ProviderContainer c = make();
    await settle();
    updates.release = _release('v1.3.0');
    await c.read(updatesProvider.notifier).check();
    updates.failure = const UpdateFailure.unreachable();

    await c.read(updatesProvider.notifier).check();

    expect(c.read(updatesProvider), isA<UpdatesFailed>());
  });

  test('nothing published after all is no release', () async {
    final ProviderContainer c = make();
    await settle();
    updates.release = null;

    await c.read(updatesProvider.notifier).check();

    expect(c.read(updatesProvider), isA<UpdatesNoRelease>());
  });
}

ReleaseValueObject _release(String tag) => ReleaseValueObject(
  version: AppVersionValueObject.tryParse(tag)!,
  notesUrl: 'https://example.com/$tag',
);

final class _Updates implements UpdatesRepository {
  ReleaseValueObject? release;
  UpdateFailure? failure;
  Completer<void>? hold;
  int asked = 0;

  @override
  Future<Result<ReleaseValueObject?, UpdateFailure>> latest() async {
    asked++;
    await hold?.future;
    final UpdateFailure? refused = failure;
    return refused == null
        ? Success<ReleaseValueObject?, UpdateFailure>(release)
        : Failure<ReleaseValueObject?, UpdateFailure>(refused);
  }
}

final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
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

/// The preferences use cases and [OpenUrlUseCase]: one call each through
/// their repository, with nothing thrown past the ones that can fail.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Preferences preferences;
  late _Desktop desktop;
  late _Recording observability;

  setUp(() {
    preferences = _Preferences();
    desktop = _Desktop();
    observability = _Recording();
  });

  group('reading', () {
    test('hands back what the repository holds', () async {
      preferences.held = const PreferencesValueObject(
        theme: ThemeChoiceEnum.dark,
      );

      final PreferencesValueObject read = await ReadPreferencesUseCase(
        preferences: preferences,
      ).read();

      expect(read.theme, ThemeChoiceEnum.dark);
    });
  });

  group('writing', () {
    WritePreferencesUseCase useCase() => WritePreferencesUseCase(
      preferences: preferences,
      observability: observability,
    );

    test('hands the choice to the repository', () async {
      const PreferencesValueObject chosen = PreferencesValueObject(
        theme: ThemeChoiceEnum.light,
      );

      final Result<void, AppFailure> result = await useCase().write(chosen);

      expect(result, isA<Success<void, AppFailure>>());
      expect(preferences.held, chosen);
    });

    test('a refusal is passed through, not reported', () async {
      preferences.refusal = const UnexpectedFailure('disk full');

      final Result<void, AppFailure> result = await useCase().write(
        PreferencesValueObject.defaults,
      );

      expect(result, isA<Failure<void, AppFailure>>());
      expect(observability.captured, isEmpty);
    });

    test('an exception never escapes, and is reported', () async {
      preferences.throws = true;

      final Result<void, AppFailure> result = await useCase().write(
        PreferencesValueObject.defaults,
      );

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured, hasLength(1));
    });
  });

  group('opening an address', () {
    OpenUrlUseCase useCase() =>
        OpenUrlUseCase(desktop: desktop, observability: observability);

    test('hands the address to the desktop', () async {
      final Result<void, AppFailure> result = await useCase().open(
        Uri.parse('https://example.com/a'),
      );

      expect(result, isA<Success<void, AppFailure>>());
      expect(desktop.asked, <Uri>[Uri.parse('https://example.com/a')]);
    });

    test('a refusal is passed through, not reported', () async {
      desktop.refusal = const UnexpectedFailure('no browser');

      final Result<void, AppFailure> result = await useCase().open(
        Uri.parse('https://example.com'),
      );

      expect(result, isA<Failure<void, AppFailure>>());
      expect(observability.captured, isEmpty);
    });

    test('an exception never escapes, and is reported', () async {
      desktop.throws = true;

      final Result<void, AppFailure> result = await useCase().open(
        Uri.parse('https://example.com'),
      );

      expect(result, isA<Failure<void, AppFailure>>());
      expect(observability.captured, hasLength(1));
    });
  });
}

final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;
  AppFailure? refusal;
  bool throws = false;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    if (throws) {
      throw StateError('the store fell over');
    }
    final AppFailure? refused = refusal;
    if (refused != null) {
      return Failure<void, AppFailure>(refused);
    }
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}

final class _Desktop implements DesktopRepository {
  AppFailure? refusal;
  bool throws = false;
  final List<Uri> asked = <Uri>[];

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async {
    if (throws) {
      throw StateError('the desktop fell over');
    }
    asked.add(address);
    final AppFailure? refused = refusal;
    return refused == null
        ? const Success<void, AppFailure>(null)
        : Failure<void, AppFailure>(refused);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _Recording implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}

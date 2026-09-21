/// What the providers do when nobody wired them.
///
/// The point of declaring them here with no default is that forgetting the
/// composition root fails loudly and at once, rather than producing a screen
/// that quietly does nothing.
library;

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  /// What reading [provider] threw, unwrapped.
  ///
  /// Riverpod wraps whatever a provider's body throws in a
  /// [ProviderException], so the thing worth asserting on is one level in.
  Object causeOfReading(ProviderListenable<Object?> provider) {
    try {
      container.read(provider);
    } on ProviderException catch (exception) {
      return exception.exception;
    }
    throw StateError('reading the provider did not throw');
  }

  test('openSpaceProvider has no default', () {
    expect(causeOfReading(openSpaceProvider), isA<StateError>());
  });

  test('listRecentSpacesProvider has no default', () {
    expect(causeOfReading(listRecentSpacesProvider), isA<StateError>());
  });

  test('forgetRecentSpaceProvider has no default', () {
    expect(causeOfReading(forgetRecentSpaceProvider), isA<StateError>());
  });

  test('and each says where it is supposed to be wired', () {
    // A message that names the place is the difference between a minute and
    // an afternoon for whoever adds the next screen.
    expect(
      (causeOfReading(openSpaceProvider) as StateError).message,
      allOf(contains('composition root'), contains('runTom')),
    );
  });
}

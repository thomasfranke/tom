/// What the file tree's providers do when nobody wired them.
///
/// The same claim `home_providers_test.dart` makes, for the panel that
/// arrived after it: declaring a use case here with no default is what makes
/// forgetting the composition root fail loudly and at once, instead of
/// producing a tree that quietly shows nothing.
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

  test('listSpaceEntriesProvider has no default', () {
    expect(causeOfReading(listSpaceEntriesProvider), isA<StateError>());
  });

  test('and it says where it is supposed to be wired', () {
    expect(
      (causeOfReading(listSpaceEntriesProvider) as StateError).message,
      allOf(contains('composition root'), contains('runTom')),
    );
  });
}

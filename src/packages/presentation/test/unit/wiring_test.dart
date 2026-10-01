/// What the use-case providers do when nobody wired them.
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

  /// What reading [provider] threw, unwrapped: Riverpod wraps whatever a
  /// provider's body throws in a [ProviderException].
  Object causeOfReading(ProviderListenable<Object?> provider) {
    try {
      container.read(provider);
    } on ProviderException catch (exception) {
      return exception.exception;
    }
    throw StateError('reading the provider did not throw');
  }

  final Map<String, ProviderListenable<Object?>> unwired =
      <String, ProviderListenable<Object?>>{
        'readGitStatusProvider': readGitStatusProvider,
        'stageChangesProvider': stageChangesProvider,
        'commitChangesProvider': commitChangesProvider,
        'readMergeStateProvider': readMergeStateProvider,
        'fetchRemoteProvider': fetchRemoteProvider,
        'pullRemoteProvider': pullRemoteProvider,
        'pushRemoteProvider': pushRemoteProvider,
        'abortPullProvider': abortPullProvider,
        'indexSpaceProvider': indexSpaceProvider,
        'indexDocumentProvider': indexDocumentProvider,
        'searchSpaceProvider': searchSpaceProvider,
        'readPreferencesProvider': readPreferencesProvider,
        'writePreferencesProvider': writePreferencesProvider,
      };

  for (final MapEntry<String, ProviderListenable<Object?>> each
      in unwired.entries) {
    test('${each.key} has no default, and says where it is wired', () {
      final Object cause = causeOfReading(each.value);

      expect(cause, isA<StateError>());
      expect(
        (cause as StateError).message,
        allOf(contains(each.key), contains('composition root')),
      );
    });
  }
}

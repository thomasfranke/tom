import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// Every use case this package names, and nothing behind any of them: each
/// seam refuses to answer rather than falling back, and names who was
/// supposed to override it.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  /// Asserts [provider] has no default, and names itself when asked.
  void expectNoDefault(ProviderListenable<Object?> provider, String named) {
    expect(
      () => container.read(provider),
      throwsA(
        isA<ProviderException>().having(
          (ProviderException thrown) => thrown.exception.toString(),
          'what it threw',
          allOf(contains(named), contains('composition root')),
        ),
      ),
      reason: '$named should refuse to answer without an override',
    );
  }

  test('the document seams have no default', () {
    expectNoDefault(readDocumentProvider, 'readDocumentProvider');
    expectNoDefault(saveDocumentProvider, 'saveDocumentProvider');
    expectNoDefault(splitDocumentProvider, 'splitDocumentProvider');
  });

  test('the space seams have no default', () {
    expectNoDefault(openSpaceProvider, 'openSpaceProvider');
    expectNoDefault(listRecentSpacesProvider, 'listRecentSpacesProvider');
    expectNoDefault(forgetRecentSpaceProvider, 'forgetRecentSpaceProvider');
    expectNoDefault(listSpaceEntriesProvider, 'listSpaceEntriesProvider');
  });

  test('the git seams have no default', () {
    expectNoDefault(readGitStatusProvider, 'readGitStatusProvider');
    expectNoDefault(stageChangesProvider, 'stageChangesProvider');
    expectNoDefault(commitChangesProvider, 'commitChangesProvider');
    expectNoDefault(listBranchesProvider, 'listBranchesProvider');
    expectNoDefault(switchBranchProvider, 'switchBranchProvider');
    expectNoDefault(readFileHistoryProvider, 'readFileHistoryProvider');
    expectNoDefault(readVersionProvider, 'readVersionProvider');
  });

  test('the remote seams have no default', () {
    expectNoDefault(fetchRemoteProvider, 'fetchRemoteProvider');
    expectNoDefault(pullRemoteProvider, 'pullRemoteProvider');
    expectNoDefault(pushRemoteProvider, 'pushRemoteProvider');
  });

  test('the diff seam has no default', () {
    expectNoDefault(diffDocumentProvider, 'diffDocumentProvider');
  });
}

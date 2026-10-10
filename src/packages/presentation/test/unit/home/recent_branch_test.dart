/// The branch each recent row names.
library;

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  final RecentSpaceEntity docs = RecentSpaceEntity(
    root: '/work/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 10, 8),
  );

  ProviderContainer containerOver(RecentBranchRepository branches) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        readRecentBranchProvider.overrideWithValue(
          ReadRecentBranchUseCase(
            branches: branches,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('a row gets the branch its folder is on', () async {
    final ProviderContainer container = containerOver(
      _Branches(<String, BranchNameValueObject?>{
        '/work/docs': BranchNameValueObject('feat/notes'),
      }),
    );

    expect(
      await container.read(recentBranchProvider(docs).future),
      BranchNameValueObject('feat/notes'),
    );
  });

  test('a row on no branch gets nothing', () async {
    final ProviderContainer container = containerOver(
      _Branches(const <String, BranchNameValueObject?>{}),
    );

    expect(await container.read(recentBranchProvider(docs).future), isNull);
  });

  test('a repository that throws costs the branch, not the row', () async {
    final ProviderContainer container = containerOver(_Throwing());

    expect(await container.read(recentBranchProvider(docs).future), isNull);
  });
}

/// Answers the branch [byRoot] holds for a row's folder.
final class _Branches implements RecentBranchRepository {
  const _Branches(this.byRoot);

  final Map<String, BranchNameValueObject?> byRoot;

  @override
  Future<Result<BranchNameValueObject?, Never>> branchOf(
    RecentSpaceEntity recent,
  ) async => Success<BranchNameValueObject?, Never>(byRoot[recent.root]);
}

/// Breaks its contract by throwing.
final class _Throwing implements RecentBranchRepository {
  @override
  Future<Result<BranchNameValueObject?, Never>> branchOf(
    RecentSpaceEntity recent,
  ) => throw StateError('broken');
}

/// An [Observability] that drops everything.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}

/// Drives the compare surface: what to compare against, chosen from a list.
library;

// `select` is an extension on `ProviderListenable` and lives in the runtime
// package; `riverpod_annotation` carries the annotations and not much else.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/branches/branches_notifier.dart';
import 'package:tom_presentation/src/branches/branches_state.dart';
import 'package:tom_presentation/src/compare/compare_state.dart';
import 'package:tom_presentation/src/history/history_notifier.dart';
import 'package:tom_presentation/src/history/history_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'compare_notifier.g.dart';

/// Offers the branches and the document's commits, and records the choice.
///
/// **It asks git nothing.** The branches are the switcher's reading and the
/// commits are the history panel's, so what this surface offers cannot
/// disagree with what the control beside it says or the list under it shows.
/// The choice is written to the session, because the preview and the bar
/// above the document both have to know.
@riverpod
class CompareNotifier extends _$CompareNotifier {
  @override
  CompareState build() {
    final bool hasDocument = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument != null,
      ),
    );
    if (!hasDocument) {
      return const CompareState.idle();
    }
    // Listened to, not watched: a list arriving is not a reason to empty the
    // box somebody is typing into.
    ref
      ..listen<List<BranchEntity>>(
        branchesProvider.select(_branchesOf),
        (List<BranchEntity>? _, List<BranchEntity> next) =>
            _offer(branches: next),
      )
      ..listen<List<CommitEntity>>(
        historyProvider.select(_commitsOf),
        (List<CommitEntity>? _, List<CommitEntity> next) =>
            _offer(commits: next),
      );
    return CompareState.ready(
      branches: _branchesOf(ref.read(branchesProvider)),
      commits: _commitsOf(ref.read(historyProvider)),
    );
  }

  /// Types [draft] into the box, narrowing both lists.
  void type(String draft) {
    if (state case final CompareReady ready) {
      state = ready.copyWith(draft: draft);
    }
  }

  /// Compares the document against [revision].
  void choose(RevisionValueObject revision) {
    ref.read(spaceSessionProvider.notifier).compare(revision);
    dismiss();
  }

  /// Goes back to the default comparison.
  void stop() {
    ref.read(spaceSessionProvider.notifier).compare(null);
    dismiss();
  }

  /// Puts the surface away, keeping nothing half-typed.
  void dismiss() => type('');

  /// Replaces what the surface offers, leaving the draft alone.
  void _offer({List<BranchEntity>? branches, List<CommitEntity>? commits}) {
    if (state case final CompareReady ready) {
      state = ready.copyWith(
        branches: branches ?? ready.branches,
        commits: commits ?? ready.commits,
      );
    }
  }

  /// The branches the switcher has, or none until it has read them.
  static List<BranchEntity> _branchesOf(BranchesState state) => switch (state) {
    BranchesReady(:final List<BranchEntity> branches) => branches,
    _ => const <BranchEntity>[],
  };

  /// The commits history has, or none until it has read them.
  static List<CommitEntity> _commitsOf(HistoryState state) => switch (state) {
    HistoryReady(:final List<CommitEntity> commits) => commits,
    _ => const <CommitEntity>[],
  };
}

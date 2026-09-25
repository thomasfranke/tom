/// Drives the branch switcher: list, filter, switch, start one.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/branches/branches_providers.dart';
import 'package:tom_presentation/src/branches/branches_state.dart';
import 'package:tom_presentation/src/changes/changes_notifier.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/file_tree/file_tree_notifier.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'branches_notifier.g.dart';

/// Switches branches, starts them, and refuses to lose work doing either.
///
/// A switch rewrites the working tree, so it ends by re-reading the status,
/// the folder and the open buffer, in that order. It reads no git status of
/// its own — [ChangesNotifier] does, so the window keeps one source.
@riverpod
class BranchesNotifier extends _$BranchesNotifier {
  /// Reads the repository's local branches.
  ListBranchesUseCase get listBranches => ref.read(listBranchesProvider);

  /// Moves onto a branch, or starts one.
  SwitchBranchUseCase get switchBranch => ref.read(switchBranchProvider);

  @override
  BranchesState build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null) {
      return const BranchesState.initial();
    }
    // Scheduled, not awaited: `build` answers synchronously.
    unawaited(Future<void>.microtask(() => _list(space)));
    return const BranchesState.loading();
  }

  /// Types [draft] into the one box: a filter while listing, the new name
  /// while creating — and what is wrong with that name, as it is typed.
  void type(String draft) {
    if (state case final BranchesReady ready) {
      state = ready.copyWith(
        draft: draft,
        failure: null,
        rejected: ready.isCreating ? _whyNot(draft, ready.branches) : null,
      );
    }
  }

  /// Turns the surface into the one that names a new branch, with the draft
  /// carried across: a branch filtered for and not found is one to create.
  void startCreating() {
    if (state case final BranchesReady ready) {
      state = ready.copyWith(
        isCreating: true,
        failure: null,
        rejected: _whyNot(ready.draft, ready.branches),
      );
    }
  }

  /// Goes back to choosing among the branches that exist.
  void stopCreating() {
    if (state case final BranchesReady ready) {
      state = ready.copyWith(isCreating: false, rejected: null, failure: null);
    }
  }

  /// Moves onto [name], asking first if that would lose unsaved work; the
  /// branch already checked out is a click on where you are, not an error.
  Future<void> choose(BranchNameValueObject name) async {
    if (state case final BranchesReady ready) {
      if (ready.isBusy ||
          ready.branches.any(
            (BranchEntity it) => it.isCurrent && it.name == name,
          )) {
        return;
      }
      await _move(name);
    }
  }

  /// Writes the buffer to disk, then switches — or leaves the question
  /// standing when the save failed, since the point of asking was not to
  /// lose it.
  Future<void> saveAndSwitch() async {
    if (state case BranchesReady(pending: final BranchNameValueObject name)) {
      await ref.read(editorProvider.notifier).save();
      if (!ref.mounted) {
        return;
      }
      if (ref.read(editorProvider).isDirty) {
        return;
      }
      await _switchTo(name);
    }
  }

  /// Switches, letting the buffer go: the re-read that follows is what
  /// discarding amounts to.
  Future<void> discardAndSwitch() async {
    if (state case BranchesReady(pending: final BranchNameValueObject name)) {
      await _switchTo(name);
    }
  }

  /// Puts the surface away, answering every question it was asking: a
  /// switch waiting on unsaved work is cancelled, not left standing behind
  /// a popover nobody can see.
  void dismiss() {
    if (state case final BranchesReady ready) {
      state = ready.copyWith(
        draft: '',
        isCreating: false,
        pending: null,
        failure: null,
        rejected: null,
      );
    }
  }

  /// Leaves the branch where it is, and the buffer with it.
  void cancelSwitch() {
    if (state case final BranchesReady ready) {
      state = ready.copyWith(pending: null);
    }
  }

  /// Starts the branch named in the box, and moves onto it.
  Future<void> create() async {
    if (state case final BranchesReady ready) {
      final BranchNameValueObject? name = BranchNameValueObject.tryParse(
        ready.draft,
      );
      if (!state.canCreate || name == null) {
        return;
      }
      await _move(name);
    }
  }

  /// Heads for [name], asking first when the buffer would be lost — the one
  /// door for a chosen branch and a typed one, so the question is asked once.
  Future<void> _move(BranchNameValueObject name) async {
    if (state case final BranchesReady ready) {
      // Only the buffer needs asking about: git refuses on its own when the
      // *tree* would be overwritten
      // (`docs/product/git-workflow/branch-switch/doc.md`).
      if (ref.read(editorProvider).isDirty) {
        state = ready.copyWith(pending: name, failure: null);
        return;
      }
      await _switchTo(name);
    }
  }

  /// Checks [name] out, starting it when no branch has that name, and puts
  /// the window back together around it.
  Future<void> _switchTo(BranchNameValueObject name) {
    final bool exists = switch (state) {
      BranchesReady(:final List<BranchEntity> branches) => branches.any(
        (BranchEntity it) => it.name == name,
      ),
      _ => false,
    };
    return _run(
      (SpaceEntity space) => exists
          ? switchBranch.switchTo(space, name)
          : switchBranch.create(space, name),
      onDone: (BranchesReady now) =>
          now.copyWith(pending: null, draft: '', isCreating: false),
    );
  }

  /// Runs [operation], then re-reads everything the switch invalidated.
  ///
  /// [onDone] tidies the surface only on success: a refused switch leaves
  /// the question and the typed name where they were.
  Future<void> _run(
    Future<Result<void, AppFailure>> Function(SpaceEntity space) operation, {
    required BranchesReady Function(BranchesReady now) onDone,
  }) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null || state is! BranchesReady) {
      return;
    }
    state = (state as BranchesReady).copyWith(isBusy: true, failure: null);
    final Result<void, AppFailure> done = await operation(space);
    // The popover can be gone by the time git answers.
    if (!ref.mounted) {
      return;
    }
    if (done case Failure<void, AppFailure>(failure: final AppFailure why)) {
      state = (state as BranchesReady).copyWith(isBusy: false, failure: why);
      return;
    }
    // The status first (the branch just changed), then the folder the
    // checkout rewrote, then the buffer still showing the old branch's text.
    await ref.read(changesProvider.notifier).refresh();
    await ref.read(fileTreeProvider.notifier).refresh();
    await ref.read(editorProvider.notifier).reload();
    if (!ref.mounted) {
      return;
    }
    await _list(space);
    if (state case final BranchesReady now) {
      state = onDone(now).copyWith(isBusy: false);
    }
  }

  /// Asks git which branches there are.
  Future<void> _list(SpaceEntity space) async {
    final Result<List<BranchEntity>, AppFailure> read = await listBranches.list(
      space,
    );
    if (!ref.mounted) {
      return;
    }
    // What the surface was in the middle of survives: a list arriving is no
    // reason to empty a box or drop a question.
    final BranchesReady? before = state is BranchesReady
        ? state as BranchesReady
        : null;
    state = switch (read) {
      Success<List<BranchEntity>, AppFailure>(
        value: final List<BranchEntity> branches,
      ) =>
        (before ?? const BranchesReady(branches: <BranchEntity>[])).copyWith(
          branches: branches,
        ),
      Failure<List<BranchEntity>, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        BranchesState.failed(failure),
    };
  }

  /// Why [draft] is not a branch that could be started, or null when it is.
  static String? _whyNot(String draft, List<BranchEntity> branches) {
    if (draft.isEmpty) {
      return null;
    }
    if (BranchNameValueObject.tryParse(draft) == null) {
      return 'Not a name git accepts';
    }
    if (branches.any((BranchEntity it) => it.name.value == draft)) {
      return 'There is already a branch called that';
    }
    return null;
  }
}

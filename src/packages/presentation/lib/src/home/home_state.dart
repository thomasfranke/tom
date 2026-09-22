/// What Home is showing right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'home_state.freezed.dart';

/// The states Home can be in, and there are only these.
///
/// `initial / loading / data / error(AppFailure)` is the shape every
/// notifier takes. Spelling them out is what stops a screen from inventing
/// a fifth state out of two booleans that can both be true.
///
/// **There is no `opened` state**: which space is open is not a fact about
/// Home but the one the whole window is built on, so it lives in the space
/// session ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
@freezed
sealed class HomeState with _$HomeState {
  /// Nothing has been asked for yet.
  const factory HomeState.initial() = HomeInitial;

  /// The recent list is being read.
  const factory HomeState.loading() = HomeLoading;

  /// Home is ready, offering [recents].
  ///
  /// An empty list is an ordinary state, not an empty-list error: it is the
  /// first run.
  const factory HomeState.ready(List<RecentSpaceEntity> recents) = HomeReady;

  /// A folder was picked and could not be opened.
  ///
  /// The failure travels whole rather than as a message: Home's one named
  /// failure is a folder outside a repository, shown as its own screen
  /// (`docs/product/home/doc.md`). The recent list comes with it, because
  /// the other rows are still there to click.
  const factory HomeState.failed({
    required AppFailure failure,
    required List<RecentSpaceEntity> recents,
  }) = HomeFailed;
}

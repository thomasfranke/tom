/// What Home is showing right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'home_state.freezed.dart';

/// The states Home can be in, and there are only these.
///
/// Sealed and explicit — `initial / loading / data / error(AppFailure)` is
/// the shape every notifier in the app takes
/// ([flows](../../../../../docs/technical/flows.md)). Spelling them out is
/// what stops a screen from inventing a fifth state out of two booleans that
/// can both be true.
///
/// [HomeFailed] carries an [AppFailure] rather than a message: **Home's one
/// named failure is a folder that is not inside a repository**, and it is
/// shown as its own screen with its own explanation
/// (`docs/product/home/doc.md`). A string would have thrown away the
/// difference between that and a folder that is simply gone.
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
  const factory HomeState.ready(List<RecentSpace> recents) = HomeReady;

  /// A folder was picked and could not be opened.
  ///
  /// The recent list travels with the failure, because the screen still
  /// offers it: whatever went wrong with one folder, the others are still
  /// there to click.
  const factory HomeState.failed({
    required AppFailure failure,
    required List<RecentSpace> recents,
  }) = HomeFailed;

  /// A space is open, and the shell has taken over.
  const factory HomeState.opened(Space space) = HomeOpened;
}

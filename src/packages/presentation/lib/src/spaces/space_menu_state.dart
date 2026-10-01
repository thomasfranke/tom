/// What the breadcrumb's menu is showing.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/space_departure.dart';

part 'space_menu_state.freezed.dart';

/// The recent spaces, whether the menu is open, and any question standing.
///
/// One class rather than a hierarchy: a menu with no recents yet is the
/// same menu, and `Close space` works before the list has arrived.
@freezed
abstract class SpaceMenuState with _$SpaceMenuState {
  /// Creates the state.
  const factory SpaceMenuState({
    /// The spaces to offer going back to, most recent first.
    @Default(<RecentSpaceEntity>[]) List<RecentSpaceEntity> recents,

    /// Whether the menu is on screen.
    @Default(false) bool isShowing,

    /// What is waiting on the unsaved question, or null when nothing is.
    SpaceDeparture? pending,

    /// Whether a space is being opened; the rows refuse a second click.
    @Default(false) bool isBusy,

    /// Why the space that was chosen could not be opened.
    ///
    /// Said in the menu rather than on a screen of its own: the space that
    /// *is* open never closed, so there is nothing to go back from.
    String? failure,
  }) = _SpaceMenuState;
}

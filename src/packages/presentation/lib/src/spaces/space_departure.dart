/// Where leaving the open space is headed.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'space_departure.freezed.dart';

/// What the menu is waiting to do once the unsaved question is answered.
///
/// The two ways out are one thing to the buffer at risk, so they are one
/// type: the question is the same, and only the words on the buttons and
/// what happens afterwards differ
/// (`docs/product/workspace/leaving-a-space/doc.md`).
@freezed
sealed class SpaceDeparture with _$SpaceDeparture {
  /// Back to the opening screen, with nothing open.
  const factory SpaceDeparture.closing() = SpaceDepartureClosing;

  /// Straight into [space], without the trip through Home.
  const factory SpaceDeparture.switching(RecentSpaceEntity space) =
      SpaceDepartureSwitching;
}

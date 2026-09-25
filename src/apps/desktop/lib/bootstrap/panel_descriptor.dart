/// What a module registers when it contributes a panel.
library;

import 'package:flutter/widgets.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// One panel, described rather than built.
///
/// The shell never names a panel: it asks the registry what belongs in each
/// region and calls [builder], and the built-in panels take exactly this path
/// ([Decision 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
@immutable
class PanelDescriptor {
  /// Describes a panel.
  const PanelDescriptor({
    required this.id,
    required this.title,
    required this.placement,
    required this.builder,
    this.order = 0,
    this.modes = DocumentModeEnum.values,
  });

  /// The panel's global, stable identity — `tom.explorer`, `acme.tasks`.
  ///
  /// Namespaced by the module that contributes it, so two modules cannot
  /// collide; it outlives any rename of [title].
  final String id;

  /// What the user sees this panel called.
  final String title;

  /// Which region of the shell it belongs to.
  final PanelPlacementEnum placement;

  /// Builds the panel's content, inside the region's own constraints.
  ///
  /// A panel reaches the space and the open document through the providers
  /// in scope, never through arguments here, so the descriptor stays a value.
  final WidgetBuilder builder;

  /// Which document modes it is drawn in — every one of them by default.
  ///
  /// The panel names its modes and the shell only filters, so the mode bar
  /// hides a panel without knowing what it is. Meaningless outside
  /// [PanelPlacementEnum.document], the only region the bar governs.
  final List<DocumentModeEnum> modes;

  /// Where it sits among its region's other panels, lowest first.
  ///
  /// Ties fall back to registration order, which is module order.
  final int order;
}

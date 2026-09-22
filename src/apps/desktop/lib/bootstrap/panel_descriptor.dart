/// What a module registers when it contributes a panel.
library;

import 'package:flutter/widgets.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';

/// One panel, described rather than built.
///
/// The shell never names a panel and never imports one
/// ([Decision 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
/// It asks the registry what belongs in each region and calls [builder].
/// **The built-in panels go through exactly this path** — that is what keeps
/// the extension point real instead of letting it rot from disuse.
@immutable
class PanelDescriptor {
  /// Describes a panel.
  const PanelDescriptor({
    required this.id,
    required this.title,
    required this.placement,
    required this.builder,
    this.order = 0,
  });

  /// What identifies this panel, globally and for the life of the product.
  ///
  /// Namespaced by whoever contributes it — `tom.explorer`, `acme.tasks` —
  /// so two modules cannot collide by accident. It is what a persisted
  /// layout, a keyboard shortcut and a test all refer to, so it outlives any
  /// rename of the title.
  final String id;

  /// What the user sees this panel called.
  ///
  /// Separate from [id] because it is translated, renamed, and sometimes
  /// not shown at all.
  final String title;

  /// Which region of the shell it belongs to.
  final PanelPlacementEnum placement;

  /// Builds the panel's content.
  ///
  /// Called by the shell, inside the region's own constraints. A panel that
  /// needs the space, the open document or anything else reaches it through
  /// the providers in scope, never through arguments here — which is what
  /// lets the descriptor stay a value.
  final WidgetBuilder builder;

  /// Where it sits among its region's other panels, lowest first.
  ///
  /// Ties are broken by registration order, and registration order is module
  /// order, so `runTom(modules: [a, b])` is predictable without anyone
  /// having to number everything.
  final int order;
}

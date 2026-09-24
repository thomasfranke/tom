/// What the shell asks when it needs to know what to draw.
library;

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_presentation/tom_presentation.dart';

part 'panel_registry.g.dart';

/// Every registered panel, by region.
///
/// Built once from the modules `runTom` was given, and read by the shell.
/// The shell holds no list of its own: **panels are registered, never
/// hardcoded**
/// ([flows](../../../../../docs/technical/flows.md#panels-are-registered-never-hardcoded)),
/// and a shell that kept its own list would be a second, quieter registry.
@immutable
class PanelRegistry {
  /// Collects the panels of [modules], in the order they were given.
  factory PanelRegistry(List<TomModule> modules) {
    final Map<PanelPlacementEnum, List<PanelDescriptor>> byPlacement =
        <PanelPlacementEnum, List<PanelDescriptor>>{
          for (final PanelPlacementEnum placement in PanelPlacementEnum.values)
            placement: <PanelDescriptor>[],
        };
    final Set<String> seen = <String>{};
    for (final TomModule module in modules) {
      for (final PanelDescriptor panel in module.panels) {
        assert(
          seen.add(panel.id),
          'Two panels share the id "${panel.id}" — '
          'ids are global and must be namespaced by their module',
        );
        byPlacement[panel.placement]!.add(panel);
      }
    }
    for (final List<PanelDescriptor> panels in byPlacement.values) {
      // A stable sort, so a tie falls back to registration order, which is
      // module order. Nobody has to number anything for `runTom` to be
      // predictable.
      mergeSortByOrder(panels);
    }
    return PanelRegistry._(byPlacement);
  }

  const PanelRegistry._(this._byPlacement);

  final Map<PanelPlacementEnum, List<PanelDescriptor>> _byPlacement;

  /// What belongs in [placement], lowest order first.
  ///
  /// An empty list is an ordinary answer: a region with nothing registered
  /// in it draws nothing, which is how a build with a panel's feature flag
  /// off looks from here.
  ///
  /// [mode] narrows it to the panels that belong in that document mode. The
  /// filtering lives here rather than in the shell because the descriptor is
  /// what carries the answer, and a shell that read `modes` would be a shell
  /// that knows what a panel is for.
  List<PanelDescriptor> at(
    PanelPlacementEnum placement, {
    DocumentModeEnum? mode,
  }) => List<PanelDescriptor>.unmodifiable(
    mode == null
        ? _byPlacement[placement]!
        : _byPlacement[placement]!.where(
            (PanelDescriptor panel) => panel.modes.contains(mode),
          ),
  );

  /// Whether anything at all is registered.
  bool get isEmpty =>
      _byPlacement.values.every((List<PanelDescriptor> p) => p.isEmpty);
}

/// Sorts [panels] by order, keeping the original order of equal entries.
///
/// `List.sort` is not stable, and stability is the whole contract here.
@visibleForTesting
void mergeSortByOrder(List<PanelDescriptor> panels) {
  final List<(int, PanelDescriptor)> indexed =
      <(int, PanelDescriptor)>[
        for (int i = 0; i < panels.length; i++) (i, panels[i]),
      ]..sort(((int, PanelDescriptor) a, (int, PanelDescriptor) b) {
        final int byOrder = a.$2.order.compareTo(b.$2.order);
        return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
      });
  panels
    ..clear()
    ..addAll(indexed.map(((int, PanelDescriptor) e) => e.$2));
}

/// The registry in scope.
///
/// Overridden by `runTom` at the root of the app. It has no default: a shell
/// built without one is a wiring mistake, and failing loudly at startup is
/// better than drawing an empty window.
@Riverpod(keepAlive: true)
PanelRegistry panelRegistry(Ref ref) => throw StateError(
  'No PanelRegistry in scope. The app starts through runTom(), which '
  'installs one.',
);

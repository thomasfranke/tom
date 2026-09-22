/// The panel layout.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The window: explorer, document area, aside and status bar, all at once.
///
/// **There is no full-screen takeover.** The explorer does not disappear
/// while editing and the status bar does not hide while reading
/// (`docs/product/workspace/doc.md`). A new panel is added to this layout,
/// never bolted on as a separate window or a new top-level mode.
///
/// This widget names no panel. It asks [PanelRegistry] what belongs in each
/// region and builds what it is told, which is the same answer it gives for
/// a third party's panel and for the app's own.
class TomShell extends ConsumerWidget {
  /// Creates the shell.
  const TomShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PanelRegistry registry = ref.watch(panelRegistryProvider);
    final TomColors colors = TomColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: <Widget>[
          const _TopBar(),
          Divider(height: 1, color: colors.border),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Region(
                  placement: PanelPlacementEnum.explorer,
                  registry: registry,
                  width: TomMetrics.explorer,
                ),
                Expanded(
                  child: _Region(
                    placement: PanelPlacementEnum.document,
                    registry: registry,
                  ),
                ),
                _Region(
                  placement: PanelPlacementEnum.aside,
                  registry: registry,
                  width: TomMetrics.git,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          _StatusBar(registry: registry),
        ],
      ),
    );
  }
}

/// One region of the shell, holding whatever was registered into it.
///
/// A fixed [width] for the columns that must not move between screens, and
/// null for the document area, which takes what is left.
class _Region extends StatelessWidget {
  const _Region({required this.placement, required this.registry, this.width});

  /// Which region this is.
  final PanelPlacementEnum placement;

  /// Where to ask what belongs in it.
  final PanelRegistry registry;

  /// Its fixed width, or null to take what is left.
  final double? width;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<PanelPlacementEnum>('placement', placement))
      ..add(DiagnosticsProperty<PanelRegistry>('registry', registry))
      ..add(DoubleProperty('width', width));
  }

  @override
  Widget build(BuildContext context) {
    final List<PanelDescriptor> panels = registry.at(placement);
    if (panels.isEmpty) {
      // Nothing registered: the region takes no space at all rather than
      // reserving an empty column. A fixed-width gap nobody put anything in
      // reads as a bug in the layout.
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    final Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < panels.length; i++) ...<Widget>[
          if (i > 0) VerticalDivider(width: 1, color: colors.border),
          Expanded(child: Builder(builder: panels[i].builder)),
        ],
      ],
    );
    // The divider belongs to the fixed column, on the side facing the
    // document area — so the explorer's own width stays exactly what the
    // wireframe says and the rule sits beside it.
    final Widget bordered = switch (placement) {
      PanelPlacementEnum.explorer => Row(
        children: <Widget>[
          Expanded(child: content),
          VerticalDivider(width: 1, color: colors.border),
        ],
      ),
      PanelPlacementEnum.aside => Row(
        children: <Widget>[
          VerticalDivider(width: 1, color: colors.border),
          Expanded(child: content),
        ],
      ),
      PanelPlacementEnum.document || PanelPlacementEnum.statusBar => content,
    };
    final double? total = width;
    return total == null
        ? bordered
        : SizedBox(width: total + 1, child: bordered);
  }
}

/// The bar above everything: what space is open, and the global actions.
///
/// The design writes it `repository / folder`, because a space is a folder
/// and three checkouts all have a `docs/`. The folder is the emphasis and
/// the repository the context, which is what the two weights say.
///
/// The branch control beside it, with Fetch and Push, arrives with M1 — it
/// belongs to another product, and absent beats a control that cannot say
/// which branch this is.
class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: TomMetrics.topBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TomMetrics.pad + _spaceInset,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: session == null
              // Nothing, which is what the design draws with no space open —
              // and the shell only shows with one anyway.
              ? const SizedBox.shrink()
              : Row(
                  children: <Widget>[
                    Text(
                      Space.nameOfFolder(session.space.repositoryRoot),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '/',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      session.space.name,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// How much further in than the panels the chrome's own text sits.
///
/// Both bars carry it, and so does Home's status line: the name and the
/// status read as one column down the left edge.
const double _spaceInset = 4;

/// The strip below everything: branch, ahead/behind, counts.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.registry});

  /// Where to ask what belongs in it.
  final PanelRegistry registry;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PanelRegistry>('registry', registry));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: TomMetrics.statusBar,
      child: ColoredBox(
        color: colors.surfaceSunken,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TomMetrics.pad + _spaceInset,
          ),
          child: Row(
            children: <Widget>[
              for (final PanelDescriptor panel in registry.at(
                PanelPlacementEnum.statusBar,
              ))
                Builder(builder: panel.builder),
            ],
          ),
        ),
      ),
    );
  }
}

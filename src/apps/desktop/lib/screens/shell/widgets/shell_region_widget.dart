/// One region of the shell, holding whatever was registered into it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_page_enum.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/screens/workspace/workspace_aside_switch_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_bottom_head_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One region of the shell, holding whatever was registered into it.
///
/// It draws the panels and nothing around them: the width of a fixed column
/// and the container it sits on are the shell's, because the document's
/// container holds the row above the document too.
class ShellRegionWidget extends ConsumerWidget {
  /// Creates the region for [placement], reading [registry].
  const ShellRegionWidget({
    required this.placement,
    required this.registry,
    this.mode,
    this.page,
    super.key,
  });

  /// Which page of the window is up, or null for a region every page
  /// shares; passed through to the registry, like [mode].
  final PanelPageEnum? page;

  /// Which region this is.
  final PanelPlacementEnum placement;

  /// Where to ask what belongs in it.
  final PanelRegistry registry;

  /// Which document mode to draw, or null for a region the bar does not
  /// govern; passed through to the registry, never read here.
  final DocumentModeEnum? mode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<PanelPlacementEnum>('placement', placement))
      ..add(DiagnosticsProperty<PanelRegistry>('registry', registry))
      ..add(EnumProperty<DocumentModeEnum?>('mode', mode))
      ..add(EnumProperty<PanelPageEnum?>('page', page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PanelDescriptor> panels = registry.at(
      placement,
      mode: mode,
      page: page,
    );
    if (panels.isEmpty) {
      // Nothing registered takes no space: an empty fixed column reads as a
      // bug in the layout.
      return const SizedBox.shrink();
    }
    // The aside shows one panel at a time and the document area splits:
    // stacking does not survive a third panel, since a share of the height
    // is not always enough panel to read
    // (`docs/product/workspace/columns/doc.md`).
    final Widget content = switch (placement) {
      PanelPlacementEnum.aside => _SwitchedWidget(
        panels: panels,
        chosen: _chosenOf(panels, ref),
      ),
      PanelPlacementEnum.bottom => _TabbedWidget(
        panels: panels,
        chosen: _chosenBelow(panels, ref),
      ),
      _ => _SplitWidget(
        drawn: panels,
        kept: registry.keptAt(placement, mode: mode, page: page),
      ),
    };
    // The container is the shell's, not a region's: the document column's
    // runs from under the top bar to under the status bar and the row above
    // the document is **inside** it, which a box drawn here could not reach
    // (`docs/design/screens/measurements.md`).
    return content;
  }
}

/// Which panel the column is showing.
///
/// The one the reader chose, or the first: a saved choice outlives the panel
/// it named only until a module stops registering it, and falling back keeps
/// the column from going blank.
PanelDescriptor _chosenOf(List<PanelDescriptor> panels, WidgetRef ref) {
  final String? id = ref.watch(
    workspaceProvider.select((WorkspaceState it) => it.asidePanel),
  );
  return panels.firstWhere(
    (PanelDescriptor it) => it.id == id,
    orElse: () => panels.first,
  );
}

/// Which tab the panel under the document is showing, the same way.
PanelDescriptor _chosenBelow(List<PanelDescriptor> panels, WidgetRef ref) {
  final String? id = ref.watch(
    workspaceProvider.select((WorkspaceState it) => it.bottomPanel),
  );
  return panels.firstWhere(
    (PanelDescriptor it) => it.id == id,
    orElse: () => panels.first,
  );
}

/// The panels side by side, and under them, unseen, the ones kept alive.
///
/// Each panel carries a key of its own across modes, so the source pane
/// moving between the row and the hidden layer keeps its state — and with
/// it `re_editor`'s undo history. The hidden layer is always in the
/// `Stack`, empty or not: one that came and went would re-parent the row.
class _SplitWidget extends StatefulWidget {
  const _SplitWidget({required this.drawn, required this.kept});

  final List<PanelDescriptor> drawn;
  final List<PanelDescriptor> kept;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<PanelDescriptor>('drawn', drawn))
      ..add(IterableProperty<PanelDescriptor>('kept', kept));
  }

  @override
  State<_SplitWidget> createState() => _SplitWidgetState();
}

class _SplitWidgetState extends State<_SplitWidget> {
  final Map<String, GlobalKey> _keys = <String, GlobalKey>{};

  Widget _panel(PanelDescriptor panel) => KeyedSubtree(
    key: _keys.putIfAbsent(panel.id, () => GlobalKey(debugLabel: panel.id)),
    child: Builder(builder: panel.builder),
  );

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (int i, PanelDescriptor panel)
                in widget.drawn.indexed) ...<Widget>[
              if (i > 0) VerticalDivider(width: 1, color: colors.border),
              Expanded(child: _panel(panel)),
            ],
          ],
        ),
        // Laid out at the region's size but never painted, hit or focused:
        // a keystroke in preview must not edit a pane nobody can see.
        Visibility(
          visible: false,
          maintainState: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final PanelDescriptor panel in widget.kept)
                Expanded(child: _panel(panel)),
            ],
          ),
        ),
      ],
    );
  }
}

/// The panel under the document: its tabs, then the one chosen.
class _TabbedWidget extends StatelessWidget {
  const _TabbedWidget({required this.panels, required this.chosen});

  final List<PanelDescriptor> panels;
  final PanelDescriptor chosen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<PanelDescriptor>('panels', panels))
      ..add(DiagnosticsProperty<PanelDescriptor>('chosen', chosen));
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      WorkspaceBottomHeadWidget(panels: panels, chosen: chosen),
      Expanded(child: Builder(builder: chosen.builder)),
    ],
  );
}

/// One panel at a time, with the switch that chooses it above.
class _SwitchedWidget extends StatelessWidget {
  const _SwitchedWidget({required this.panels, required this.chosen});

  final List<PanelDescriptor> panels;
  final PanelDescriptor chosen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<PanelDescriptor>('panels', panels))
      ..add(DiagnosticsProperty<PanelDescriptor>('chosen', chosen));
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // One panel needs no switch: a control with a single choice says
          // nothing the panel does not already say.
          if (panels.length > 1)
            WorkspaceAsideSwitchWidget(panels: panels, chosen: chosen),
          Expanded(child: Builder(builder: chosen.builder)),
        ],
      ),
      // **Over** the column rather than above it: the boards draw the bar
      // across the column's own top edge, and a row reserved for it would
      // push everything under it down by three whether or not a request is
      // out (`docs/product/git-workflow/push-pull/while-a-request-runs/doc.md`).
      const Positioned(
        left: 0,
        right: 0,
        top: 0,
        child: _RemoteProgressWidget(),
      ),
    ],
  );
}

/// The bar, while git is talking to a remote.
///
/// Watched here rather than inside a panel because **committing is not
/// touched**: staging and committing reach no remote, and the bar is what
/// teaches that it is about the network and not about the app being busy.
class _RemoteProgressWidget extends ConsumerWidget {
  const _RemoteProgressWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Down while the command waits for a yes: nothing is on the network yet.
    final bool working =
        ref.watch(remoteProvider.select((RemoteState state) => state.isBusy)) &&
        !ref.watch(remoteAwaitingApprovalProvider);
    return working ? const TomProgressBarWidget() : const SizedBox.shrink();
  }
}

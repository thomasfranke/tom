import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/bootstrap/core_module.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/shell/tom_shell.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_desktop/theme/tom_theme.dart';

void main() {
  /// Mounts the shell with [modules] registered, in a window of [size].
  Future<void> pumpShell(
    WidgetTester tester, {
    List<TomModule> modules = const <TomModule>[CoreModule()],
    Size size = const Size(1280, 800),
    Brightness brightness = Brightness.light,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          panelRegistryProvider.overrideWithValue(PanelRegistry(modules)),
        ],
        child: MaterialApp(theme: tomTheme(brightness), home: const TomShell()),
      ),
    );
    // `MaterialApp` animates a theme change, so a single frame reads a
    // colour halfway between the two modes. Settling is what makes the
    // assertion about the theme rather than about the animation.
    await tester.pumpAndSettle();
  }

  PanelDescriptor panelSaying(
    String text, {
    required PanelPlacement placement,
    int order = 0,
  }) => PanelDescriptor(
    id: 'test.$text',
    title: text,
    placement: placement,
    order: order,
    builder: (BuildContext context) => Text(text),
  );

  group('the built-in panels go through the registry', () {
    testWidgets('the core module puts a panel in every region it claims', (
      WidgetTester tester,
    ) async {
      // The claim Decision 12 makes: the app's own panels are registered,
      // not wired into the shell. If this passes with CoreModule and the
      // next group passes with a stranger's module, the extension point is
      // real rather than decorative.
      await pumpShell(tester);

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('SOURCE'), findsOneWidget);
      expect(find.text('PREVIEW'), findsOneWidget);
      expect(find.text('no space open'), findsOneWidget);
    });

    testWidgets('the shell draws no panel of its own', (
      WidgetTester tester,
    ) async {
      // With no modules at all the regions collapse. Anything still on
      // screen beyond the chrome would be a panel the shell hardcoded.
      await pumpShell(tester, modules: const <TomModule>[]);

      expect(find.text('EXPLORER'), findsNothing);
      expect(find.text('SOURCE'), findsNothing);
      expect(find.text('no space open'), findsNothing);
    });
  });

  group('a module contributes the same way', () {
    testWidgets('a stranger panel appears in the region it asked for', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        modules: <TomModule>[
          const CoreModule(),
          _Module(<PanelDescriptor>[
            panelSaying('TASKS', placement: PanelPlacement.aside),
          ]),
        ],
      );

      expect(find.text('TASKS'), findsOneWidget);
      // And it displaced nothing: modules add.
      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('SOURCE'), findsOneWidget);
    });

    testWidgets('two panels in the document area sit side by side', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        modules: <TomModule>[
          _Module(<PanelDescriptor>[
            panelSaying('LEFT', placement: PanelPlacement.document),
            panelSaying('RIGHT', placement: PanelPlacement.document, order: 1),
          ]),
        ],
      );

      expect(
        tester.getCenter(find.text('LEFT')).dx,
        lessThan(tester.getCenter(find.text('RIGHT')).dx),
      );
      // Same row, not stacked: source and preview are two panels, never one
      // panel with a mode.
      expect(
        tester.getCenter(find.text('LEFT')).dy,
        tester.getCenter(find.text('RIGHT')).dy,
      );
    });
  });

  group('the layout', () {
    testWidgets('the explorer is exactly as wide as the wireframe says', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester);

      // A panel narrower on one screen than another is a bug, not a
      // variant (docs/product/workspace/doc.md). The extra pixel is the
      // rule between the explorer and the document area.
      final Size region = tester.getSize(
        find
            .ancestor(
              of: find.text('EXPLORER'),
              matching: find.byType(SizedBox),
            )
            .last,
      );
      expect(region.width, TomMetrics.explorer + 1);
    });

    testWidgets('explorer, document and status bar are on screen at once', (
      WidgetTester tester,
    ) async {
      // There is no full-screen takeover that hides the tree while editing.
      await pumpShell(tester);

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('SOURCE'), findsOneWidget);
      expect(find.text('no space open'), findsOneWidget);
    });

    testWidgets('the layout holds at the smallest window it allows', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        size: const Size(
          TomMetrics.minimumWindowWidth,
          TomMetrics.minimumWindowHeight,
        ),
      );

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('SOURCE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the theme', () {
    testWidgets('both modes render, and differ', (WidgetTester tester) async {
      // A colour added in one mode without its counterpart is a bug, not a
      // follow-up (docs/technical/design/visual-language.md).
      await pumpShell(tester);
      final TomColors light = TomColors.of(
        tester.element(find.byType(TomShell)),
      );

      await pumpShell(tester, brightness: Brightness.dark);
      final TomColors dark = TomColors.of(
        tester.element(find.byType(TomShell)),
      );

      expect(light.surface, isNot(dark.surface));
      expect(light.accent, isNot(dark.accent));
    });
  });
}

/// A module that contributes exactly what it was given.
class _Module implements TomModule {
  const _Module(this.panels);

  @override
  String get id => 'test.module';

  @override
  final List<PanelDescriptor> panels;

  @override
  List<Override> get overrides => const <Override>[];
}

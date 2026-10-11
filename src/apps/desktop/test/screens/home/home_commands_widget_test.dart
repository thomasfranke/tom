/// The Commands panel over Home's foot, with no space open.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/home/widgets/home_commands_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A module with the one panel Home draws, and a marker in it.
final class _Module implements TomModule {
  const _Module(this.panelId);

  final String panelId;

  @override
  String get id => 'test';

  @override
  List<Override> get overrides => const <Override>[];

  @override
  List<PanelDescriptor> get panels => <PanelDescriptor>[
    PanelDescriptor(
      id: panelId,
      title: (BuildContext context) => 'Commands',
      placement: PanelPlacementEnum.bottom,
      builder: (BuildContext context) => const Text('the list'),
    ),
  ];
}

void main() {
  late ProviderContainer container;

  Future<void> pump(
    WidgetTester tester, {
    String panel = 'tom.commands',
  }) async {
    container = ProviderContainer(
      overrides: <Override>[
        panelRegistryProvider.overrideWithValue(
          PanelRegistry(<TomModule>[_Module(panel)]),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: HomeCommandsWidget()),
        ),
      ),
    );
  }

  testWidgets('shut, it draws nothing and asks the registry nothing', (
    WidgetTester tester,
  ) async {
    await pump(tester);

    expect(find.text('the list'), findsNothing);
    expect(tester.getSize(find.byType(HomeCommandsWidget)), Size.zero);
  });

  testWidgets(
    'opened, it is the Commands panel at its height, under its head',
    (WidgetTester tester) async {
      await pump(tester);
      container.read(workspaceProvider.notifier).toggleBottom();
      await tester.pump();

      expect(find.text('the list'), findsOneWidget);
      expect(find.text('Commands'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is SizedBox && w.height == WorkspaceDesign.bottomHeight,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('a registry without the Commands panel draws nothing', (
    WidgetTester tester,
  ) async {
    await pump(tester, panel: 'acme.other');
    container.read(workspaceProvider.notifier).toggleBottom();
    await tester.pump();

    expect(find.text('the list'), findsNothing);
  });
}

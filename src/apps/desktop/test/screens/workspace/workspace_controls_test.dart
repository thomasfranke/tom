import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/workspace/workspace_controls_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  /// Mounts the group under [brightness], which is what the theme control
  /// reads to decide what it offers.
  Future<void> pumpControls(
    WidgetTester tester, {
    Brightness brightness = Brightness.dark,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          home: const Scaffold(body: Center(child: WorkspaceControlsWidget())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  WorkspaceState state() => container.read(workspaceProvider);

  testWidgets('it is three controls, read left to right', (
    WidgetTester tester,
  ) async {
    // One set: theme, then the two columns
    // (`docs/product/workspace/columns/doc.md`).
    await pumpControls(tester);

    expect(find.byType(TomThemeToggleWidget), findsOneWidget);
    expect(find.byType(TomPanelToggleWidget), findsNWidgets(2));
    expect(
      tester.getCenter(find.byType(TomThemeToggleWidget)).dx,
      lessThan(tester.getCenter(find.byType(TomPanelToggleWidget).first).dx),
    );
  });

  testWidgets('both columns open at the start, and each toggle closes one', (
    WidgetTester tester,
  ) async {
    await pumpControls(tester);
    expect(state().showingExplorer, isTrue);
    expect(state().showingAside, isTrue);

    await tester.tap(find.byTooltip('Hide explorer'));
    await tester.pumpAndSettle();

    expect(state().showingExplorer, isFalse);
    expect(
      state().showingAside,
      isTrue,
      reason: 'one toggle hides one column, never the other',
    );
  });

  testWidgets('a hidden column says how to bring it back', (
    WidgetTester tester,
  ) async {
    await pumpControls(tester);

    await tester.tap(find.byTooltip('Hide git'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Show git'), findsOneWidget);
  });

  testWidgets('in dark, the theme control offers light', (
    WidgetTester tester,
  ) async {
    // What it switches to is read off the theme actually drawn, so the first
    // press after opening is never the one that changes nothing.
    await pumpControls(tester);

    await tester.tap(find.byTooltip('Light theme'));
    await tester.pumpAndSettle();

    expect(state().theme, ThemeChoiceEnum.light);
  });

  testWidgets('and in light it offers dark', (WidgetTester tester) async {
    await pumpControls(tester, brightness: Brightness.light);

    await tester.tap(find.byTooltip('Dark theme'));
    await tester.pumpAndSettle();

    expect(state().theme, ThemeChoiceEnum.dark);
  });
}

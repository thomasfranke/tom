import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late TextEditingController controller;
  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Widget app(Widget child) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(
      body: Center(child: SizedBox(width: 200, child: child)),
    ),
  );

  testWidgets('shows its hint while empty, in the muted role', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(TomFieldWidget(controller: controller, hint: 'Search', fontSize: 13)),
    );

    expect(find.text('Search'), findsOneWidget);
    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.hintStyle!.color, TomColors.dark.textMuted);
    expect(field.cursorColor, TomColors.dark.accent);
    expect(field.cursorWidth, 1);
  });

  testWidgets('what is typed reaches the controller and onChanged, in the '
      'primary role at the weight it was given', (WidgetTester tester) async {
    final List<String> seen = <String>[];
    await tester.pumpWidget(
      app(
        TomFieldWidget(
          controller: controller,
          hint: 'Search',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          onChanged: seen.add,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'docs');

    expect(controller.text, 'docs');
    expect(seen, <String>['docs']);
    final TextStyle style = tester
        .widget<TextField>(find.byType(TextField))
        .style!;
    expect(style.color, TomColors.dark.textPrimary);
    expect(style.fontWeight, FontWeight.w600);
    expect(style.fontSize, 13);
  });

  testWidgets('Enter calls onSubmit and the field keeps the keyboard', (
    WidgetTester tester,
  ) async {
    int submitted = 0;
    final FocusNode focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      app(
        TomFieldWidget(
          controller: controller,
          hint: '',
          fontSize: 13,
          focusNode: focus,
          autofocus: true,
          onSubmit: () => submitted++,
        ),
      ),
    );
    await tester.pump();
    expect(focus.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, 1);
    expect(focus.hasFocus, isTrue);
  });

  testWidgets('the text starts the inset it was given from the box’s edge', (
    WidgetTester tester,
  ) async {
    controller.text = 'x';
    await tester.pumpWidget(
      app(
        TomFieldWidget(controller: controller, hint: '', fontSize: 13, pad: 20),
      ),
    );

    final double left = tester.getTopLeft(find.byType(TomFieldWidget)).dx;
    expect(tester.getTopLeft(find.byType(EditableText)).dx - left, 20);
  });
}

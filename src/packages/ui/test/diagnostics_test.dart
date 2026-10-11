/// What every control tells the inspector, and what a trunk commit is.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  const Color ink = Color(0xFF123456);

  /// The properties [widget] reports, as the inspector prints them.
  String described(Widget widget) => widget.toStringDeep();

  testWidgets('each control names the values it was built from', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);
    final Map<Widget, List<String>> expected = <Widget, List<String>>{
      const TomBarWidget(height: 40, child: SizedBox()): <String>['height: 40'],
      const DiffMarkWidget(letter: 'M', ink: ink, tooltip: 'Modified'):
          <String>['letter: "M"', 'isBare: false', 'tooltip: "Modified"'],
      const DiffMarkWidget.bare(letter: 'A', ink: ink): <String>[
        'isBare: true',
      ],
      const TomChevronWidget(isOpen: true, color: ink, size: 20): <String>[
        'isOpen: true',
        'size: 20.0',
      ],
      const TomFieldClearWidget(on: ink): <String>['on:'],
      const TomFieldBoxWidget(
        height: 28,
        fill: ink,
        radius: 6,
        isRefused: true,
        child: SizedBox(),
      ): <String>[
        'height: 28.0',
        'isFocused: false',
        'isRefused: true',
        'radius: 6.0',
      ],
      TomFieldWidget(
        controller: controller,
        hint: 'Search',
        fontSize: 13,
        onSubmit: () {},
        onChanged: (String _) {},
      ): <String>[
        'hint: "Search"',
        'fontSize: 13.0',
        'pad: 12.0',
        'onSubmit',
      ],
      const TomPanelToggleWidget(
        side: TomPanelSideEnum.bottom,
        isOpen: true,
        width: 20,
        height: 16,
        radius: 3,
        stroke: 1,
        strip: 5,
      ): <String>[
        'side: bottom',
        'isOpen: true',
        'strip: 5.0',
      ],
      const TomWordmarkWidget(letters: ink, commit: ink, capHeight: 40):
          <String>['capHeight: 40.0'],
      TomRowActionWidget(
        kind: TomRowActionKind.always,
        label: 'Always allow',
        onPressed: () {},
      ): <String>[
        'kind: always',
        'label: "Always allow"',
        'onPressed',
      ],
      TomCheckWidget(isChecked: true, onChanged: (bool _) {}): <String>[
        'isChecked: true',
        'onChanged',
      ],
      TomToolbarButtonWidget(
        glyph: TomGlyphEnum.plus,
        tooltip: 'Bold',
        onPressed: () {},
      ): <String>[
        'glyph: plus',
        'tooltip: "Bold"',
        'onPressed',
      ],
      const TomGlyphWidget(glyph: TomGlyphEnum.file, color: ink, outline: true):
          <String>['glyph: file', 'outline'],
      NoticeBandWidget(
        sentence: 'Behind',
        ink: ink,
        fill: ink,
        action: 'Pull',
        alternative: 'Later',
        onAlternative: () {},
      ): <String>[
        'sentence: "Behind"',
        'action: "Pull"',
        'alternative: "Later"',
        'disabled',
      ],
      const TomMenuButtonWidget(
        tooltip: 'Menu',
        width: 200,
        groups: <List<TomMenuEntry>>[],
      ): <String>[
        'tooltip: "Menu"',
        'width: 200.0',
        'drop: 1.5',
      ],
      TomMenuWidget(
        width: 200,
        onDismissed: () {},
        groups: const <List<TomMenuEntry>>[],
      ): <String>[
        'width: 200.0',
        'onDismissed',
      ],
      const TomDialogWidget(
        title: 'Sure?',
        body: <String>['a'],
        actions: <TomDialogAction>[],
      ): <String>[
        'title: "Sure?"',
        'actions: 0',
      ],
      const CommitTrunkWidget(
        commits: <TrunkCommit>[TrunkCommit(sha: 'abc', subject: 'one')],
        child: SizedBox(),
      ): <String>[
        'commits:',
      ],
    };

    for (final MapEntry<Widget, List<String>> entry in expected.entries) {
      final String text = described(entry.key);
      for (final String line in entry.value) {
        expect(
          text,
          contains(line),
          reason: '${entry.key.runtimeType} reports $line',
        );
      }
    }
  });

  testWidgets('the widgets a control builds inside report themselves too', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: tomTheme(Brightness.dark),
        home: Scaffold(
          body: CommitTrunkWidget(
            child: Column(
              children: <Widget>[
                TomMenuWidget(
                  width: 200,
                  onDismissed: () {},
                  groups: <List<TomMenuEntry>>[
                    <TomMenuEntry>[
                      TomMenuEntry(
                        glyph: TomGlyphEnum.discard,
                        label: 'Delete',
                        isDestructive: true,
                        onSelected: () {},
                      ),
                    ],
                  ],
                ),
                TomRowActionWidget(
                  kind: TomRowActionKind.always,
                  label: 'Always',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    for (final String name in <String>['_RowWidget', '_TwoChecks']) {
      final Element element = tester.element(
        find.byWidgetPredicate(
          (Widget w) => w.runtimeType.toString() == name,
          description: name,
        ),
      );
      expect(element.widget.toStringDeep(), startsWith(name));
    }
    final Element scope = tester.element(
      find.byWidgetPredicate(
        (Widget w) => w.runtimeType.toString() == '_TrunkScope',
        description: '_TrunkScope',
      ),
    );
    expect(scope.widget.toStringDeep(), contains('anchor'));
  });

  test('a trunk commit is its sha and its subject, and nothing else', () {
    const TrunkCommit a = TrunkCommit(sha: 'abc1234', subject: 'one');

    expect(a, const TrunkCommit(sha: 'abc1234', subject: 'one'));
    expect(
      a.hashCode,
      const TrunkCommit(sha: 'abc1234', subject: 'one').hashCode,
    );
    expect(a, isNot(const TrunkCommit(sha: 'abc1234', subject: 'two')));
    expect(a, isNot(const TrunkCommit(sha: 'ffffff', subject: 'one')));
    expect(a == Object(), isFalse);
  });
}

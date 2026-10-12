/// Every menu of the CLI is alphabetical, and the e2e group menu's right-hand
/// text is two columns that line up.
///
/// The menus are the ones the screens draw, built by the same functions
/// (`cliMenus`), so a screen added later is held to the order once it has a
/// line there.
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../../tool/src/cli/menu.dart';
import '../../../tool/src/commands/e2e_catalogue.dart';

void main() {
  group('alphabetical order', () {
    // `cli --menus`: every screen's lists of labels, as the screens build them.
    final ProcessResult printed = Process.runSync(
      Platform.resolvedExecutable,
      <String>['run', 'tool/cli.dart', '--menus'],
      workingDirectory: _repositoryRoot.path,
    );
    final Map<String, List<List<String>>> menus =
        (jsonDecode(printed.stdout as String) as Map<String, Object?>).map(
          (String name, Object? runs) =>
              MapEntry<String, List<List<String>>>(name, <List<String>>[
                for (final Object? run in runs! as List<Object?>)
                  <String>[for (final Object? l in run! as List<Object?>) '$l'],
              ]),
        );
    final Set<String> planned = <String>{
      for (final Scenario s in discoverScenarios(repository: _repositoryRoot))
        if (s.isPlanned) s.name,
    };

    /// The lists that keep an order of their own, by the menu they sit in and
    /// the first label of the list.
    ///
    /// `Codegen` runs mildest first (`Normal`, `Hard`) so the safe default is
    /// under the cursor; the `Package` screen's `Packages` list is the layer
    /// graph from `core` up. A written scenario precedes a plan, each half
    /// alphabetical, and is checked below.
    const Map<String, String> fixed = <String, String>{
      'Codegen': 'Normal',
      'Package': 'Core',
    };

    test('the screens are all there', () {
      expect(
        menus.keys,
        containsAll(<String>[
          'Root',
          'Build',
          'Codegen',
          'Package',
          'Rules',
          'End-to-end',
        ]),
      );
    });

    test('the Tests list reads Coverage, End-to-end, Integration, Unit', () {
      final List<String> tests = menus['Root']!.firstWhere(
        (List<String> r) => r.first.startsWith('Coverage'),
      );
      expect(tests, <String>[
        'Coverage (Unit + Integration)',
        'End-to-end',
        'Integration',
        'Unit',
      ]);
    });

    for (final MapEntry<String, List<List<String>>> menu in menus.entries) {
      test('${menu.key} is in order', () {
        for (final List<String> run in menu.value) {
          if (fixed[menu.key] == run.first) {
            continue;
          }
          final List<String> written = <String>[
            for (final String l in run)
              if (!planned.contains(l)) l,
          ];
          final List<String> plans = <String>[
            for (final String l in run)
              if (planned.contains(l)) l,
          ];
          // A plan follows every written scenario: what can run comes first.
          expect(run, <String>[...written, ...plans], reason: 'plans last');
          for (final List<String> part in <List<String>>[written, plans]) {
            final List<String> sorted = <String>[...part]
              ..sort(
                (String a, String b) =>
                    menuSortKey(a).compareTo(menuSortKey(b)),
              );
            expect(part, sorted, reason: '${menu.key}: ${run.join(' · ')}');
          }
        }
      });
    }

    test(
      'the order the helper uses ignores case, a leading symbol and a gloss',
      () {
        expect(menuSortKey('iOS'), 'ios');
        expect(menuSortKey('— odd'), 'odd');
        expect(
          menuSortKey(
            'Last — the 10 files',
          ).compareTo(menuSortKey('Last coverage')),
          isNegative,
        );
      },
    );

    test('a list out of order is told apart from one in order', () {
      const List<MenuItem<String>> wrong = <MenuItem<String>>[
        MenuItem<String>('Unit', 'u'),
        MenuItem<String>('End-to-end', 'e'),
      ];
      expect(entryRuns(wrong).single, <String>['Unit', 'End-to-end']);
      expect(
        sortedByLabel(wrong).map((MenuItem<String> i) => i.label),
        <String>['End-to-end', 'Unit'],
      );
    });
  });

  group('the e2e group menu columns', () {
    // `NNN planned`, ` · `, then the state: 11 + 3 + 14.
    const int plannedWidth = 11;
    const int separatorWidth = 3;
    const int stateWidth = 14;
    const int total = plannedWidth + separatorWidth + stateWidth;

    final List<String> lines = _preview(<String>['e2e']);
    final List<String> rows = <String>[
      for (final String l in lines)
        if (l.contains(' · ') &&
            (l.trimRight().endsWith('passed') ||
                l.trimRight().endsWith('failing') ||
                l.trimRight().endsWith('run')))
          l,
    ];

    test('the groups are rows with a state', () {
      expect(rows.length, greaterThanOrEqualTo(5));
    });

    test('every row ends on the same column', () {
      expect(rows.map((String l) => l.trimRight().length).toSet().length, 1);
    });

    test('the two columns have the same widths on every row', () {
      for (final String row in rows) {
        final String tail = row.trimRight().substring(
          row.trimRight().length - total,
        );
        final String plans = tail.substring(0, plannedWidth);
        expect(
          tail.substring(plannedWidth, plannedWidth + separatorWidth),
          ' · ',
        );
        expect(plans, matches(RegExp(r'^ *(\d+ planned)?$')));
        expect(
          tail.substring(plannedWidth + separatorWidth),
          matches(
            RegExp(
              r'^ *(✓ +\d+ passed|✘ +\d+ failing|○ +\d+ passed|\d+ +of +\d+ +run)$',
            ),
          ),
        );
        expect(
          tail.substring(plannedWidth + separatorWidth).length,
          stateWidth,
        );
      }
    });

    test('a row with no plans leaves its column blank and keeps the state', () {
      final List<String> unplanned = <String>[
        for (final String row in rows)
          if (!row.contains('planned')) row,
      ];
      expect(unplanned, isNotEmpty, reason: 'a group with nothing planned');
      for (final String row in unplanned) {
        final String tail = row.trimRight().substring(
          row.trimRight().length - total,
        );
        expect(tail.substring(0, plannedWidth).trim(), isEmpty);
      }
      expect(unplanned.first.trimRight().length, rows.first.trimRight().length);
    });

    test('the counts are right-aligned inside their columns', () {
      final List<String> counted = <String>[
        for (final String row in rows)
          if (row.contains('planned')) row,
      ];
      final Set<int> ends = <int>{
        for (final String row in counted) row.indexOf(' planned'),
      };
      expect(ends.length, 1);
    });
  });
}

List<String> _preview(List<String> arguments) {
  final ProcessResult result = Process.runSync(
    Platform.resolvedExecutable,
    <String>['run', 'tool/cli.dart', '--preview', ...arguments],
    workingDirectory: _repositoryRoot.path,
  );
  if (result.exitCode != 0) {
    throw StateError('cli --preview failed: ${result.stderr}');
  }
  return (result.stdout as String)
      .replaceAll(RegExp(r'\x1B\[[0-9;?]*[a-zA-Z]'), '')
      .split('\n');
}

Directory get _repositoryRoot {
  Directory directory = Directory.current;
  while (!File('${directory.path}/tool/cli.dart').existsSync()) {
    final Directory parent = directory.parent;
    if (parent.path == directory.path) {
      throw StateError('tool/cli.dart not found above ${Directory.current}');
    }
    directory = parent;
  }
  return directory;
}

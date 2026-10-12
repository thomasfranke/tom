/// The scenario menus: how many entries each holds, the order they are in,
/// where the files sit, and how the last-run column is padded.
///
/// Read from the sources through `discoverScenarios(repository:)`, so a
/// scenario added tomorrow is held to the same rules without a line here.
library;

import 'dart:io';

import 'package:test/test.dart';

import '../../../tool/src/commands/e2e_catalogue.dart';

void main() {
  final Directory repository = _repositoryRoot;
  final List<Scenario> all = discoverScenarios(repository: repository);

  group('the last-run column', () {
    final DateTime now = DateTime.now();
    final List<DateTime> whens = <DateTime>[
      now,
      now.subtract(const Duration(days: 1)),
      now.subtract(const Duration(days: 3)),
      now.subtract(const Duration(days: 10)),
      now.subtract(const Duration(days: 30)),
      now.subtract(const Duration(days: 400)),
    ];
    final int width = whens
        .map((DateTime w) => relativeWord(w).length)
        .reduce((int a, int b) => a > b ? a : b);

    test('puts the relative word first and the date after it', () {
      final String text = describeWhen(now);
      expect(text, startsWith('today · '));
      expect(text, matches(RegExp(r'^today · \d{4}-\d{2}-\d{2}$')));
    });

    test('pads every relative word to the longest, so the dates line up', () {
      final List<String> rows = <String>[
        for (final DateTime when in whens)
          describeWhen(when, relativeWidth: width),
      ];
      final Set<int> dateColumns = <int>{
        for (final String row in rows) row.indexOf(RegExp(r'\d{4}-\d{2}-')),
      };
      expect(dateColumns, hasLength(1), reason: rows.join('\n'));
      expect(
        rows.map((String row) => row.length).toSet(),
        hasLength(1),
        reason: 'every row is as wide as the next',
      );
      expect(dateColumns.single, width + ' · '.length);
    });

    test('the width is the longest relative word of the results', () {
      final List<ScenarioResult> results = <ScenarioResult>[
        for (final DateTime when in whens)
          ScenarioResult(
            outcome: ScenarioOutcome.passed,
            when: when.toUtc(),
            version: '0.1.0',
            steps: 1,
            elapsed: Duration.zero,
          ),
      ];
      expect(relativeWidthOf(results), width);
      expect(relativeWidthOf(const <ScenarioResult>[]), 0);
    });
  });

  group('the menus', () {
    test('the groups are listed alphabetically', () {
      expect(scenarioGroups, <String>[...scenarioGroups]..sort());
    });

    test('every scenario names a declared group', () {
      for (final Scenario s in all) {
        expect(scenarioGroups, contains(s.group), reason: s.name);
      }
    });

    test('no menu holds more than $menuLimit entries', () {
      expect(
        scenarioGroups.length,
        lessThanOrEqualTo(menuLimit),
        reason: 'the groups',
      );
      for (final MapEntry<String, List<Scenario>> group in scenariosByGroup(
        all,
      ).entries) {
        final Map<String, List<Scenario>> submenus = scenariosBySubmenu(
          group.value,
        );
        expect(
          submenus.isEmpty ? group.value.length : submenus.length,
          lessThanOrEqualTo(menuLimit),
          reason: group.key,
        );
        for (final MapEntry<String, List<Scenario>> sub in submenus.entries) {
          expect(
            sub.value.length,
            lessThanOrEqualTo(menuLimit),
            reason: '${group.key} › ${sub.key}',
          );
        }
      }
    });

    test('a group lists submenus or scenarios, never both', () {
      for (final MapEntry<String, List<Scenario>> group in scenariosByGroup(
        all,
      ).entries) {
        final int withSubmenu = group.value
            .where((Scenario s) => s.submenu != null)
            .length;
        expect(
          withSubmenu == 0 || withSubmenu == group.value.length,
          isTrue,
          reason: '${group.key} mixes scenarios and submenus',
        );
      }
    });

    test('submenus and scenarios are alphabetical, plans after written', () {
      for (final MapEntry<String, List<Scenario>> group in scenariosByGroup(
        all,
      ).entries) {
        final Map<String, List<Scenario>> submenus = scenariosBySubmenu(
          group.value,
        );
        expect(
          submenus.keys.toList(),
          <String>[...submenus.keys]..sort(),
          reason: '${group.key}: submenus',
        );
        final Iterable<List<Scenario>> menus = submenus.isEmpty
            ? <List<Scenario>>[group.value]
            : submenus.values;
        for (final List<Scenario> menu in menus) {
          final List<String> written = <String>[
            for (final Scenario s in menu)
              if (!s.isPlanned) s.name,
          ];
          final List<String> planned = <String>[
            for (final Scenario s in menu)
              if (s.isPlanned) s.name,
          ];
          expect(
            <String>[for (final Scenario s in menu) s.name],
            <String>[...written, ...planned],
            reason: '${group.key}: a plan sits before a written scenario',
          );
          expect(written, <String>[...written]..sort(), reason: group.key);
          expect(planned, <String>[...planned]..sort(), reason: group.key);
        }
      }
    });
  });

  group('the folders', () {
    test('a scenario sits under the folder of its menu', () {
      for (final Scenario s in all) {
        final String directory = s.file.substring(0, s.file.lastIndexOf('/'));
        expect(
          directory,
          s.folder,
          reason:
              '${s.name} is in ${s.file}, listed under '
              '${s.group}${s.submenu == null ? '' : ' › ${s.submenu}'}',
        );
      }
    });

    test('every folder under e2e/ is a menu that exists', () {
      final Set<String> folders = <String>{
        for (final Scenario s in all) s.folder,
      };
      final Directory root = Directory(
        '${repository.path}/$scenarioDirectory/$scenarioRoot',
      );
      for (final FileSystemEntity entry in root.listSync(recursive: true)) {
        if (entry is! File) {
          continue;
        }
        final String relative = entry.path.substring(
          '${repository.path}/$scenarioDirectory/'.length,
        );
        final String directory = relative.substring(
          0,
          relative.lastIndexOf('/'),
        );
        expect(
          folders,
          contains(directory),
          reason: '$relative is in a folder no menu lists',
        );
      }
    });

    test('no scenario or plan sits outside e2e/', () {
      final Directory base = Directory('${repository.path}/$scenarioDirectory');
      final List<String> stray = <String>[
        for (final FileSystemEntity entry in base.listSync(recursive: true))
          if (entry is File &&
              (entry.path.endsWith('_test.dart') ||
                  entry.path.endsWith('_planned.dart')) &&
              !entry.path.contains('/$scenarioRoot/'))
            entry.path,
      ];
      expect(stray, isEmpty);
    });

    test('a folder is the menu\'s own words in snake case', () {
      expect(menuSlug('Pull request'), 'pull_request');
      expect(menuSlug('Leaving a space'), 'leaving_a_space');
      expect(menuSlug('Home'), 'home');
    });
  });
}

Directory get _repositoryRoot {
  Directory directory = Directory.current;
  for (int level = 0; level < 8; level++) {
    if (File('${directory.path}/Makefile').existsSync() &&
        File('${directory.path}/src/pubspec.yaml').existsSync()) {
      return directory;
    }
    directory = directory.parent;
  }
  throw StateError('The repository root was not found.');
}

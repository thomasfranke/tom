/// The layer graph, checked for the three leaks the compiler cannot see: a
/// dependency added to a pubspec, an SDK library that needs no declaration,
/// and Flutter arriving through `dev_dependencies`.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// What each package may depend on. Declaring fewer is fine; declaring
/// anything absent from this map is the failure guarded against.
const Map<String, Set<String>> graph = <String, Set<String>>{
  'tom_core': <String>{},
  'tom_domain': <String>{'tom_core'},
  'tom_application': <String>{'tom_core', 'tom_domain'},
  // One layer in two packages that depend on each other on purpose
  // (Decision 24); what `tom_infra` may not have is `tom_domain`, which is
  // the whole guarantee.
  'tom_data': <String>{'tom_core', 'tom_domain', 'tom_infra'},
  'tom_infra': <String>{'tom_core', 'tom_data'},
  'tom_presentation': <String>{'tom_core', 'tom_domain', 'tom_application'},
  // Depends on nothing, which is what makes the look shareable (Decision 26).
  'tom_ui': <String>{},
  'tom_desktop': <String>{
    'tom_core',
    'tom_domain',
    'tom_application',
    'tom_infra',
    'tom_data',
    'tom_presentation',
    'tom_ui',
  },
  // Reserved for Phase 3 (docs/roadmap.md); its infra and data arrive with
  // the mobile implementations of the contracts.
  'tom_mobile': <String>{
    'tom_core',
    'tom_domain',
    'tom_application',
    'tom_presentation',
    'tom_ui',
  },
};

/// What each package may depend on to test only, on top of [graph].
///
/// Empty since Decision 24, and kept so the next exception has somewhere to
/// be declared and a test below proving `lib/` never uses it.
const Map<String, Set<String>> testOnlyGraph = <String, Set<String>>{};

/// Libraries each package may not import, whatever its pubspec says.
///
/// The pubspec answers which *packages* a layer may reach; this answers
/// which *capabilities*, since `dart:io` needs no declaration and a domain
/// entity could otherwise run `Process.run` with every other check green.
const Map<String, Set<String>> forbiddenImports = <String, Set<String>>{
  'tom_core': <String>{
    'dart:io',
    'dart:ffi',
    'dart:isolate',
    'package:flutter',
  },
  'tom_domain': <String>{
    'dart:io',
    'dart:ffi',
    'dart:isolate',
    'package:flutter',
  },
  'tom_application': <String>{
    'dart:io',
    'dart:ffi',
    'dart:isolate',
    'package:flutter',
  },
  'tom_data': <String>{'dart:io', 'dart:ffi', 'package:flutter'},
  'tom_presentation': <String>{'dart:io', 'dart:ffi', 'package:flutter'},
  'tom_infra': <String>{'package:flutter'},
  // A component that reads a file cannot be drawn on the other platform.
  'tom_ui': <String>{'dart:io', 'dart:ffi', 'dart:isolate'},
  'tom_desktop': <String>{},
  'tom_mobile': <String>{},
};

/// Packages that drag Flutter in, in any dependency section.
///
/// `flutter_test` in a pure package's `dev_dependencies` is the quiet
/// failure: nothing imports a widget, but `dart test` no longer runs.
const Set<String> flutterPackages = <String>{
  'flutter',
  'flutter_test',
  'flutter_lints',
  'flutter_localizations',
  'integration_test',
};

/// The composition roots — the packages that wire an application together.
///
/// The end-to-end harness is not a third: it runs inside the app's own
/// native runner, and a second runner drifts into a configuration nobody
/// ships, so the scenarios live in `apps/desktop/integration_test/`.
const Set<String> compositionRoots = <String>{'tom_desktop', 'tom_mobile'};

/// The packages allowed to know Flutter exists: the roots plus `tom_ui`,
/// which draws for both applications and wires nothing (Decision 26).
const Set<String> framework = <String>{...compositionRoots, 'tom_ui'};

/// An `import` or `export`, with the URI it names.
final RegExp directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main() {
  final Map<String, YamlMap> pubspecs = <String, YamlMap>{};
  final Map<String, Directory> directories = <String, Directory>{};
  late final Directory workspace;

  setUpAll(() {
    workspace = findWorkspaceRoot();
    for (final Directory entry in <Directory>[
      for (final String group in <String>['packages', 'apps'])
        ...Directory(
          '${workspace.path}/$group',
        ).listSync().whereType<Directory>(),
    ]) {
      final File file = File('${entry.path}/pubspec.yaml');
      if (!file.existsSync()) {
        continue;
      }
      final YamlMap doc = loadYaml(file.readAsStringSync()) as YamlMap;
      final String name = doc['name'] as String;
      pubspecs[name] = doc;
      directories[name] = entry;
    }
  });

  /// Every package named in [section] of [package]'s pubspec.
  Set<String> declared(String package, String section) =>
      ((pubspecs[package]![section] as YamlMap?)?.keys ?? const <String>[])
          .cast<String>()
          .toSet();

  /// Everything [package] depends on, whether to build or only to test.
  Set<String> allDependenciesOf(String package) =>
      declared(package, 'dependencies')
        ..addAll(declared(package, 'dev_dependencies'));

  test('the workspace contains exactly the packages this test knows about', () {
    expect(
      pubspecs.keys.toSet(),
      graph.keys.toSet(),
      reason:
          'A package was added, removed or renamed without updating this '
          'test. That is deliberate friction: the graph is a decision, so '
          'changing it should be a decision.',
    );
  });

  /// The `tom_` packages [package] names in [section].
  Set<String> siblingsIn(String package, String section) => declared(
    package,
    section,
  ).where((String d) => d.startsWith('tom_')).toSet();

  group('dependency direction', () {
    graph.forEach((String package, Set<String> allowed) {
      final String expectation = allowed.isEmpty
          ? 'nothing'
          : allowed.join(', ');
      test('$package depends on $expectation', () {
        expect(
          siblingsIn(package, 'dependencies').difference(allowed),
          isEmpty,
          reason:
              '$package declares a dependency it is not allowed to have. If '
              'the layering genuinely changed, change it here first and say '
              'why in docs/technical/architecture.md.',
        );
      });

      final Set<String> forTests = <String>{
        ...allowed,
        ...?testOnlyGraph[package],
      };
      test('$package tests against ${forTests.join(', ')}', () {
        expect(
          siblingsIn(package, 'dev_dependencies').difference(forTests),
          isEmpty,
          reason:
              "$package's tests reach a package the layer graph does not "
              'allow. A dev dependency is a smaller admission than a real '
              'one, but it is still one: add it to testOnlyGraph with the '
              'reason, or stop using it.',
        );
      });
    });
  });

  group('a test-only dependency stays out of the build', () {
    testOnlyGraph.forEach((String package, Set<String> testOnly) {
      test('$package does not import ${testOnly.join(', ')} from lib/', () {
        final List<String> offences = <String>[
          for (final File file in dartFilesIn(directories[package]!))
            for (final RegExpMatch match in directive.allMatches(
              file.readAsStringSync(),
            ))
              if (testOnly.any(
                (String banned) =>
                    match.group(1)!.startsWith('package:$banned/'),
              ))
                '${file.path.replaceFirst('${workspace.path}/', '')} imports '
                    '${match.group(1)}',
        ];

        expect(
          offences,
          isEmpty,
          reason:
              'A package $package is only allowed to *test* against reached '
              'its lib/. That is the layer graph inverted, and the pubspec '
              'cannot catch it — the dependency is declared, just for the '
              'other half of the package.',
        );
      });
    });
  });

  group('framework isolation', () {
    for (final String package in graph.keys) {
      final bool draws = framework.contains(package);

      test(
        draws
            ? '$package is a Flutter package and says so'
            : '$package declares no Flutter package, not even to test',
        () {
          final Set<String> flutter = allDependenciesOf(
            package,
          ).intersection(flutterPackages);

          if (draws) {
            expect(
              flutter,
              contains('flutter'),
              reason:
                  '$package draws — a composition root or the shared look; '
                  'it is meant to have Flutter.',
            );
          } else {
            expect(
              flutter,
              isEmpty,
              reason:
                  'Flutter reached $package through $flutter. Framework '
                  'independence stops being provable the moment a layer '
                  'below the app needs a binding to run.',
            );
          }
        },
      );
    }
  });

  group('forbidden imports', () {
    forbiddenImports.forEach((String package, Set<String> forbidden) {
      final String expectation = forbidden.isEmpty
          ? 'may import anything — it is the composition root'
          : 'imports no ${forbidden.join(', ')}';

      test('$package $expectation', () {
        if (forbidden.isEmpty) {
          return;
        }

        final List<String> offences = <String>[];
        for (final File file in dartFilesIn(directories[package]!)) {
          for (final RegExpMatch match in directive.allMatches(
            file.readAsStringSync(),
          )) {
            final String uri = match.group(1)!;
            final String path = file.path.replaceFirst(
              '${workspace.path}/',
              '',
            );
            if (forbidden.any(
              (String banned) => uri == banned || uri.startsWith('$banned/'),
            )) {
              offences.add('$path imports $uri');
            }
          }
        }

        expect(
          offences,
          isEmpty,
          reason:
              'A capability the layer is not allowed to have reached '
              '$package. The pubspec cannot catch this — SDK libraries need '
              'no declaration — so the boundary lives here.',
        );
      });
    });
  });

  test("a screen's own widgets stay its own", () {
    // Privacy in Dart is per file, so a screen's widgets split into files
    // are public and the statement lives here: `screens/<a>/widgets/` is
    // readable from `screens/<a>/` only, and what two screens both draw
    // belongs in `tom_ui` (Decision 26).
    final RegExp owned = RegExp(
      r'package:tom_desktop/screens/([a-z_]+)/widgets/',
    );
    final List<String> offences = <String>[];

    for (final String package in compositionRoots) {
      final Directory? directory = directories[package];
      if (directory == null) {
        continue;
      }
      for (final File file in <File>[
        ...dartFilesIn(directory),
        ...dartFilesUnder(Directory('${directory.path}/test')),
      ]) {
        final String path = file.path.replaceFirst('${workspace.path}/', '');
        for (final RegExpMatch match in directive.allMatches(
          file.readAsStringSync(),
        )) {
          final RegExpMatch? owner = owned.firstMatch(match.group(1)!);
          if (owner == null) {
            continue;
          }
          final String belongsTo = owner.group(1)!;
          if (!file.path.contains('/screens/$belongsTo/')) {
            offences.add('$path imports ${match.group(1)}');
          }
        }
      }
    }

    expect(
      offences,
      isEmpty,
      reason:
          "A screen reached into another screen's widgets. A widget two "
          "screens both draw is not either one's — move it to packages/ui "
          'and let both import it from there.',
    );
  });

  // The naming and shape rules live in `tom rules`
  // (`tool/src/commands/rules.dart`); this file is about the graph.

  test('nothing overrides a dependency', () {
    final List<String> overriding = <String>[
      for (final MapEntry<String, YamlMap> entry in pubspecs.entries)
        if ((entry.value['dependency_overrides'] as YamlMap?)?.isNotEmpty ??
            false)
          entry.key,
      if ((loadYaml(File('${workspace.path}/pubspec.yaml').readAsStringSync())
              as YamlMap)['dependency_overrides'] !=
          null)
        'the workspace root',
    ];

    expect(
      overriding,
      isEmpty,
      reason:
          'An override silently replaces what a pubspec declares, which makes '
          'every check above describe a graph that is not the one being '
          'built. If one is genuinely needed, it is a decision, and it is '
          'documented before it is added.',
    );
  });
}

/// Every `.dart` file under a package's `lib/`, generated ones included,
/// since a generated `package:flutter` import is the leak nobody writes.
Iterable<File> dartFilesIn(Directory package) =>
    dartFilesUnder(Directory('${package.path}/lib'));

/// Every `.dart` file under [directory], or nothing when it is not there.
Iterable<File> dartFilesUnder(Directory directory) => directory.existsSync()
    ? directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) => file.path.endsWith('.dart'))
    : const <File>[];

/// The `src/` directory, found from wherever the test was started — `src/`,
/// a single package, or the repository root.
Directory findWorkspaceRoot() {
  bool isWorkspace(Directory dir) {
    final File pubspec = File('${dir.path}/pubspec.yaml');
    return pubspec.existsSync() &&
        pubspec.readAsStringSync().contains(
          RegExp(r'^workspace:', multiLine: true),
        );
  }

  final Directory nested = Directory('${Directory.current.path}/src');
  if (isWorkspace(nested)) {
    return nested;
  }

  Directory dir = Directory.current;
  while (true) {
    if (isWorkspace(dir)) {
      return dir;
    }
    final Directory parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'No pub workspace above ${Directory.current.path}. Run this from the '
        'repository root (make test-arch) or from src/.',
      );
    }
    dir = parent;
  }
}

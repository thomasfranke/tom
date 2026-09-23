/// The layer graph, checked against what the code and the pubspecs declare.
///
/// The package boundaries already make an illegal `package:` import fail to
/// compile. This test covers the three failures the compiler cannot see:
///
///   * a dependency **added to a pubspec**, after which the illegal import
///     compiles perfectly well;
///   * an SDK library — `dart:io` needs no declaration, so nothing stops a
///     pure layer spawning a process or opening a file;
///   * a Flutter package arriving through `dev_dependencies`, after which the
///     package no longer runs under `dart test` at all.
///
/// A diagram in the docs would catch none of them. This does.
///
///     dart test test/architecture_test.dart
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// What each package may depend on.
///
/// Declaring *fewer* is fine — a layer that has not needed one of these yet is
/// not a problem. Declaring anything absent from this map is the failure being
/// guarded against.
const Map<String, Set<String>> graph = <String, Set<String>>{
  'tom_core': <String>{},
  'tom_domain': <String>{'tom_core'},
  'tom_application': <String>{'tom_core', 'tom_domain'},
  // The two halves of the data layer, and they depend on each other on
  // purpose (Decision 24): `tom_infra` holds each capability's contract and
  // failures, `tom_data` the DTOs that cross those contracts and the
  // repositories written against them. One layer, two packages, and pub
  // resolves the cycle.
  //
  // What `tom_infra` may *not* have is `tom_domain`, which is the whole
  // guarantee: an adapter cannot name a domain type, because the package
  // holding them is not on its list.
  'tom_data': <String>{'tom_core', 'tom_domain', 'tom_infra'},
  'tom_infra': <String>{'tom_core', 'tom_data'},
  'tom_presentation': <String>{'tom_core', 'tom_domain', 'tom_application'},
  'tom_desktop': <String>{
    'tom_core',
    'tom_domain',
    'tom_application',
    'tom_infra',
    'tom_data',
    'tom_presentation',
  },
  // Reserved skeleton for Phase 3 (docs/roadmap.md). No infra/data
  // yet — those are platform-specific and arrive with the mobile-specific
  // implementations of the contracts tom_infra defines for desktop.
  'tom_mobile': <String>{
    'tom_core',
    'tom_domain',
    'tom_application',
    'tom_presentation',
  },
};

/// What each package may depend on **to test only**, on top of [graph].
///
/// Empty, and worth keeping: `tom_data` needed `tom_infra` as a dev
/// dependency only while the ports lived in `tom_data` and the arrow pointed
/// the other way. It is an ordinary dependency now (Decision 24), so the
/// exception is gone — and the next package that wants one has somewhere to
/// declare it, and a test below proving `lib/` never uses it.
const Map<String, Set<String>> testOnlyGraph = <String, Set<String>>{};

/// Libraries each package may not import, whatever its pubspec says.
///
/// The pubspec answers *which packages* a layer may reach; this answers *which
/// capabilities*. They are different questions: `dart:io` ships with the SDK
/// and is available to everything by default, so without this table a domain
/// entity can run `Process.run` and every other mechanism stays green.
///
/// `tom_infra` is where the process, the socket and the file belong — that is
/// the whole job of the package. `tom_desktop` is the composition root and is
/// deliberately unconstrained.
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
  'tom_desktop': <String>{},
  'tom_mobile': <String>{},
};

/// Packages that drag Flutter in, in any dependency section.
///
/// `flutter_test` in a pure package's `dev_dependencies` is the quiet version
/// of the failure: nothing imports a widget, but the package can no longer run
/// under `dart test`, and framework independence stops being provable.
const Set<String> flutterPackages = <String>{
  'flutter',
  'flutter_test',
  'flutter_lints',
  'flutter_localizations',
  'integration_test',
};

/// The composition roots — the only packages allowed to know Flutter exists.
///
/// The end-to-end harness is not a fourth entry here, and the reason is
/// worth knowing before anyone tries: an end-to-end run happens inside the
/// app's own native runner, with the app's entitlements and its Podfile. A
/// package of its own would need a second runner, and a second runner
/// drifts — at which point the tests prove something about a configuration
/// nobody ships. So the scenarios live in `apps/desktop/integration_test/`.
const Set<String> compositionRoots = <String>{'tom_desktop', 'tom_mobile'};

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
              'why in docs/technical/layers.md.',
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
      final bool isRoot = compositionRoots.contains(package);

      test(
        isRoot
            ? '$package is a composition root with Flutter'
            : '$package declares no Flutter package, not even to test',
        () {
          final Set<String> flutter = allDependenciesOf(
            package,
          ).intersection(flutterPackages);

          if (isRoot) {
            expect(
              flutter,
              contains('flutter'),
              reason:
                  '$package is a composition root; it is meant to have '
                  'Flutter.',
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
    // A screen's sub-widgets used to be private classes in one file, which
    // is what said "these are Home's, not yours". Splitting them into files
    // made them public — privacy in Dart is per file — so the statement
    // moved here. `screens/<a>/widgets/` is readable from `screens/<a>/`
    // and nowhere else; anything shared between two screens belongs in the
    // app's own `widgets/`, which is what that folder is for.
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
          // The screen the widget belongs to, and the one importing it.
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
          'screens both draw is not either one\'s — move it to '
          'apps/desktop/lib/widgets/ and let both import it from there.',
    );
  });

  // The naming and shape rules — `Impl` in the class and in the file, a
  // capability as a complete folder, the barrel as its whole `lib/src`, a
  // repository holding no capability — live in `tom rules`
  // (`tool/src/commands/rules.dart`), which `tom verify` runs. Same
  // mechanism, different subject: this file is about the graph.

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

/// Every `.dart` file under a package's `lib/`, generated ones included.
///
/// Generated code is scanned on purpose: an annotation that generates a
/// `package:flutter` import in a pure package is exactly the kind of leak that
/// arrives without anyone writing the import.
Iterable<File> dartFilesIn(Directory package) =>
    dartFilesUnder(Directory('${package.path}/lib'));

/// Every `.dart` file under [directory], or nothing when it is not there.
Iterable<File> dartFilesUnder(Directory directory) => directory.existsSync()
    ? directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) => file.path.endsWith('.dart'))
    : const <File>[];

/// The `src/` directory, found from wherever the test was started.
///
/// `dart test` from `src/`, from a single package, or `make test` from the
/// repository root all have to reach the same place.
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

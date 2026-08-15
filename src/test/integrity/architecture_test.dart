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
  'tom_infra': <String>{'tom_core'},
  'tom_data': <String>{'tom_core', 'tom_domain', 'tom_infra'},
  'tom_presentation': <String>{'tom_core', 'tom_domain', 'tom_application'},
  'tom_desktop': <String>{
    'tom_core',
    'tom_domain',
    'tom_application',
    'tom_infra',
    'tom_data',
    'tom_presentation',
  },
};

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

/// The composition root, and the only package allowed to know Flutter exists.
const String compositionRoot = 'tom_desktop';

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
    for (final String group in <String>['packages', 'apps']) {
      final Directory dir = Directory('${workspace.path}/$group');
      for (final Directory entry in dir.listSync().whereType<Directory>()) {
        final File file = File('${entry.path}/pubspec.yaml');
        if (!file.existsSync()) {
          continue;
        }
        final YamlMap doc = loadYaml(file.readAsStringSync()) as YamlMap;
        final String name = doc['name'] as String;
        pubspecs[name] = doc;
        directories[name] = entry;
      }
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

  group('dependency direction', () {
    graph.forEach((String package, Set<String> allowed) {
      final String expectation = allowed.isEmpty
          ? 'nothing'
          : allowed.join(', ');
      test('$package depends on $expectation', () {
        final Set<String> siblings = allDependenciesOf(
          package,
        ).where((String d) => d.startsWith('tom_')).toSet();

        expect(
          siblings.difference(allowed),
          isEmpty,
          reason:
              '$package declares a dependency it is not allowed to have. If '
              'the layering genuinely changed, change it here first and say '
              'why in docs/architecture/layers.md.',
        );
      });
    });
  });

  group('framework isolation', () {
    for (final String package in graph.keys) {
      final bool isRoot = package == compositionRoot;

      test(
        isRoot
            ? '$package is the only package with Flutter'
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
                  '$compositionRoot is the composition root; it is meant to '
                  'have Flutter.',
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
Iterable<File> dartFilesIn(Directory package) {
  final Directory lib = Directory('${package.path}/lib');
  if (!lib.existsSync()) {
    return const <File>[];
  }
  return lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'));
}

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

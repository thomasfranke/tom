/// The layer graph, checked against what the pubspecs actually declare.
///
/// The package boundaries already make an illegal import fail to compile.
/// This test covers the failure the compiler cannot see: someone *adding* the
/// dependency to a pubspec, after which the illegal import compiles perfectly
/// well. A diagram in the docs would not catch that. This does.
///
///     dart test
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

/// The composition root, and the only package allowed to know Flutter exists.
const String compositionRoot = 'tom_desktop';

void main() {
  final Map<String, YamlMap> pubspecs = <String, YamlMap>{};

  setUpAll(() {
    for (final Directory dir in <Directory>[
      Directory('packages'),
      Directory('apps'),
    ]) {
      for (final Directory entry in dir.listSync().whereType<Directory>()) {
        final File file = File('${entry.path}/pubspec.yaml');
        if (!file.existsSync()) {
          continue;
        }
        final YamlMap doc = loadYaml(file.readAsStringSync()) as YamlMap;
        pubspecs[doc['name'] as String] = doc;
      }
    }
  });

  Set<String> siblingsOf(String package) =>
      ((pubspecs[package]!['dependencies'] as YamlMap?)?.keys ??
              const <String>[])
          .cast<String>()
          .where((String d) => d.startsWith('tom_'))
          .toSet();

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
        expect(
          siblingsOf(package).difference(allowed),
          isEmpty,
          reason:
              '$package declares a dependency it is not allowed to have. If '
              'the layering genuinely changed, change it here first and say '
              'why in docs/architecture.',
        );
      });
    });
  });

  group('framework isolation', () {
    for (final String package in graph.keys) {
      final bool isRoot = package == compositionRoot;
      final String what = isRoot
          ? 'is the only package with Flutter'
          : 'is pure Dart';

      test('$package $what', () {
        final Iterable<dynamic> deps =
            (pubspecs[package]!['dependencies'] as YamlMap?)?.keys ??
            const <String>[];

        expect(
          deps.contains('flutter'),
          isRoot,
          reason: isRoot
              ? '$compositionRoot is the composition root; it is meant to '
                    'have Flutter.'
              : 'Flutter reached $package. Framework independence stops '
                    'being provable the moment a layer below the app can '
                    'import a widget.',
        );
      });
    }
  });
}

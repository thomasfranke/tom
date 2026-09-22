import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';

void main() {
  PanelDescriptor panel(
    String id, {
    PanelPlacementEnum placement = PanelPlacementEnum.document,
    int order = 0,
  }) => PanelDescriptor(
    id: id,
    title: id,
    placement: placement,
    order: order,
    builder: (BuildContext context) => const SizedBox.shrink(),
  );

  List<String> idsAt(PanelRegistry registry, PanelPlacementEnum placement) =>
      registry
          .at(placement)
          .map((PanelDescriptor descriptor) => descriptor.id)
          .toList();

  group('collecting', () {
    test('a registry with no modules has nothing in it', () {
      expect(PanelRegistry(const <TomModule>[]).isEmpty, isTrue);
    });

    test('a module with no panels is still a module', () {
      // Overriding a provider and contributing nothing to the screen is a
      // perfectly ordinary thing for a module to do.
      final PanelRegistry registry = PanelRegistry(const <TomModule>[
        _Module('a', <PanelDescriptor>[]),
      ]);

      expect(registry.isEmpty, isTrue);
    });

    test('panels land in the region they named', () {
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('a', <PanelDescriptor>[
          panel('tree', placement: PanelPlacementEnum.explorer),
          panel('editor'),
          panel('git', placement: PanelPlacementEnum.aside),
          panel('branch', placement: PanelPlacementEnum.statusBar),
        ]),
      ]);

      expect(idsAt(registry, PanelPlacementEnum.explorer), <String>['tree']);
      expect(idsAt(registry, PanelPlacementEnum.document), <String>['editor']);
      expect(idsAt(registry, PanelPlacementEnum.aside), <String>['git']);
      expect(idsAt(registry, PanelPlacementEnum.statusBar), <String>['branch']);
    });

    test('an empty region answers with an empty list, not null', () {
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('a', <PanelDescriptor>[panel('editor')]),
      ]);

      expect(registry.at(PanelPlacementEnum.aside), isEmpty);
    });

    test('what comes back cannot be changed under the registry', () {
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('a', <PanelDescriptor>[panel('editor')]),
      ]);

      expect(
        () => registry.at(PanelPlacementEnum.document).add(panel('sneaked')),
        throwsUnsupportedError,
      );
    });
  });

  group('ordering', () {
    test('lowest order first', () {
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('a', <PanelDescriptor>[
          panel('preview', order: 1),
          panel('source'),
        ]),
      ]);

      expect(idsAt(registry, PanelPlacementEnum.document), <String>[
        'source',
        'preview',
      ]);
    });

    test('a tie keeps registration order, which is module order', () {
      // The reason the sort has to be stable: `runTom(modules: [a, b])` is
      // predictable without anyone having to number everything.
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('a', <PanelDescriptor>[panel('first'), panel('second')]),
        _Module('b', <PanelDescriptor>[panel('third')]),
      ]);

      expect(idsAt(registry, PanelPlacementEnum.document), <String>[
        'first',
        'second',
        'third',
      ]);
    });

    test('order wins over module order', () {
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('a', <PanelDescriptor>[panel('late', order: 5)]),
        _Module('b', <PanelDescriptor>[panel('early')]),
      ]);

      expect(idsAt(registry, PanelPlacementEnum.document), <String>[
        'early',
        'late',
      ]);
    });
  });

  group('identity', () {
    test('two panels cannot share an id', () {
      // Ids are global and outlive a rename of the title: a persisted
      // layout, a shortcut and a test all refer to one.
      expect(
        () => PanelRegistry(<TomModule>[
          _Module('a', <PanelDescriptor>[panel('same')]),
          _Module('b', <PanelDescriptor>[panel('same')]),
        ]),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

/// A module that contributes exactly what it was given.
class _Module implements TomModule {
  const _Module(this.id, this.panels);

  @override
  final String id;

  @override
  final List<PanelDescriptor> panels;

  @override
  List<Override> get overrides => const <Override>[];
}

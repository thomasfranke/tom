import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  PanelDescriptor panel(
    String id, {
    PanelPlacementEnum placement = PanelPlacementEnum.document,
    int order = 0,
    List<DocumentModeEnum> modes = DocumentModeEnum.values,
  }) => PanelDescriptor(
    id: id,
    title: id,
    placement: placement,
    order: order,
    modes: modes,
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

  group('the document modes', () {
    test('a panel with no modes named is in all of them', () {
      // Modules add; one written before the mode bar existed must not
      // disappear because a mode arrived.
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('m', <PanelDescriptor>[panel('anywhere')]),
      ]);

      for (final DocumentModeEnum mode in DocumentModeEnum.values) {
        expect(
          registry
              .at(PanelPlacementEnum.document, mode: mode)
              .map((PanelDescriptor descriptor) => descriptor.id),
          <String>['anywhere'],
        );
      }
    });

    test('a panel is drawn only in the modes it named', () {
      // The filtering is the registry's, so the shell never reads `modes`
      // and never learns what a panel is for.
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('m', <PanelDescriptor>[
          panel(
            'source',
            modes: const <DocumentModeEnum>[
              DocumentModeEnum.source,
              DocumentModeEnum.split,
            ],
          ),
          panel(
            'preview',
            order: 1,
            modes: const <DocumentModeEnum>[
              DocumentModeEnum.split,
              DocumentModeEnum.preview,
            ],
          ),
        ]),
      ]);

      expect(
        registry
            .at(PanelPlacementEnum.document, mode: DocumentModeEnum.split)
            .map((PanelDescriptor descriptor) => descriptor.id),
        <String>['source', 'preview'],
      );
      expect(
        registry
            .at(PanelPlacementEnum.document, mode: DocumentModeEnum.preview)
            .map((PanelDescriptor descriptor) => descriptor.id),
        <String>['preview'],
      );
      expect(
        registry
            .at(PanelPlacementEnum.document, mode: DocumentModeEnum.source)
            .map((PanelDescriptor descriptor) => descriptor.id),
        <String>['source'],
      );
    });

    test('asking without a mode asks about the whole region', () {
      // Which is how the other three regions ask: they are not in a mode.
      final PanelRegistry registry = PanelRegistry(<TomModule>[
        _Module('m', <PanelDescriptor>[
          panel(
            'preview',
            modes: const <DocumentModeEnum>[DocumentModeEnum.preview],
          ),
        ]),
      ]);

      expect(idsAt(registry, PanelPlacementEnum.document), <String>['preview']);
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

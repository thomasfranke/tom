import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Preview preview;
  late _Tree tree;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );
  final SpaceRelativePathValueObject architecture =
      SpaceRelativePathValueObject('technical/architecture.md');

  SpaceEntryValueObject file(String path) => SpaceEntryValueObject(
    path: SpaceRelativePathValueObject(path),
    type: SpaceEntryTypeEnum.file,
  );

  final List<SpaceEntryValueObject> listing = <SpaceEntryValueObject>[
    file('guides/writing.md'),
    file('technical/architecture.md'),
    file('product/export/doc.md'),
    file('product/wikilinks/doc.md'),
  ];

  const WikilinkValueObject toArchitecture = WikilinkValueObject(
    target: 'architecture',
    anchor: 'graph',
    label: 'the graph',
  );
  const WikilinkValueObject toDoc = WikilinkValueObject(target: 'doc');
  const WikilinkValueObject toRoadmap = WikilinkValueObject(target: 'roadmap');

  /// The preview showing a document that holds [links].
  PreviewState showing(List<WikilinkValueObject> links) => PreviewState.ready(
    ParsedDocumentValueObject(
      document: DocumentEntity(path: writing, content: '…'),
      blocks: const <BlockValueObject>[],
      linkDefinitions: '',
      wikilinks: links,
    ),
  );

  /// The tree once it has read [entries].
  FileTreeState listed(List<SpaceEntryValueObject> entries) =>
      FileTreeState.ready(
        entries: entries,
        collapsed: const <SpaceRelativePathValueObject>{},
      );

  setUp(() {
    container = ProviderContainer(
      overrides: <Override>[
        previewProvider.overrideWith(() => preview = _Preview()),
        fileTreeProvider.overrideWith(() => tree = _Tree()),
      ],
    );
    addTearDown(container.dispose);
    container.listen<PreviewLinksState>(previewLinksProvider, (_, _) {});
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(writing);
  });

  PreviewLinksState links() => container.read(previewLinksProvider);

  test('nothing is known while the space is still being listed', () {
    preview.answer = showing(<WikilinkValueObject>[toRoadmap]);
    tree.answer = const FileTreeState.loading();

    expect(links().targets, isEmpty);
    // Unknown, not missing: nothing is drawn as broken before it is known.
    expect(links().targetOf(toRoadmap), isNull);
  });

  test('nothing is known while the document is still being read', () {
    preview.answer = const PreviewState.loading();
    tree.answer = listed(listing);

    expect(links().targets, isEmpty);
  });

  test('each link gets its own answer: resolved, ambiguous, missing', () {
    preview.answer = showing(<WikilinkValueObject>[
      toArchitecture,
      toDoc,
      toRoadmap,
      toDoc,
    ]);
    tree.answer = listed(listing);

    expect(links().targets, <WikilinkValueObject, WikilinkTargetValueObject>{
      toArchitecture: WikilinkTargetValueObject.resolved(architecture),
      toDoc: WikilinkTargetValueObject.ambiguous(<SpaceRelativePathValueObject>[
        SpaceRelativePathValueObject('product/export/doc.md'),
        SpaceRelativePathValueObject('product/wikilinks/doc.md'),
      ]),
      toRoadmap: const WikilinkTargetValueObject.missing(),
    });
  });

  test('a link is asked for as written, label and all', () {
    preview.answer = showing(<WikilinkValueObject>[toArchitecture]);
    tree.answer = listed(listing);

    expect(
      links().targetOf(
        WikilinkValueObject.tryParse('architecture#graph|the graph')!,
      ),
      WikilinkTargetValueObject.resolved(architecture),
    );
  });

  test('a document created in the tree is linkable at once', () {
    preview.answer = showing(<WikilinkValueObject>[toRoadmap]);
    tree.answer = listed(listing);
    expect(
      links().targetOf(toRoadmap),
      const WikilinkTargetValueObject.missing(),
    );

    tree.answer = listed(<SpaceEntryValueObject>[
      ...listing,
      file('roadmap.md'),
    ]);

    expect(
      links().targetOf(toRoadmap),
      WikilinkTargetValueObject.resolved(
        SpaceRelativePathValueObject('roadmap.md'),
      ),
    );
  });

  group('following a link', () {
    setUp(() {
      preview.answer = showing(<WikilinkValueObject>[
        toArchitecture,
        toDoc,
        toRoadmap,
      ]);
      tree.answer = listed(listing);
    });

    SpaceSessionState session() => container.read(spaceSessionProvider)!;

    test('a resolved one opens its document, the way the tree does', () {
      container.read(previewLinksProvider.notifier).follow(toArchitecture);

      expect(session().openDocument, architecture);
      expect(session().tabs, contains(DocumentTab.inSpace(architecture)));
    });

    test('its anchor waits for the heading in the document it opens', () {
      container.listen<PreviewAnchor?>(previewAnchorProvider, (_, _) {});

      container.read(previewLinksProvider.notifier).follow(toArchitecture);

      expect(
        container.read(previewAnchorProvider),
        PreviewAnchor(document: architecture, anchor: 'graph'),
      );
    });

    test('an anchor alone stays in the document and asks for its heading', () {
      const WikilinkValueObject here = WikilinkValueObject(
        target: '',
        anchor: 'graph',
      );
      preview.answer = showing(<WikilinkValueObject>[here]);
      container.listen<PreviewAnchor?>(previewAnchorProvider, (_, _) {});

      expect(
        links().targetOf(here),
        WikilinkTargetValueObject.resolved(writing),
      );

      container.read(previewLinksProvider.notifier).follow(here);

      expect(session().openDocument, writing);
      expect(session().tabs, <DocumentTab>[DocumentTab.inSpace(writing)]);
      expect(
        container.read(previewAnchorProvider),
        PreviewAnchor(document: writing, anchor: 'graph'),
      );
    });

    test('one with no anchor asks for no heading', () {
      const WikilinkValueObject plain = WikilinkValueObject(
        target: 'architecture',
      );
      preview.answer = showing(<WikilinkValueObject>[plain]);
      container.listen<PreviewAnchor?>(previewAnchorProvider, (_, _) {});

      container.read(previewLinksProvider.notifier).follow(plain);

      expect(session().openDocument, architecture);
      expect(container.read(previewAnchorProvider), isNull);
    });

    test('an ambiguous or missing one goes nowhere', () {
      container.read(previewLinksProvider.notifier)
        ..follow(toDoc)
        ..follow(toRoadmap);

      expect(session().openDocument, writing);
    });

    test('an ambiguous one opens the candidate somebody chose', () {
      final SpaceRelativePathValueObject chosen = SpaceRelativePathValueObject(
        'product/wikilinks/doc.md',
      );

      container.read(previewLinksProvider.notifier).choose(toDoc, chosen);

      expect(session().openDocument, chosen);
    });

    test('a choice the link does not offer goes nowhere', () {
      container.read(previewLinksProvider.notifier)
        ..choose(toDoc, architecture)
        ..choose(toArchitecture, architecture);

      expect(session().openDocument, writing);
    });

    test('a link the document does not hold goes nowhere', () {
      container
          .read(previewLinksProvider.notifier)
          .follow(const WikilinkValueObject(target: 'architecture'));

      expect(session().openDocument, writing);
    });
  });
}

/// The preview, answering whatever the test sets.
final class _Preview extends PreviewNotifier {
  @override
  PreviewState build() => const PreviewState.empty();

  PreviewState get answer => state;

  set answer(PreviewState next) => state = next;
}

/// The tree, answering whatever the test sets.
final class _Tree extends FileTreeNotifier {
  @override
  FileTreeState build() => const FileTreeState.initial();

  FileTreeState get answer => state;

  set answer(FileTreeState next) => state = next;
}

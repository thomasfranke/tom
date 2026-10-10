import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const WikilinkCompletionService service = WikilinkCompletionService();

  SpaceEntryValueObject file(String path) => SpaceEntryValueObject(
    path: SpaceRelativePathValueObject(path),
    type: SpaceEntryTypeEnum.file,
  );

  SpaceEntryValueObject folder(String path) => SpaceEntryValueObject(
    path: SpaceRelativePathValueObject(path),
    type: SpaceEntryTypeEnum.directory,
  );

  final List<SpaceEntryValueObject> space = <SpaceEntryValueObject>[
    folder('product'),
    file('product/export/doc.md'),
    file('product/wikilinks/doc.md'),
    file('technical/architecture.md'),
    file('technical/runtime/preview.md'),
    file('notes/pre-release.md'),
    file('roadmap.md'),
    file('logo.png'),
  ];

  /// What [marked] offers, where `‸` is the caret and is not in the text.
  WikilinkCompletionValueObject? complete(
    String marked, [
    List<SpaceEntryValueObject>? entries,
  ]) {
    final int caret = marked.indexOf('‸');
    return service.complete(
      marked.replaceFirst('‸', ''),
      caret,
      entries ?? space,
    );
  }

  /// The targets [marked] offers, best first.
  List<String> targetsOf(String marked) => <String>[
    for (final WikilinkCandidateValueObject candidate in complete(
      marked,
    )!.candidates)
      candidate.target,
  ];

  group('when it offers', () {
    test('straight after [[, with nothing typed yet', () {
      final WikilinkCompletionValueObject offered = complete('See [[‸')!;

      expect(offered.from, 6);
      expect(offered.query, '');
      expect(offered.candidates, hasLength(6));
    });

    test('with part of a target typed, from the first character after [[', () {
      final WikilinkCompletionValueObject offered = complete('See [[arc‸')!;

      expect(offered.from, 6);
      expect(offered.query, 'arc');
    });

    test('while the link is already closed after the caret', () {
      expect(complete('See [[arc‸]] here')?.query, 'arc');
    });

    test('not outside a link', () {
      expect(complete('See ‸ [[a]]'), isNull);
      expect(complete('‸'), isNull);
      expect(complete('[‸'), isNull);
    });

    test('not past a link that was closed before the caret', () {
      expect(complete('[[a]] and ‸'), isNull);
    });

    test('not once the target is finished — an anchor or a label', () {
      expect(complete('[[roadmap#‸'), isNull);
      expect(complete('[[roadmap|the plan‸'), isNull);
    });

    test('not across a line break', () {
      expect(complete('[[road\nmap‸'), isNull);
    });

    test('not after an escaped bracket', () {
      expect(complete(r'\[[road‸'), isNull);
    });

    test('not with a caret outside the buffer', () {
      expect(service.complete('[[', 3, space), isNull);
    });

    test('not inside a fenced block, closed or not', () {
      expect(complete('```\n[[road‸\n```'), isNull);
      expect(complete('~~~md\n[[‸'), isNull);
    });

    test('not inside an inline code span', () {
      expect(complete('Write `[[road‸` for a link'), isNull);
    });

    test('again once the code is behind the caret', () {
      expect(complete('```\n[[a]]\n```\nSee [[road‸')?.query, 'road');
      expect(complete('Write `[[a]]`, as in [[road‸')?.query, 'road');
    });
  });

  group('what it offers', () {
    test('documents only — not a folder, not another file', () {
      expect(
        complete('[[‸')!.candidates.map(
          (WikilinkCandidateValueObject candidate) => candidate.path.value,
        ),
        isNot(anyOf(contains('product'), contains('logo.png'))),
      );
    });

    test('a name that starts with what was typed comes first', () {
      expect(targetsOf('[[pre‸'), <String>['preview', 'pre-release']);
    });

    test('then a name with a word that starts with it', () {
      expect(targetsOf('[[rel‸'), <String>['pre-release']);
    });

    test('then a name that holds it, then a folder that does', () {
      expect(targetsOf('[[chit‸'), <String>['architecture']);
      expect(targetsOf('[[runtime‸'), <String>['preview']);
    });

    test('matching ignores case', () {
      expect(targetsOf('[[ROAD‸'), <String>['roadmap']);
    });

    test('nothing matches is an empty list, not null', () {
      expect(complete('[[zzz‸')!.candidates, isEmpty);
    });

    test('a name the space holds twice is offered as its path', () {
      // So what is written resolves to the one that was chosen, rather than
      // to an ambiguous link (Decision 28).
      expect(targetsOf('[[doc‸'), <String>[
        'product/export/doc',
        'product/wikilinks/doc',
      ]);
    });

    test('a slash means a path, matched against paths and written whole', () {
      // Shorter name first, as everywhere else.
      expect(targetsOf('[[technical/‸'), <String>[
        'technical/runtime/preview',
        'technical/architecture',
      ]);
      expect(targetsOf('[[wikilinks/do‸'), <String>['product/wikilinks/doc']);
    });

    test('every candidate written resolves to its own document', () {
      const WikilinkResolverService resolver = WikilinkResolverService();
      for (final WikilinkCandidateValueObject candidate in complete(
        '[[‸',
      )!.candidates) {
        expect(
          resolver
              .resolve(WikilinkValueObject(target: candidate.target), space)
              .destination,
          candidate.path,
          reason: candidate.target,
        );
      }
    });
  });
}

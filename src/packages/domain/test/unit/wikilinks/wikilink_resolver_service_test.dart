import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const WikilinkResolverService resolver = WikilinkResolverService();

  SpaceEntryValueObject file(String path) => SpaceEntryValueObject(
    path: SpaceRelativePathValueObject(path),
    type: SpaceEntryTypeEnum.file,
  );

  SpaceEntryValueObject folder(String path) => SpaceEntryValueObject(
    path: SpaceRelativePathValueObject(path),
    type: SpaceEntryTypeEnum.directory,
  );

  WikilinkTargetValueObject resolve(
    String written,
    List<SpaceEntryValueObject> entries,
  ) => resolver.resolve(WikilinkValueObject.tryParse(written)!, entries);

  group('by name', () {
    final List<SpaceEntryValueObject> space = <SpaceEntryValueObject>[
      file('technical/architecture.md'),
      file('product/export/doc.md'),
      file('product/wikilinks/doc.md'),
    ];

    test('a name the space holds once resolves to it', () {
      expect(
        resolve('architecture', space),
        WikilinkTargetValueObject.resolved(
          SpaceRelativePathValueObject('technical/architecture.md'),
        ),
      );
    });

    test('writing the extension means the same thing', () {
      expect(
        resolve('architecture.md', space).destination?.value,
        'technical/architecture.md',
      );
    });

    test('a name is matched however it was capitalised', () {
      expect(
        resolve('ARCHITECTURE', space).destination?.value,
        'technical/architecture.md',
      );
    });

    test('a name nothing carries is missing, not a failure', () {
      expect(
        resolve('nowhere', space),
        const WikilinkTargetValueObject.missing(),
      );
    });

    test('a name the space holds twice is ambiguous, never the first', () {
      final WikilinkTargetValueObject target = resolve('doc', space);

      expect(target, isA<WikilinkAmbiguous>());
      expect(
        (target as WikilinkAmbiguous).candidates.map(
          (SpaceRelativePathValueObject p) => p.value,
        ),
        <String>['product/export/doc.md', 'product/wikilinks/doc.md'],
      );
      expect(
        target.destination,
        isNull,
        reason: 'the choice is the author\'s, not the clicker\'s',
      );
    });
  });

  group('by path', () {
    final List<SpaceEntryValueObject> space = <SpaceEntryValueObject>[
      file('product/export/doc.md'),
      file('product/wikilinks/doc.md'),
    ];

    test('a slash reaches one of two files sharing a name', () {
      expect(
        resolve('product/wikilinks/doc', space).destination?.value,
        'product/wikilinks/doc.md',
      );
    });

    test('a path is matched exactly, capitals included', () {
      expect(
        resolve('Product/Wikilinks/doc', space),
        const WikilinkTargetValueObject.missing(),
      );
    });

    test('a path that names nothing is missing', () {
      expect(
        resolve('product/nothing/doc', space),
        const WikilinkTargetValueObject.missing(),
      );
    });
  });

  group('what is not a document', () {
    test('a folder is never a target, even when the name matches', () {
      expect(
        resolve('notes', <SpaceEntryValueObject>[folder('notes')]),
        const WikilinkTargetValueObject.missing(),
      );
    });

    test('a file that is not markdown is never a target', () {
      expect(
        resolve('palette', <SpaceEntryValueObject>[file('design/palette.svg')]),
        const WikilinkTargetValueObject.missing(),
      );
    });
  });

  test('an empty listing answers missing rather than throwing', () {
    expect(
      resolve('anything', const <SpaceEntryValueObject>[]),
      const WikilinkTargetValueObject.missing(),
    );
  });
}

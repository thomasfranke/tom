import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  SpaceEntryValueObject entryAt(String path, SpaceEntryTypeEnum type) =>
      SpaceEntryValueObject(
        path: SpaceRelativePathValueObject(path),
        type: type,
      );

  group('name', () {
    test('is the last segment', () {
      expect(
        entryAt('adr/001-git.md', SpaceEntryTypeEnum.file).name,
        '001-git.md',
      );
      expect(entryAt('adr', SpaceEntryTypeEnum.directory).name, 'adr');
    });
  });

  group('isDocument', () {
    test('is true for a markdown file', () {
      expect(entryAt('adr/001.md', SpaceEntryTypeEnum.file).isDocument, isTrue);
    });

    test('is false for a file that is not markdown', () {
      expect(entryAt('logo.png', SpaceEntryTypeEnum.file).isDocument, isFalse);
    });

    test('is false for a folder, whatever it is called', () {
      // A folder named `notes.md` is legal and is not a document.
      expect(
        entryAt('notes.md', SpaceEntryTypeEnum.directory).isDocument,
        isFalse,
      );
    });

    test('is false for a link, which was never followed', () {
      // It may point outside the space, or at nothing at all; the listing
      // did not look.
      expect(entryAt('shared.md', SpaceEntryTypeEnum.link).isDocument, isFalse);
    });
  });

  group('equality', () {
    // Built at runtime: const instances are canonicalised.
    test('compares by value', () {
      expect(
        entryAt('a.md', SpaceEntryTypeEnum.file),
        entryAt('a.md', SpaceEntryTypeEnum.file),
      );
      expect(
        entryAt('a.md', SpaceEntryTypeEnum.file).hashCode,
        entryAt('a.md', SpaceEntryTypeEnum.file).hashCode,
      );
    });

    test('the same path of a different kind is a different entry', () {
      expect(
        entryAt('a.md', SpaceEntryTypeEnum.file),
        isNot(entryAt('a.md', SpaceEntryTypeEnum.link)),
      );
    });
  });
}

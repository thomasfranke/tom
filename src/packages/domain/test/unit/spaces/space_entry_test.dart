import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  SpaceEntry entryAt(String path, SpaceEntryType type) =>
      SpaceEntry(path: SpaceRelativePath(path), type: type);

  group('name', () {
    test('is the last segment', () {
      expect(entryAt('adr/001-git.md', SpaceEntryType.file).name, '001-git.md');
      expect(entryAt('adr', SpaceEntryType.directory).name, 'adr');
    });
  });

  group('isDocument', () {
    test('is true for a markdown file', () {
      expect(entryAt('adr/001.md', SpaceEntryType.file).isDocument, isTrue);
    });

    test('is false for a file that is not markdown', () {
      expect(entryAt('logo.png', SpaceEntryType.file).isDocument, isFalse);
    });

    test('is false for a folder, whatever it is called', () {
      // A folder named `notes.md` is legal and is not a document.
      expect(entryAt('notes.md', SpaceEntryType.directory).isDocument, isFalse);
    });

    test('is false for a link, which was never followed', () {
      // It may point outside the space, or at nothing at all; the listing
      // did not look.
      expect(entryAt('shared.md', SpaceEntryType.link).isDocument, isFalse);
    });
  });

  group('equality', () {
    // Built at runtime: const instances are canonicalised.
    test('compares by value', () {
      expect(
        entryAt('a.md', SpaceEntryType.file),
        entryAt('a.md', SpaceEntryType.file),
      );
      expect(
        entryAt('a.md', SpaceEntryType.file).hashCode,
        entryAt('a.md', SpaceEntryType.file).hashCode,
      );
    });

    test('the same path of a different kind is a different entry', () {
      expect(
        entryAt('a.md', SpaceEntryType.file),
        isNot(entryAt('a.md', SpaceEntryType.link)),
      );
    });
  });
}

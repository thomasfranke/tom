import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('tryParse', () {
    test('a bare name is the target, with no anchor', () {
      final WikilinkValueObject link = WikilinkValueObject.tryParse(
        'architecture',
      )!;

      expect(link.target, 'architecture');
      expect(link.anchor, isNull);
    });

    test('what follows the first hash is the anchor', () {
      final WikilinkValueObject link = WikilinkValueObject.tryParse(
        'architecture#what-enforces-it',
      )!;

      expect(link.target, 'architecture');
      expect(link.anchor, 'what-enforces-it');
    });

    test('a later hash belongs to the anchor, not to a second split', () {
      expect(WikilinkValueObject.tryParse('doc#a#b')!.anchor, 'a#b');
    });

    test('surrounding space is not part of what was written', () {
      final WikilinkValueObject link = WikilinkValueObject.tryParse(
        '  architecture  #  top  ',
      )!;

      expect(link.target, 'architecture');
      expect(link.anchor, 'top');
    });

    test('an empty anchor is no anchor', () {
      expect(WikilinkValueObject.tryParse('architecture#')!.anchor, isNull);
    });

    test('nothing to look up is null, not an empty link', () {
      expect(WikilinkValueObject.tryParse(''), isNull);
      expect(WikilinkValueObject.tryParse('   '), isNull);
      expect(WikilinkValueObject.tryParse('#anchor-only'), isNull);
    });
  });

  group('isPath', () {
    test('a slash means the author wrote a path', () {
      expect(WikilinkValueObject.tryParse('a/b')!.isPath, isTrue);
    });

    test('a bare name is not a path', () {
      expect(WikilinkValueObject.tryParse('doc')!.isPath, isFalse);
    });
  });

  group('targetWithoutExtension', () {
    test('a trailing .md is optional and dropped', () {
      expect(
        WikilinkValueObject.tryParse('doc.md')!.targetWithoutExtension,
        'doc',
      );
    });

    test('the extension is recognised however it was capitalised', () {
      expect(
        WikilinkValueObject.tryParse('doc.MD')!.targetWithoutExtension,
        'doc',
      );
    });

    test('a name that merely contains md keeps all of it', () {
      expect(
        WikilinkValueObject.tryParse('mdbook')!.targetWithoutExtension,
        'mdbook',
      );
    });
  });
}

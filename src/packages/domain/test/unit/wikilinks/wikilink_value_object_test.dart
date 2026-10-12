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
      expect(WikilinkValueObject.tryParse('#'), isNull);
      expect(WikilinkValueObject.tryParse('|label-only'), isNull);
      expect(WikilinkValueObject.tryParse(' # |label'), isNull);
    });

    test('an anchor alone is a heading of the document it is in', () {
      final WikilinkValueObject link = WikilinkValueObject.tryParse(
        '#Troubleshooting',
      )!;

      expect(link.target, '');
      expect(link.anchor, 'Troubleshooting');
      expect(link.isWithinDocument, isTrue);
    });

    test('a link to a document is not within one', () {
      expect(
        WikilinkValueObject.tryParse('setup#Install')!.isWithinDocument,
        isFalse,
      );
    });
  });

  group('the words it is shown as', () {
    String shown(String inner) => WikilinkValueObject.tryParse(inner)!.shownAs;

    test('the label first, then the document, then the heading', () {
      expect(shown('setup#Install|how to install'), 'how to install');
      expect(shown('setup#Install'), 'setup');
      expect(shown('#Install'), 'Install');
    });

    test('what follows the first bar is the label, trimmed', () {
      final WikilinkValueObject link = WikilinkValueObject.tryParse(
        'architecture | the graph ',
      )!;

      expect(link.target, 'architecture');
      expect(link.anchor, isNull);
      expect(link.label, 'the graph');
    });

    test('the bar is split first, so a hash in the label is the label', () {
      final WikilinkValueObject link = WikilinkValueObject.tryParse(
        'doc#top|see #1',
      )!;

      expect(link.target, 'doc');
      expect(link.anchor, 'top');
      expect(link.label, 'see #1');
    });

    test('an empty label is no label', () {
      expect(WikilinkValueObject.tryParse('doc|')!.label, isNull);
      expect(WikilinkValueObject.tryParse('doc')!.label, isNull);
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

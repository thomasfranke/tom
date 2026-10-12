/// [MarkdownCodeService] held to the real parser: where the editor says a
/// `[[` is inside code, the preview must read no link, and the reverse —
/// two scanners that answer one question have to give one answer.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const MarkdownCodeService code = MarkdownCodeService();
  const MarkdownBlockReaderImpl reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );

  /// Whether the real parser reads the `[[target]]` in [buffer] as a link.
  Future<bool> parserReadsTheLink(String buffer) async {
    final Result<ParsedDocumentValueObject, DocumentFailure> read = await reader
        .read(
          DocumentEntity(
            path: SpaceRelativePathValueObject('guides/writing.md'),
            content: buffer,
          ),
        );
    final List<WikilinkValueObject> links =
        (read as Success<ParsedDocumentValueObject, DocumentFailure>)
            .value
            .wikilinks;
    return links.any((WikilinkValueObject link) => link.target == 'target');
  }

  /// Whether the editor says the caret just after the `[[` of [buffer]'s
  /// `[[target]]` is inside code — where the autocomplete asks.
  bool editorSaysCode(String buffer) {
    final int brackets = buffer.indexOf('[[target]]');
    expect(brackets, isNot(-1), reason: 'the fixture holds no [[target]]');
    return code.isInsideCode(buffer, brackets + 2);
  }

  /// Holds [buffer] to the rule, and to [isCode], so a fixture that stopped
  /// being code fails rather than passing for the wrong reason.
  Future<void> expectAgreement(String buffer, {required bool isCode}) async {
    expect(
      await parserReadsTheLink(buffer),
      !isCode,
      reason: 'the parser ${isCode ? 'read' : 'did not read'} the link',
    );
    expect(
      editorSaysCode(buffer),
      isCode,
      reason: 'the editor says ${isCode ? 'prose' : 'code'}',
    );
  }

  group('prose, where both read a link', () {
    test('a sentence', () async {
      await expectAgreement('See [[target]] for more.\n', isCode: false);
    });

    test('after a fence that closed', () async {
      await expectAgreement(
        '```\ncode\n```\n\nSee [[target]].\n',
        isCode: false,
      );
    });

    test('after a span that closed, on the same line', () async {
      await expectAgreement('Run `tom` and see [[target]].\n', isCode: false);
    });

    test('inside a quote and inside a list item', () async {
      await expectAgreement('> See [[target]].\n', isCode: false);
      await expectAgreement('- See [[target]].\n', isCode: false);
    });

    test('after a fence shorter than the one it sits in closed it '
        'all', () async {
      await expectAgreement(
        '````\n```\ncode\n````\n\nSee [[target]].\n',
        isCode: false,
      );
    });
  });

  group('code, where neither reads one', () {
    test('a backtick fence', () async {
      await expectAgreement('```\n[[target]]\n```\n', isCode: true);
    });

    test('a fence that names its language', () async {
      await expectAgreement('```dart\n[[target]]\n```\n', isCode: true);
    });

    test('a tilde fence', () async {
      await expectAgreement('~~~\n[[target]]\n~~~\n', isCode: true);
    });

    test('a fence never closed, to the end of the document', () async {
      await expectAgreement(
        'Prose.\n\n```\ncode\n\n[[target]]\n',
        isCode: true,
      );
    });

    test('a fence a shorter one cannot close', () async {
      await expectAgreement('````\n```\n[[target]]\n````\n', isCode: true);
    });

    test('a tilde fence a backtick fence cannot close', () async {
      await expectAgreement('~~~\n```\n[[target]]\n~~~\n', isCode: true);
    });

    test('a fence inside a quote', () async {
      await expectAgreement('> ```\n> [[target]]\n> ```\n', isCode: true);
    });

    test('a fence inside a list item', () async {
      await expectAgreement(
        '- An item:\n\n  ```\n  [[target]]\n  ```\n',
        isCode: true,
      );
    });

    test('a span', () async {
      await expectAgreement('Type `[[target]]` to link.\n', isCode: true);
    });

    test('a span opened by two backticks', () async {
      await expectAgreement(
        'Type `` a ` and [[target]] `` to link.\n',
        isCode: true,
      );
    });

    test('a block indented by four spaces', () async {
      await expectAgreement('Prose.\n\n    [[target]]\n', isCode: true);
    });

    test('four spaces under a paragraph are still the paragraph', () async {
      await expectAgreement('Prose.\n    [[target]]\n', isCode: false);
    });

    test('four spaces under a list item are the item\'s own text', () async {
      await expectAgreement('- An item.\n\n    [[target]]\n', isCode: false);
    });
  });

  group('the one place they differ on purpose', () {
    test('a backtick with no partner is a span still being typed: the '
        'editor offers nothing, though the parser reads the link '
        'today', () async {
      const String buffer = 'Type `[[target]] to link.\n';

      expect(editorSaysCode(buffer), isTrue);
      expect(await parserReadsTheLink(buffer), isTrue);
    });
  });
}

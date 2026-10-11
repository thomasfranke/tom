import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The line diff over the real differ, on what real files do to it: line
/// endings, a missing final newline, and a file long enough to be slow.
void main() {
  const LineDifferService differ = LineDifferService(
    aligner: TextDifferLineAlignerImpl(
      differ: TextDifferDataSource(differ: DiffutilTextDifferImpl()),
    ),
  );
  final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
    'config/site.yaml',
  );

  Future<List<LineRunValueObject>> runsOf(String before, String after) async {
    final Result<LineDiffValueObject, DocumentFailure> result = await differ
        .diff(
          before: DocumentEntity(path: path, content: before),
          after: DocumentEntity(path: path, content: after),
        );
    return switch (result) {
      Success<LineDiffValueObject, DocumentFailure>(
        value: final LineDiffValueObject diff,
      ) =>
        diff.runs,
      Failure<LineDiffValueObject, DocumentFailure>(
        failure: final DocumentFailure failure,
      ) =>
        fail('diffing failed: ${failure.diagnostics}'),
    };
  }

  const String file = 'title: Site\nlang: en\nbase: /docs\ntheme: plain\n';

  /// [text] with every line ending as Windows writes it.
  String crlf(String text) => text.replaceAll('\n', '\r\n');

  group('line endings', () {
    // Decision #50 (D-34): the diff ignores line endings.
    test('the same file in CRLF and in LF has no runs', () async {
      expect(await runsOf(file, crlf(file)), isEmpty);
    });

    test('a CRLF file against itself has no runs', () async {
      expect(await runsOf(crlf(file), crlf(file)), isEmpty);
    });

    test('one line rewritten in a CRLF file is that line, modified', () async {
      expect(
        await runsOf(
          crlf(file),
          crlf(file).replaceFirst('base: /docs', 'base: /documentation'),
        ),
        <LineRunValueObject>[const LineRunValueObject.modified(from: 2, to: 2)],
      );
    });
  });

  group('the final newline', () {
    test('removed is no run', () async {
      expect(await runsOf(file, file.trimRight()), isEmpty);
    });

    test('added is no run', () async {
      expect(await runsOf(file.trimRight(), file), isEmpty);
    });

    test('missing on both sides, a line typed at the end is that line '
        'added', () async {
      expect(
        await runsOf(file.trimRight(), '${file}draft: true'),
        <LineRunValueObject>[const LineRunValueObject.added(from: 4, to: 4)],
      );
    });

    test('a blank line at the end is a line, and it is added', () async {
      expect(await runsOf(file, '$file\n'), <LineRunValueObject>[
        const LineRunValueObject.added(from: 4, to: 4),
      ]);
    });
  });

  group('a long file', () {
    test('ten thousand lines with one in a hundred rewritten are a hundred '
        'runs of one line, inside half a minute', () async {
      String line(int index, {required bool rewritten}) =>
          'key$index: the value of entry number $index'
          '${rewritten ? ', revised' : ''}';
      final String before = <String>[
        for (int index = 0; index < 10000; index++)
          line(index, rewritten: false),
      ].join('\n');
      final String after = <String>[
        for (int index = 0; index < 10000; index++)
          line(index, rewritten: index % 100 == 50),
      ].join('\n');

      final Stopwatch watch = Stopwatch()..start();
      final List<LineRunValueObject> runs = await runsOf(before, after);
      watch.stop();

      expect(runs, <LineRunValueObject>[
        for (int index = 50; index < 10000; index += 100)
          LineRunValueObject.modified(from: index, to: index),
      ]);
      // Well under a second on a laptop; the bound is for a loaded CI
      // machine, and what it guards is an alignment that went quadratic.
      expect(watch.elapsed, lessThan(const Duration(seconds: 30)));
    });
  });
}

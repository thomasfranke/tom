import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The line diff over the real differ: what a person editing a file that is
/// not markdown sees in the gutter.
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

  test('the same text has no runs', () async {
    expect(await runsOf('a: 1\nb: 2\n', 'a: 1\nb: 2\n'), isEmpty);
  });

  test('a line typed in is added, where it was typed', () async {
    expect(
      await runsOf(
        'title: Site\nlang: en\n',
        'title: Site\nbase: /\nlang: en\n',
      ),
      <LineRunValueObject>[const LineRunValueObject.added(from: 1, to: 1)],
    );
  });

  test('a line rewritten in part is modified', () async {
    expect(
      await runsOf(
        'title: My documentation site\nlang: en\n',
        'title: My new documentation site\nlang: en\n',
      ),
      <LineRunValueObject>[const LineRunValueObject.modified(from: 0, to: 0)],
    );
  });

  test('lines taken out are a seam above the line that followed', () async {
    expect(
      await runsOf('one\ntwo\nthree\nfour\n', 'one\nfour\n'),
      <LineRunValueObject>[const LineRunValueObject.removed(at: 1, count: 2)],
    );
  });

  test('a new file is every line added', () async {
    expect(await runsOf('', 'first\nsecond\n'), <LineRunValueObject>[
      const LineRunValueObject.added(from: 0, to: 1),
    ]);
  });
}

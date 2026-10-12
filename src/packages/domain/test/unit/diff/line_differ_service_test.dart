import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
    'config/site.yaml',
  );

  /// One edit, spelled the way the aligner answers.
  SequenceEditValueObject editOf(
    SequenceEditKindEnum kind, {
    int? before,
    int? after,
  }) => SequenceEditValueObject(
    kind: kind,
    beforeIndex: before,
    afterIndex: after,
  );

  /// The runs of a diff over an aligner answering [edits].
  Future<List<LineRunValueObject>> runsOf(
    List<SequenceEditValueObject> edits,
  ) async {
    final _Aligner aligner = _Aligner(edits);
    final Result<LineDiffValueObject, DocumentFailure> result =
        await LineDifferService(aligner: aligner).diff(
          before: DocumentEntity(path: path, content: 'a\nb\n'),
          after: DocumentEntity(path: path, content: 'a\nc\n'),
        );
    return switch (result) {
      Success<LineDiffValueObject, DocumentFailure>(
        value: final LineDiffValueObject diff,
      ) =>
        diff.runs,
      Failure<LineDiffValueObject, DocumentFailure>() => fail('diff failed'),
    };
  }

  group('what a line is', () {
    test('a final break ends the last line rather than starting one', () {
      expect(LineDifferService.linesOf('a\nb\n'), <String>['a', 'b']);
      expect(LineDifferService.linesOf('a\nb'), <String>['a', 'b']);
      expect(LineDifferService.linesOf('a\n\n'), <String>['a', '']);
    });

    test('nothing at all is no lines', () {
      expect(LineDifferService.linesOf(''), isEmpty);
    });

    test('the aligner is handed both sides cut into lines', () async {
      final _Aligner aligner = _Aligner(const <SequenceEditValueObject>[]);
      await LineDifferService(aligner: aligner).diff(
        before: DocumentEntity(path: path, content: 'one\ntwo\n'),
        after: DocumentEntity(path: path, content: 'one\n'),
      );
      expect(aligner.before, <String>['one', 'two']);
      expect(aligner.after, <String>['one']);
      expect(aligner.threshold, LineDifferService.pairingThreshold);
    });
  });

  group('how verdicts gather into runs', () {
    test('an unchanged file has no runs', () async {
      final List<LineRunValueObject> runs =
          await runsOf(<SequenceEditValueObject>[
            editOf(SequenceEditKindEnum.equal, before: 0, after: 0),
            editOf(SequenceEditKindEnum.equal, before: 1, after: 1),
          ]);
      expect(runs, isEmpty);
    });

    test('consecutive lines of one kind are one run', () async {
      final List<LineRunValueObject> runs =
          await runsOf(<SequenceEditValueObject>[
            editOf(SequenceEditKindEnum.equal, before: 0, after: 0),
            editOf(SequenceEditKindEnum.added, after: 1),
            editOf(SequenceEditKindEnum.added, after: 2),
            editOf(SequenceEditKindEnum.changed, before: 1, after: 3),
            editOf(SequenceEditKindEnum.equal, before: 2, after: 4),
            editOf(SequenceEditKindEnum.changed, before: 3, after: 5),
          ]);
      expect(runs, <LineRunValueObject>[
        const LineRunValueObject.added(from: 1, to: 2),
        const LineRunValueObject.modified(from: 3, to: 3),
        const LineRunValueObject.modified(from: 5, to: 5),
      ]);
    });

    test('removed lines are one seam above the line that follows', () async {
      final List<LineRunValueObject> runs =
          await runsOf(<SequenceEditValueObject>[
            editOf(SequenceEditKindEnum.equal, before: 0, after: 0),
            editOf(SequenceEditKindEnum.removed, before: 1),
            editOf(SequenceEditKindEnum.removed, before: 2),
            editOf(SequenceEditKindEnum.added, after: 1),
            editOf(SequenceEditKindEnum.equal, before: 3, after: 2),
            editOf(SequenceEditKindEnum.removed, before: 4),
          ]);
      expect(runs, <LineRunValueObject>[
        const LineRunValueObject.removed(at: 1, count: 2),
        const LineRunValueObject.added(from: 1, to: 1),
        const LineRunValueObject.removed(at: 3, count: 1),
      ]);
    });

    test('a file the old version did not hold is every line added', () async {
      final List<LineRunValueObject> runs =
          await runsOf(<SequenceEditValueObject>[
            editOf(SequenceEditKindEnum.added, after: 0),
            editOf(SequenceEditKindEnum.added, after: 1),
          ]);
      expect(runs, <LineRunValueObject>[
        const LineRunValueObject.added(from: 0, to: 1),
      ]);
    });
  });

  test('a broken aligner fails the diff', () async {
    final Result<LineDiffValueObject, DocumentFailure> result =
        await const LineDifferService(aligner: _Broken()).diff(
          before: DocumentEntity(path: path, content: 'a'),
          after: DocumentEntity(path: path, content: 'b'),
        );
    expect(result, isA<Failure<LineDiffValueObject, DocumentFailure>>());
  });
}

final class _Aligner implements LineAlignerPort {
  _Aligner(this.answer);

  final List<SequenceEditValueObject> answer;
  List<String>? before;
  List<String>? after;
  double? threshold;

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    List<String> before,
    List<String> after, {
    required SpaceRelativePathValueObject path,
    required double threshold,
  }) async {
    this.before = before;
    this.after = after;
    this.threshold = threshold;
    return Success<List<SequenceEditValueObject>, DocumentFailure>(answer);
  }
}

final class _Broken implements LineAlignerPort {
  const _Broken();

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    List<String> before,
    List<String> after, {
    required SpaceRelativePathValueObject path,
    required double threshold,
  }) async => Failure<List<SequenceEditValueObject>, DocumentFailure>(
    DocumentOperationFailed(path.value),
  );
}

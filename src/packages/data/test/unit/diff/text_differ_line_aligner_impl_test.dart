import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
    'config/site.yaml',
  );

  test('the lines reach the differ as they are, with the threshold', () async {
    final _Differ differ = _Differ(
      const Success<List<TextEditDto>, TextDifferFailure>(<TextEditDto>[]),
    );
    await TextDifferLineAlignerImpl(
      differ: TextDifferDataSource(differ: differ),
    ).align(
      <String>['name: site', ''],
      <String>['name: blog'],
      path: path,
      threshold: 0.5,
    );
    expect(differ.before, <String>['name: site', '']);
    expect(differ.after, <String>['name: blog']);
    expect(differ.threshold, 0.5);
  });

  test(
    'each verdict arrives in the domain vocabulary, positions untouched',
    () async {
      final Result<List<SequenceEditValueObject>, DocumentFailure> result =
          await TextDifferLineAlignerImpl(
            differ: TextDifferDataSource(
              differ: _Differ(
                const Success<List<TextEditDto>, TextDifferFailure>(
                  <TextEditDto>[
                    TextEditDto(
                      kind: TextEditKindEnum.equal,
                      beforeIndex: 0,
                      afterIndex: 0,
                    ),
                    TextEditDto(
                      kind: TextEditKindEnum.changed,
                      beforeIndex: 1,
                      afterIndex: 1,
                    ),
                    TextEditDto(kind: TextEditKindEnum.removed, beforeIndex: 2),
                    TextEditDto(kind: TextEditKindEnum.added, afterIndex: 2),
                  ],
                ),
              ),
            ),
          ).align(
            <String>['a', 'b', 'c'],
            <String>['a', 'B', 'd'],
            path: path,
            threshold: 0.5,
          );
      expect(
        (result as Success<List<SequenceEditValueObject>, DocumentFailure>)
            .value,
        const <SequenceEditValueObject>[
          SequenceEditValueObject(
            kind: SequenceEditKindEnum.equal,
            beforeIndex: 0,
            afterIndex: 0,
          ),
          SequenceEditValueObject(
            kind: SequenceEditKindEnum.changed,
            beforeIndex: 1,
            afterIndex: 1,
          ),
          SequenceEditValueObject(
            kind: SequenceEditKindEnum.removed,
            beforeIndex: 2,
          ),
          SequenceEditValueObject(
            kind: SequenceEditKindEnum.added,
            afterIndex: 2,
          ),
        ],
      );
    },
  );

  test(
    'a differ that broke is the file, failing in the product vocabulary',
    () async {
      const TextDifferFailure reported = TextDifferFailed('out of memory');
      final Result<List<SequenceEditValueObject>, DocumentFailure> result =
          await TextDifferLineAlignerImpl(
            differ: TextDifferDataSource(
              differ: _Differ(
                const Failure<List<TextEditDto>, TextDifferFailure>(reported),
              ),
            ),
          ).align(<String>['a'], <String>['b'], path: path, threshold: 0.5);
      expect(
        (result as Failure<List<SequenceEditValueObject>, DocumentFailure>)
            .failure,
        const DocumentOperationFailed('config/site.yaml', cause: reported),
      );
    },
  );
}

/// A differ that answers what it was told to, and records what it was asked.
final class _Differ implements TextDiffer {
  _Differ(this.answer);

  final Result<List<TextEditDto>, TextDifferFailure> answer;
  List<String>? before;
  List<String>? after;
  double? threshold;

  @override
  Future<Result<List<TextEditDto>, TextDifferFailure>> align(
    List<String> before,
    List<String> after, {
    required double threshold,
  }) async {
    this.before = before;
    this.after = after;
    this.threshold = threshold;
    return answer;
  }
}

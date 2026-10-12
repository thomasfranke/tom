import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('CloneProgressValueObject', () {
    test('compares by value', () {
      // Built through a function so nothing is canonicalised into passing.
      CloneProgressValueObject at(int percent) => CloneProgressValueObject(
        stage: CloneStageEnum.receiving,
        percent: percent,
      );

      expect(at(40), at(40));
      expect(at(40), isNot(at(41)));
    });

    test('may carry no fraction', () {
      const CloneProgressValueObject progress = CloneProgressValueObject(
        stage: CloneStageEnum.starting,
      );

      expect(progress.percent, isNull);
    });

    test('refuses a fraction outside 0 to 100', () {
      expect(
        () => CloneProgressValueObject(
          stage: CloneStageEnum.receiving,
          percent: int.parse('101'),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('tryParse', () {
    test('reads the line git prints, whatever follows the number', () {
      expect(
        GitVersionValueObject.tryParse('git version 2.54.0 (Apple Git-157)'),
        const GitVersionValueObject(major: 2, minor: 54),
      );
    });

    test('a release with no patch is patch 0', () {
      expect(
        GitVersionValueObject.tryParse('git version 2.41'),
        GitVersionValueObject.minimum,
      );
    });

    test('a Windows build keeps its first three numbers', () {
      expect(
        GitVersionValueObject.tryParse('git version 2.43.0.windows.1')?.text,
        '2.43.0',
      );
    });

    test('a line with no number names no release', () {
      expect(GitVersionValueObject.tryParse('git, of some kind'), isNull);
      expect(GitVersionValueObject.tryParse(''), isNull);
    });
  });

  group('isSupported', () {
    bool supported(String line) =>
        GitVersionValueObject.tryParse(line)!.isSupported;

    test('2.41.0 is the first release the product works on', () {
      expect(supported('git version 2.41.0'), isTrue);
      expect(supported('git version 2.40.9'), isFalse);
    });

    test('a newer minor or major is enough', () {
      expect(supported('git version 2.54.1'), isTrue);
      expect(supported('git version 3.0.0'), isTrue);
    });

    test('an older major is not, whatever its minor says', () {
      expect(supported('git version 1.99.0'), isFalse);
      expect(supported('git version 2.39.2'), isFalse);
    });
  });
}

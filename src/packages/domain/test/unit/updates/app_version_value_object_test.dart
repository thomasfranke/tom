import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('a tag is read with or without its v', () {
    expect(AppVersionValueObject.tryParse('v1.2.3')?.text, '1.2.3');
    expect(AppVersionValueObject.tryParse('1.2')?.text, '1.2.0');
    expect(AppVersionValueObject.tryParse('v2.0.0-rc.1')?.text, '2.0.0');
  });

  test('a tag with no number names no release', () {
    expect(AppVersionValueObject.tryParse('nightly'), isNull);
    expect(AppVersionValueObject.tryParse(''), isNull);
  });

  test('newer is by major, then minor, then patch', () {
    AppVersionValueObject v(String s) => AppVersionValueObject.tryParse(s)!;
    expect(v('1.0.1').isNewerThan(v('1.0.0')), isTrue);
    expect(v('1.1.0').isNewerThan(v('1.0.9')), isTrue);
    expect(v('2.0.0').isNewerThan(v('1.9.9')), isTrue);
    expect(v('1.0.0').isNewerThan(v('1.0.0')), isFalse);
    expect(v('0.9.0').isNewerThan(v('1.0.0')), isFalse);
  });
}

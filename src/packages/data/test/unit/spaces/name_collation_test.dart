import 'package:test/test.dart';
import 'package:tom_data/src/spaces/name_collation.dart';

void main() {
  /// [names] in the tree's order.
  List<String> sorted(List<String> names) => names.toList()..sort(compareNames);

  test('case does not decide the order', () {
    expect(sorted(<String>['beta', 'Alpha', 'alpha2', 'Beta2']), <String>[
      'Alpha',
      'alpha2',
      'beta',
      'Beta2',
    ]);
  });

  test('an accented letter sorts with its letter, not after z', () {
    expect(
      sorted(<String>['zebra.md', 'Ácido.md', 'bravo.md', 'école.md', 'delta']),
      <String>['Ácido.md', 'bravo.md', 'delta', 'école.md', 'zebra.md'],
    );
  });

  test('a name the disk holds decomposed sorts the same as composed', () {
    // An HFS+ volume hands `ã` back as `a` and a combining tilde.
    const String decomposed = 'ação.md';
    expect(sorted(<String>['b.md', decomposed, 'a.md']), <String>[
      'a.md',
      decomposed,
      'b.md',
    ]);
    expect(collationKeyOf(decomposed), collationKeyOf('ação.md'));
  });

  test('letters of other Latin alphabets fold too', () {
    expect(collationKeyOf('Łódź'), 'lodz');
    expect(collationKeyOf('Çağrı'), 'cagri');
    expect(collationKeyOf('Straße'), 'strasse');
    expect(collationKeyOf('Œuvre'), 'oeuvre');
    expect(collationKeyOf('Ærø'), 'aero');
  });

  test('what has no accent to lose is only lowered', () {
    expect(collationKeyOf('README-2.md'), 'readme-2.md');
    expect(collationKeyOf('日本語.md'), '日本語.md');
  });

  test('two names that fold alike keep one order, whichever comes first', () {
    // A sort that called them equal would leave the order to the disk.
    expect(sorted(<String>['resume.md', 'résumé.md']), <String>[
      'resume.md',
      'résumé.md',
    ]);
    expect(sorted(<String>['résumé.md', 'resume.md']), <String>[
      'resume.md',
      'résumé.md',
    ]);
  });
}

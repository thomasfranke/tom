/// [DiffutilTextDifferImpl] at the sizes and in the scripts a real space
/// holds: thousands of entries a side, emoji, accents, and entries with no
/// word in them at all.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const DiffutilTextDifferImpl differ = DiffutilTextDifferImpl();

  /// How [before] and [after] line up, or a failed test.
  Future<List<TextEditDto>> alignOf(
    List<String> before,
    List<String> after, {
    double threshold = 0.5,
  }) async {
    final Result<List<TextEditDto>, TextDifferFailure> result = await differ
        .align(before, after, threshold: threshold);
    return switch (result) {
      Success<List<TextEditDto>, TextDifferFailure>(
        value: final List<TextEditDto> edits,
      ) =>
        edits,
      Failure<List<TextEditDto>, TextDifferFailure>(
        failure: final TextDifferFailure failure,
      ) =>
        fail('the differ failed: $failure'),
    };
  }

  /// Every edit as `kind before/after`.
  List<String> spelled(Iterable<TextEditDto> edits) => <String>[
    for (final TextEditDto edit in edits)
      '${edit.kind.name} ${edit.beforeIndex ?? '-'}/${edit.afterIndex ?? '-'}',
  ];

  /// Holds [edits] to the contract: every position of both sides exactly
  /// once, each side's positions in order.
  void expectEveryPositionOnce(
    List<TextEditDto> edits, {
    required int before,
    required int after,
  }) {
    expect(
      <int>[
        for (final TextEditDto edit in edits)
          if (edit.beforeIndex case final int index) index,
      ],
      <int>[for (int index = 0; index < before; index++) index],
    );
    expect(
      <int>[
        for (final TextEditDto edit in edits)
          if (edit.afterIndex case final int index) index,
      ],
      <int>[for (int index = 0; index < after; index++) index],
    );
  }

  group('five thousand entries a side', () {
    // Each bound is many times what a laptop takes; it is there for a
    // loaded CI machine, and what it guards is Myers at its worst case
    // answering in minutes.
    const Duration bound = Duration(seconds: 60);
    final List<String> side = <String>[
      for (int index = 0; index < 5000; index++)
        'alpha$index beta$index gamma$index',
    ];

    test('two identical sides are every entry equal, inside a '
        'minute', () async {
      final Stopwatch watch = Stopwatch()..start();
      final List<TextEditDto> edits = await alignOf(
        side,
        List<String>.of(side),
      );
      watch.stop();

      expect(edits, hasLength(5000));
      expect(
        edits.every(
          (TextEditDto edit) =>
              edit.kind == TextEditKindEnum.equal &&
              edit.beforeIndex == edit.afterIndex,
        ),
        isTrue,
      );
      expect(watch.elapsed, lessThan(bound));
    });

    test('every entry reworded is every entry changed, paired with '
        'itself, inside a minute', () async {
      final Stopwatch watch = Stopwatch()..start();
      final List<TextEditDto> edits = await alignOf(side, <String>[
        for (final String entry in side) '$entry more',
      ]);
      watch.stop();

      expect(edits, hasLength(5000));
      expect(
        edits.every(
          (TextEditDto edit) =>
              edit.kind == TextEditKindEnum.changed &&
              edit.beforeIndex == edit.afterIndex,
        ),
        isTrue,
      );
      expect(watch.elapsed, lessThan(bound));
    });

    test('two sides sharing no word are five thousand removals before '
        'five thousand additions, inside a minute', () async {
      final Stopwatch watch = Stopwatch()..start();
      final List<TextEditDto> edits = await alignOf(side, <String>[
        for (int index = 0; index < 5000; index++)
          'delta$index epsilon$index zeta$index',
      ]);
      watch.stop();

      expect(edits, hasLength(10000));
      expect(
        edits
            .take(5000)
            .every((TextEditDto edit) => edit.kind == TextEditKindEnum.removed),
        isTrue,
      );
      expect(
        edits
            .skip(5000)
            .every((TextEditDto edit) => edit.kind == TextEditKindEnum.added),
        isTrue,
      );
      expectEveryPositionOnce(edits, before: 5000, after: 5000);
      expect(watch.elapsed, lessThan(bound));
    }, timeout: const Timeout(Duration(minutes: 5)));

    test('one entry dropped from the middle and one added at the end move '
        'nothing else', () async {
      final List<String> after = List<String>.of(side)
        ..removeAt(2500)
        ..add('something new entirely');

      final List<TextEditDto> edits = await alignOf(side, after);

      expectEveryPositionOnce(edits, before: 5000, after: 5000);
      expect(
        spelled(
          edits.where(
            (TextEditDto edit) => edit.kind != TextEditKindEnum.equal,
          ),
        ),
        <String>['removed 2500/-', 'added -/4999'],
      );
    });
  });

  group('text that is not plain ASCII', () {
    test('an accented word is one word, and a different one from the same '
        'letters without the accent', () async {
      // `ação` against `acao` shares nothing; `revisão final` against
      // `revisão geral` shares one word of two, which is the threshold.
      expect(
        spelled(await alignOf(<String>['ação'], <String>['acao'])),
        <String>['removed 0/-', 'added -/0'],
      );
      expect(
        spelled(
          await alignOf(<String>['revisão final'], <String>['revisão geral']),
        ),
        <String>['changed 0/0'],
      );
    });

    test('accents written as one character and as a letter plus a mark '
        'are the same position, changed and never lost', () async {
      const String composed = 'café da manhã';
      const String decomposed = 'café da manhã';

      final List<TextEditDto> edits = await alignOf(
        <String>['# Title', composed, 'End.'],
        <String>['# Title', decomposed, 'End.'],
      );

      expectEveryPositionOnce(edits, before: 3, after: 3);
      expect(edits.first.kind, TextEditKindEnum.equal);
      expect(edits.last.kind, TextEditKindEnum.equal);
    });

    test('an entry of emoji alone has no word, so it pairs with nothing '
        'but itself', () async {
      expect(spelled(await alignOf(<String>['🎉'], <String>['🎉'])), <String>[
        'equal 0/0',
      ]);
      expect(spelled(await alignOf(<String>['🎉'], <String>['🚀'])), <String>[
        'removed 0/-',
        'added -/0',
      ]);
    });

    test('emoji beside words do not stop the words pairing', () async {
      expect(
        spelled(
          await alignOf(
            <String>['Shipped the release 🚀', 'unrelated'],
            <String>['Shipped the release 🎉 today', 'unrelated'],
          ),
        ),
        <String>['changed 0/0', 'equal 1/1'],
      );
    });

    test('an emoji made of several code points is never cut: both sides '
        'keep every position', () async {
      final List<TextEditDto> edits = await alignOf(
        <String>['👩‍👩‍👧‍👦 family', '🇧🇷 flag', 'plain'],
        <String>['👩‍👩‍👧 family', 'plain', '🇵🇹 flag'],
      );

      expectEveryPositionOnce(edits, before: 3, after: 3);
    });

    test('Chinese, Japanese and Korean lines pair by the words a space '
        'makes', () async {
      expect(
        spelled(
          await alignOf(
            <String>['文档 是 产品', '第二 行'],
            <String>['文档 是 好 产品', '第二 行'],
          ),
        ),
        <String>['changed 0/0', 'equal 1/1'],
      );
    });
  });

  group('entries with nothing in them', () {
    test('blank entries on both sides line up with each other', () async {
      final List<TextEditDto> edits = await alignOf(
        <String>['a', '', 'b', '', 'c'],
        <String>['a', '', 'b', '', 'c'],
      );

      expect(
        edits.every((TextEditDto edit) => edit.kind == TextEditKindEnum.equal),
        isTrue,
      );
    });

    test('a threshold of zero pairs anything, and still answers every '
        'position once', () async {
      final List<TextEditDto> edits = await alignOf(
        <String>['one', '***', ''],
        <String>['two', '---', '   '],
        threshold: 0,
      );

      expectEveryPositionOnce(edits, before: 3, after: 3);
      expect(
        edits.every(
          (TextEditDto edit) => edit.kind == TextEditKindEnum.changed,
        ),
        isTrue,
      );
    });
  });
}

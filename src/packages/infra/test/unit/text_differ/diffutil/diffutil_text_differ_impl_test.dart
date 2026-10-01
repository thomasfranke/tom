import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const DiffutilTextDifferImpl differ = DiffutilTextDifferImpl();

  /// The alignment of [before] and [after], or the test failing.
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
        fail('aligning failed: ${failure.diagnostics}'),
    };
  }

  /// [edits] as `kind before->after`, which is what the assertions read.
  List<String> spelled(List<TextEditDto> edits) => <String>[
    for (final TextEditDto edit in edits)
      '${edit.kind.name} ${edit.beforeIndex}->${edit.afterIndex}',
  ];

  group('the format the contract promises', () {
    test('two identical sides are every entry, equal', () async {
      final List<TextEditDto> edits = await alignOf(
        <String>['one', 'two'],
        <String>['one', 'two'],
      );

      expect(spelled(edits), <String>['equal 0->0', 'equal 1->1']);
    });

    test('an entry only the new side holds is added', () async {
      final List<TextEditDto> edits = await alignOf(
        <String>['one'],
        <String>['one', 'two'],
      );

      expect(spelled(edits), <String>['equal 0->0', 'added null->1']);
    });

    test('an entry only the old side holds is removed', () async {
      final List<TextEditDto> edits = await alignOf(
        <String>['one', 'two'],
        <String>['one'],
      );

      expect(spelled(edits), <String>['equal 0->0', 'removed 1->null']);
    });

    test('every position of both sides appears exactly once', () async {
      final List<String> before = <String>['a', 'b', 'c', 'd'];
      final List<String> after = <String>['a', 'x', 'c', 'y', 'z'];

      final List<TextEditDto> edits = await alignOf(before, after);

      expect(
        edits
            .map((TextEditDto edit) => edit.beforeIndex)
            .whereType<int>()
            .toList()
          ..sort(),
        <int>[0, 1, 2, 3],
      );
      expect(
        edits
            .map((TextEditDto edit) => edit.afterIndex)
            .whereType<int>()
            .toList()
          ..sort(),
        <int>[0, 1, 2, 3, 4],
      );
    });

    test('an empty old side is every entry added', () async {
      final List<TextEditDto> edits = await alignOf(<String>[], <String>[
        'one',
        'two',
      ]);

      expect(spelled(edits), <String>['added null->0', 'added null->1']);
    });

    test('an empty new side is every entry removed', () async {
      final List<TextEditDto> edits = await alignOf(<String>[
        'one',
        'two',
      ], <String>[]);

      expect(spelled(edits), <String>['removed 0->null', 'removed 1->null']);
    });

    test('two empty sides are no edits at all', () async {
      expect(await alignOf(<String>[], <String>[]), isEmpty);
    });
  });

  group('pairing by similarity', () {
    test(
      'a rewritten entry is changed, not a removal and an addition',
      () async {
        final List<TextEditDto> edits = await alignOf(
          <String>['The quick brown fox jumps over the lazy dog.'],
          <String>['The quick brown fox leaps over the lazy dog.'],
        );

        expect(spelled(edits), <String>['changed 0->0']);
      },
    );

    test(
      'an entry sharing too little is a removal beside an addition',
      () async {
        final List<TextEditDto> edits = await alignOf(
          <String>['The quick brown fox jumps over the lazy dog.'],
          <String>['Nothing whatsoever to do with any of that.'],
        );

        expect(spelled(edits), <String>['removed 0->null', 'added null->0']);
      },
    );

    test(
      'punctuation and case do not decide whether two entries pair',
      () async {
        // With the full stop counted as part of the word, these two share
        // nothing.
        final List<TextEditDto> edits = await alignOf(
          <String>['Prose.'],
          <String>['Prose, rewritten.'],
        );

        expect(spelled(edits), <String>['changed 0->0']);
      },
    );

    test('sharing exactly the threshold is enough to pair', () async {
      // Two words each, one shared: 2 × 1 / (2 + 2) = 0.5, the default
      // threshold exactly.
      final List<TextEditDto> edits = await alignOf(
        <String>['gone one'],
        <String>['new one'],
      );

      expect(spelled(edits), <String>['changed 0->0']);
    });

    test('a threshold of 1 pairs only identical entries', () async {
      final List<TextEditDto> edits = await alignOf(
        <String>['The quick brown fox jumps over the lazy dog.'],
        <String>['The quick brown fox leaps over the lazy dog.'],
        threshold: 1,
      );

      expect(spelled(edits), <String>['removed 0->null', 'added null->0']);
    });

    test('what went comes before what arrived, in every gap', () async {
      final List<TextEditDto> edits = await alignOf(
        <String>['keep', 'first casualty', 'second casualty', 'tail'],
        <String>['keep', 'something else entirely', 'tail'],
      );

      expect(spelled(edits), <String>[
        'equal 0->0',
        'removed 1->null',
        'removed 2->null',
        'added null->1',
        'equal 3->2',
      ]);
    });

    test('entries sharing no word are not paired, however short', () async {
      // `---` shares no word with `***`, so pairing them would be a guess.
      final List<TextEditDto> edits = await alignOf(
        <String>['keep', '---'],
        <String>['keep', '***'],
      );

      expect(spelled(edits), <String>[
        'equal 0->0',
        'removed 1->null',
        'added null->1',
      ]);
    });
  });

  group('a document-sized run', () {
    test('a paragraph inserted in the middle moves nothing else', () async {
      final List<String> before = <String>[
        for (int index = 0; index < 200; index++) 'Paragraph number $index.',
      ];
      final List<String> after = <String>[
        ...before.take(100),
        'A paragraph nobody had written yet.',
        ...before.skip(100),
      ];

      final List<TextEditDto> edits = await alignOf(before, after);

      expect(
        edits.where((TextEditDto edit) => edit.kind != TextEditKindEnum.equal),
        <Matcher>[
          isA<TextEditDto>()
              .having(
                (TextEditDto edit) => edit.kind,
                'kind',
                TextEditKindEnum.added,
              )
              .having((TextEditDto edit) => edit.afterIndex, 'afterIndex', 100),
        ],
      );
    });
  });
}

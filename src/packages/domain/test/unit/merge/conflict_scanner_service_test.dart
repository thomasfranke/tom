import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const ConflictScannerService scanner = ConflictScannerService();

  /// The one conflict in [cut], for a test that arranged exactly one.
  ConflictRegionValueObject find(List<ConflictSegment> cut) =>
      cut.whereType<ConflictAt>().single.region;

  String conflicted({
    String current = 'ours',
    String incoming = 'theirs',
    String currentLabel = 'HEAD',
    String incomingLabel = 'main',
  }) =>
      '# Title\n'
      '\n'
      '<<<<<<< $currentLabel\n'
      '$current\n'
      '=======\n'
      '$incoming\n'
      '>>>>>>> $incomingLabel\n'
      '\n'
      'After.\n';

  group('scan', () {
    test('finds nothing in a document git never touched', () {
      expect(scanner.scan('# Title\n\nJust prose.\n'), isEmpty);
      expect(scanner.scan(''), isEmpty);
    });

    test('reads both sides and both labels', () {
      final List<ConflictRegionValueObject> found = scanner.scan(conflicted());

      expect(found, hasLength(1));
      expect(found.single.current, 'ours');
      expect(found.single.incoming, 'theirs');
      expect(found.single.currentLabel, 'HEAD');
      expect(found.single.incomingLabel, 'main');
    });

    test('spans from the opening marker to past the closing one', () {
      final String text = conflicted();
      final ConflictRegionValueObject region = scanner.scan(text).single;

      expect(text.substring(region.start), startsWith('<<<<<<<'));
      expect(text.substring(region.start, region.end), endsWith('main\n'));
      expect(text.substring(region.end), '\nAfter.\n');
    });

    test('finds every region in a document with several', () {
      final String text =
          '${conflicted(current: 'a', incoming: 'b')}'
          '${conflicted(current: 'c', incoming: 'd')}';

      final List<ConflictRegionValueObject> found = scanner.scan(text);

      expect(found.map((ConflictRegionValueObject r) => r.current), <String>[
        'a',
        'c',
      ]);
      expect(found.first.end, lessThanOrEqualTo(found.last.start));
    });

    test('keeps a side that is empty', () {
      final ConflictRegionValueObject region = scanner
          .scan(conflicted(current: ''))
          .single;

      expect(region.current, isEmpty);
      expect(region.incoming, 'theirs');
    });

    test('carries a multi-line side whole', () {
      final ConflictRegionValueObject region = scanner
          .scan(conflicted(current: 'one\ntwo'))
          .single;

      expect(region.current, 'one\ntwo');
    });

    // The rule this protects: a document *about* merging quotes these
    // markers, and quoting them must not turn a paragraph into a conflict.
    test('ignores a marker that is not at the start of a line', () {
      expect(scanner.scan('Type <<<<<<< HEAD to see it.\n'), isEmpty);
    });

    test('ignores an opening with no separator', () {
      expect(scanner.scan('<<<<<<< HEAD\nours\n>>>>>>> main\n'), isEmpty);
    });

    test('ignores a separator with no closing marker', () {
      expect(scanner.scan('<<<<<<< HEAD\nours\n=======\ntheirs\n'), isEmpty);
    });

    test('recovers when a second opening interrupts the first', () {
      final String text = '<<<<<<< HEAD\nstray\n${conflicted()}';

      final List<ConflictRegionValueObject> found = scanner.scan(text);

      expect(found, hasLength(1));
      expect(found.single.current, 'ours');
    });
  });

  group('resolve', () {
    test('keeping the current side leaves it and drops the markers', () {
      final String text = conflicted();
      final ConflictRegionValueObject region = scanner.scan(text).single;

      final String resolved = scanner.resolve(
        text,
        region,
        ConflictChoiceEnum.current,
      );

      expect(resolved, '# Title\n\nours\n\nAfter.\n');
      expect(scanner.scan(resolved), isEmpty);
    });

    test('keeping the incoming side leaves it and drops the markers', () {
      final String text = conflicted();
      final ConflictRegionValueObject region = scanner.scan(text).single;

      expect(
        scanner.resolve(text, region, ConflictChoiceEnum.incoming),
        '# Title\n\ntheirs\n\nAfter.\n',
      );
    });

    test('keeping both puts the current side first', () {
      final String text = conflicted();
      final ConflictRegionValueObject region = scanner.scan(text).single;

      expect(
        scanner.resolve(text, region, ConflictChoiceEnum.both),
        '# Title\n\nours\ntheirs\n\nAfter.\n',
      );
    });

    test('keeping an empty side removes the region entirely', () {
      final String text = conflicted(current: '');
      final ConflictRegionValueObject region = scanner.scan(text).single;

      final String resolved = scanner.resolve(
        text,
        region,
        ConflictChoiceEnum.current,
      );

      expect(resolved, '# Title\n\n\nAfter.\n');
      expect(scanner.scan(resolved), isEmpty);
    });

    test('resolving one of two leaves the other', () {
      final String text =
          '${conflicted(current: 'a', incoming: 'b')}'
          '${conflicted(current: 'c', incoming: 'd')}';
      final ConflictRegionValueObject first = scanner.scan(text).first;

      final String resolved = scanner.resolve(
        text,
        first,
        ConflictChoiceEnum.current,
      );

      expect(scanner.scan(resolved), hasLength(1));
      expect(scanner.scan(resolved).single.current, 'c');
    });
  });

  group('segment', () {
    test('a document with no conflict is one stretch of prose', () {
      final List<ConflictSegment> cut = scanner.segment('# Title\n\nProse.\n');

      expect(cut, hasLength(1));
      expect((cut.single as ConflictProse).text, '# Title\n\nProse.\n');
    });

    test('an empty document is still one stretch', () {
      expect(scanner.segment(''), hasLength(1));
    });

    test('prose, conflict, prose — in that order', () {
      final List<ConflictSegment> cut = scanner.segment(conflicted());

      expect(cut, hasLength(3));
      expect(cut[0], isA<ConflictProse>());
      expect(cut[1], isA<ConflictAt>());
      expect(cut[2], isA<ConflictProse>());
      expect((cut[0] as ConflictProse).text, '# Title\n\n');
      expect((cut[2] as ConflictProse).text, '\nAfter.\n');
    });

    // The rule the whole cut exists for: git marks whole lines while
    // markdown ends a paragraph at a blank one, so one paragraph holds
    // prose, a conflict and more prose.
    test('cuts a paragraph the markers run through', () {
      const String text =
          'Before the conflict.\n'
          '<<<<<<< HEAD\nours\n=======\ntheirs\n>>>>>>> main\n'
          'After the conflict.\n';

      final List<ConflictSegment> cut = scanner.segment(text);

      expect(cut, hasLength(3));
      expect((cut[0] as ConflictProse).text, 'Before the conflict.\n');
      expect((cut[2] as ConflictProse).text, 'After the conflict.\n');
      expect(find(cut).current, 'ours');
    });

    test('no marker survives the cut', () {
      final List<ConflictSegment> cut = scanner.segment(conflicted());

      for (final ConflictProse part in cut.whereType<ConflictProse>()) {
        expect(part.text, isNot(contains('<<<<<<<')));
        expect(part.text, isNot(contains('=======')));
        expect(part.text, isNot(contains('>>>>>>>')));
      }
    });

    test('a conflict at the very start has no prose before it', () {
      const String text = '<<<<<<< HEAD\nours\n=======\ntheirs\n>>>>>>> main\n';

      final List<ConflictSegment> cut = scanner.segment(text);

      expect(cut, hasLength(1));
      expect(cut.single, isA<ConflictAt>());
    });

    test('two conflicts keep the prose between them', () {
      final String text =
          '${conflicted(current: 'a', incoming: 'b')}'
          '${conflicted(current: 'c', incoming: 'd')}';

      final List<ConflictSegment> cut = scanner.segment(text);

      expect(cut.whereType<ConflictAt>(), hasLength(2));
      expect(cut.whereType<ConflictProse>(), isNotEmpty);
    });

    test('putting the prose back with the markers rebuilds the document', () {
      final String text = conflicted();

      final String rebuilt = scanner
          .segment(text)
          .map(
            (ConflictSegment part) => switch (part) {
              ConflictProse(text: final String it) => it,
              ConflictAt(region: final ConflictRegionValueObject it) =>
                text.substring(it.start, it.end),
            },
          )
          .join();

      expect(rebuilt, text);
    });
  });

  group('holdsMarker', () {
    test('is true while a region is still there', () {
      expect(scanner.holdsMarker(conflicted()), isTrue);
    });

    test('is false once every region is resolved', () {
      final String text = conflicted();
      final String resolved = scanner.resolve(
        text,
        scanner.scan(text).single,
        ConflictChoiceEnum.both,
      );

      expect(scanner.holdsMarker(resolved), isFalse);
    });

    test('is false for a document that merely quotes a marker', () {
      expect(scanner.holdsMarker('Git writes `<<<<<<< HEAD` here.\n'), isFalse);
    });

    // A region somebody half resolved by hand: one line of it deleted, the
    // rest still there. Not a region any more, and still not prose.
    for (final (String left, String text) in <(String, String)>[
      ('the opening line', '# Title\n\n<<<<<<< HEAD\nours\n\nAfter.\n'),
      ('the separator', '# Title\n\nours\n=======\ntheirs\n\nAfter.\n'),
      ('the closing line', '# Title\n\ntheirs\n>>>>>>> main\n\nAfter.\n'),
      ('the base line', '# Title\n\nours\n||||||| 1a2b3c4\nbase\n\nAfter.\n'),
      ('a closing line with no label', 'theirs\n>>>>>>>\n'),
      ('a marker on the last line, unterminated', 'theirs\n>>>>>>> main'),
      ('a marker in a file with Windows line endings', 'a\r\n=======\r\nb\r\n'),
    ]) {
      test('is true with only $left left', () {
        expect(scanner.holdsMarker(text), isTrue);
      });
    }

    test('is false for a heading underlined with more than seven', () {
      expect(scanner.holdsMarker('Title\n========\n\nProse.\n'), isFalse);
    });

    test('is false for a table row that opens with empty cells', () {
      expect(scanner.holdsMarker('||||||||a|\n'), isFalse);
    });

    test('is false for a marker that is indented, which is code', () {
      expect(scanner.holdsMarker('    <<<<<<< HEAD\n'), isFalse);
    });
  });

  group('a region written with its base (diff3, zdiff3)', () {
    const String withBase =
        '# Title\n'
        '\n'
        '<<<<<<< HEAD\n'
        'ours\n'
        '||||||| 1a2b3c4\n'
        'as it was\n'
        '=======\n'
        'theirs\n'
        '>>>>>>> main\n'
        '\n'
        'After.\n';

    test('is one region, and the base is on neither side', () {
      final ConflictRegionValueObject region = scanner.scan(withBase).single;

      expect(region.current, 'ours');
      expect(region.incoming, 'theirs');
      expect(region.currentLabel, 'HEAD');
      expect(region.incomingLabel, 'main');
    });

    test('spans all four marker lines', () {
      final ConflictRegionValueObject region = scanner.scan(withBase).single;

      expect(withBase.substring(region.start), startsWith('<<<<<<< HEAD\n'));
      expect(withBase.substring(region.end), '\nAfter.\n');
    });

    for (final ConflictChoiceEnum choice in ConflictChoiceEnum.values) {
      test('resolved as ${choice.name}, no marker and no base text is '
          'left', () {
        final String resolved = scanner.resolve(
          withBase,
          scanner.scan(withBase).single,
          choice,
        );

        expect(resolved, isNot(contains('|||||||')));
        expect(resolved, isNot(contains('as it was')));
        expect(scanner.holdsMarker(resolved), isFalse);
      });
    }

    test('keeping both is current then incoming, as without a base', () {
      expect(
        scanner.resolve(
          withBase,
          scanner.scan(withBase).single,
          ConflictChoiceEnum.both,
        ),
        '# Title\n\nours\ntheirs\n\nAfter.\n',
      );
    });

    test('an empty base is still a base', () {
      const String text =
          '<<<<<<< HEAD\nours\n||||||| base\n=======\ntheirs\n>>>>>>> main\n';

      expect(scanner.scan(text).single.current, 'ours');
    });

    test('a base with no separator after it is not a conflict', () {
      expect(
        scanner.scan('<<<<<<< HEAD\nours\n||||||| base\nwas\n>>>>>>> main\n'),
        isEmpty,
      );
    });

    test('the preview is cut around it, with no marker in the prose', () {
      final List<ConflictSegment> cut = scanner.segment(withBase);

      expect(cut, hasLength(3));
      expect(find(cut).current, 'ours');
      for (final ConflictProse prose in cut.whereType<ConflictProse>()) {
        expect(prose.text, isNot(contains('|||||||')));
        expect(prose.text, isNot(contains('as it was')));
      }
    });
  });
}

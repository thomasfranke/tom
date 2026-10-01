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
      final String text = '${conflicted(current: 'a', incoming: 'b')}'
          '${conflicted(current: 'c', incoming: 'd')}';

      final List<ConflictRegionValueObject> found = scanner.scan(text);

      expect(found.map((ConflictRegionValueObject r) => r.current), <String>[
        'a',
        'c',
      ]);
      expect(found.first.end, lessThanOrEqualTo(found.last.start));
    });

    test('keeps a side that is empty', () {
      final ConflictRegionValueObject region =
          scanner.scan(conflicted(current: '')).single;

      expect(region.current, isEmpty);
      expect(region.incoming, 'theirs');
    });

    test('carries a multi-line side whole', () {
      final ConflictRegionValueObject region =
          scanner.scan(conflicted(current: 'one\ntwo')).single;

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
      final String text = '${conflicted(current: 'a', incoming: 'b')}'
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
      final String text = '${conflicted(current: 'a', incoming: 'b')}'
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
  });
}

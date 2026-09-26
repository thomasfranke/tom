/// The index against a real sqlite, because FTS5 is the whole capability.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Sqlite3SearchIndexImpl index;

  setUp(() => index = Sqlite3SearchIndexImpl());
  tearDown(() => index.dispose());

  /// What [terms] finds, as keys in the order the index ranked them.
  Future<List<String>> keysFor(String terms) async {
    final Result<List<SearchHitDto>, SearchIndexFailure> found = await index
        .find(terms, limit: 10);
    return switch (found) {
      Success<List<SearchHitDto>, SearchIndexFailure>(
        value: final List<SearchHitDto> hits,
      ) =>
        hits.map((SearchHitDto hit) => hit.key).toList(),
      Failure<List<SearchHitDto>, SearchIndexFailure>(
        failure: final SearchIndexFailure failure,
      ) =>
        fail('search failed: $failure'),
    };
  }

  Future<void> fill(Map<String, String> documents) async {
    final Result<void, SearchIndexFailure> filled = await index
        .replaceAll(<IndexedDocumentDto>[
          for (final MapEntry<String, String> entry in documents.entries)
            IndexedDocumentDto(key: entry.key, text: entry.value),
        ]);
    expect(filled, isA<Success<void, SearchIndexFailure>>());
  }

  group('finding', () {
    test('finds a document by a word in its body, not in its name', () async {
      await fill(<String, String>{
        'docs/about.md': 'The bet is that a rendered diff is worth it.',
        'docs/roadmap.md': 'Phases, milestones and the order things arrive.',
      });

      expect(await keysFor('rendered'), <String>['docs/about.md']);
    });

    test('takes the last word as half-typed, so results follow typing', () {
      expect(
        fill(<String, String>{
          'a.md': 'documentation',
        }).then((void _) => keysFor('docum')),
        completion(<String>['a.md']),
      );
    });

    test('asks for every word, not any of them', () async {
      await fill(<String, String>{
        'both.md': 'a rendered diff',
        'one.md': 'a rendered preview',
      });

      expect(await keysFor('rendered diff'), <String>['both.md']);
    });

    test('folds diacritics, so "revisao" finds "revisão"', () async {
      await fill(<String, String>{'pt.md': 'uma revisão do documento'});

      expect(await keysFor('revisao'), <String>['pt.md']);
    });

    test('finds nothing for terms that are all punctuation', () async {
      await fill(<String, String>{'a.md': 'anything'});

      expect(await keysFor('   '), isEmpty);
      expect(await keysFor('-- ...'), isEmpty);
    });

    test('cannot be broken by what a person types', () async {
      await fill(<String, String>{'a.md': 'the quick brown fox'});

      // Every one of these is FTS5 syntax, and every one of them is a word
      // somebody typed as far as this is concerned.
      expect(await keysFor('quick"'), <String>['a.md']);
      expect(await keysFor('quick AND brown'), isEmpty);
      expect(await keysFor('quick*^'), <String>['a.md']);
      expect(await keysFor('(quick'), <String>['a.md']);
    });

    test('carries an excerpt of the text around the match', () async {
      await fill(<String, String>{
        'a.md':
            'A paragraph of prose that goes on for a while before it '
            'mentions marmalade, and then continues for a good while after '
            'it has, so that neither end of it can fit in one excerpt.',
      });

      final Result<List<SearchHitDto>, SearchIndexFailure> found = await index
          .find('marmalade', limit: 10);
      final List<SearchHitDto> hits =
          (found as Success<List<SearchHitDto>, SearchIndexFailure>).value;

      expect(hits.single.excerpt, contains('marmalade'));
      expect(hits.single.excerpt, contains('…'));
    });
  });

  group('keeping up with the files', () {
    test('forgets a document that is not in the new set', () async {
      await fill(<String, String>{'gone.md': 'marmalade'});
      await fill(<String, String>{'kept.md': 'jam'});

      expect(await keysFor('marmalade'), isEmpty);
      expect(await keysFor('jam'), <String>['kept.md']);
    });

    test('replaces one document without touching the others', () async {
      await fill(<String, String>{'a.md': 'marmalade', 'b.md': 'jam'});

      await index.put(const IndexedDocumentDto(key: 'a.md', text: 'honey'));

      expect(await keysFor('marmalade'), isEmpty);
      expect(await keysFor('honey'), <String>['a.md']);
      expect(await keysFor('jam'), <String>['b.md']);
    });

    test('files a document that was never indexed before', () async {
      await fill(<String, String>{});

      await index.put(const IndexedDocumentDto(key: 'new.md', text: 'honey'));

      expect(await keysFor('honey'), <String>['new.md']);
    });
  });

  test('answers again after being disposed of', () async {
    await fill(<String, String>{'a.md': 'marmalade'});
    index.dispose();

    // The database is reopened empty, which is the contract: what the index
    // holds is a cache, and rebuilding it is the caller's move.
    expect(await keysFor('marmalade'), isEmpty);
  });
}

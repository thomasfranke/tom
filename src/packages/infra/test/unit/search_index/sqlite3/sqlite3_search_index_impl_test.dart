/// [Sqlite3SearchIndexImpl] over sqlite in memory: the index never touches a
/// disk, so this is the whole capability in a unit.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Sqlite3SearchIndexImpl index;

  setUp(() => index = Sqlite3SearchIndexImpl());
  tearDown(() => index.dispose());

  Future<List<SearchHitDto>> hits(String terms, {int limit = 10}) async {
    final Result<List<SearchHitDto>, SearchIndexFailure> found = await index
        .find(terms, limit: limit);
    return (found as Success<List<SearchHitDto>, SearchIndexFailure>).value;
  }

  Future<void> fill(Map<String, String> documents) async {
    await index.replaceAll(<IndexedDocumentDto>[
      for (final MapEntry<String, String> entry in documents.entries)
        IndexedDocumentDto(key: entry.key, text: entry.value),
    ]);
  }

  test('a word in the body finds the document, with an excerpt', () async {
    await fill(<String, String>{
      'a.md': 'The bet is that a rendered diff is worth it.',
      'b.md': 'Phases and milestones.',
    });

    final List<SearchHitDto> found = await hits('rendered');

    expect(found.map((SearchHitDto h) => h.key), <String>['a.md']);
    expect(found.single.excerpt, contains('rendered'));
  });

  test('the last word is half-typed, and accents do not matter', () async {
    await fill(<String, String>{'a.md': 'documentação toda'});

    expect((await hits('docum')).single.key, 'a.md');
    expect((await hits('documentacao')).single.key, 'a.md');
  });

  test('every word must be there', () async {
    await fill(<String, String>{'a.md': 'red apple', 'b.md': 'red pear'});

    expect((await hits('red apple')).map((SearchHitDto h) => h.key), <String>[
      'a.md',
    ]);
  });

  test('punctuation and nothing but it ask nothing', () async {
    await fill(<String, String>{'a.md': 'x'});

    expect(await hits(''), isEmpty);
    expect(await hits('  --- "  '), isEmpty);
  });

  test('a query written as a language is only words', () async {
    await fill(<String, String>{'a.md': 'one two'});

    expect((await hits('one OR "two" NOT')).length, 0);
    expect((await hits('one* two')).single.key, 'a.md');
  });

  test('the limit caps the answer, best first', () async {
    await fill(<String, String>{
      'a.md': 'tom',
      'b.md': 'tom tom tom tom',
      'c.md': 'tom filler words here',
    });

    final List<SearchHitDto> found = await hits('tom', limit: 2);

    expect(found.length, 2);
    expect(found.first.key, 'b.md');
  });

  test('putting a document again replaces it, not adds it', () async {
    await fill(<String, String>{'a.md': 'old words'});

    await index.put(const IndexedDocumentDto(key: 'a.md', text: 'new words'));
    await index.put(const IndexedDocumentDto(key: 'b.md', text: 'old'));

    expect((await hits('old')).map((SearchHitDto h) => h.key), <String>[
      'b.md',
    ]);
    expect((await hits('new')).single.key, 'a.md');
  });

  test('replacing everything forgets what was there', () async {
    await fill(<String, String>{'a.md': 'alpha'});
    await fill(<String, String>{'b.md': 'beta'});

    expect(await hits('alpha'), isEmpty);
    expect((await hits('beta')).single.key, 'b.md');
  });

  test('a put into a fresh index opens it', () async {
    expect(
      await index.put(const IndexedDocumentDto(key: 'a.md', text: 'x')),
      isA<Success<void, SearchIndexFailure>>(),
    );
  });

  test('after dispose the index starts again, empty', () async {
    await fill(<String, String>{'a.md': 'alpha'});

    index.dispose();

    expect(await hits('alpha'), isEmpty);
    index
      ..dispose()
      ..dispose();
  });
}

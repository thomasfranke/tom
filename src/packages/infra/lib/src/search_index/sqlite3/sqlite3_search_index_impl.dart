/// The `sqlite3` implementation of [SearchIndex], over an FTS5 table.
library;

import 'package:sqlite3/sqlite3.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

/// [SearchIndex] as one in-memory FTS5 table.
///
/// In memory, and deliberately: the index is rebuilt from the `.md` files
/// when a space opens, so a copy on disk would be written and never read —
/// and a database that never outlives the session cannot go stale, cannot be
/// half-written and has no schema to migrate
/// ([search](../../../../../../../docs/technical/runtime/search.md)).
final class Sqlite3SearchIndexImpl implements SearchIndex {
  /// Creates an index; the database is opened when it is first used.
  Sqlite3SearchIndexImpl();

  /// The one table, named in the SQL and in `snippet()`.
  static const String _table = 'documents';

  /// Which column `snippet()` cuts an excerpt out of: `text`, the second.
  static const int _textColumn = 1;

  /// How many tokens of context an excerpt carries.
  static const int _excerptTokens = 12;

  /// The database, or null until something needs it.
  Database? _database;

  @override
  Future<Result<void, SearchIndexFailure>> replaceAll(
    List<IndexedDocumentDto> documents,
  ) async => _opened().flatMap(
    (Database database) => _guard(() {
      database.execute('DELETE FROM $_table;');
      final PreparedStatement insert = database.prepare(
        'INSERT INTO $_table(key, text) VALUES (?, ?);',
      );
      try {
        for (final IndexedDocumentDto document in documents) {
          insert.execute(<Object>[document.key, document.text]);
        }
      } finally {
        insert.dispose();
      }
    }),
  );

  @override
  Future<Result<void, SearchIndexFailure>> put(
    IndexedDocumentDto document,
  ) async => _opened().flatMap(
    (Database database) => _guard(() {
      database
        ..execute('DELETE FROM $_table WHERE key = ?;', <Object>[document.key])
        ..execute('INSERT INTO $_table(key, text) VALUES (?, ?);', <Object>[
          document.key,
          document.text,
        ]);
    }),
  );

  @override
  Future<Result<List<SearchHitDto>, SearchIndexFailure>> find(
    String terms, {
    required int limit,
  }) async {
    final String? match = _matchOf(terms);
    if (match == null) {
      return const Success<List<SearchHitDto>, SearchIndexFailure>(
        <SearchHitDto>[],
      );
    }
    return _opened().flatMap(
      (Database database) => _guard(() {
        // `rank` is bm25 unless the table says otherwise, and ascending is
        // best first — the one ordering FTS5 spells backwards.
        final ResultSet rows = database.select(
          "SELECT key, snippet($_table, $_textColumn, '', '', '…', "
          '$_excerptTokens) AS excerpt FROM $_table '
          'WHERE $_table MATCH ? ORDER BY rank LIMIT ?;',
          <Object>[match, limit],
        );
        return List<SearchHitDto>.unmodifiable(
          rows.map(
            (Row row) => SearchHitDto(
              key: row['key'] as String,
              excerpt: (row['excerpt'] as String).trim(),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _database?.dispose();
    _database = null;
  }

  /// The database, opened and given its table the first time.
  Result<Database, SearchIndexFailure> _opened() {
    final Database? database = _database;
    if (database != null) {
      return Success<Database, SearchIndexFailure>(database);
    }
    return _guard(() {
      final Database opened = sqlite3.openInMemory()
        ..execute(
          'CREATE VIRTUAL TABLE $_table USING '
          'fts5(key UNINDEXED, text, '
          "tokenize = 'unicode61 remove_diacritics 2');",
        );
      _database = opened;
      return opened;
    });
  }

  /// [body]'s value, with anything sqlite throws reported instead.
  static Result<T, SearchIndexFailure> _guard<T>(T Function() body) {
    try {
      return Success<T, SearchIndexFailure>(body());
    } on Object catch (error) {
      return Failure<T, SearchIndexFailure>(
        SearchIndexFailed(error.toString()),
      );
    }
  }

  /// What [terms] means as an FTS5 expression, or null when it means nothing.
  ///
  /// The words are taken out and everything else is a separator, so no
  /// character a person types can reach FTS5's own syntax — `AND`, `"` and
  /// `*` included. Every word has to appear and the last one may still be
  /// half-typed, which is what makes the results follow the typing.
  static String? _matchOf(String terms) {
    final List<String> words = terms
        .split(RegExp(r'[^\p{L}\p{N}_]+', unicode: true))
        .where((String word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return null;
    }
    return words.map((String word) => '"$word"*').join(' ');
  }
}

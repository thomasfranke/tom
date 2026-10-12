/// The list of allowed commands, over its file.
library;

import 'dart:convert';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/approvals/approvals_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [ApprovalsRepository] over [ApprovalsDataSource]: plain JSON, a command's
/// key and `true` or `false`.
///
/// **Reading never fails and writing never destroys**: a file that is
/// missing, broken or holding something else allows nothing, and one that is
/// not a JSON object is left as it is rather than written over — it can be
/// edited by hand, so what is in it is somebody's typing.
final class ApprovalsRepositoryImpl implements ApprovalsRepository {
  /// Creates the repository over [source], listing [keys].
  const ApprovalsRepositoryImpl({required this.source, required this.keys});

  /// Where the file is read and written.
  final ApprovalsDataSource source;

  /// Every command the app can run, by key, in the order [seed] lists them —
  /// the composition root's to gather, since it sees every capability.
  final List<String> keys;

  @override
  Future<ApprovalsValueObject> read() async =>
      switch (_decode((await source.read()).valueOrNull)) {
        final Map<String, Object?> held => ApprovalsValueObject(<String, bool>{
          for (final MapEntry<String, Object?> entry in held.entries)
            // Only a literal `true` allows: `"yes"` or `1` is not a yes.
            entry.key: entry.value == true,
        }),
        null => ApprovalsValueObject.none,
      };

  @override
  Future<Result<void, AppFailure>> write(String key, {required bool allowed}) =>
      _change((Map<String, Object?> held) => held[key] = allowed);

  @override
  Future<Result<void, AppFailure>> seed() =>
      _change((Map<String, Object?> held) {
        for (final String key in keys) {
          held.putIfAbsent(key, () => false);
        }
      });

  /// Applies [change] to what the file holds and writes it back — unless
  /// nothing changed, so a file already complete is never touched.
  Future<Result<void, AppFailure>> _change(
    void Function(Map<String, Object?> held) change,
  ) async {
    final Result<String?, FilesystemFailure> text = await source.read();
    if (text case Failure<String?, FilesystemFailure>(
      failure: final FilesystemFailure failure,
    )) {
      return Failure<void, AppFailure>(failure);
    }
    final Map<String, Object?>? held = _decode(text.valueOrNull);
    if (held == null) {
      return Failure<void, AppFailure>(
        FilesystemOperationFailed(
          source.path,
          'not a JSON object; it is left as it is',
        ),
      );
    }
    final String before = _encoder.convert(held);
    change(held);
    final String after = _encoder.convert(held);
    if (after == before && text.valueOrNull != null) {
      return const Success<void, AppFailure>(null);
    }
    return source.write(after);
  }

  /// Two spaces, one key per line: the file is read by a person.
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// [text] as a JSON object — an empty one for no file or an empty file —
  /// or null when it holds anything else.
  static Map<String, Object?>? _decode(String? text) {
    if (text == null || text.trim().isEmpty) {
      return <String, Object?>{};
    }
    try {
      return switch (jsonDecode(text)) {
        final Map<String, Object?> held => held,
        _ => null,
      };
    } on FormatException {
      return null;
    }
  }
}

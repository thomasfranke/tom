/// The domain's releases contract, fulfilled by the host's API.
library;

import 'dart:convert';

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
// For the capability's contract and failures only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [UpdatesRepository] over [AppUpdates]: reads the answer, and says
/// nothing published when the answer holds no version it can read.
final class UpdatesRepositoryImpl implements UpdatesRepository {
  /// Creates a repository over [updates].
  const UpdatesRepositoryImpl({required this.updates});

  /// Where the host is asked.
  final AppUpdates updates;

  @override
  Future<Result<ReleaseValueObject?, UpdateFailure>> latest() async {
    final Result<String?, AppUpdatesFailure> asked = await updates.latest();
    switch (asked) {
      case Failure<String?, AppUpdatesFailure>(
        :final AppUpdatesFailure failure,
      ):
        return Failure<ReleaseValueObject?, UpdateFailure>(
          UpdateFailure.unreachable(cause: failure),
        );
      case Success<String?, AppUpdatesFailure>(:final String? value):
        return Success<ReleaseValueObject?, UpdateFailure>(_read(value));
    }
  }

  /// The release [body] describes, or null when it describes none.
  static ReleaseValueObject? _read(String? body) {
    if (body == null) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(body);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      final Object? tag = decoded['tag_name'];
      final AppVersionValueObject? version = tag is String
          ? AppVersionValueObject.tryParse(tag)
          : null;
      if (version == null) {
        return null;
      }
      final Object? page = decoded['html_url'];
      return ReleaseValueObject(
        version: version,
        notesUrl: page is String ? page : '',
      );
    } on FormatException {
      return null;
    }
  }
}

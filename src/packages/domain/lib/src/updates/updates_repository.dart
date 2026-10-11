/// Where TOM's releases are asked about.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/updates/release_value_object.dart';
import 'package:tom_domain/src/updates/update_failure.dart';

/// The latest published release, from wherever builds are published.
abstract interface class UpdatesRepository {
  /// The latest release, or null when nothing has been published.
  Future<Result<ReleaseValueObject?, UpdateFailure>> latest();
}

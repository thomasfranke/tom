/// Reading and writing the list of commands allowed to run unasked.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/approvals/approvals_value_object.dart';

/// Where `git-approvals.json` comes from and goes back to: a file of its
/// own beside the preferences, never in a repository
/// (`docs/product/git-workflow/approvals/doc.md`).
///
/// **A read cannot fail**: a missing file, a missing key or a value nobody
/// can read is `false`, silently — the safe answer, since `false` only ever
/// means the person is asked.
abstract interface class ApprovalsRepository {
  /// The file's name, which the product fixes: it is what the person is
  /// told to open, and what its tab says.
  static const String fileName = 'git-approvals.json';

  /// What the file holds, with nothing allowed where it says nothing.
  Future<ApprovalsValueObject> read();

  /// Writes [allowed] beside [key], leaving every other key as it is.
  Future<Result<void, AppFailure>> write(String key, {required bool allowed});

  /// Makes the file list every command the app can run, each `false` unless
  /// it is already there — so the person can edit it by hand.
  ///
  /// Never touches a key the file already holds, one the app does not know
  /// included.
  Future<Result<void, AppFailure>> seed();
}

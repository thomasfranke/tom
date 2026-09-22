/// What `dart:io` reported, kept for the diagnostics and nothing else.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'dart_io_failure.freezed.dart';

/// The detail only this adapter knows, carried as the cause of a contract's
/// failure.
///
/// **Not a vocabulary.** No contract names it, nothing outside this package
/// can switch on it, and the barrel does not export it — which is the whole
/// isolation: a third-party dependency lives here, and so does the shape of
/// what it says when it fails ([Decision
/// 7](../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
///
/// What the *contract* answers with is a `FilesystemFailure` or a
/// `GitClientFailure`, decided by the adapter and identical whichever
/// implementation produced it. This hangs off that one as
/// [AppFailure.cause], so `EACCES` against `EPERM` — two values the product
/// answers identically — stay one variant and two numbers, and the bug report
/// still has the number.
@freezed
abstract class DartIoFailure with _$DartIoFailure implements AppFailure {
  /// Creates the record of what the operating system said.
  const factory DartIoFailure({
    /// The message `dart:io` put on the exception.
    required String message,

    /// The path it named, when it named one.
    String? path,

    /// The OS error code, when there was one.
    ///
    /// POSIX `errno` on Unix and a Win32 code on Windows — the same number
    /// means different things on the two, which is exactly why nothing
    /// switches on it and it is only ever read by a human.
    int? osErrorCode,

    /// The OS error message, when there was one.
    String? osErrorMessage,

    /// Nothing: this is the bottom of a chain by construction.
    AppFailure? cause,
  }) = _DartIoFailure;
}

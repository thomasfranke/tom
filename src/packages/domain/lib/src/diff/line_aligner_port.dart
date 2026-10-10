/// What lines two versions of a file up, line against line.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/diff/sequence_edit_value_object.dart';
import 'package:tom_domain/src/documents/document_failure.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

/// Which line of one version is which line of the other.
///
/// The line twin of `BlockAlignerPort`, with its format: a port because an
/// alignment is a published algorithm, and `LineDifferService` is the rule
/// on top of it.
abstract interface class LineAlignerPort {
  /// How [before] and [after] line up, in reading order; two lines pair when
  /// at least [threshold] alike. [path] is the file they are lines of, which
  /// a failure names.
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    List<String> before,
    List<String> after, {
    required SpaceRelativePathValueObject path,
    required double threshold,
  });
}

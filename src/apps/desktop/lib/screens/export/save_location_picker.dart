/// Asking where an export goes, behind something that can be replaced.
library;

import 'package:file_selector/file_selector.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'save_location_picker.g.dart';

/// Asks where to write a [format] file offered as [suggestedName]; null when
/// the person changed their mind.
typedef SaveLocationPicker =
    Future<String?> Function(String suggestedName, ExportFormatEnum format);

/// The platform's save dialog, filtered to the one format asked for.
///
/// A seam for the same reason the folder picker is: a native dialog is the
/// one thing no test can drive, so the e2e suite replaces it through a
/// `TomModule`.
@riverpod
SaveLocationPicker saveLocationPicker(Ref ref) =>
    (String suggestedName, ExportFormatEnum format) async =>
        (await getSaveLocation(
          suggestedName: suggestedName,
          acceptedTypeGroups: <XTypeGroup>[
            XTypeGroup(
              label: format.name.toUpperCase(),
              extensions: <String>[format.extension],
            ),
          ],
        ))?.path;

/// Where a name typed in the tree lands.
library;

import 'package:tom_domain/tom_domain.dart';

/// [typed] inside [folder] — the space's root when null — or null when it is
/// not a name.
///
/// One segment only: a `/` would reach into or out of another folder, and
/// `.` or `..` would name the folder itself or its parent.
SpaceRelativePathValueObject? entryPathFor(
  SpaceRelativePathValueObject? folder,
  String typed,
) {
  final String name = typed.trim();
  if (name.isEmpty ||
      name == '.' ||
      name == '..' ||
      name.contains('/') ||
      name.contains(r'\')) {
    return null;
  }
  return SpaceRelativePathValueObject.tryParse(
    folder == null ? name : '${folder.value}/$name',
  );
}

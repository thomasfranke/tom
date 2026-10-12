/// The vendored interface face, for a widget test that measures a board.
library;

import 'dart:io';

import 'package:flutter/services.dart';

/// Loads IBM Plex Sans under the name `TomFonts.sans` — the family a widget
/// test otherwise draws in the test font, whose every glyph is a square of
/// its size, so no line wraps where it does in the app and no height is the
/// app's. Call it before pumping anything whose numbers a board fixes.
///
/// Read from the package's `fonts/` by a path relative to the application's
/// folder, which is where `flutter test` runs.
Future<void> loadTomFaces() async {
  final FontLoader sans = FontLoader('packages/tom_ui/IBMPlexSans');
  for (final String face in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final Uint8List bytes = File(
      '../../packages/ui/fonts/IBMPlexSans-$face.ttf',
    ).readAsBytesSync();
    sans.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await sans.load();
}

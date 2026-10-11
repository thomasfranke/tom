/// Closing the window, behind something the composition root supplies.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'window_closer.g.dart';

/// Closes the app's window for good, which ends the app.
typedef WindowCloser = Future<void> Function();

/// What closes the window once leaving was answered for.
///
/// A seam with no default because the window is a plugin's, and a plugin
/// lives in the application: this package decides *when* the window may go,
/// never how (`docs/product/editor/tabs/doc.md`).
@Riverpod(keepAlive: true)
WindowCloser windowCloser(Ref ref) => throw StateError(
  'windowCloserProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

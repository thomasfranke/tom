/// How a path is written on screen.
library;

import 'dart:io' show Platform;

/// [path] with the home folder written as `~`, as the design shows it;
/// left alone when there is no home to shorten against.
///
/// Shared by the status bar and the breadcrumb's menu, which both write a
/// path the reader has to recognise at a glance — two spellings of the same
/// folder read as two folders.
String homeRelative(String path) {
  final String? home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (home == null || home.isEmpty || !path.startsWith(home)) {
    return path;
  }
  return '~${path.substring(home.length)}';
}

/// Which git the app starts, decided at the composition root.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What is started to run git: the `git` the `PATH` names, unless a run
/// points the app at another
/// (`integration_test/support/e2e_module_impl.dart`).
final Provider<String> gitExecutableProvider = Provider<String>(
  (Ref ref) => 'git',
);

/// Variables added to the ones git is run with: none, unless a run points
/// git at a configuration of its own so the developer's never reaches it.
final Provider<Map<String, String>> gitEnvironmentProvider =
    Provider<Map<String, String>>((Ref ref) => const <String, String>{});

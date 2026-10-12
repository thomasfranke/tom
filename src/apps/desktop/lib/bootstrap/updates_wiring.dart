/// Where the update check asks, decided at the composition root.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/about/app_build.dart';
import 'package:tom_infra/tom_infra.dart';

/// The place releases are published, asked over `HttpClient`.
///
/// A run that must not reach GitHub overrides it with its own address
/// (`integration_test/support/e2e_module_impl.dart`).
final Provider<AppUpdates> appUpdatesProvider = Provider<AppUpdates>(
  (Ref ref) => DartIoHttpClientAppUpdatesImpl(
    endpoint: Uri.parse(AppBuild.latestRelease),
  ),
);

/// Whether a first release exists, as this build was told; a run that
/// publishes its own overrides it.
final Provider<bool> releasesAreOutProvider = Provider<bool>(
  (Ref ref) => AppBuild.releasesPublished,
);

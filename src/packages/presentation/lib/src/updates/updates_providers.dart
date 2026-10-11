/// What the update check is wired from, declared where it lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_domain/tom_domain.dart';

part 'updates_providers.g.dart';

/// Asks whether a newer TOM has been published.
@riverpod
CheckForUpdatesUseCase checkForUpdates(Ref ref) => throw StateError(
  'checkForUpdatesProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);

/// The version this build is, read at build time.
@riverpod
AppVersionValueObject runningVersion(Ref ref) => throw StateError(
  'runningVersionProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);

/// Whether a first release has been published; until then the check is
/// unavailable and the dialog says so
/// (`docs/product/about/doc.md`).
@riverpod
bool releasesPublished(Ref ref) => false;

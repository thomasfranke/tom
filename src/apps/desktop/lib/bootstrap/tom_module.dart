/// The app's public extension contract.
library;

// `Override` is not in Riverpod 3's main barrel; it lives in `misc.dart`.
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';

/// Something that adds to TOM
/// ([Decision 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
///
/// One direction: a module depends on the app, never the reverse. Modules
/// add, never change the app and never need the network to start; a change
/// here that stops one compiling is breaking
/// (`docs/technical/process/versioning.md`).
abstract interface class TomModule {
  /// The module's namespaced, stable identity — `tom.core`, `acme.tasks`.
  String get id;

  /// The panels it contributes; empty for a module that only overrides.
  List<PanelDescriptor> get panels;

  /// Provider overrides it installs into the app's scope.
  ///
  /// The seam for replacing an implementation without forking. Later
  /// modules win over earlier ones, because that is how `ProviderScope`
  /// composes them.
  List<Override> get overrides;
}

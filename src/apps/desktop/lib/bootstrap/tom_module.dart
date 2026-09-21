/// The app's public extension contract.
library;

// `Override` is not in Riverpod 3's main barrel — it lives in `misc.dart`,
// alongside the other types a consumer needs only when composing scopes.
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';

/// Something that adds to TOM.
///
/// The contract exists from M0 with nothing to load
/// ([Decision 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)):
/// an app that hardcodes its own panels has no way to accept anyone else's,
/// and retrofitting a monolithic shell costs weeks where being born
/// extensible costs hours.
///
/// **One direction.** A module depends on the app; the app never imports a
/// module. `main.dart` calls `runTom(modules: [])`, and what arrives in that
/// list is the only thing the app knows about extensions.
///
/// **Modules add.** They never change or degrade what the app already does,
/// and none of them may need the network to start.
///
/// Changing this class so that an existing module stops compiling is a
/// breaking change (`docs/technical/versioning.md`).
abstract interface class TomModule {
  /// What identifies this module — `tom.core`, `acme.tasks`.
  ///
  /// Namespaced, and stable: it is what a failure to load names, and what a
  /// user's settings refer to.
  String get id;

  /// The panels it contributes.
  ///
  /// Empty is a perfectly good answer: a module that only overrides a
  /// provider is still a module.
  List<PanelDescriptor> get panels;

  /// Provider overrides it installs into the app's scope.
  ///
  /// The seam for replacing an implementation without forking — a different
  /// filesystem for a test, a different git client on a platform that has no
  /// binary. Overrides from later modules win over earlier ones, because
  /// that is how `ProviderScope` composes them and pretending otherwise
  /// would need a second mechanism.
  List<Override> get overrides;
}

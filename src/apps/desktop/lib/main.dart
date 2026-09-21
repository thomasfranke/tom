/// The composition root.
///
/// Three lines, and that is the claim: everything the app is made of arrives
/// through [runTom], and a module added to that list is the only way to
/// change what the app does without changing the app
/// ([Decision 12](../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
///
/// The wiring itself lives in `bootstrap/`, where it can be read and tested;
/// this file exists so that `flutter run` has an entrypoint and so that the
/// shape of the entrypoint is obvious at a glance.
library;

import 'package:tom_desktop/bootstrap/run_tom.dart';

/// Starts the app with no extra modules.
void main() => runTom();

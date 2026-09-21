/// Everything a scenario needs, in one import.
///
/// **The reuse lives here, not in the scenarios.** A scenario file is a list
/// of named steps and nothing else; every tap, wait and assertion is in
/// `robot.dart`, so the tenth scenario costs a list rather than another copy
/// of "find the button, tap it, settle".
///
/// Why this is inside `tom_desktop` rather than a package of its own: an
/// end-to-end run has to happen inside **the app's own native runner**, with
/// the app's entitlements and the app's Podfile. A separate package would
/// need a second runner, and a second runner drifts — at which point the
/// tests would be proving something about a configuration nobody ships.
library;

export 'e2e_module.dart';
export 'fixture.dart';
export 'robot.dart';
export 'scenario.dart';

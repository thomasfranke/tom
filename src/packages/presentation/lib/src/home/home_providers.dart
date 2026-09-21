/// What Home is wired from, declared where Home lives.
library;

import 'package:riverpod/riverpod.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_presentation/src/home/home_notifier.dart';
import 'package:tom_presentation/src/home/home_state.dart';

/// Turns a folder into a space, and remembers it.
///
/// Declared here and **overridden by the composition root**. This package
/// names the use case it needs; it has no idea which repository, which git
/// client or which disk ends up behind it, and it cannot find out —
/// `tom_presentation` does not depend on `tom_data` or `tom_infra`
/// ([layers](../../../../../docs/technical/layers.md)).
///
/// Throwing rather than defaulting is deliberate: a default here would be a
/// second place where the app decides what satisfies a contract, and the
/// whole point of the composition root is that there is one.
final Provider<OpenSpace> openSpaceProvider = Provider<OpenSpace>(
  (Ref ref) => throw StateError(_notWired('openSpaceProvider')),
);

/// Reads the spaces to offer going back to.
final Provider<ListRecentSpaces> listRecentSpacesProvider =
    Provider<ListRecentSpaces>(
      (Ref ref) => throw StateError(_notWired('listRecentSpacesProvider')),
    );

/// Drops one space from that list.
final Provider<ForgetRecentSpace> forgetRecentSpaceProvider =
    Provider<ForgetRecentSpace>(
      (Ref ref) => throw StateError(_notWired('forgetRecentSpaceProvider')),
    );

/// Home's state.
///
/// The one provider a widget reaches for. A widget that named a repository
/// would have skipped the use case, and with it the guarantee that nothing
/// throws across a boundary.
final NotifierProvider<HomeNotifier, HomeState> homeProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

String _notWired(String name) =>
    '$name has no default. The composition root overrides it — see '
    'runTom() in tom_desktop.';

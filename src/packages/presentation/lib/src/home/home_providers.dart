/// What Home is wired from, declared where Home lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'home_providers.g.dart';

/// Turns a folder into a space, and remembers it.
///
/// Declared here and overridden by the composition root: this package names
/// the use case it needs and cannot see what satisfies it
/// ([architecture](../../../../../../docs/technical/architecture.md)). Throwing rather
/// than defaulting keeps that decision in one place.
@riverpod
OpenSpaceUseCase openSpace(Ref ref) =>
    throw StateError(_notWired('openSpaceProvider'));

/// Reads the spaces to offer going back to.
@riverpod
ListRecentSpacesUseCase listRecentSpaces(Ref ref) =>
    throw StateError(_notWired('listRecentSpacesProvider'));

/// Drops one space from that list.
@riverpod
ForgetRecentSpaceUseCase forgetRecentSpace(Ref ref) =>
    throw StateError(_notWired('forgetRecentSpaceProvider'));

String _notWired(String name) =>
    '$name has no default. The composition root overrides it — see '
    'runTom() in tom_desktop.';

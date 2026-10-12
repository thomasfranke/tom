/// Where cloning by URL has got to, on Home.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'home_clone_state.freezed.dart';

/// The field that takes `Clone from URL`'s place, and what it is doing
/// (`docs/product/home/cloning/doc.md`).
///
/// The address being typed is the field's own; the notifier is handed it on
/// `Clone`, so a keystroke rebuilds nothing but the field.
@freezed
sealed class HomeCloneState with _$HomeCloneState {
  /// The button, not the field.
  const factory HomeCloneState.closed() = HomeCloneClosed;

  /// The field, waiting for an address.
  const factory HomeCloneState.open() = HomeCloneOpen;

  /// [url] being cloned into [destination], [progress] once git has said
  /// anything.
  const factory HomeCloneState.cloning({
    required String url,
    required String destination,
    CloneProgressValueObject? progress,
  }) = HomeCloneCloning;

  /// [url] could not be cloned; the field keeps it so trying again is one
  /// press.
  const factory HomeCloneState.failed({
    required String url,
    required AppFailure failure,
  }) = HomeCloneFailed;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_plan_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Carries the opening's [CommandScope] from Home or the breadcrumb, which
/// ran the commands that open a folder, to `GitReadingNotifier`, which runs
/// the first reading once the window has changed — so the two are one plan
/// in the Commands panel, `Reading the repository`, and not a plan per read
/// (`docs/product/git-workflow/approvals/doc.md`).
///
/// Kept alive: it is written by a screen on its way out.

@ProviderFor(OpeningPlanNotifier)
final openingPlanProvider = OpeningPlanNotifierProvider._();

/// Carries the opening's [CommandScope] from Home or the breadcrumb, which
/// ran the commands that open a folder, to `GitReadingNotifier`, which runs
/// the first reading once the window has changed — so the two are one plan
/// in the Commands panel, `Reading the repository`, and not a plan per read
/// (`docs/product/git-workflow/approvals/doc.md`).
///
/// Kept alive: it is written by a screen on its way out.
final class OpeningPlanNotifierProvider
    extends $NotifierProvider<OpeningPlanNotifier, CommandScope?> {
  /// Carries the opening's [CommandScope] from Home or the breadcrumb, which
  /// ran the commands that open a folder, to `GitReadingNotifier`, which runs
  /// the first reading once the window has changed — so the two are one plan
  /// in the Commands panel, `Reading the repository`, and not a plan per read
  /// (`docs/product/git-workflow/approvals/doc.md`).
  ///
  /// Kept alive: it is written by a screen on its way out.
  OpeningPlanNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openingPlanProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openingPlanNotifierHash();

  @$internal
  @override
  OpeningPlanNotifier create() => OpeningPlanNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommandScope? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommandScope?>(value),
    );
  }
}

String _$openingPlanNotifierHash() =>
    r'6a448421c256781b5d49884164e6d8e38cd84644';

/// Carries the opening's [CommandScope] from Home or the breadcrumb, which
/// ran the commands that open a folder, to `GitReadingNotifier`, which runs
/// the first reading once the window has changed — so the two are one plan
/// in the Commands panel, `Reading the repository`, and not a plan per read
/// (`docs/product/git-workflow/approvals/doc.md`).
///
/// Kept alive: it is written by a screen on its way out.

abstract class _$OpeningPlanNotifier extends $Notifier<CommandScope?> {
  CommandScope? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CommandScope?, CommandScope?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CommandScope?, CommandScope?>,
              CommandScope?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_branch.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The branch [recent] was left on, or null when there is none to name
/// (`docs/product/home/recent-spaces/doc.md`).
///
/// One per row and disposed with it, so coming back to Home asks git again
/// rather than showing the branch a space was on the last time Home was up.
/// Never retried: a branch git could not name in time is a row without one.

@ProviderFor(recentBranch)
final recentBranchProvider = RecentBranchFamily._();

/// The branch [recent] was left on, or null when there is none to name
/// (`docs/product/home/recent-spaces/doc.md`).
///
/// One per row and disposed with it, so coming back to Home asks git again
/// rather than showing the branch a space was on the last time Home was up.
/// Never retried: a branch git could not name in time is a row without one.

final class RecentBranchProvider
    extends
        $FunctionalProvider<
          AsyncValue<BranchNameValueObject?>,
          BranchNameValueObject?,
          FutureOr<BranchNameValueObject?>
        >
    with
        $FutureModifier<BranchNameValueObject?>,
        $FutureProvider<BranchNameValueObject?> {
  /// The branch [recent] was left on, or null when there is none to name
  /// (`docs/product/home/recent-spaces/doc.md`).
  ///
  /// One per row and disposed with it, so coming back to Home asks git again
  /// rather than showing the branch a space was on the last time Home was up.
  /// Never retried: a branch git could not name in time is a row without one.
  RecentBranchProvider._({
    required RecentBranchFamily super.from,
    required RecentSpaceEntity super.argument,
  }) : super(
         retry: _never,
         name: r'recentBranchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentBranchHash();

  @override
  String toString() {
    return r'recentBranchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BranchNameValueObject?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BranchNameValueObject?> create(Ref ref) {
    final argument = this.argument as RecentSpaceEntity;
    return recentBranch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentBranchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentBranchHash() => r'b60be75e6da90bf1336bf6225496f2a2126bd8c5';

/// The branch [recent] was left on, or null when there is none to name
/// (`docs/product/home/recent-spaces/doc.md`).
///
/// One per row and disposed with it, so coming back to Home asks git again
/// rather than showing the branch a space was on the last time Home was up.
/// Never retried: a branch git could not name in time is a row without one.

final class RecentBranchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<BranchNameValueObject?>,
          RecentSpaceEntity
        > {
  RecentBranchFamily._()
    : super(
        retry: _never,
        name: r'recentBranchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The branch [recent] was left on, or null when there is none to name
  /// (`docs/product/home/recent-spaces/doc.md`).
  ///
  /// One per row and disposed with it, so coming back to Home asks git again
  /// rather than showing the branch a space was on the last time Home was up.
  /// Never retried: a branch git could not name in time is a row without one.

  RecentBranchProvider call(RecentSpaceEntity recent) =>
      RecentBranchProvider._(argument: recent, from: this);

  @override
  String toString() => r'recentBranchProvider';
}

# Pattern: Feature flags

A feature flag is an `if` that decides whether part of the app exists in a given build. It is what lets large features **integrate early** on `main` instead of living on a branch for weeks — the merge pain disappears, integration is tested continuously, and a release never waits for a branch to stabilize.

Flags in TOM are **build-time only**. There is no remote flag service, ever: that would be a phone-home, contradicting [Decision 11](../decisions/011-telemetry-is-opt-in.md). Zero infrastructure, zero network.

## Declaration

One place, `core/features.dart` in the app:

```dart
/// Build-time feature flags. Enable with --dart-define.
abstract final class Features {
  /// Block-level rendered diff (v1). Target: M2.
  static const renderedDiffV1 =
      bool.fromEnvironment('FEATURE_DIFF_V1', defaultValue: false);

  /// Wikilink autocomplete. Target: M3.
  static const wikilinks =
      bool.fromEnvironment('FEATURE_WIKILINKS', defaultValue: false);
}
```

```bash
flutter run --dart-define=FEATURE_DIFF_V1=true      # local development
flutter run --dart-define=FEATURE_DIFF_V1=true \
            --dart-define=FEATURE_WIKILINKS=true    # testing two together
flutter build windows                                # release: both off
```

Every flag carries a comment stating **what it gates and when it is expected to be removed**. A flag without a target milestone is already rotting.

## Rule 1 — Disabled means unreachable, not invisible

A disabled flag must make the feature *not exist*: not registered, not listening, not routable, not reachable by a keyboard shortcut. Hiding a widget while its shortcut still fires, or registering a panel and then filtering it out of the UI, is the way flags leak.

The natural place to apply this in TOM is the panel registration itself ([extension-modules.md](extension-modules.md)):

```dart
// in CoreModule
@override
List<PanelDescriptor> get panels => [
      explorerPanel,
      editorPanel,
      gitPanel,
      if (Features.renderedDiffV1) diffPanel,   // absent entirely when off
    ];
```

Same principle for providers, shortcuts and commands: guard the *registration*, not the rendering.

## Rule 2 — Flags have an expiry date

Once a feature ships and is stable, **remove the flag and the `if` in the very next PR**. A permanent flag multiplies execution paths, doubles what tests must cover, and becomes the worst kind of technical debt: a branch in the code that nobody remembers the reason for.

A `chore(desktop): remove FEATURE_DIFF_V1 flag` commit is a healthy sign, not busywork.

## Flags and modules are different questions

They stack and must never be conflated:

| Question | Mechanism |
|---|---|
| Is this code **in this repository**? | The repository itself. Code that lives elsewhere is not "flagged off" here — it is simply absent, and no flag can reveal it |
| Is it **exposed** in this build? | A build-time feature flag |

A feature being developed inside a separate module sits behind a flag *there*, in its own repository, on exactly the same terms as anything here.

**Hooks for modules outside this repository:** a module sometimes needs an extension point in the shell. That hook is ordinary code here, and it must **stand on its own** — either useful to the people using this repository, or generic enough for any third-party module. A hook whose only purpose is to serve one particular module degrades this repository for the benefit of another.

## Anti-patterns

| ❌ | Why |
|---|---|
| Widget rendered then hidden by a flag | Shortcuts, listeners and providers stay alive — the feature leaks |
| A flag with no removal target | Permanent branching in the code; the debt never gets paid |
| A remote/runtime flag service | Phone-home; contradicts Decision 11 and offline-first |
| Nested flags (`if (a && b)`) | Combinatorial paths nobody tests; split the work instead |
| Using a flag to hide code that belongs in another repository | The repository answers "who has this code"; a flag only answers whether it is reachable |

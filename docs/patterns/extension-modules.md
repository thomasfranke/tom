# Pattern: Extension modules

Complements [Decision 12](../decisions/012-paid-edition-ships-as-compile-time-module.md). The app shell is extensible through compile-time modules from M0 — even with no module existing yet. Panels, providers and commands are registered, never hardcoded.

## The contract (public repo)

```dart
// apps/tom_desktop/lib/bootstrap/extensions/tom_module.dart

/// A compile-time extension module. Implementations register extra
/// panels, provider overrides and commands into the app shell.
abstract interface class TomModule {
  /// Unique identifier (e.g. 'pro', 'my_extension').
  String get id;

  /// Extra panels contributed to the shell.
  List<PanelDescriptor> get panels;

  /// Riverpod overrides (extra or substituted providers).
  List<Override> get overrides;
}

/// Describes a panel the shell can host.
final class PanelDescriptor {
  const PanelDescriptor({
    required this.id,
    required this.title,
    required this.builder,
    this.placement = PanelPlacement.sidebar,
  });

  final String id;
  final String title;
  final WidgetBuilder builder;
  final PanelPlacement placement;
}
```

## The entrypoint

```dart
// apps/tom_desktop/lib/run_tom.dart
Future<void> runTom({required final List<TomModule> modules}) async {
  // collects descriptors and overrides from every module,
  // builds the ProviderScope with the overrides and starts the shell
}

// apps/tom_desktop/lib/main.dart — community build
void main() => runTom(modules: const []);
```

```dart
// (future) private repo — apps/tom_desktop_pro/lib/main_pro.dart
void main() => runTom(modules: [ProModule()]);
```

## Rules

1. **The shell knows no panel by name** — including the built-in ones (explorer, editor, diff, git), which are registered through the same mechanism (an internal `CoreModule`). One path for everything: the mechanism never rots from disuse.
2. **One direction:** modules depend on the app/core; the public app never imports a module.
3. **A paid feature is a module + a license key** (offline signature validation — the app is offline-first; license infrastructure is only built alongside the first paid module).
4. The `TomModule` contract is public on purpose: third parties can write their own modules (the seed of a future extension ecosystem).

## Anti-patterns

| ❌ | Why |
|---|---|
| A panel added directly to the shell widget | Expensive retrofit later; violates rule 1 |
| `if (isPro)` scattered through the UI | Gating belongs to the module (present in the build + licensed), not to community UI |
| A module altering free-tier behavior | The free tier is untouchable (Decision 4); modules **add** |
| License checks requiring the network | Breaks offline-first |

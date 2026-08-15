# Pattern: Extension modules

Complements [Decision 12](../../decisions/012-shell-is-extensible-via-compile-time-modules.md). The app shell is extensible through compile-time modules from M0 — even with no module existing yet. Panels, providers and commands are registered, never hardcoded.

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
// a separate application composing the same shell with an extra module
void main() => runTom(modules: [SomeModule()]);
```

## Rules

What the mechanism guarantees — built-in panels going through the same path, the one-way dependency, composition happening at build time, and the contract being public on purpose — is [Decision 12](../../decisions/012-shell-is-extensible-via-compile-time-modules.md). This page is the code; the anti-patterns below are what breaking those guarantees looks like in practice.

## Anti-patterns

| ❌ | Why |
|---|---|
| A panel added directly to the shell widget | Expensive retrofit later; violates rule 1 |
| `if (isPro)` scattered through the UI | Gating belongs to the module (present in the build + licensed), not to community UI |
| A module altering the shell's existing behavior | Modules **add**; they never change or degrade what the app already does |
| A module that needs the network to start | Breaks offline-first — the app must work with no connection |

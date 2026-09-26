# What enforces the graph

The layering in [`architecture.md`](architecture.md) is not a convention anyone
has to remember. Four mechanisms prove it.

| Mechanism | Catches |
|---|---|
| the pubspecs | An import of a package the layer never declared — it does not resolve |
| `depend_on_referenced_packages: error` | That same import arriving through a *transitive* dependency, which would otherwise compile |
| `implementation_imports: error` | Reaching into another package's `lib/src/` instead of using its barrel |
| `src/test/integrity/architecture_test.dart` | What no pubspec can express — below |

## The three the test carries alone

- **A dependency added to a pubspec**, after which the illegal import is entirely legal.
- **An SDK library**, which needs no declaration at all. `dart:io` is available to every package by default, so the pubspec graph has nothing to say about a domain entity calling `Process.run`. The test holds a second table — which *capabilities* each layer may import — and scans every `.dart` file under `lib/`, generated code included.
- **A Flutter package in `dev_dependencies`**, the quiet version of the leak: nothing imports a widget, but the package stops running under `dart test` and framework independence stops being provable.

Run it with `dart run tool/tom.dart test arch`. A dependency between layers is
declared there deliberately, because the graph is a decision
([Decision 14](decisions/014-each-layer-is-its-own-package.md)).

---

*See also: [architecture.md](architecture.md) · [process/commands.md](process/commands.md) · [process/ci.md](process/ci.md)*

# tom_desktop

The desktop application: composition root and widgets. The only package in the
workspace that depends on Flutter, and the only one that knows which
implementation satisfies which contract.

Depends on every layer, because wiring them together is its whole job. Nothing
depends on it.

Run it from the repository root:

```bash
make run              # or: make run DEVICE=windows|linux|macos
```

Part of [TOM](../../../README.md); the layer graph is in
[docs/architecture](../../../docs/architecture/).

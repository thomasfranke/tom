# tom_infra

Technical capabilities behind contracts — git, filesystem, markdown, search. Implementations never leave this package.

Organised by capability, not technology: each one is a folder holding the contract, its failure type, and one subfolder per implementation, named after how it is done. `filesystem/` is the first: `Filesystem` (contract) + `FilesystemFailure` + `dart_io/` (implementation). A second implementation is a sibling folder; the contract does not change.

Depends on: `tom_core`.

Part of [TOM](../../../README.md); the layer graph is in [docs/architecture/layers.md](../../../docs/architecture/layers.md).

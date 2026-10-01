# Runtime

How the layers behave once the app is running. The static picture — who may
depend on whom — is [`architecture.md`](../architecture.md); the rules each
package is held to are [`conventions/`](../conventions/README.md).

| File | Answers |
|---|---|
| [`git.md`](git.md) | The three conceptual layers of the git integration, the serialized queue per space, and the protocol the watcher and git cooperate by |
| [`preview.md`](preview.md) | The preview assembled block by block, what its base is, and the two document-scope constructs that do not survive |
| [`rendered-diff.md`](rendered-diff.md) | The diff layer by layer, and the three steps it ships in |
| [`search.md`](search.md) | Why the FTS5 index is a disposable cache and never state |
| [`state.md`](state.md) | The space session as the single source of truth, and one notifier per panel |
| [`composition.md`](composition.md) | Panels registered rather than hardcoded, and the three lifetimes the composition root wires |

---

*See also: [architecture.md](../architecture.md) · [technical/](../README.md)*

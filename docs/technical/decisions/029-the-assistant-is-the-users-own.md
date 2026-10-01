# Decision 29 — The assistant is the user's own, reached through one contract

**Status:** proposed — **draft, not accepted.** It carries two open questions the maintainer settles before this becomes a decision; they are named at the foot.

## Context

The documentation this project exists to review is increasingly written by an agent, and the question arrived from the maintainer rather than from the code: *what does a git client for markdown do when the author is not a person?*

Four things already constrain the answer, and none of them had been written down together.

**Nothing in either repository mentions this.** Neither `docs/` nor the commercial catalogue names an assistant, a model or a provider. There is no prior commitment to honour and none to contradict.

**The bet is the git workflow, not the editor.** [about.md](../../about.md) says so in the first fold, and the non-goals list rich-text editing. Generating prose moves effort into the editor, which is the one place this project deliberately does not compete — so the first thing to settle is not *how* but *what for*.

**Nothing leaves the user's machine.** [Decision 11](011-telemetry-is-opt-in.md) puts observability behind a contract, off by default, and says no data leaves the machine. An assistant that calls a service is the first feature that would send the user's own documents somewhere.

**The commercial rules already answer the tier.** A feature is paid only if whoever misses it is an organization rather than a person; a feature using the user's **own** credential against their **own** account has no claim to the paid side. Both tests put this in the free tier, which is why it is specified here and not elsewhere.

## Decision

**TOM ships no model, holds no account and proxies nothing. The user brings their own, and TOM reaches it through one capability contract.**

```
tom_infra/lib/src/assistant/
  assistant.dart              the contract
  assistant_failure.dart      not configured · refused · no answer · too long
  openai_compatible/          one implementation, many destinations
```

- **One implementation, a base URL.** Ollama, LM Studio, OpenRouter, vLLM and the providers themselves all speak the OpenAI-compatible shape, so local and remote stop being two implementations and become one setting. A provider that later earns its own adapter gets a subfolder beside it ([Decision 24](024-a-capability-is-a-folder.md)).
- **Not configured is the default, and it is a state rather than an error.** The surface says what it needs, drawn and unavailable, the way the git column says `No remote configured`.
- **A failure says what was refused, never why** — the rule the remote band already follows, for the same reason: the provider's answer is not TOM's to interpret.
- **The credential is not a preference.** Preferences are a JSON file the app offers to open in its own editor ([where it is stored](../../product/preferences/where-it-is-stored/doc.md)); a secret cannot live there. It goes to the platform keychain, which is a new capability — reachable because the macOS app is not sandboxed ([Decision 20](020-the-macos-app-is-not-sandboxed.md)).
- **The assistant reads the space through the repositories that already exist** — documents, git, search — rather than being handed the folder. What it sees is what it asked for, and what it asked for can be shown.

## Rationale

**The user's own credential is what makes the privacy question answerable at all.** TOM having an account would mean TOM choosing a destination for somebody else's documents. With the credential and the endpoint both the user's, the app sends nothing until a destination exists, and the destination was named by the person whose documents they are.

**One contract, because the alternative is a fork in the product.** A local-only assistant and a cloud one are the same feature to the person using it; making them two implementations of one contract keeps the choice at composition, where every other capability already puts it ([Decision 7](007-external-dependencies-behind-contracts.md)).

**The OpenAI shape is not an endorsement, it is arithmetic.** It is the format the local runtimes chose to imitate, so supporting it is what makes *local* work — the cloud providers speaking it too is the accident, not the point.

**The keychain is worth a capability** because the alternative is a secret in a file the app has a button to open. That is not a hypothetical: the preferences screen draws that button.

## Consequences

- An HTTP client and a keychain package enter the stack, both under [rule 1](../../../AGENTS.md) — licence checked before either is taken.
- `AssistantFailure` is a sealed hierarchy beside `GitFailure` and `SearchFailure`, so a surface switches over it exhaustively.
- The contract, the implementation and any panel are **public and free**. A hook in the public shell that exists only to serve a commercial edition is forbidden by the commercial rules themselves.
- A panel is a `PanelDescriptor` and nothing else ([Decision 12](012-shell-is-extensible-via-compile-time-modules.md)): the shell is not touched, and the aside's `Git · History` switch is already the mechanism a third panel needs.
- **Nothing here is drawn.** [Rule 13](../../../AGENTS.md) holds: no screen exists before its board does, and there is no board for any of this.
- This does not enter M3. The launch milestone is unchanged.

## What this does not decide

**Whether Decision 11 covers the assistant.** It says no data leaves the machine, and it was written about telemetry — data TOM collects about itself. An assistant sends data the user chose to send, to a destination the user named. That may be outside its spirit or inside its letter, and the two readings produce different products: one is local-only by principle, the other is local-by-default with the user free to point elsewhere. **An ADR is revised explicitly, never edited in passing** — so if the second reading wins, Decision 11 gains a revision note rather than a quiet reinterpretation.

**How a stream crosses the contract.** Every contract in the app answers `Future<Result<T, F>>`; an assistant produces tokens over time and can be cancelled halfway. Either `Result` learns to stream, or the contract stays a `Future` per turn and a notifier accumulates. The first is honest about what is happening; the second leaves the error convention untouched. This is settled when the first surface is designed, because the answer depends on what the surface has to draw.

## Revisit when

A reason appears that only a model TOM controls can serve — something the user's own endpoint cannot be asked for. Until then, shipping one would mean holding an account, and holding an account is what this decision exists to avoid.

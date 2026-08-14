# Roadmap

## Phases

```
Phase 0 · Validation      Do non-developers already read docs in a repo?
                          (in parallel: Spikes A and B — editor and AST)
Phase 1 · MVP (M0–M3)     Build in public; launch with a GIF of the rendered diff
Phase 2 · Traction        Assisted conflict resolution, section blame
Phase 3 · Mobile          iOS and Android, post-1.0 (Decision 8 reserves the shape)
```

Mobile is a committed direction, not a maybe — but it comes **after** 1.0. It is not a port for its own sake: writing documentation needs a repository, markdown and git, not a development environment, and the people who read and approve documentation are rarely at a desk when they do it. Desktop stays the reference platform: the panel layout, the Git-CLI infrastructure and the MVP scope are all unchanged by it. The cost is bounded because `tom_core` is pure Dart by construction, so mobile means new infrastructure implementations plus a new presentation, not a refactor. Two things must be resolved before Phase 3 starts:

- **Git without a system binary.** iOS and Android have no `git` CLI and no free filesystem — this is exactly the trigger [Decision 2](decisions/002-git-via-system-binary.md) names for embedding `libgit2` via FFI.
- **Editing on touch.** `re_editor` is desktop-oriented ([dependencies](dependencies.md)); source mode on a phone is an open design question, not just a port.

## What Phase 0 asks

The question is not "is documentation in Git painful?". Pain deduced from one's own experience is not evidence, and a leading question gets a yes from anyone being polite. The question is whether people who do not write code **already** read, comment on or approve documentation that lives in a repository — and how that happens today.

Five conversations with tech leads, about what already happens rather than about a product that does not exist:

- Does a PM, designer or manager on your team ever read documentation in the repository?
- Have they ever commented on a pull request? Do they have an account in the organization at all?
- When something the team wrote needs their approval, where does that happen today?

Answers about past behaviour beat answers about intent. And "they do not even have an account" is as useful a result as "every week" — it names the barrier precisely, which is the whole reason to ask before building rather than after.

## Open questions

- [ ] ~~Does the `markdown` AST handle diff v1?~~ → **Spike B** ([mvp.md](mvp.md))
- [ ] ~~Can `re_editor` serve as source mode?~~ → **Spike A** ([mvp.md](mvp.md))
- [ ] ~~Space configuration format~~ → `.tom/` is reserved for it, and nothing is written there until a genuinely shared setting needs it ([domain model](architecture/08-domain-model.md))
- [ ] ~~How far does `flutter_markdown_plus` take the preview?~~ → the preview renders block by block and delegates inline to the package ([presentation](architecture/06-presentation.md))
- [ ] Binary signing (Windows/macOS certificate cost) — needed for launch or later?

---

*See also: [mvp.md](mvp.md) · [product.md](product.md)*

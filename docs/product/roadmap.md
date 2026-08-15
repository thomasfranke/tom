# Roadmap

## Phases

```
Phase 0 · Spikes          The two technical unknowns: the editor and the AST
Phase 1 · MVP (M0–M3)     Build in public; launch with a GIF of the rendered diff
Phase 2 · Traction        Assisted conflict resolution, section blame
Phase 3 · Mobile          iOS and Android, post-1.0 (Decision 8 reserves the shape)
```

Mobile is a committed direction, not a maybe — but it comes **after** 1.0. It is not a port for its own sake: writing documentation needs a repository, markdown and git, not a development environment, and the people who read and approve documentation are rarely at a desk when they do it. Desktop stays the reference platform: the panel layout, the Git-CLI infrastructure and the MVP scope are all unchanged by it. The cost is bounded because `tom_core` is pure Dart by construction, so mobile means new infrastructure implementations plus a new presentation, not a refactor. Two things must be resolved before Phase 3 starts:

- **Git without a system binary.** iOS and Android have no `git` CLI and no free filesystem — this is exactly the trigger [Decision 2](../decisions/002-git-via-system-binary.md) names for embedding `libgit2` via FFI.
- **Editing on touch.** `re_editor` is desktop-oriented ([dependencies](../architecture/dependencies.md)); source mode on a phone is an open design question, not just a port.

## Goals

Three, in this order.

**A tool worth using every day.** The scope comes from problems the maintainer hits directly — documentation kept as markdown in a repository, a diff that shows syntax instead of the document, colleagues who would read and approve that documentation if reaching it did not require a terminal. Nothing in the MVP is speculative; every item is something the author wants on their own machine.

**A demonstration of how software can be built.** The architecture notes, the decision records and the code patterns are as thorough as they are on purpose: this repository is meant to be read as much as run. That goal explains choices a purely product-driven project would skip — a pure Dart core with framework independence proved by `dart test`, a decision file behind every architectural commitment, documentation updated in the same pull request as the behaviour it describes. If TOM never has a second user, this part still succeeded.

**Revenue, eventually, and only if earned.** [Decision 4](../decisions/004-business-model-is-open-core.md) gates anything commercial on genuine signals of team demand and keeps the free tier whole regardless. It is third on this list on purpose, and the first two do not depend on it.

The ordering is also what makes the plan honest: goals one and two are met by building well, which is entirely within the maintainer's control. Goal three is not, so it is written as a possibility rather than a projection, and no date is attached to it anywhere.

Feedback comes from use, not from research. The maintainer is the first user and the documentation in this repository is the first space TOM opens, so anything awkward shows up within a day of shipping it. Beyond that, the repository is public: whoever clones it, uses it and reports what breaks is a slower signal than a study, but it is a real one, and it arrives from people who chose to be there.

## Open questions

- [ ] ~~Does the `markdown` AST handle diff v1?~~ → **Spike B** ([mvp.md](mvp.md))
- [ ] ~~Can `re_editor` serve as source mode?~~ → **Spike A** ([mvp.md](mvp.md))
- [ ] ~~Space configuration format~~ → `.tom/` is reserved for it, and nothing is written there until a genuinely shared setting needs it ([domain model](../architecture/domain/model.md))
- [ ] ~~How far does `flutter_markdown_plus` take the preview?~~ → the preview renders block by block and delegates inline to the package ([presentation](../architecture/presentation/state.md))
- [ ] Binary signing (Windows/macOS certificate cost) — needed for launch or later?

---

*See also: [mvp.md](mvp.md) · [product.md](product.md)*

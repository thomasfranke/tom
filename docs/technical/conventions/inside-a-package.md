# Inside a package

What every package under `src/packages/` looks like from the inside. The graph
that puts it where it is: [`architecture.md`](../architecture.md). What its
identifiers have to say: [`naming.md`](naming.md).

## Rules

- **One barrel**, `lib/tom_<name>.dart`; everything else under `lib/src/`, which no other package may import. What the barrel exports *is* the public API.
- **`tom_infra` organises by capability, not by technology** — `src/git_client/` holds the contract, its failures, and one subfolder per implementation. A second implementation is a sibling folder, and the composition root is the only file that changes ([Decision 24](../decisions/024-a-capability-is-a-folder.md)).
- Nothing sits loose beside the capabilities: a file in that package without a contract is a capability that was never declared.
- **One failure file per capability, beside the contract**, and every variant in it is one a second implementation must also be able to produce — that is what makes it the contract rather than one adapter's diary.
- **No type from a dependency crosses a contract.** A `ProcessException` dies inside `dart_io/` and leaves as a `GitClientFailure`; if it escaped, the caller would handle exceptions from a library it is not supposed to know about and the folder would be decoration.
- **A repository obtains nothing itself** — a data source does, leaving the repository the order the questions are asked in, the turn from DTO into the domain's vocabulary, and the failure translation ([Decision 25](../decisions/025-a-repository-reads-through-a-data-source.md)).
- A source is a concrete class, and it names no domain type. Whatever varies, varies at the capability below.
- **Holding a capability is what a repository may not do**; `tom rules` fails on a field of one in a `*_repository_impl.dart`. Naming a capability's *failure* in order to translate it is still the repository's work.
- **`tom_core` holds mechanism, never vocabulary.** `Result`, `AppFailure` and `Observability` belong there; git, documents and search have vocabulary, and vocabulary belongs to `tom_domain` — otherwise the package everything depends on becomes the package that changes most.
- **A comment is two or three lines**: what the thing is, then why it is that way. The `tom-comments` skill is the whole of it.

## Why an adapter keeps nothing of its own

What the dependency said and the contract has no word for is **dropped**.
[`AppFailure.cause`](../../../src/packages/core/lib/src/app_failure.dart) links
two *vocabularies* — it is what a repository attaches when it turns
`GitClientFailure` into `GitFailure` — and an adapter has only one.

---

*See also: [conventions/](README.md) · [naming.md](naming.md) · [errors.md](errors.md) · [testing.md](testing.md)*

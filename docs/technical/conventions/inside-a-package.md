# Inside a package

What every package under `src/packages/` looks like from the inside. The graph
that puts it where it is: [`architecture.md`](../architecture.md). What its
identifiers have to say: [`naming.md`](naming.md).

## One barrel

`lib/tom_<name>.dart`; everything else under `lib/src/`, which no other package
may import. What the barrel exports *is* the public API.

## `tom_infra` organises by capability, not by technology

`src/git_client/` holds the contract, its failures, and one subfolder per
implementation (`dart_io/`, later `libgit2/`). A second implementation is a
sibling folder, and the composition root is the only file that changes.
Nothing sits loose beside the capabilities — a file in this package without a
contract is a capability that was never declared
([Decision 24](../decisions/024-a-capability-is-a-folder.md)).

**One failure file per capability, beside the contract**, and every variant in
it is one a second implementation must also be able to produce — that is what
makes it the contract rather than one adapter's diary. An adapter keeps
nothing of its own: what the dependency said and the contract has no word for
is dropped, because
[`AppFailure.cause`](../../../src/packages/core/lib/src/app_failure.dart)
links two *vocabularies* — it is what a repository attaches when it turns
`GitClientFailure` into `GitFailure` — and an adapter has only one.

## No type from a dependency crosses a contract

A `ProcessException` dies inside `dart_io/` and leaves as a
`GitClientFailure`. If it escaped, the caller would be handling exceptions
from a library it is not supposed to know about, and the folder would be
decoration.

## A repository obtains nothing itself

A data source does, and the repository is left with the order the questions
are asked in, the turn from a DTO into the domain's vocabulary, and the
failure translation
([Decision 25](../decisions/025-a-repository-reads-through-a-data-source.md)).
A source is a concrete class — whatever varies, varies at the capability below
— and it names no domain type. Holding a capability is what a repository may
not do, and `tom rules` fails on a field of one in a `*_repository_impl.dart`;
naming a capability's *failure* in order to translate it is still the
repository's work.

## `tom_core` holds mechanism, never vocabulary

`Result`, `AppFailure` and `Observability` belong there. Git, documents and
search have vocabulary, and vocabulary belongs to `tom_domain` — otherwise the
package everything depends on becomes the package that changes most.

## A comment is two or three lines

One sentence saying what the thing is, then the reason it is that way — and
there it stops. The exceptions are real but rare: a rule whose only home is
this dartdoc ([the canonical form of a rule is the code that implements
it](../README.md#the-link-dont-restate-rule)), or a trap that costs an
afternoon to rediscover. Anything longer is usually two comments, or a
paragraph that belongs in `docs/technical/` with a link from here. Keep it
prose — cutting a paragraph into a list of fragments is not the same as making
it short.

---

*See also: [naming.md](naming.md) · [errors.md](errors.md) · [testing.md](testing.md)*

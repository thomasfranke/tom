# Staying current

When a document becomes searchable.

**Status:** Shipped · Milestone M2

## Rules

- **A document saved in TOM is searchable immediately.**
- One changed outside TOM is picked up when it is saved here, or when the space is opened again.

Nothing watches the folder. The index does not outlive the session, so it
cannot go stale — which is what makes the absence of a watcher a decision
rather than a gap ([runtime/search.md](../../../../technical/runtime/search.md)).

---

*See also: [full-text-search/](../README.md) · [what-is-searched/](../what-is-searched/doc.md)*

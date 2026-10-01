# The message

Every commit carries one, and the box is not taken away lightly.

**Status:** Planned · Milestone M1

## Rules

- **A commit requires a message.** Committing with nothing staged is disabled.
- **Committing on a detached `HEAD` is refused**, and the refusal says so where it was asked for. Git itself would allow it, onto no branch, and the commit would be reachable from nothing the moment `HEAD` moved — which is the one outcome this product promises never happens.
- The refusal is the app's policy, not git's answer, so it costs no round trip: the branch is already on the session from the last reading.
- **The message box is never taken away**, not because git is working and not because a push stands refused. Working on something else is not a reason to interrupt a sentence, and the refusal is a band above the document — the column it would have replaced is where the next commit is written.
- **A merge in progress fills the box rather than emptying it**, with the message git already wrote, editable like any other: concluding a merge is a commit ([when a pull conflicts](../../push-pull/when-a-pull-conflicts/doc.md)).

---

*See also: [commit/](../README.md) · [confirming/](../confirming/doc.md) · [when a push fails](../../push-pull/when-it-fails/doc.md)*

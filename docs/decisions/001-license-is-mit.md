# Decision 1 — License is MIT

**Status:** accepted

## Decision
The core ships under MIT, with a closed paid edition on top — the standard open-core shape for developer tools. Contributors sign a CLA ([CLA.md](../../CLA.md)) granting the project the right to relicense contributed code — including, in the future, under non-MIT terms.

## Rationale
Maximize adoption and trust; allow a closed paid edition on top; avoid AGPL contamination.

The CLA is **not** what makes the paid edition possible. MIT already permits building proprietary software on top of MIT code: a closed module composed with this app at build time ([Decision 12](012-shell-is-extensible-via-compile-time-modules.md)) needs no one's permission, and no contribution has to be signed over for that to be legal.

What the CLA preserves is a different and narrower option: relicensing the **public core itself**. That option is held deliberately. It is stated here, plainly, rather than left to be discovered later — because being discovered later is precisely what does the damage. Comparable open-core projects have changed terms without much backlash; the ones that were punished were the ones whose change contradicted something they had published.

## What is promised, and what is not

- **Promised:** every release published under MIT stays MIT, irrevocably. MIT grants are perpetual and carry no revocation clause. Whatever ships free can be forked, maintained and distributed by anyone, forever, with no permission from this project.
- **Not promised:** that *future* releases will be MIT. If the license ever changes, it changes going forward only.

The fork is therefore **not a threat to be contained — it is the community's guaranteed exit.** It is what makes this position honest rather than a trap: anyone who dislikes a future license change keeps working software under free terms, not a consolation prize. Terraform → OpenTofu and Redis → Valkey are what that exit looks like in practice.

Public communication must never promise "MIT forever" or imply permanence of license. The damage in these situations comes from contradicting a public promise, not from the change itself — so the discipline here is to say only what the project can stand behind, and to say it warmly rather than defensively.

## Consequences
- **No AGPL/GPL dependency in the core** (this rules out `appflowy_editor`).
- Every new dependency goes through a license check (PR checklist item).
- The CLA and its bot must be in place **before the first external PR**. A contribution merged without a signature is MIT-only and permanently blocks relicensing of that code, short of retroactive consent or removing it.
- A renamed commercial fork is possible by design; the countermeasures are trademark, the closed pro edition, speed and community — never license terms.

## Revisit when
Changing the license is a live option, not a contingency — it is the reason the CLA exists. It would be considered if the open-core boundary proves unsustainable. It would **not** be considered as a response to a fork: the countermeasures there are the ones named above, and a project that answers a fork by changing its terms has confirmed every suspicion the fork was based on. Two rules hold if it ever happens: it is announced before it ships, never retroactively, and the standing rule from [Decision 4](004-business-model-is-open-core.md) survives it — the free/paid boundary may move toward free, never away.

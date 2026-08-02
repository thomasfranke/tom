# Decision 1 — License is MIT

**Status:** accepted

## Decision
The core ships under MIT, with a closed paid edition on top — the standard open-core shape for developer tools. Contributors sign a CLA ([CLA.md](../../CLA.md)) granting the project the right to relicense contributed code — including, in the future, under non-MIT terms.

## Rationale
Maximize adoption and trust; allow a closed paid edition on top; avoid AGPL contamination.

The CLA is **not** what makes the paid edition possible. MIT already permits building proprietary software on top of MIT code — which is exactly what [Decision 12](012-paid-edition-ships-as-compile-time-module.md) does, with `tom_pro` depending on the public package and compiling into one binary. No contribution needs to be signed over for that to be legal.

What the CLA preserves is a different and narrower option: relicensing the **public core itself**. That option is held deliberately. It is stated here, plainly, rather than left to be discovered later — because being discovered later is precisely what caused the damage in the prior art ([Decision 4](004-business-model-is-open-core.md)).

## What is promised, and what is not

- **Promised:** every release published under MIT stays MIT, irrevocably. MIT grants are perpetual and carry no revocation clause. Whatever ships free can be forked, maintained and distributed by anyone, forever, with no permission from this project.
- **Not promised:** that *future* releases will be MIT. If the license ever changes, it changes going forward only.

The fork is therefore **not a threat to be contained — it is the community's guaranteed exit.** It is what makes this position honest rather than a trap: anyone who dislikes a future license change keeps working software under free terms, not a consolation prize. Terraform → OpenTofu and Redis → Valkey are what that exit looks like in practice.

Public communication must never promise "MIT forever" or imply permanence of license. In the prior art, the damage came from contradicting a public promise rather than from the change itself — so the discipline here is to say only what the project can stand behind, and to say it warmly rather than defensively.

## Consequences
- **No AGPL/GPL dependency in the core** (this rules out `appflowy_editor`).
- Every new dependency goes through a license check (PR checklist item).
- The CLA and its bot must be in place **before the first external PR**. A contribution merged without a signature is MIT-only and permanently blocks relicensing of that code, short of retroactive consent or removing it.
- A renamed commercial fork is possible by design; the countermeasures are trademark, the closed pro edition, speed and community — never license terms.

## Revisit when
Changing the license is a live option, not a contingency — it is the reason the CLA exists. It would be considered if a commercial fork causes real damage, or if the open-core boundary proves unsustainable. Two rules hold if it ever happens: it is announced before it ships, never retroactively, and the standing rule from [Decision 4](004-business-model-is-open-core.md) survives it — the free/paid boundary may move toward free, never away.

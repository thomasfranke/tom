# Decision 4 — The business model is open-core

**Status:** accepted as a *plan*, not as a commitment

> ## ⚠️ Nothing here exists yet
>
> **No paid edition is available. No feature listed as Team or Enterprise has been built. No pricing has been set, announced or promised.** This document records the intended direction so that today's architecture does not foreclose it — nothing more.
>
> The commercial edition is gated: it is only built once there are real signals of team demand, and the whole free tier ships first. Until then:
>
> - The app is **entirely free and MIT**, with no capped version and no trial.
> - Every feature currently implemented is, and remains, free.
> - Prices, tier boundaries and timing are **all subject to change** — this plan may be revised or abandoned outright.
> - **Nothing in this document is a promise to anyone.** Promises are made on the website and in release notes, never in a planning file — and the one promise this project does make is the standing rule below: the free/paid boundary may move toward free, never away from it.

## Golden rule
Individuals never pay; organizations pay for convenience and governance.

## The three tiers

| Tier | Audience | Model | Delivery |
|---|---|---|---|
| **Free** | Everyone — individuals, open source projects, small teams | MIT, forever | Community build or the official build with no key |
| **Team** | Organizations, self-service | Subscription per seat / year, public pricing, card checkout | License key by email |
| **Enterprise** | Larger organizations | Negotiated subscription, invoice against PO, SLA | License key + support contract |

**Sponsors** (GitHub Sponsors) exist alongside, as *voluntary support* — never a plan, never gated behind features, and never a substitute for the free tier. An individual who sponsors gets nothing the free user does not have; they support the project because they want to.

**There is no plan aimed at individuals, and there never will be** — see the prior art below.

## Acid test for a feature to be paid
(a) whoever misses it is an **organization**, not a person; (b) charging for it does not break the individual user's core use case; (c) whoever approves the purchase has a budget and is not paying out of pocket. **If its absence would make a solo developer abandon the app → free forever, no exceptions.**

## Free tier (untouchable, publicly declared)
Everything in the MVP · the rendered diff in all its versions (v0→v2 — it is the reason to use the app) · conflict resolution · section blame, **including which PR a change came from** · **proposing a change** (branch, commit, push, and open the PR on the host) · wikilinks · in-space search · multiple open spaces · basic themes.

*Note: conflicts and blame look like "team features", but a solo developer uses both — they fail test (a).*

**Why PR attribution and proposing a change are free.** The public pitch is that the Git workflow is a first-class citizen; a version where you cannot see which PR a paragraph came from, or cannot propose an edit, would contradict that pitch — the exact failure the prior art below teaches. Both are also free *technically*: PR attribution is parsed from the merge commit in local history, and proposing a change is a push plus the host's compare URL. Neither calls a remote API, so neither crosses the module boundary. The paid line falls where the **reviewer's** work begins.

## Team tier
- **The review surface as a product:** reviewing PRs inside the app — the queue of what awaits you, inline review comments over the rendered preview, approvals, CI status. This is work a reviewer does for an organization; a solo developer with no one to review for loses nothing, so it passes test (a). *Reading* PR context and *opening* a PR stay free (see above).
- The billing boundary equals a module boundary: **layer 2, local git = free; layer 3, remote APIs = paid.** Anything that needs a GitHub/GitLab API token is on the paid side; anything derivable from the local repository is not.
- **Publishing documentation for non-technical readers** — making a space readable outside the app. The exact shape is deliberately unspecified.
- **Unified multi-space search** *(genuine grey zone: it is the first thing that should move to the free tier if it turns out solo users depend on it).*

## Enterprise tier
- **SSO/SAML and administrative policies.**
- **Enterprise integrations** (Jira embeds and the like).
- Invoicing against a PO, support SLA, migration assistance.

## Billing mechanics
Annual subscription. The delivered key is always annual, even if billing is monthly — decoupling *price*, *billing* and *key validity* is what keeps the offline model working (monthly keys would mean twelve re-activations a year per seat and would render perpetual fallback meaningless). Letting a subscription lapse freezes the covered version; it never disables what was already paid for. Mechanics: Decision 12.

## Prior art: what these migrations teach

The pattern is common enough in open-core developer tools to be studied without naming anyone. A project launches a perpetual license aimed at individuals, then later moves commercial use to a subscription. The stated reasons are always the same three: most "individual" licenses turn out to have been bought by organizations, selling to both audiences creates tax complications, and customers find a perpetual and a subscription plan coexisting confusing. The community reaction is harsh — accusations of disrespect toward lifetime buyers and, most damaging, users pointing at the contradiction with the project's own published principles. Four lessons, adopted here:

1. **Start where those migrations end up:** subscription, organizations only.
2. **Never label a plan "for individuals".** Organizations will buy it, and the mislabelling is what forces the painful correction later.
3. **Never promise "lifetime" or "perpetual" in marketing.** It is the most expensive promise to walk back. Our perpetual fallback is deliberately narrower: it does not promise the software forever, it promises *the version you paid for never dies*.
4. **Never run two models at once.** One model, one audience.

The broader lesson: what hurt was not the price — it was the perceived contradiction with a public promise. Hence the standing rule in the paid module catalogue: **the free/paid boundary may move toward free, never away from it.**

## Integration mechanics
Private repo + compile-time module + a single binary gated by a license key: Decision 12.

# Security policy

## Reporting a vulnerability

**Do not open a public issue for a security problem.**

Report it privately through [GitHub Security Advisories](../../security/advisories/new). The thread stays private between us until a fix is published, and it needs nothing beyond your GitHub account — no email, no form, no waiting for someone to hand out an address.

Please include: what the issue is, how to reproduce it, the version affected, and what an attacker could achieve. A proof of concept helps enormously.

What to expect:

| | |
|---|---|
| First response | Within 5 days |
| Assessment and plan | Within 14 days |
| Fix and disclosure | Coordinated with you; credit given unless you prefer otherwise |

TOM is maintained in spare time — these are honest targets, not an SLA. If you get no answer within a week, ping again; something went wrong.

## Supported versions

Only the most recent release receives security fixes. TOM is a desktop application with a single active version line; there is no long-term-support branch ([the release model](CONTRIBUTING.md#workflow)).

## Where the risk actually is

This section exists to point researchers at the parts that matter, rather than at the parts that look interesting.

**TOM drives the system `git` binary.** Paths, branch names, remote names and refs flow from repository contents and user input into command invocations. Arguments are passed as an argument list, never through a shell, and any value that could be read as a flag must be separated with `--`. Command injection or argument injection here would be the most serious class of bug in the project.

**TOM renders arbitrary markdown from repositories the user opens.** A malicious repository is a realistic threat: a cloned docs repo could contain markdown crafted to abuse the renderer, embedded HTML, or links and image paths pointing outside the space. Path traversal out of the space root, and anything that turns rendering into code execution or local file disclosure, is in scope.

**TOM writes files.** Document paths derive from the space tree; writes must stay inside the space root.

**What TOM deliberately does not do**, and which therefore reduces the surface: it has no telemetry ([Decision 11](docs/decisions/011-telemetry-is-opt-in.md)), no account system, no cloud sync, no runtime plugin loading, and no network access of its own — authentication and transport are entirely the system git's responsibility, using the user's own credentials and configuration ([Decision 2](docs/decisions/002-git-via-system-binary.md)).

## Out of scope

- Vulnerabilities in `git` itself, in Flutter, or in third-party packages — report those upstream (tell us too if TOM's usage makes them worse).
- Anything requiring the attacker to already have write access to the user's machine or filesystem.
- Missing hardening that is not exploitable on its own.

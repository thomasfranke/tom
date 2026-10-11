# The update check

The one request TOM makes of its own accord, and every layer it passes through. What the person sees is [`product/about/`](../../product/about/doc.md).

- **The capability is `app_updates/` in `tom_infra`** — a contract (`AppUpdates.latest()`), its failure (`AppUpdatesFailure.unreachable`) and one implementation, `http_client/DartIoHttpClientAppUpdatesImpl`, over `dart:io` `HttpClient` — no package was added for it.
- **The request is a single GET**, ten seconds to answer, carrying `User-Agent: TOM` and `Accept` and nothing else — no identifier, no version, no machine ([Decision 11](../decisions/011-telemetry-is-opt-in.md), revised).
- **The contract hands the body back verbatim**, or `null` on a 404 — GitHub's way of saying nothing is published; any other status or a silence is `unreachable`.
- **`tom_domain` reads it**: `AppVersionValueObject`, `ReleaseValueObject`, `UpdateAnswerValueObject` (no release · up to date · newer), `UpdateFailure` and the `UpdatesRepository` contract; `tom_data` fulfils it in `UpdatesRepositoryImpl`.
- **`CheckForUpdatesUseCase` compares the latest release with the running version**; `UpdatesNotifier` (keepAlive) holds the state the dialog, the gear's dot and the status bar read.
- **The notifier asks on its own unless the preference was unticked**, once, after the store is read — `checkingForUpdates` in `preferences.json`, on by default; a stored `false` is respected ([Decision 11](../decisions/011-telemetry-is-opt-in.md), revised).
- **What this build is comes from `--dart-define`s**, read in `apps/desktop/lib/about/app_build.dart`:

| Define | Holds | Default |
|---|---|---|
| `TOM_VERSION` | The release number | The pubspec's |
| `TOM_BUILD` | What it was made from | `dev` |
| `TOM_RELEASES` | Whether a first release is published; false keeps the check unavailable and the notifier at `noRelease` | false |

- **Not built:** the download, `Update and restart` and `Restart now` — what replaces the running app on each platform is undecided.

---

*See also: [runtime/](README.md) · [architecture.md](../architecture.md) · [stack/platform.md](../stack/platform.md)*

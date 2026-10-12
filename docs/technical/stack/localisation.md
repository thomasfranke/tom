# Localisation

The interface's words in more than one language — Flutter's own mechanism, nothing added ([Decision 34](../decisions/034-the-interface-is-localised-with-gen-l10n.md)).

| Package | License | Role |
|---|---|---|
| `flutter_localizations` | BSD-3 | Material's own words, and the delegates `MaterialApp` installs. Part of the SDK, so it moves with Flutter |
| `intl` | BSD-3 | The plurals and placeholders the generated `AppLocalizations` formats with. `any` in the pubspec: the version is the one `flutter_localizations` pins (0.20.2 today) |
| `flutter gen-l10n` | SDK | Generates `AppLocalizations` from the ARB files in `src/apps/desktop/lib/l10n/`, on every `pub get` |

- **Only `tom_desktop` depends on them.** `tom_ui` carries no words of its own and presentation is pure Dart ([Decision 14](../decisions/014-each-layer-is-its-own-package.md)).
- **`slang`, `easy_localization` and the like are not taken** — each is a second mechanism beside the one the SDK ships, and a dependency the SDK makes unnecessary.

---

*See also: [stack/](README.md) · [Decision 34](../decisions/034-the-interface-is-localised-with-gen-l10n.md)*

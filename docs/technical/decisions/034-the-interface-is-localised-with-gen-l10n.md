# Decision 34 — The interface is localised with Flutter's gen-l10n

**Status:** draft, on the maintainer's call of 2026-10-08 — two languages to set up the structure, English and Português (Brasil).

## Context

The language preference was a value written and read by nothing: every string the app showed was an English literal inside a widget ([what it holds](../../product/preferences/what-it-holds/doc.md)). Making it apply needs one place a string is written, and one mechanism that picks the language.

## Decision

**Every user-facing string of `tom_desktop` is a message in an ARB file, read through the `AppLocalizations` class `flutter gen-l10n` generates from them.**

- **English is the template.** `src/apps/desktop/lib/l10n/app_en.arb` is where a key is written first, with its `@` description and placeholders; `app_pt.arb` is Brazilian Portuguese. The generated class lives in `lib/l10n/generated/` and is regenerated on every `pub get` (`generate: true`).
- **One localisation, the application's.** `tom_ui` carries no user-facing words: a component takes its label, tooltip and title from the screen that draws it. A string `tom_ui` ever owns is passed in, not translated there.
- **Presentation stays pure Dart.** Nothing below the application imports Flutter's localisations; a sentence a notifier still produces in English is a follow-up for that layer, never a reason to reach up.
- **Counts and names are ICU messages**, never fragments joined in code — word order is the translation's.
- **The preference drives the locale.** `LanguageEnum` is `system`, `english`, `portuguese`; `system` hands `MaterialApp` a null locale, which follows the machine and falls back to English (`preferred-supported-locales` in `l10n.yaml`). A stored language this build does not offer reads as `system`.
- **A widget outside the app speaks English.** `context.l10n` falls back to the template when no delegate is in scope, so a widget test mounts a screen without the app's delegates and finds the same words.
- **Product words drawn on the boards stay the boards' in English**; Portuguese is the translation's own.

## Glossary (pt-BR)

| English | Português | |
|---|---|---|
| commit, push, pull, fetch, branch, merge, stage, diff, HEAD, pull request | unchanged | as Brazilian developers say them — *fazer commit*, *a branch* |
| Stage all · Unstage all | Adicionar tudo ao stage · Remover tudo do stage | |
| remote · repository · space · document | remoto · repositório · espaço · documento | |
| Source · Split · Preview | Código · Dividido · Prévia | |
| tab · explorer | aba · explorador | |
| Accept Current / Incoming / Both Changes | Aceitar Alteração Atual / de Entrada / Ambas as Alterações | VS Code's pt-BR, for the same reason the English is VS Code's |

The full list rides in `app_pt.arb` as `@@x-glossary`.

## Licence

`flutter_localizations` ships with the Flutter SDK and `intl` 0.20.2 with the Dart team's packages — both **BSD-3-Clause**, compatible with the project's MIT ([Decision 1](001-license-is-mit.md)).

## Consequences

- A new string is a new key in both ARB files; `test/l10n/arb_test.dart` fails when Portuguese misses one, because `gen-l10n` would fall back to English silently.
- `PanelDescriptor.title` is a builder, so a module localises its own titles with its own delegates ([Decision 12](012-shell-is-extensible-via-compile-time-modules.md)).
- The end-to-end robot pins the platform locale to English: its finders are the template's words, and `System` would follow the developer's machine.
- A third language is one ARB file and one `LanguageEnum` member, never one without the other.

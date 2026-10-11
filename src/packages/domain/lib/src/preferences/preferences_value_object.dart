/// What the machine remembers about how the app looks and speaks.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/preferences/git_approval_mode_enum.dart';
import 'package:tom_domain/src/preferences/language_enum.dart';
import 'package:tom_domain/src/preferences/theme_choice_enum.dart';

part 'preferences_value_object.freezed.dart';

/// The preferences — how the app looks and speaks, and who approves git —
/// and nothing else.
///
/// **A preference belongs to the machine, not to the space**: opening
/// another folder changes none of these, and anything that should differ per
/// space is not a preference (`docs/product/preferences/what-it-holds/doc.md`).
///
/// Every field has a default, because **a missing file, a missing key or an
/// unreadable value is the default, silently** — losing the store loses a
/// choice, never the app.
@freezed
abstract class PreferencesValueObject with _$PreferencesValueObject {
  /// A set of preferences.
  const factory PreferencesValueObject({
    /// Which theme the window draws; the platform's until somebody chooses.
    @Default(ThemeChoiceEnum.system) ThemeChoiceEnum theme,

    /// Which language the app speaks; the machine's until somebody chooses.
    @Default(LanguageEnum.system) LanguageEnum language,

    /// Whether the row above the document carries its seventeen buttons.
    ///
    /// The row itself stays either way, because it is also where the view is
    /// chosen; what this hides is the tools
    /// (`docs/product/editor/formatting-shortcuts/doc.md`).
    @Default(true) bool showingFormattingBar,

    /// Who says yes before git and `gh` run; nobody, until somebody chooses
    /// (`docs/product/git-workflow/approvals/doc.md`).
    @Default(GitApprovalModeEnum.automatic) GitApprovalModeEnum gitApprovals,

    /// Whether opening the app asks GitHub for a newer release; on until
    /// somebody unticks it, and a stored `false` keeps the choice
    /// (`docs/product/about/doc.md`).
    @Default(true) bool checkingForUpdates,
  }) = _PreferencesValueObject;

  const PreferencesValueObject._();

  /// What a machine that has never been asked holds.
  static const PreferencesValueObject defaults = PreferencesValueObject();
}

/// What the account button and its popover draw.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'account_state.freezed.dart';

/// The open space's account summary, and whether it is being read.
@freezed
abstract class AccountState with _$AccountState {
  /// A state; nothing is known until the first reading lands.
  const factory AccountState({
    /// The last summary read, kept while the next one is read.
    AccountSummaryValueObject? summary,

    /// What git said before the first [summary]: who commits and the
    /// project, nothing about GitHub yet.
    AccountSummaryValueObject? local,

    /// Whether a reading is out.
    @Default(false) bool isReading,
  }) = _AccountState;

  const AccountState._();

  /// The best summary there is: the last whole one, else git's half.
  AccountSummaryValueObject? get known => summary ?? local;

  /// Whether the popover is still asking who the person is on GitHub —
  /// only before the first answer, so a later reading never flickers back.
  bool get isAsking => isReading && summary == null;

  /// What the button wears: the first and last initials of `user.name`, else
  /// the first letter of the GitHub login — or null with neither, when the
  /// button draws the outline of a person
  /// (`docs/product/workspace/the-account/doc.md`).
  String? get initials {
    final List<String> words = (known?.identity.name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      final String? login = known?.chosen?.login;
      return login == null ? null : _first(login).toUpperCase();
    }
    final String last = words.length > 1 ? _first(words.last) : '';
    return '${_first(words.first)}$last'.toUpperCase();
  }

  /// [word]'s first code point, so an accented or astral letter is whole.
  static String _first(String word) => String.fromCharCode(word.runes.first);
}

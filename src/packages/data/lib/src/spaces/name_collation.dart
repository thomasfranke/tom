/// The order names are listed in, whatever their case and their accents.
library;

/// What each accented Latin letter is filed under, lower case.
///
/// A table rather than Unicode normalisation, which Dart's core does not
/// carry: Latin-1 and Latin Extended-A, the letters a document's name is
/// written with in the languages this interface speaks and their neighbours.
const Map<String, String> _folded = <String, String>{
  'àáâãäåāăą': 'a',
  'çćĉċč': 'c',
  'ďđ': 'd',
  'èéêëēĕėęě': 'e',
  'ĝğġģ': 'g',
  'ĥħ': 'h',
  'ìíîïĩīĭįı': 'i',
  'ĵ': 'j',
  'ķ': 'k',
  'ĺļľŀł': 'l',
  'ñńņňŉ': 'n',
  'òóôõöøōŏő': 'o',
  'ŕŗř': 'r',
  'śŝşš': 's',
  'ţťŧ': 't',
  'ùúûüũūŭůűų': 'u',
  'ŵ': 'w',
  'ýÿŷ': 'y',
  'źżž': 'z',
  'ß': 'ss',
  'æ': 'ae',
  'œ': 'oe',
};

/// Each accented letter on its own, to what it is filed under.
final Map<int, String> _byLetter = <int, String>{
  for (final MapEntry<String, String> entry in _folded.entries)
    for (final int letter in entry.key.runes) letter: entry.value,
};

/// [name] as it is compared: lower case, its accents taken off.
///
/// A combining mark is dropped too, so a name the disk hands back decomposed
/// files where its composed spelling does.
String collationKeyOf(String name) {
  final StringBuffer key = StringBuffer();
  for (final int rune in name.toLowerCase().runes) {
    if (rune >= 0x0300 && rune <= 0x036F) {
      continue;
    }
    key.write(_byLetter[rune] ?? String.fromCharCode(rune));
  }
  return key.toString();
}

/// Orders two names ignoring case and accents
/// (`docs/product/navigation/file-tree/order-and-shape/doc.md`).
///
/// Names that fold alike fall back to their own spelling, so the order never
/// depends on which one the disk listed first.
int compareNames(String a, String b) {
  final int folded = collationKeyOf(a).compareTo(collationKeyOf(b));
  return folded != 0 ? folded : a.compareTo(b);
}

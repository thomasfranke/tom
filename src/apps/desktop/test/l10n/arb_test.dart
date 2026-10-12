import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  /// [locale]'s ARB file, metadata included.
  Map<String, Object?> arbOf(String locale) =>
      jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, Object?>;

  /// The messages in [arb], metadata left out.
  Map<String, String> messagesOf(Map<String, Object?> arb) => <String, String>{
    for (final MapEntry<String, Object?> entry in arb.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value! as String,
  };

  test('Portuguese translates every English key, and nothing else', () {
    // `gen-l10n` falls back to English for a missing key without failing,
    // so a string added in English alone would ship untranslated unseen.
    expect(
      messagesOf(arbOf('pt')).keys.toSet(),
      messagesOf(arbOf('en')).keys.toSet(),
    );
  });

  test('a translation uses every placeholder its English declares', () {
    final Map<String, Object?> english = arbOf('en');
    final Map<String, String> portuguese = messagesOf(arbOf('pt'));
    for (final String key in messagesOf(english).keys) {
      final Object? placeholders =
          (english['@$key'] as Map<String, Object?>?)?['placeholders'];
      if (placeholders is! Map<String, Object?>) {
        continue;
      }
      final String translated = portuguese[key] ?? '';
      for (final String name in placeholders.keys) {
        expect(
          translated.contains('{$name}') || translated.contains('{$name,'),
          isTrue,
          reason: '$key does not use {$name} in Portuguese',
        );
      }
    }
  });
}

/// Tests for what `tom rules` walks and what it lets through, over small
/// trees written for each: the catalogue, the generated output no rule may
/// read, and the one class named in the naming rule's exemption.
library;

import 'dart:io';

import 'package:test/test.dart';

import '../../../tool/src/commands/rules.dart';
import '../../../tool/src/rule.dart';
import '../../../tool/src/rules/comment_rules.dart';
import '../../../tool/src/rules/naming_rules.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('tom-rules-');
  });

  tearDown(() {
    root.deleteSync(recursive: true);
  });

  /// Writes [content] at [path] under the root, folders included.
  void write(String path, String content) {
    File('${root.path}/$path')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  group('the catalogue', () {
    test('lists the rule files alphabetically, links among them', () {
      expect(catalogue.map((RuleFile entry) => entry.name), <String>[
        'comments',
        'data-layer',
        'infrastructure',
        'links',
        'naming',
      ]);
    });

    test('finds a file by its name, and nothing by another', () {
      expect(ruleFileNamed('links')?.file, 'link_rules.dart');
      expect(ruleFileNamed('nonesuch'), isNull);
    });
  });

  group('isHandWritten', () {
    test('takes a source file and a test', () {
      expect(isHandWritten('src/packages/core/lib/src/result.dart'), isTrue);
      expect(isHandWritten('src/apps/desktop/test/a_test.dart'), isTrue);
    });

    test('leaves out everything a generator wrote', () {
      for (final String path in <String>[
        'src/packages/domain/lib/src/space_entity.freezed.dart',
        'src/packages/presentation/lib/src/a_notifier.g.dart',
        'src/apps/desktop/lib/l10n/generated/app_localizations.dart',
        r'src\apps\desktop\lib\l10n\generated\app_localizations_pt.dart',
        'src/packages/core/.dart_tool/build/entrypoint/build.dart',
        'src/packages/core/coverage/report.dart',
      ]) {
        expect(isHandWritten(path), isFalse, reason: path);
      }
    });

    test('keeps the hand-written half of the l10n folder', () {
      expect(isHandWritten('src/apps/desktop/lib/l10n/l10n.dart'), isTrue);
    });
  });

  group('commentsHaveACeiling', () {
    final String header = List<String>.filled(20, '/// A line.').join('\n');

    test('objects to a long comment somebody wrote', () {
      write('src/apps/desktop/lib/l10n/l10n.dart', '$header\nclass A {}\n');

      expect(commentsHaveACeiling(root), hasLength(1));
    });

    test("does not read gen-l10n's header", () {
      write(
        'src/apps/desktop/lib/l10n/generated/app_localizations.dart',
        '$header\nclass AppLocalizations {}\n',
      );

      expect(commentsHaveACeiling(root), isEmpty);
    });
  });

  group('implementationsSaySo', () {
    test('objects to an implementation that does not say so', () {
      write(
        'src/packages/core/lib/src/command_log.dart',
        'final class SilentCommandLog implements CommandLog {}\n',
      );

      expect(
        implementationsSaySo(root).single.detail,
        contains('SilentCommandLog'),
      );
    });

    test('lets the notifier that is the port keep its name', () {
      write(
        'src/packages/presentation/lib/src/commands/commands_notifier.dart',
        'class CommandsNotifier extends _\$CommandsNotifier\n'
            '    implements CommandLog, CommandGate {}\n',
      );

      expect(implementationsSaySo(root), isEmpty);
    });

    test('exempts that one class and no other notifier', () {
      expect(fulfilsUnderItsOwnName, <String>{'CommandsNotifier'});

      write(
        'src/packages/presentation/lib/src/other/other_notifier.dart',
        'class OtherNotifier extends _\$OtherNotifier\n'
            '    implements CommandLog {}\n',
      );

      expect(implementationsSaySo(root), hasLength(1));
    });
  });
}

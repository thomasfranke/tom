import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/terminal/terminal_look.dart';
import 'package:tom_desktop/screens/terminal/terminal_sequence_filter.dart';
import 'package:xterm/xterm.dart' hide TerminalState;

/// The terminal is an ordinary one: the emulator's own palette and the
/// platform's own monospace face, nothing of the app's roles
/// (`docs/product/workspace/terminal/doc.md`).
void main() {
  group('what the emulator keeps of an escape sequence', () {
    late Terminal terminal;

    setUp(() => terminal = Terminal());

    BufferLine line() => terminal.buffer.lines[0];

    ({int type, int value}) fg(int column) {
      final int raw = line().getForeground(column);
      return (type: raw & CellColor.typeMask, value: raw & CellColor.valueMask);
    }

    test('the sixteen colours stay named, 30–37 and 90–97', () {
      terminal.write('\x1b[31mA\x1b[32mB\x1b[34mC\x1b[91mD\x1b[97mE\x1b[0m');

      expect(fg(0), (type: CellColor.named, value: 1));
      expect(fg(1), (type: CellColor.named, value: 2));
      expect(fg(2), (type: CellColor.named, value: 4));
      expect(fg(3), (type: CellColor.named, value: 9));
      expect(fg(4), (type: CellColor.named, value: 15));
    });

    test('256 colours and truecolor are the emulator\'s, not remapped', () {
      terminal.write('\x1b[38;5;196mA\x1b[38;2;10;20;30mB\x1b[0m');

      expect(fg(0), (type: CellColor.palette, value: 196));
      expect(line().getForeground(1) & CellColor.typeMask, CellColor.rgb);
      expect(line().getForeground(1) & CellColor.valueMask, 0x0A141E);
    });

    test('bold is an attribute, not a colour', () {
      terminal.write('\x1b[1mA\x1b[0mB');

      expect(line().getAttributes(0) & CellAttr.bold, CellAttr.bold);
      expect(line().getAttributes(1) & CellAttr.bold, 0);
    });

    test('box-drawing and block characters land one per cell', () {
      terminal.write('─│┌┐└┘█');

      expect(<int>[
        for (int i = 0; i < 7; i++) line().getCodePoint(i),
      ], '─│┌┐└┘█'.runes.toList());
      expect(line().getWidth(0), 1);
    });
  });

  test(
    'what a real shell prints through printf reaches the same cells',
    () async {
      // The bytes come from a real `/bin/sh`, not from a string typed here;
      // the pty itself is the plugin's and the scenario's.
      final ProcessResult printed = await Process.run('/bin/sh', <String>[
        '-c',
        r'printf "\033[32mok\033[0m \033[38;5;208mx\033[0m \342\224\214\342\224\200\342\224\220 \342\226\210"',
      ], stdoutEncoding: utf8);
      final Terminal terminal = Terminal()..write(printed.stdout as String);
      final BufferLine line = terminal.buffer.lines[0];

      expect(line.getForeground(0), CellColor.named | 2);
      expect(line.getForeground(3), CellColor.palette | 208);
      expect(<int>[
        for (int i = 5; i < 8; i++) line.getCodePoint(i),
      ], '┌─┐'.runes.toList());
      expect(line.getCodePoint(9), '█'.runes.single);
    },
    skip: Platform.isWindows ? 'a POSIX shell' : false,
  );

  group('what Claude Code writes, as it wrote it', () {
    // The start of a real session, captured from a pty at 100 columns: the
    // negotiation (`CSI > 4 m` is xterm's modifyOtherKeys, not underline),
    // then the banner with its block graphics and 24-bit colour.
    const String startup =
        '\x1b7\x1b[r\x1b8\x1b[?25h\x1b[?25l\x1b[?2004h\x1b[?2031h\x1b[?1004h'
        '\x1b[>0q\x1b[?u\x1b[c\x1b[>4m\x1b[<u\x1b[?1004l\x1b[?2031l'
        '\x1b[?2004l\x1b[?2004h\x1b[?2031h\x1b[?1004h'
        '\x1b]0;\u{2733} Claude Code\x07\x1b[?1049h\x1b[2J\x1b[H'
        '\x1b[?1000h\x1b[?1002h\x1b[?1003h\x1b[?1006h\x1b[?25l\x1b[?2026h'
        '\x1b[H\r\x1b[1B\x1b[38;2;215;119;87m \u{2590}'
        '\x1b[48;2;0;0;0m\u{259b}\u{2588}\u{2588}\u{2588}\u{259b}\u{2588}'
        '\x1b[12G\x1b[39m\x1b[49m\x1b[1mClaude Code\x1b[24G\x1b[22m'
        '\x1b[38;2;153;153;153mv2.1.287\r\x1b[1B'
        '\x1b[38;2;215;119;87m\u{259d}\u{259c}\x1b[48;2;0;0;0m'
        '\u{2588}\u{2588}\u{2588}\u{2588}\u{2588}\x1b[49m\u{2588}\u{2580}'
        '\x1b[12G\x1b[38;2;153;153;153mhigh effort\r\x1b[2B'
        '\x1b[38;2;255;193;7m\u{26a0}\x1b[3GYour login expires'
        '\x1b[38;2;136;136;136m\r\x1b[1B'
        '\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}';

    Terminal replay() =>
        Terminal()..write(TerminalSequenceFilter().filter(startup));

    test(
      'the emulator alone gets it wrong, which is why there is a filter',
      () {
        final Terminal raw = Terminal()..write('\x1b[>4mA\x1b[1mB\x1b[22mC');

        expect(
          raw.buffer.lines[0].getAttributes(0) & CellAttr.underline,
          isNot(0),
        );
        expect(raw.buffer.lines[0].getAttributes(2) & CellAttr.bold, isNot(0));
      },
    );

    group('the filter', () {
      String filtered(String input) => TerminalSequenceFilter().filter(input);

      test('drops a private-prefixed m, keeps every other sequence', () {
        expect(
          filtered('a\x1b[>4mb\x1b[?25lc\x1b[31md'),
          'ab\x1b[?25lc\x1b[31md',
        );
      });

      test('SGR 22 clears bold as well, wherever it stands', () {
        expect(filtered('\x1b[22m'), '\x1b[21;22m');
        expect(filtered('\x1b[1;22;31m'), '\x1b[1;21;22;31m');
      });

      test('a colour that contains 22 is left alone', () {
        expect(filtered('\x1b[38;2;22;22;22m'), '\x1b[38;2;22;22;22m');
        expect(filtered('\x1b[38;5;22m'), '\x1b[38;5;22m');
      });

      test('colon sub-parameters become the semicolon form', () {
        expect(filtered('\x1b[4:3m'), '\x1b[4m');
        expect(filtered('\x1b[4:0m'), '\x1b[24m');
        expect(filtered('\x1b[38:2::1:2:3m'), '\x1b[38;2;1;2;3m');
        expect(filtered('\x1b[48:2:1:2:3m'), '\x1b[48;2;1;2;3m');
        expect(filtered('\x1b[58:5:9m'), '\x1b[58;5;9m');
      });

      test('a sequence cut by the end of a chunk is joined to its rest', () {
        final TerminalSequenceFilter filter = TerminalSequenceFilter();

        final String all =
            filter.filter('x\x1b[>') +
            filter.filter('4my') +
            filter.filter('\x1b');

        expect(all, 'xy');
        expect(filter.filter('[22m'), '\x1b[21;22m');
      });
    });

    test('nothing is underlined: CSI > 4 m is not SGR 4', () {
      final Terminal terminal = replay();
      final List<int> underlined = <int>[
        for (int row = 0; row < terminal.buffer.lines.length; row++)
          for (int col = 0; col < terminal.viewWidth; col++)
            if (terminal.buffer.lines[row].getAttributes(col) &
                    CellAttr.underline !=
                0)
              row * 1000 + col,
      ];

      expect(underlined, isEmpty);
    });

    test('plain text is not bold, and bold ends at SGR 22', () {
      final Terminal terminal = replay();
      final BufferLine banner = terminal.buffer.lines[1];

      expect(banner.getAttributes(11) & CellAttr.bold, CellAttr.bold);
      expect(banner.getAttributes(24) & CellAttr.bold, 0);
    });

    test('a rule of box-drawing is one line of single cells', () {
      final Terminal terminal = replay();
      final BufferLine rule = terminal.buffer.lines[5];

      expect(rule.getCodePoint(0), 0x2500);
      expect(rule.getAttributes(0) & CellAttr.underline, 0);
    });
  });

  group('the palette', () {
    test('dark is the emulator\'s own default theme', () {
      expect(
        terminalThemeOf(Brightness.dark),
        same(TerminalThemes.defaultTheme),
      );
      expect(TerminalThemes.defaultTheme.red, const Color(0xFFCD3131));
      expect(TerminalThemes.defaultTheme.green, const Color(0xFF0DBC79));
    });

    test('light is black on white with the standard sixteen', () {
      final TerminalTheme light = terminalThemeOf(Brightness.light);

      expect(light.background, const Color(0xFFFFFFFF));
      expect(light.foreground, const Color(0xFF000000));
      expect(light.black, const Color(0xFF000000));
      expect(light.red, const Color(0xFFCD3131));
      expect(light.blue, const Color(0xFF0451A5));
      expect(light.brightWhite, const Color(0xFFA5A5A5));
    });
  });

  group('the face', () {
    test('is the platform\'s own monospace, never a vendored one', () {
      for (final TargetPlatform platform in TargetPlatform.values) {
        final TerminalStyle style = terminalStyleOf(platform);
        expect(style.fontFamily, isNot(contains('packages/')));
        expect(style.fontFamily, isNot(contains('IBMPlex')));
        expect(style.fontFamilyFallback, isNot(contains('IBMPlexMono')));
      }
    });

    test('Menlo on macOS, Consolas on Windows, monospace on Linux', () {
      expect(terminalStyleOf(TargetPlatform.macOS).fontFamily, 'Menlo');
      expect(terminalStyleOf(TargetPlatform.macOS).fontFamilyFallback, <String>[
        'Monaco',
        'Courier',
      ]);
      expect(terminalStyleOf(TargetPlatform.windows).fontFamily, 'Consolas');
      expect(terminalStyleOf(TargetPlatform.linux).fontFamily, 'monospace');
    });

    test('Menlo 12 on a line of 1.0 on macOS, as the Mac\'s Terminal sets '
        'it; 13 on Linux, 14 on Windows, on the emulator\'s own height', () {
      expect(terminalStyleOf(TargetPlatform.macOS).fontSize, 12);
      expect(terminalStyleOf(TargetPlatform.macOS).height, 1.0);
      expect(terminalStyleOf(TargetPlatform.linux).fontSize, 13);
      expect(terminalStyleOf(TargetPlatform.windows).fontSize, 14);
      expect(
        terminalStyleOf(TargetPlatform.linux).height,
        const TerminalStyle().height,
      );
    });
  });

  testWidgets('a screen of box-drawing, colour and emoji paints', (
    WidgetTester tester,
  ) async {
    final Terminal terminal = Terminal()
      ..write(
        '\x1b[31mred\x1b[0m \x1b[38;5;82mgreen\x1b[0m \x1b[1mbold\x1b[0m\r\n'
        '┌──┐ █▀▄ \u{1F600}\r\n└──┘\r\n',
      );
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 600,
          height: 200,
          child: TerminalView(
            terminal,
            theme: terminalThemeOf(Brightness.dark),
            textStyle: terminalStyleOf(TargetPlatform.macOS),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(TerminalView), findsOneWidget);
  });
}

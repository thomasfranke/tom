import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/core_module_impl.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_desktop/screens/terminal/terminal_design.dart';
import 'package:tom_desktop/screens/terminal/terminal_look.dart';
import 'package:tom_desktop/screens/terminal/terminal_panel.dart';
import 'package:tom_desktop/screens/workspace/workspace_bottom_head_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';
import 'package:xterm/xterm.dart' hide TerminalState;

/// The `Terminal` tab of the panel under the document, against the board
/// `Terminal` on `22 · Screens: Commands & Terminal` — a region 1166 wide,
/// over a shell that is a fake (`docs/product/workspace/terminal/doc.md`).
void main() {
  late _Terminals terminals;
  late ProviderContainer container;
  late List<String> heardByTheWindow;

  final SpaceEntity docs = SpaceEntity(
    root: '/Users/ana/work/app/docs',
    repositoryRoot: '/Users/ana/work/app',
    name: 'docs',
  );

  setUp(() {
    terminals = _Terminals();
    heardByTheWindow = <String>[];
    container = ProviderContainer(
      overrides: <Override>[
        startTerminalProvider.overrideWithValue(
          StartTerminalUseCase(
            terminals: terminals,
            observability: const _Silent(),
          ),
        ),
        homeFolderProvider.overrideWithValue('/Users/ana'),
      ],
    );
    addTearDown(container.dispose);
    container.read(spaceSessionProvider.notifier).open(docs);
    container.read(workspaceProvider.notifier).toggleBottom();
  });

  /// The region under the document, the way the shell draws it, under the
  /// window's own `⌘J`, `⌘K` and their `Ctrl` twins.
  Future<void> pumpRegion(
    WidgetTester tester, {
    Brightness brightness = Brightness.dark,
  }) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final PanelRegistry registry = PanelRegistry(const <TomModule>[
      CoreModuleImpl(),
    ]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                for (final String key in <String>['J', 'K'])
                  for (final bool meta in <bool>[true, false])
                    SingleActivator(
                      key == 'J'
                          ? LogicalKeyboardKey.keyJ
                          : LogicalKeyboardKey.keyK,
                      meta: meta,
                      control: !meta,
                    ): () =>
                        heardByTheWindow.add('${meta ? '⌘' : 'Ctrl+'}$key'),
              },
              child: FocusScope(
                autofocus: true,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 1166,
                    height: 260,
                    // The region as the shell's draws it: the head, then the
                    // tab chosen (`shell_region_widget.dart` is the shell's).
                    child: Consumer(
                      builder: (BuildContext context, WidgetRef ref, _) {
                        final List<PanelDescriptor> panels = registry.at(
                          PanelPlacementEnum.bottom,
                        );
                        final String? id = ref.watch(
                          workspaceProvider.select(
                            (WorkspaceState it) => it.bottomPanel,
                          ),
                        );
                        final PanelDescriptor chosen = panels.firstWhere(
                          (PanelDescriptor it) => it.id == id,
                          orElse: () => panels.first,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            WorkspaceBottomHeadWidget(
                              panels: panels,
                              chosen: chosen,
                            ),
                            Expanded(child: Builder(builder: chosen.builder)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseTheTerminal(WidgetTester tester) async {
    await tester.tap(find.text('Terminal'));
    await tester.pumpAndSettle();
  }

  Terminal emulator(WidgetTester tester) =>
      tester.widget<TerminalView>(find.byType(TerminalView)).terminal;

  String screenOf(WidgetTester tester) => <String>[
    for (int i = 0; i < emulator(tester).buffer.lines.length; i++)
      emulator(tester).buffer.lines[i].toString().trimRight(),
  ].join('\n');

  Future<void> focusTheTerminal(WidgetTester tester) async {
    await tester.tap(find.byType(TerminalView));
    // Past the emulator's double-tap window, which is a timer.
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('the head is two tabs, Commands first', (
    WidgetTester tester,
  ) async {
    await pumpRegion(tester);

    final double commands = tester.getTopLeft(find.text('Commands')).dx;
    final double terminal = tester.getTopLeft(find.text('Terminal')).dx;
    expect(commands, lessThan(terminal));
    expect(find.byType(CommandsPanel), findsOneWidget);
    expect(find.byType(TerminalPanel), findsNothing);
  });

  testWidgets('nothing starts a shell until the tab is chosen', (
    WidgetTester tester,
  ) async {
    await pumpRegion(tester);

    expect(terminals.started, isEmpty);
  });

  for (final Brightness brightness in Brightness.values) {
    testWidgets('choosing it starts the shell and names it, '
        '${brightness.name}', (WidgetTester tester) async {
      await pumpRegion(tester, brightness: brightness);
      await chooseTheTerminal(tester);
      final TomColors colors = brightness == Brightness.dark
          ? TomColors.dark
          : TomColors.light;
      final TargetPlatform platform = defaultTargetPlatform;

      expect(terminals.started.single.folder, '/Users/ana/work/app');
      expect(find.byType(CommandsPanel), findsNothing);
      expect(find.text('0 this session'), findsNothing);
      final Text place = tester.widget<Text>(find.text('zsh · ~/work/app'));
      expect(place.style?.fontSize, TerminalDesign.place);
      expect(place.style?.color, colors.textMuted);
      // The chosen tab is the one in the primary ink.
      expect(
        tester.widget<Text>(find.text('Terminal')).style?.color,
        colors.textPrimary,
      );
      expect(
        tester.widget<Text>(find.text('Commands')).style?.color,
        colors.textSecondary,
      );

      final TerminalView view = tester.widget<TerminalView>(
        find.byType(TerminalView),
      );
      // An ordinary terminal: none of the app's roles, its face or its
      // caret; only the board's air around the text.
      expect(view.theme, same(terminalThemeOf(brightness)));
      expect(view.theme.background, isNot(colors.surfaceRaised));
      expect(view.theme.foreground, isNot(colors.textPrimary));
      expect(view.theme.red, isNot(colors.removed));
      expect(view.theme.blue, isNot(colors.accent));
      expect(view.textStyle.fontFamily, terminalStyleOf(platform).fontFamily);
      expect(view.textStyle.fontFamily, isNot(startsWith('packages/')));
      expect(view.textStyle.fontSize, 13);
      expect(view.padding, TerminalDesign.padding);
    });
  }

  testWidgets('the text sits 14 in and 11 under the head, as the board draws '
      'it, and the shell is told the padded size', (WidgetTester tester) async {
    await pumpRegion(tester);
    await chooseTheTerminal(tester);

    final Rect view = tester.getRect(find.byType(TerminalView));
    // The scrollable is the area the cells are laid out in: the view less
    // the padding, so the first cell sits at its top left.
    final Rect cells = tester.getRect(
      find.descendant(
        of: find.byType(TerminalView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(cells.left - view.left, 14);
    expect(cells.top - view.top, 11);
    expect(view.right - cells.right, 14);
    expect(view.bottom - cells.bottom, 6);
    // The shell was started at the padded area's size, which holds fewer
    // cells than the view would.
    final TerminalSizeValueObject size = terminals.started.single.size;
    expect(size.columns, emulator(tester).viewWidth);
    expect(size.rows, emulator(tester).viewHeight);
    // 12 pt at a line of 1.0 is at least 12 high: a row more would not fit.
    expect(size.rows * 12, lessThanOrEqualTo(cells.height));
  });

  testWidgets('it starts at the size it is drawn at', (
    WidgetTester tester,
  ) async {
    await pumpRegion(tester);
    await chooseTheTerminal(tester);

    final TerminalSizeValueObject size = terminals.started.single.size;
    expect(size.columns, emulator(tester).viewWidth);
    expect(size.rows, emulator(tester).viewHeight);
    // Not the emulator's 80 × 24 it was built at: the panel's own.
    expect(size, isNot(const TerminalSizeValueObject(columns: 80, rows: 24)));
  });

  testWidgets('what the shell draws is on screen, and survives a switch', (
    WidgetTester tester,
  ) async {
    await pumpRegion(tester);
    await chooseTheTerminal(tester);

    terminals.started.single.draw('docs % git status\r\nOn branch main\r\n');
    await tester.pumpAndSettle();
    expect(screenOf(tester), contains('On branch main'));

    await tester.tap(find.text('Commands'));
    await tester.pumpAndSettle();
    await chooseTheTerminal(tester);

    expect(screenOf(tester), contains('On branch main'));
    expect(terminals.started, hasLength(1));
  });

  testWidgets('typing reaches the shell', (WidgetTester tester) async {
    await pumpRegion(tester);
    await chooseTheTerminal(tester);
    await focusTheTerminal(tester);

    tester.testTextInput.enterText('ls');
    await tester.pump();

    expect(terminals.started.single.typed.join(), 'ls');
  });

  testWidgets(
    'Ctrl+C, Tab and the arrows are the shell\'s',
    (WidgetTester tester) async {
      await pumpRegion(tester);
      await chooseTheTerminal(tester);
      await focusTheTerminal(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(terminals.started.single.typed, <String>['\x03', '\t', '\x1b[A']);
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.macOS,
      TargetPlatform.linux,
    }),
  );

  testWidgets(
    "on macOS every ⌘ key is the window's",
    (WidgetTester tester) async {
      await pumpRegion(tester);
      await chooseTheTerminal(tester);
      await focusTheTerminal(tester);

      for (final LogicalKeyboardKey key in <LogicalKeyboardKey>[
        LogicalKeyboardKey.keyJ,
        LogicalKeyboardKey.keyK,
      ]) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(key);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      }
      await tester.pump();

      expect(heardByTheWindow, <String>['⌘J', '⌘K']);
      expect(terminals.started.single.typed, isEmpty);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'off macOS Ctrl+J is the way out, and Ctrl+K is the shell\'s',
    (WidgetTester tester) async {
      await pumpRegion(tester);
      await chooseTheTerminal(tester);
      await focusTheTerminal(tester);

      for (final LogicalKeyboardKey key in <LogicalKeyboardKey>[
        LogicalKeyboardKey.keyJ,
        LogicalKeyboardKey.keyK,
      ]) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(key);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      }
      await tester.pump();

      expect(heardByTheWindow, <String>['Ctrl+J']);
      expect(terminals.started.single.typed, <String>['\x0b']);
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.linux,
      TargetPlatform.windows,
    }),
  );

  testWidgets('a shell that ends says so in the terminal', (
    WidgetTester tester,
  ) async {
    await pumpRegion(tester);
    await chooseTheTerminal(tester);

    terminals.started.single.end(0);
    await tester.pumpAndSettle();

    expect(
      screenOf(tester),
      contains('The shell ended with 0. Press any key for another.'),
    );
    expect(find.text('zsh · ~/work/app'), findsOneWidget);
  });

  testWidgets('a shell that would not start says so', (
    WidgetTester tester,
  ) async {
    terminals.refuse = true;
    await pumpRegion(tester);
    await chooseTheTerminal(tester);

    expect(find.text('The shell would not start.'), findsOneWidget);
    // And why, so a broken build is not mistaken for a broken machine.
    expect(find.textContaining('no pty'), findsOneWidget);
    expect(find.byType(TerminalView), findsNothing);
  });
}

final class _Terminals implements TerminalRepository {
  final List<_Session> started = <_Session>[];
  bool refuse = false;

  @override
  Future<Result<TerminalSessionPort, AppFailure>> start(
    String folder,
    TerminalSizeValueObject size,
  ) async {
    if (refuse) {
      return const Failure<TerminalSessionPort, AppFailure>(
        UnexpectedFailure('no pty'),
      );
    }
    final _Session session = _Session(folder, size);
    started.add(session);
    return Success<TerminalSessionPort, AppFailure>(session);
  }
}

final class _Session implements TerminalSessionPort {
  _Session(this.folder, this.size);

  final TerminalSizeValueObject size;
  final StreamController<String> _output = StreamController<String>();
  final Completer<int> _exit = Completer<int>();
  final List<String> typed = <String>[];

  void draw(String text) => _output.add(text);

  void end(int code) => _exit.complete(code);

  @override
  final String folder;

  @override
  String get shell => 'zsh';

  @override
  Stream<String> get output => _output.stream;

  @override
  Future<int> get exited => _exit.future;

  @override
  void write(String input) => typed.add(input);

  @override
  void resize(TerminalSizeValueObject size) {}

  @override
  void close() {}
}

final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}

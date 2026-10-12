/// The About dialog in every state the update check can be in, at the size
/// the boards draw it, in both languages, and the quiet announcements that
/// go with an update (`docs/product/about/doc.md`).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/about/about_dialog_widget.dart';
import 'package:tom_desktop/screens/about/about_icon_widget.dart';
import 'package:tom_desktop/screens/about/update_dot_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

import '../../support/load_tom_faces.dart';

void main() {
  late _Desktop desktop;
  late _Updates updates;

  setUp(() {
    desktop = _Desktop();
    updates = _Updates(const UpdatesState.noRelease());
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
    Locale? locale,
    Size size = const Size(1280, 800),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          updatesProvider.overrideWith(() => updates),
          openUrlProvider.overrideWithValue(
            OpenUrlUseCase(desktop: desktop, observability: const _Silent()),
          ),
          checkForUpdatesProvider.overrideWithValue(
            const CheckForUpdatesUseCase(
              updates: _NoUpdates(),
              observability: _Silent(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: tomTheme(brightness),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Center(child: child)),
        ),
      ),
    );
    await tester.pump();
  }

  Finder text(String s) => find.text(s);

  Finder checkButton(String label) => find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
  );

  bool isLive(WidgetTester tester, String label) =>
      tester.widget<ButtonStyleButton>(checkButton(label)).onPressed != null;

  group('what the build says about itself', () {
    testWidgets('the name, its line and the three facts', (
      WidgetTester tester,
    ) async {
      await pump(tester, const AboutDialogWidget());

      expect(text('TOM'), findsOneWidget);
      expect(text('Team-Oriented Markdown'), findsOneWidget);
      expect(text('Version'), findsOneWidget);
      expect(text('Platform'), findsOneWidget);
      expect(text('License'), findsOneWidget);
      expect(text('MIT'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AboutDialogWidget).first).width,
        greaterThan(0),
      );
    });

    testWidgets('the card is the dialog\'s 400 wide', (
      WidgetTester tester,
    ) async {
      await pump(tester, const AboutDialogWidget());

      final Finder card = find.descendant(
        of: find.byType(AboutDialogWidget),
        matching: find.byType(Container),
      );
      expect(tester.getSize(card.first).width, TomDialogWidget.width);
    });

    testWidgets('the three links open in the browser', (
      WidgetTester tester,
    ) async {
      await pump(tester, const AboutDialogWidget());

      await tester.tap(text('Source on GitHub'));
      await tester.tap(text('Licenses'));
      await tester.tap(text('Release notes'));

      expect(desktop.opened.map((Uri u) => u.host).toSet(), <String>{
        'github.com',
      });
      expect(desktop.opened, hasLength(3));
      expect(desktop.opened.last.path, endsWith('/releases'));
    });

    testWidgets('Close shuts it', (WidgetTester tester) async {
      await pump(tester, const _Opener());
      await tester.tap(text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutDialogWidget), findsOneWidget);

      await tester.tap(text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialogWidget), findsNothing);
    });

    testWidgets('Escape shuts it', (WidgetTester tester) async {
      await pump(tester, const _Opener());
      await tester.tap(text('open'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialogWidget), findsNothing);
    });

    testWidgets('a press outside shuts it', (WidgetTester tester) async {
      await pump(tester, const _Opener());
      await tester.tap(text('open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialogWidget), findsNothing);
    });
  });

  group('the six states of the check', () {
    testWidgets('no release yet: the line, and the button unavailable', (
      WidgetTester tester,
    ) async {
      await pump(tester, const AboutDialogWidget());

      expect(text('No release yet.'), findsOneWidget);
      expect(isLive(tester, 'Check for updates'), isFalse);
    });

    testWidgets('releases exist and nobody asked: the button is live', (
      WidgetTester tester,
    ) async {
      updates = _Updates(const UpdatesState.idle());
      await pump(tester, const AboutDialogWidget());

      expect(text('No release yet.'), findsNothing);
      expect(isLive(tester, 'Check for updates'), isTrue);
    });

    testWidgets('asking: a spinner, the sentence, the button waits', (
      WidgetTester tester,
    ) async {
      updates = _Updates(const UpdatesState.asking());
      await pump(tester, const AboutDialogWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(text('Asking GitHub for the latest release…'), findsOneWidget);
      expect(isLive(tester, 'Check for updates'), isFalse);
    });

    testWidgets('up to date: says so, and when, and keeps the button', (
      WidgetTester tester,
    ) async {
      updates = _Updates(UpdatesState.upToDate(DateTime(2026, 10, 10, 14, 5)));
      await pump(tester, const AboutDialogWidget());

      expect(find.textContaining('is the latest version.'), findsOneWidget);
      expect(text('Checked at 14:05.'), findsOneWidget);
      expect(isLive(tester, 'Check for updates'), isTrue);
    });

    testWidgets('a newer version: both named, a link, no update button', (
      WidgetTester tester,
    ) async {
      updates = _Updates(
        const UpdatesState.newer(
          version: '1.2.0',
          notesUrl: 'https://github.com/x/y/releases/tag/v1.2.0',
        ),
      );
      await pump(tester, const AboutDialogWidget());

      expect(find.textContaining('TOM 1.2.0 is available.'), findsOneWidget);
      await tester.tap(text("What's new"));
      expect(desktop.opened.single.path, endsWith('v1.2.0'));
      // The updater is not built: nothing offers to install.
      expect(find.textContaining('Update and restart'), findsNothing);
      expect(find.textContaining('Restart now'), findsNothing);
    });

    testWidgets('GitHub not answering: in modified, with Try again', (
      WidgetTester tester,
    ) async {
      updates = _Updates(const UpdatesState.failed());
      await pump(tester, const AboutDialogWidget());

      final Text said = tester.widget<Text>(text('GitHub did not answer.'));
      final TomColors colors = TomColors.of(
        tester.element(text('GitHub did not answer.')),
      );
      expect(said.style!.color, colors.modified);
      expect(isLive(tester, 'Try again'), isTrue);
      expect(text('Check for updates'), findsNothing);
    });

    testWidgets('pressing Check for updates asks', (WidgetTester tester) async {
      updates = _Updates(const UpdatesState.idle());
      await pump(tester, const AboutDialogWidget());

      await tester.tap(text('Check for updates'));
      await tester.pump();

      expect(updates.asked, 1);
    });

    testWidgets('and every state reads in the dark theme too', (
      WidgetTester tester,
    ) async {
      updates = _Updates(const UpdatesState.failed());
      await pump(
        tester,
        const AboutDialogWidget(),
        brightness: Brightness.dark,
      );

      expect(text('GitHub did not answer.'), findsOneWidget);
    });

    testWidgets('and in Portuguese', (WidgetTester tester) async {
      updates = _Updates(const UpdatesState.noRelease());
      await pump(
        tester,
        const AboutDialogWidget(),
        locale: const Locale('pt', 'BR'),
      );

      expect(text('Ainda não há versão publicada.'), findsOneWidget);
      expect(text('Fechar'), findsOneWidget);
    });
  });

  // The numbers of `about-updates/about-the-update-states-dark.svg`, measured
  // off a render of it: the card 400 × 432 with its top edge 24 above the
  // icon, the facts' values 120 in from the card's edge, the buttons 48 tall
  // and 56 apart.
  group('at the size the boards draw it', () {
    const Size board = Size(1440, 900);

    setUpAll(loadTomFaces);

    Future<Rect> card(WidgetTester tester) async {
      await pump(tester, const AboutDialogWidget(), size: board);
      return tester.getRect(
        find
            .descendant(
              of: find.byType(AboutDialogWidget),
              matching: find.byType(Container),
            )
            .first,
      );
    }

    testWidgets('the card is 432 tall whether or not there is a release', (
      WidgetTester tester,
    ) async {
      final Rect none = await card(tester);
      expect(none.width, 400);
      expect(none.height, closeTo(432, 0.01));

      updates = _Updates(UpdatesState.upToDate(DateTime(2026, 10, 10, 14, 5)));
      final Rect upToDate = await card(tester);
      expect(upToDate.height, closeTo(432, 0.01));
    });

    testWidgets('the mark is the brand icon, 56 square, 24 in', (
      WidgetTester tester,
    ) async {
      final Rect it = await card(tester);

      final Rect icon = tester.getRect(find.byType(AboutIconWidget));
      expect(icon.size, const Size(56, 56));
      expect(icon.left - it.left, closeTo(24, 0.01));
      expect(icon.top - it.top, closeTo(24, 0.01));
      // No teal tile with a letter in it.
      expect(find.text('T'), findsNothing);
    });

    testWidgets('the values are left-aligned at 120 from the card\'s edge', (
      WidgetTester tester,
    ) async {
      final Rect it = await card(tester);

      for (final String value in <String>['MIT', 'macOS', '0.1.0']) {
        final Finder found = find.textContaining(value);
        if (found.evaluate().isEmpty) {
          continue;
        }
        expect(tester.getTopLeft(found.first).dx - it.left, 120, reason: value);
      }
      expect(tester.getTopLeft(text('Version')).dx - it.left, 24);
      // The three rows are 24 apart.
      expect(
        tester.getTopLeft(text('Platform')).dy -
            tester.getTopLeft(text('Version')).dy,
        24,
      );
      expect(
        tester.getTopLeft(text('License')).dy -
            tester.getTopLeft(text('Platform')).dy,
        24,
      );
    });

    testWidgets('UPDATES opens the section, in the muted ink', (
      WidgetTester tester,
    ) async {
      await card(tester);

      final Text caption = tester.widget<Text>(text('UPDATES'));
      final TomColors colors = TomColors.of(tester.element(text('UPDATES')));
      expect(caption.style!.color, colors.textMuted);
      expect(
        tester.getTopLeft(text('UPDATES')).dy,
        lessThan(tester.getTopLeft(text('No release yet.')).dy),
      );
    });

    testWidgets('the buttons are 48 tall and 56 apart, 24 from the foot', (
      WidgetTester tester,
    ) async {
      updates = _Updates(UpdatesState.upToDate(DateTime(2026, 10, 10, 14, 5)));
      final Rect it = await card(tester);

      final Rect check = tester.getRect(checkButton('Check for updates'));
      final Rect close = tester.getRect(checkButton('Close'));
      expect(check.height, 48);
      expect(close.height, 48);
      expect(close.top - check.top, closeTo(56, 0.01));
      expect(check.top - it.top, closeTo(304, 0.01));
      expect(it.bottom - close.bottom, closeTo(24, 0.01));
    });

    testWidgets('Check for updates is the outlined one when it can ask', (
      WidgetTester tester,
    ) async {
      updates = _Updates(UpdatesState.upToDate(DateTime(2026, 10, 10, 14, 5)));
      await card(tester);

      expect(find.byType(FilledButton), findsNothing);
      final OutlinedButton check = tester.widget<OutlinedButton>(
        checkButton('Check for updates'),
      );
      final TomColors colors = TomColors.of(
        tester.element(find.text('Check for updates')),
      );
      expect(
        check.style!.foregroundColor!.resolve(<WidgetState>{}),
        colors.textSecondary,
      );
    });

    testWidgets('Close is text_secondary at the regular weight', (
      WidgetTester tester,
    ) async {
      await card(tester);

      final OutlinedButton close = tester.widget<OutlinedButton>(
        checkButton('Close'),
      );
      final TomColors colors = TomColors.of(tester.element(text('Close')));
      expect(
        close.style!.foregroundColor!.resolve(<WidgetState>{}),
        colors.textSecondary,
      );
      expect(
        close.style!.textStyle!.resolve(<WidgetState>{})!.fontWeight,
        FontWeight.w500,
      );
    });
  });

  group('an update found at opening', () {
    testWidgets('the gear\'s dot is there only for a newer version', (
      WidgetTester tester,
    ) async {
      await pump(tester, const Stack(children: <Widget>[UpdateDotWidget()]));
      expect(find.byKey(const Key('updateDot')), findsNothing);
    });

    testWidgets('a newer version draws the dot in accent', (
      WidgetTester tester,
    ) async {
      updates = _Updates(
        const UpdatesState.newer(version: '1.2.0', notesUrl: ''),
      );
      await pump(
        tester,
        const SizedBox.square(
          dimension: 40,
          child: Stack(children: <Widget>[UpdateDotWidget()]),
        ),
      );

      final Container dot = tester.widget<Container>(
        find.byKey(const Key('updateDot')),
      );
      final TomColors colors = TomColors.of(
        tester.element(find.byKey(const Key('updateDot'))),
      );
      expect((dot.decoration! as BoxDecoration).color, colors.accent);
    });

    testWidgets('the dot sits past the gear box\'s corner, centred 22 across '
        'and 3 down', (WidgetTester tester) async {
      updates = _Updates(
        const UpdatesState.newer(version: '1.2.0', notesUrl: ''),
      );
      await pump(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox.square(
            dimension: 24,
            child: Stack(
              key: Key('gearBox'),
              clipBehavior: Clip.none,
              children: <Widget>[UpdateDotWidget()],
            ),
          ),
        ),
        size: const Size(1440, 900),
      );

      final Rect gear = tester.getRect(find.byKey(const Key('gearBox')));
      final Rect dot = tester.getRect(find.byKey(const Key('updateDot')));
      expect(gear.size, const Size(24, 24));
      expect(dot.size, const Size(7, 7));
      expect(dot.center - gear.topLeft, const Offset(22, 3));
    });

    testWidgets('the status bar notice leads with a 6 point dot, 12 from '
        'the sentence\'s start', (WidgetTester tester) async {
      updates = _Updates(
        const UpdatesState.newer(version: '1.2.0', notesUrl: ''),
      );
      await pump(tester, const UpdateNoticeWidget());

      final Rect dot = tester.getRect(find.byKey(const Key('updateNoticeDot')));
      final TomColors colors = TomColors.of(
        tester.element(find.byKey(const Key('updateNoticeDot'))),
      );
      expect(dot.size, const Size(6, 6));
      expect(
        tester.getTopLeft(text('Update available: 1.2.0')).dx - dot.left,
        12,
      );
      expect(
        (tester
                    .widget<Container>(find.byKey(const Key('updateNoticeDot')))
                    .decoration!
                as BoxDecoration)
            .color,
        colors.accent,
      );
    });

    testWidgets('the status bar says the version, and a press opens the '
        'dialog', (WidgetTester tester) async {
      updates = _Updates(
        const UpdatesState.newer(version: '1.2.0', notesUrl: ''),
      );
      await pump(tester, const UpdateNoticeWidget());

      expect(text('Update available: 1.2.0'), findsOneWidget);
      await tester.tap(text('Update available: 1.2.0'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialogWidget), findsOneWidget);
    });

    testWidgets('no newer version, no notice', (WidgetTester tester) async {
      await pump(tester, const UpdateNoticeWidget());

      expect(find.textContaining('Update available'), findsNothing);
    });
  });
}

/// A button that opens the dialog the way the app does.
class _Opener extends StatelessWidget {
  const _Opener();

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => unawaited(AboutDialogWidget.show(context)),
    child: const Text('open'),
  );
}

/// An update check whose state is the test's, counting how often it is asked.
final class _Updates extends UpdatesNotifier {
  _Updates(this.initial);

  final UpdatesState initial;
  int asked = 0;

  @override
  UpdatesState build() => initial;

  @override
  Future<void> check() async => asked++;
}

final class _NoUpdates implements UpdatesRepository {
  const _NoUpdates();

  @override
  Future<Result<ReleaseValueObject?, UpdateFailure>> latest() async =>
      const Success<ReleaseValueObject?, UpdateFailure>(null);
}

final class _Desktop implements DesktopRepository {
  final List<Uri> opened = <Uri>[];

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async {
    opened.add(address);
    return const Success<void, AppFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

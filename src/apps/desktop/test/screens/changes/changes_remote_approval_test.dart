import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_remote_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The foot of the git column while a command waits for a yes, and after a
/// read was denied (`docs/product/git-workflow/approvals/doc.md`).
void main() {
  final SpaceEntity docs = SpaceEntity(
    root: '/code/docs',
    repositoryRoot: '/code/docs',
    name: 'docs',
  );

  final GitStatusValueObject status = GitStatusValueObject(
    branch: BranchNameValueObject('main'),
    upstream: BranchNameValueObject('origin/main'),
    ahead: 2,
    behind: 0,
    entries: const <StatusEntryValueObject>[],
    isDetached: false,
  );

  Future<ProviderContainer> pumpFoot(
    WidgetTester tester, {
    RemoteState remote = const RemoteState.idle(),
    bool isAwaiting = false,
    GitReadingState reading = const GitReadingState.ready(),
    Locale locale = const Locale('en'),
  }) async {
    final CountingReading readingNotifier = CountingReading(reading);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        remoteProvider.overrideWith(() => _Remote(remote)),
        pullRequestProvider.overrideWith(_NoPullRequest.new),
        remoteAwaitingApprovalProvider.overrideWithValue(isAwaiting),
        gitReadingProvider.overrideWith(() => readingNotifier),
      ],
    );
    addTearDown(container.dispose);
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..observe(status);
    tester.view
      ..physicalSize = const Size(600, 400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 280, child: ChangesRemoteWidget()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    readingCalls = readingNotifier;
    return container;
  }

  testWidgets('the pressed control says it waits, and the others go dim', (
    WidgetTester tester,
  ) async {
    await pumpFoot(
      tester,
      remote: const RemoteState.working(RemoteActionEnum.push),
      isAwaiting: true,
    );

    expect(find.text('Waiting for approval'), findsOneWidget);
    expect(find.text('Pushing…'), findsNothing);
    final Finder fetch = find.ancestor(
      of: find.text('Fetch'),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is ButtonStyleButton,
      ),
    );
    expect(tester.widget<ButtonStyleButton>(fetch).onPressed, isNull);
    // Nothing is on the network yet.
    expect(find.byType(TomProgressBarWidget), findsNothing);
  });

  testWidgets('once approved it is the verb in progress again', (
    WidgetTester tester,
  ) async {
    await pumpFoot(
      tester,
      remote: const RemoteState.working(RemoteActionEnum.push),
    );

    expect(find.text('Pushing…'), findsOneWidget);
    expect(find.text('Waiting for approval'), findsNothing);
  });

  testWidgets('a denied read leaves the foot saying it is out of date, with '
      'Reload beside it', (WidgetTester tester) async {
    await pumpFoot(tester, reading: const GitReadingState.stale());

    expect(find.text('Out of date: a read was denied.'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
    // It stands where where-the-branch-stands would be.
    expect(find.textContaining('ahead of origin/main'), findsNothing);
  });

  testWidgets('the denied read draws the board: no glyph, the sentence from '
      'the column edge, Reload in the accent', (WidgetTester tester) async {
    await pumpFoot(tester, reading: const GitReadingState.stale());

    // `manual-a-read-denied`: `Out of date…` in `modified`, `Reload` at the
    // medium weight in `accent` (`#178F71` in light), nothing before them.
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is TomGlyphWidget && w.glyph == TomGlyphEnum.alert,
      ),
      findsNothing,
    );
    final Text sentence = tester.widget<Text>(
      find.text('Out of date: a read was denied.'),
    );
    final Text reload = tester.widget<Text>(find.text('Reload'));
    final TomColors colors = TomColors.of(tester.element(find.text('Reload')));
    expect(reload.style!.color, colors.accent);
    expect(reload.style!.color, const Color(0xFF178F71));
    expect(reload.style!.fontWeight, FontWeight.w500);
    expect(sentence.style!.color, colors.modified);
    // The foot's own 14 of inset and nothing before the words (the glyph
    // and its gap used to push them 18 further).
    expect(
      tester.getTopLeft(find.text('Out of date: a read was denied.')).dx,
      14,
    );
  });

  testWidgets('Reload asks git again', (WidgetTester tester) async {
    await pumpFoot(tester, reading: const GitReadingState.stale());

    await tester.tap(find.text('Reload'));
    await tester.pump();

    expect(readingCalls.refreshes, 1);
  });

  testWidgets('a reading that stands says nothing of the kind', (
    WidgetTester tester,
  ) async {
    await pumpFoot(tester);

    expect(find.text('Out of date: a read was denied.'), findsNothing);
    expect(find.text('2 ahead of origin/main'), findsOneWidget);
  });

  testWidgets('in Portuguese both sentences are translated', (
    WidgetTester tester,
  ) async {
    await pumpFoot(
      tester,
      locale: const Locale('pt'),
      reading: const GitReadingState.stale(),
    );

    expect(find.text('Desatualizado: uma leitura foi negada.'), findsOneWidget);
    expect(find.text('Recarregar'), findsOneWidget);
  });
}

/// The reading the last test pumped, for the one that counts its refreshes.
late CountingReading readingCalls;

final class _NoPullRequest extends PullRequestNotifier {
  @override
  PullRequestState build() => const PullRequestState();
}

final class _Remote extends RemoteNotifier {
  _Remote(this._state);

  final RemoteState _state;

  @override
  RemoteState build() => _state;
}

/// A git reading that stands as it was given, and counts being asked again.
final class CountingReading extends GitReadingNotifier {
  /// Creates the reading, standing as [_state].
  CountingReading(this._state);

  final GitReadingState _state;

  /// How many times a reload was pressed.
  int refreshes = 0;

  @override
  GitReadingState build() => _state;

  @override
  Future<void> refresh() async => refreshes++;
}

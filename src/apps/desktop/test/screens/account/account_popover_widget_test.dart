import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/account/account_control_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_access_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_avatar_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_popover_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// An account that is only what the test says, and records what is asked.
final class _Account extends AccountNotifier {
  _Account(this.held);

  final AccountState held;
  final List<String> chosen = <String>[];
  int opened = 0;

  @override
  AccountState build() => held;

  @override
  Future<void> choose(GithubAccountValueObject account) async =>
      chosen.add(account.login);

  @override
  Future<void> openRepository() async => opened++;
}

void main() {
  final RemoteProjectValueObject docs = RemoteProjectValueObject.tryParse(
    'https://github.com/acme/docs.git',
  )!;
  const GithubAccountValueObject ada = GithubAccountValueObject(
    login: 'ada',
    source: AccountSourceEnum.gh,
  );
  const GithubAccountValueObject linus = GithubAccountValueObject(
    login: 'linus',
    source: AccountSourceEnum.ssh,
  );

  /// Nothing on the machine: git's name, a GitHub remote, nothing else.
  final AccountState signedOut = AccountState(
    summary: AccountSummaryValueObject(
      identity: const CommitIdentityValueObject(
        name: 'Ada Lovelace',
        email: 'ada@example.com',
      ),
      project: docs,
    ),
  );

  /// Two accounts, `ada` chosen and allowed to push.
  final AccountState signedIn = AccountState(
    summary: AccountSummaryValueObject(
      identity: const CommitIdentityValueObject(
        name: 'Ada Lovelace',
        email: 'ada@example.com',
      ),
      accounts: const <GithubAccountValueObject>[ada, linus],
      chosen: ada,
      project: docs,
      access: RepositoryAccessValueObject.granted(
        pull: true,
        push: true,
        admin: false,
      ),
    ),
  );

  /// The first reading out: git has answered, `gh` has not.
  final AccountState asking = AccountState(
    local: AccountSummaryValueObject(
      identity: const CommitIdentityValueObject(
        name: 'Ada Lovelace',
        email: 'ada@example.com',
      ),
      project: docs,
    ),
    isReading: true,
  );

  /// The five dashes inside the grid.
  Finder dashes() => find.descendant(
    of: find.byType(AccountAccessWidget),
    matching: find.byWidgetPredicate(
      (Widget it) => it is TomGlyphWidget && it.glyph == TomGlyphEnum.rule,
    ),
  );

  late _Account account;

  Future<void> pump(
    WidgetTester tester,
    AccountState state, {
    Brightness brightness = Brightness.light,
  }) async {
    account = _Account(state);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[accountProvider.overrideWith(() => account)],
        child: MaterialApp(
          theme: tomTheme(brightness),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.only(top: 8, right: 14),
              child: Align(
                alignment: Alignment.topRight,
                child: AccountControlWidget(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
  }

  for (final Brightness brightness in Brightness.values) {
    group('in the ${brightness.name} theme', () {
      testWidgets('while asking: the name, and nothing said about GitHub', (
        WidgetTester tester,
      ) async {
        await pump(tester, asking, brightness: brightness);
        await open(tester);
        final TomColors colors = TomColors.of(
          tester.element(find.byType(AccountPopoverWidget)),
        );

        expect(find.text('Ada Lovelace'), findsOneWidget);
        expect(find.text('ada@example.com'), findsOneWidget);
        final Text line = tester.widget<Text>(
          find.text('Asking git and gh who you are…'),
        );
        expect(line.style?.fontSize, 12.5);
        expect(line.style?.fontWeight, FontWeight.w400);
        expect(line.style?.color, colors.textMuted);
        expect(find.textContaining('No GitHub credentials'), findsNothing);
        expect(find.textContaining('gh auth login'), findsNothing);
        expect(find.text('github.com/acme/docs'), findsOneWidget);
        expect(dashes(), findsNWidgets(5));
        final Text pending = tester.widget<Text>(
          find.text('Known once the answer is in.'),
        );
        expect(pending.style?.fontSize, 11.5);
        expect(pending.style?.color, colors.textMuted);
        expect(find.textContaining('shows once'), findsNothing);
      });

      testWidgets('while asking, the button wears the initials', (
        WidgetTester tester,
      ) async {
        await pump(tester, asking, brightness: brightness);

        expect(find.text('AL'), findsOneWidget);
      });

      testWidgets('without credentials: the name, and nothing known here', (
        WidgetTester tester,
      ) async {
        await pump(tester, signedOut, brightness: brightness);
        await open(tester);

        expect(find.text('COMMITS AS'), findsOneWidget);
        expect(find.text('Ada Lovelace'), findsOneWidget);
        expect(find.text('ada@example.com'), findsOneWidget);
        expect(
          find.text('No GitHub credentials on this computer'),
          findsOneWidget,
        );
        expect(find.text('github.com/acme/docs'), findsOneWidget);
        // Every column a dash, never a "no".
        expect(
          find.descendant(
            of: find.byType(AccountAccessWidget),
            matching: find.byWidgetPredicate(
              (Widget it) =>
                  it is TomGlyphWidget && it.glyph == TomGlyphEnum.rule,
            ),
          ),
          findsNWidgets(5),
        );
        expect(
          find.text(
            'What you can do here shows once git or gh can reach GitHub.',
          ),
          findsOneWidget,
        );
        expect(find.text('Your role'), findsNothing);
      });

      testWidgets('with an account: the login, its tool, and the columns', (
        WidgetTester tester,
      ) async {
        await pump(tester, signedIn, brightness: brightness);
        await open(tester);

        expect(find.text('@ada'), findsOneWidget);
        expect(find.text('via gh'), findsOneWidget);
        expect(
          find.text(
            "This computer's GitHub login, through gh — TOM keeps no copy.",
          ),
          findsOneWidget,
        );
        final Finder ticks = find.descendant(
          of: find.byType(AccountAccessWidget),
          matching: find.byWidgetPredicate(
            (Widget it) =>
                it is TomGlyphWidget && it.glyph == TomGlyphEnum.check,
          ),
        );
        // Read, PR, push and merge; not admin.
        expect(ticks, findsNWidgets(4));
        expect(
          tester.widget<TomGlyphWidget>(ticks.first).color,
          TomColors.of(tester.element(find.byType(AccountPopoverWidget))).added,
        );
        expect(find.textContaining('shows once'), findsNothing);
      });

      testWidgets('the menu lists the accounts, the chosen one ticked', (
        WidgetTester tester,
      ) async {
        await pump(tester, signedIn, brightness: brightness);
        await open(tester);

        await tester.tap(find.text('@ada'));
        await tester.pumpAndSettle();

        expect(find.text('@ada'), findsNWidgets(2));
        expect(find.text('@linus'), findsOneWidget);
        expect(find.text('via SSH'), findsOneWidget);
        // Nothing but the accounts: setting one up is not TOM's business.
        expect(find.textContaining('gh auth login'), findsNothing);

        await tester.tap(find.text('@linus'));
        await tester.pumpAndSettle();

        expect(account.chosen, <String>['linus']);
        expect(find.text('@linus'), findsNothing);
        expect(find.byType(AccountPopoverWidget), findsOneWidget);
      });
    });
  }

  testWidgets('before git answers, nothing says the name is not set', (
    WidgetTester tester,
  ) async {
    await pump(tester, const AccountState(isReading: true));
    await open(tester);

    expect(find.text('Not set'), findsNothing);
    expect(find.textContaining('git asks for'), findsNothing);
    expect(find.text('Asking git and gh who you are…'), findsOneWidget);
  });

  testWidgets('a later reading keeps the last answer, never asks again', (
    WidgetTester tester,
  ) async {
    await pump(tester, signedIn.copyWith(isReading: true));
    await open(tester);

    expect(find.text('@ada'), findsOneWidget);
    expect(find.text('Asking git and gh who you are…'), findsNothing);
    expect(find.text('Known once the answer is in.'), findsNothing);
  });

  testWidgets('it asks in Portuguese', (WidgetTester tester) async {
    account = _Account(asking);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[accountProvider.overrideWith(() => account)],
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: const Scaffold(body: Center(child: AccountPopoverWidget())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Perguntando ao git e ao gh quem você é…'),
      findsOneWidget,
    );
    expect(find.text('Aparece assim que a resposta chegar.'), findsOneWidget);
  });

  testWidgets('the popover hangs from the button, 280 wide, 6 under it', (
    WidgetTester tester,
  ) async {
    await pump(tester, signedOut);
    await open(tester);

    final Rect button = tester.getRect(find.byTooltip('Account'));
    final Rect popover = tester.getRect(find.byType(AccountPopoverWidget));

    expect(button, const Rect.fromLTWH(1402, 8, 24, 24));
    expect(popover.left, 1148);
    expect(popover.top, 38);
    expect(popover.width, 280);
  });

  testWidgets('the button wears a ring while open, and closes as it opened', (
    WidgetTester tester,
  ) async {
    await pump(tester, signedOut);

    /// The colour of the ring around the button.
    Color ring() {
      final Container circle = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AccountControlWidget),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration decoration = circle.decoration! as BoxDecoration;
      return (decoration.border! as Border).top.color;
    }

    expect(ring(), Colors.transparent);
    await open(tester);
    expect(
      ring(),
      TomColors.of(tester.element(find.byType(AccountControlWidget))).accent,
    );

    await open(tester);
    expect(find.byType(AccountPopoverWidget), findsNothing);
  });

  testWidgets("the button wears git's initials", (WidgetTester tester) async {
    await pump(tester, signedOut);

    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('with nobody named, the button is a person', (
    WidgetTester tester,
  ) async {
    await pump(tester, const AccountState());
    expect(
      tester
          .widget<AccountAvatarWidget>(find.byType(AccountAvatarWidget))
          .initials,
      isNull,
    );
    expect(
      find.byWidgetPredicate(
        (Widget it) => it is TomGlyphWidget && it.glyph == TomGlyphEnum.person,
      ),
      findsOneWidget,
    );
  });

  testWidgets('git without a name says so, and why it matters', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      const AccountState(
        summary: AccountSummaryValueObject(
          identity: CommitIdentityValueObject(),
        ),
      ),
    );
    await open(tester);

    expect(find.text('Not set'), findsOneWidget);
    expect(find.text('git asks for a name and an email first'), findsOneWidget);
    // No remote on GitHub: no repository section, nothing about permissions.
    expect(find.text('THIS REPOSITORY'), findsNothing);
    expect(find.byType(AccountAccessWidget), findsNothing);
  });

  testWidgets('an SSH login says what SSH cannot say', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      AccountState(
        summary: AccountSummaryValueObject(
          identity: const CommitIdentityValueObject(name: 'Linus'),
          accounts: const <GithubAccountValueObject>[linus],
          chosen: linus,
          project: docs,
        ),
      ),
    );
    await open(tester);

    expect(
      find.text(
        "This computer's GitHub login, through SSH — TOM keeps no copy.",
      ),
      findsOneWidget,
    );
    expect(
      find.text('SSH says who you are, not what you can do here.'),
      findsOneWidget,
    );
  });

  testWidgets('the repository name opens its page', (
    WidgetTester tester,
  ) async {
    await pump(tester, signedOut);
    await open(tester);

    await tester.tap(find.text('github.com/acme/docs'));
    await tester.pumpAndSettle();

    expect(account.opened, 1);
  });

  testWidgets('it speaks Portuguese', (WidgetTester tester) async {
    account = _Account(signedOut);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[accountProvider.overrideWith(() => account)],
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: const Scaffold(body: Center(child: AccountPopoverWidget())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FAZ COMMIT COMO'), findsOneWidget);
    expect(find.text('ESTE REPOSITÓRIO'), findsOneWidget);
  });
}

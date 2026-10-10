/// What opens under the account button: who commits, the GitHub account,
/// and what it may do in this repository.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/account/account_design.dart';
import 'package:tom_desktop/screens/account/widgets/account_access_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_select_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The account popover (`docs/product/workspace/the-account/doc.md`).
///
/// **It shows and never edits**: the identity is git's and the login the
/// machine's tools', so the only choice in it is which of those logins this
/// repository is used with. The repository's section is drawn only for a
/// remote on GitHub — a grid about a host it does not describe would be a
/// claim about nothing.
class AccountPopoverWidget extends ConsumerWidget {
  /// Creates the popover.
  const AccountPopoverWidget({this.tapGroup, super.key});

  /// The tap region the popover closes outside of, which the account menu
  /// joins: it opens in the overlay too.
  final Object? tapGroup;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object?>('tapGroup', tapGroup));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (AccountSummaryValueObject? summary, bool isAsking) = ref.watch(
      accountProvider.select(
        (AccountState state) => (state.known, state.isAsking),
      ),
    );
    final TomColors colors = TomColors.of(context);
    final RemoteProjectValueObject? project = summary?.project;
    return SizedBox(
      width: AccountDesign.width,
      // The same card and shadow as the preferences popover: a surface that
      // leaves the page says so (`design/components/controls.md`).
      child: Material(
        color: colors.surfaceRaised,
        elevation: 8,
        borderRadius: BorderRadius.circular(AccountDesign.radius),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AccountDesign.radius),
          ),
          child: Padding(
            // The card's inset, less the stroke Flutter draws inside it.
            padding: const EdgeInsets.symmetric(
              vertical: AccountDesign.inset - 1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _SectionWidget(
                  caption: context.l10n.accountCommitsAs,
                  // Git answers at once; a line held empty until it does,
                  // never `Not set` for an identity nobody has read yet.
                  child: summary == null && isAsking
                      ? const SizedBox(height: AccountDesign.line)
                      : _IdentityWidget(
                          identity:
                              summary?.identity ??
                              const CommitIdentityValueObject(),
                        ),
                ),
                const _RuleWidget(),
                _SectionWidget(
                  caption: context.l10n.accountGithub,
                  child: isAsking
                      ? AccountLineWidget(
                          context.l10n.accountAsking,
                          size: AccountDesign.text,
                          color: colors.textMuted,
                        )
                      : _GithubWidget(summary: summary, tapGroup: tapGroup),
                ),
                if (project != null) ...<Widget>[
                  const _RuleWidget(),
                  _SectionWidget(
                    caption: context.l10n.accountThisRepository,
                    child: _RepositoryWidget(
                      project: project,
                      access: summary?.access,
                      source: summary?.chosen?.source,
                      isAsking: isAsking,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A caption and what it heads, inside the card's side inset.
class _SectionWidget extends StatelessWidget {
  const _SectionWidget({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('caption', caption));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AccountDesign.inset - 1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          caption,
          style: TextStyle(
            fontSize: AccountDesign.caption,
            height: 1.2,
            letterSpacing: AccountDesign.captionSpacing,
            fontWeight: FontWeight.w600,
            color: TomColors.of(context).textMuted,
          ),
        ),
        const SizedBox(height: AccountDesign.captionToContent),
        child,
      ],
    ),
  );
}

/// The full-width rule between two sections.
class _RuleWidget extends StatelessWidget {
  const _RuleWidget();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AccountDesign.ruleGap),
    child: Divider(height: 1, color: TomColors.of(context).border),
  );
}

/// `user.name` over `user.email`, or the reason git will not commit yet.
class _IdentityWidget extends StatelessWidget {
  const _IdentityWidget({required this.identity});

  final CommitIdentityValueObject identity;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<CommitIdentityValueObject>('identity', identity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final String? name = identity.name;
    final String? email = identity.email;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AccountLineWidget(
          name ?? context.l10n.accountNameNotSet,
          size: AccountDesign.text,
          weight: name == null ? FontWeight.w400 : FontWeight.w500,
          color: name == null ? colors.textSecondary : colors.textPrimary,
        ),
        if (email != null)
          AccountLineWidget(
            email,
            size: AccountDesign.text,
            color: colors.textSecondary,
          ),
        if (identity.isIncomplete)
          AccountLineWidget(
            context.l10n.accountIdentityMissing,
            size: AccountDesign.text,
            color: colors.textMuted,
          ),
      ],
    );
  }
}

/// The account in use and the way to choose another, or what to do about
/// having none.
class _GithubWidget extends ConsumerWidget {
  const _GithubWidget({required this.summary, required this.tapGroup});

  final AccountSummaryValueObject? summary;
  final Object? tapGroup;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<AccountSummaryValueObject?>('summary', summary))
      ..add(DiagnosticsProperty<Object?>('tapGroup', tapGroup));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final GithubAccountValueObject? chosen = summary?.chosen;
    if (chosen == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AccountLineWidget(
            l10n.accountNoCredentials,
            size: AccountDesign.text,
            color: colors.textSecondary,
          ),
          const SizedBox(height: 2),
          AccountLineWidget(
            l10n.accountNoCredentialsHint,
            size: AccountDesign.small,
            color: colors.textMuted,
            wraps: true,
          ),
        ],
      );
    }
    final AccountNotifier notifier = ref.read(accountProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AccountSelectWidget(
          accounts: summary?.accounts ?? const <GithubAccountValueObject>[],
          chosen: chosen,
          tapGroup: tapGroup,
          onChoose: (GithubAccountValueObject account) =>
              unawaited(notifier.choose(account)),
        ),
        const SizedBox(height: AccountDesign.selectToNote),
        AccountLineWidget(
          switch (chosen.source) {
            AccountSourceEnum.gh => l10n.accountLoginViaGh,
            AccountSourceEnum.git => l10n.accountLoginViaGit,
            AccountSourceEnum.ssh => l10n.accountLoginViaSsh,
          },
          size: AccountDesign.small,
          color: colors.textMuted,
          wraps: true,
        ),
        // The section ends 16 under the caption, which the rule's own 14
        // tops up from.
        const SizedBox(
          height: AccountDesign.noteToRule - AccountDesign.ruleGap,
        ),
      ],
    );
  }
}

/// The repository's name, which opens it, and the grid of what the account
/// may do in it.
class _RepositoryWidget extends ConsumerWidget {
  const _RepositoryWidget({
    required this.project,
    required this.access,
    required this.source,
    required this.isAsking,
  });

  final RemoteProjectValueObject project;
  final RepositoryAccessValueObject? access;
  final AccountSourceEnum? source;

  /// Whether the first answer is still out, so the dashes are pending
  /// rather than unknown.
  final bool isAsking;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<RemoteProjectValueObject>('project', project))
      ..add(DiagnosticsProperty<RepositoryAccessValueObject?>('access', access))
      ..add(EnumProperty<AccountSourceEnum?>('source', source))
      ..add(DiagnosticsProperty<bool>('isAsking', isAsking));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: l10n.accountOpenRepository,
            child: InkWell(
              onTap: () => unawaited(
                ref.read(accountProvider.notifier).openRepository(),
              ),
              child: SizedBox(
                height: AccountDesign.line,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: AccountLineWidget(
                        project.label,
                        size: AccountDesign.text,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AccountDesign.externalGap),
                    TomGlyphWidget(
                      glyph: TomGlyphEnum.external,
                      color: colors.textSecondary,
                      size: AccountDesign.external,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AccountDesign.linkToGrid - AccountDesign.line),
        AccountAccessWidget(access: access),
        if (access == null) ...<Widget>[
          const SizedBox(height: AccountDesign.gridToNote),
          AccountLineWidget(
            isAsking
                ? l10n.accountAccessPending
                : source == AccountSourceEnum.ssh
                ? l10n.accountAccessSsh
                : l10n.accountAccessUnknown,
            size: AccountDesign.small,
            color: colors.textMuted,
            wraps: true,
          ),
        ],
      ],
    );
  }
}

/// One line of the popover's text, at the popover's pitch.
class AccountLineWidget extends StatelessWidget {
  /// Creates a line saying [text].
  const AccountLineWidget(
    this.text, {
    required this.size,
    required this.color,
    this.weight = FontWeight.w400,
    this.wraps = false,
    super.key,
  });

  /// What it says.
  final String text;

  /// Its size.
  final double size;

  /// Its ink.
  final Color color;

  /// Its weight.
  final FontWeight weight;

  /// Whether it wraps at the content's width, or is cut on one line.
  final bool wraps;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(DoubleProperty('size', size))
      ..add(ColorProperty('color', color))
      ..add(DiagnosticsProperty<FontWeight>('weight', weight))
      ..add(DiagnosticsProperty<bool>('wraps', wraps));
  }

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: wraps ? null : 1,
    softWrap: wraps,
    overflow: wraps ? TextOverflow.clip : TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: size,
      height: (wraps ? 16 : AccountDesign.line) / size,
      fontWeight: weight,
      color: color,
    ),
  );
}

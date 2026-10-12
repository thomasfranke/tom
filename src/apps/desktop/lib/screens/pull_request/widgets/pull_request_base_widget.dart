/// The base the pull request is proposed onto, and the menu that moves it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The branch glyph, the base's name and a chevron, in the field box the
/// branch switch draws; pressed, a menu of the branches it can move to
/// (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
class PullRequestBaseWidget extends ConsumerStatefulWidget {
  /// Creates the control for [base].
  const PullRequestBaseWidget({required this.base, super.key});

  /// What the pull request is proposed onto now.
  final BranchNameValueObject base;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('base', base.value));
  }

  @override
  ConsumerState<PullRequestBaseWidget> createState() =>
      _PullRequestBaseWidgetState();
}

class _PullRequestBaseWidgetState extends ConsumerState<PullRequestBaseWidget> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  /// Shared by the control and the menu, so a second press closes it.
  final Object _group = Object();

  void _dismiss() {
    if (_portal.isShowing) {
      setState(_portal.hide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final List<BranchNameValueObject> bases = ref.watch(
      pullRequestProvider.select((PullRequestState state) => state.bases),
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          CompositedTransformTarget(
            link: _link,
            child: OverlayPortal(
              controller: _portal,
              overlayChildBuilder: (BuildContext context) => Positioned(
                width: constraints.maxWidth,
                child: CompositedTransformFollower(
                  link: _link,
                  targetAnchor: Alignment.bottomLeft,
                  offset: const Offset(0, 4),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TomMenuWidget(
                      width: constraints.maxWidth,
                      onDismissed: _dismiss,
                      tapRegionGroupId: _group,
                      groups: <List<TomMenuEntry>>[
                        <TomMenuEntry>[
                          for (final BranchNameValueObject base in bases)
                            TomMenuEntry(
                              glyph: TomGlyphEnum.branch,
                              label: base.value,
                              onSelected: () => ref
                                  .read(pullRequestProvider.notifier)
                                  .chooseBase(base),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              child: TapRegion(
                groupId: _group,
                child: TomFieldBoxWidget(
                  height: PullRequestDesign.selectHeight,
                  fill: colors.surfaceSunken,
                  radius: ChangesDesign.radius,
                  isFocused: _portal.isShowing,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: bases.length < 2
                          ? null
                          : () => setState(_portal.toggle),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: <Widget>[
                            TomGlyphWidget(
                              glyph: TomGlyphEnum.branch,
                              color: colors.accent,
                              size: PullRequestDesign.glyph,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.base.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            TomGlyphWidget(
                              glyph: TomGlyphEnum.chevronDown,
                              color: colors.textMuted,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

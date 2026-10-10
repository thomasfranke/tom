/// One wikilink in the preview's prose, drawn by what it points at.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `[[target]]` as its label, in the role of its answer
/// (`docs/product/wikilinks/doc.md`, board `editor-links-export/wikilinks`).
///
/// Resolved is `accent` and opens on a click; missing is `removed` and,
/// pointed at, offers to create the document; ambiguous is `modified` with
/// the count raised after it, and lists its candidates when pressed. Not
/// known yet is plain prose, never red.
class PreviewWikilinkWidget extends ConsumerStatefulWidget {
  /// Creates the link [link], set in the prose's own [style].
  const PreviewWikilinkWidget({
    required this.link,
    required this.style,
    super.key,
  });

  /// What was written between the brackets.
  final WikilinkValueObject link;

  /// The prose around it, which the link keeps but for its ink.
  final TextStyle style;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<WikilinkValueObject>('link', link))
      ..add(DiagnosticsProperty<TextStyle>('style', style));
  }

  /// The folder and the name a missing [link] is created as, written in
  /// [origin]; null when the path it names cannot be one.
  ///
  /// A path is created where it says; a bare name beside the document the
  /// link is written in, which is where the `+` would put it.
  static (SpaceRelativePathValueObject?, String)? whereToCreate(
    WikilinkValueObject link,
    SpaceRelativePathValueObject? origin,
  ) {
    final String target = link.target;
    final int slash = target.lastIndexOf('/');
    if (slash >= 0) {
      final String folder = target.substring(0, slash);
      final SpaceRelativePathValueObject? path = folder.isEmpty
          ? null
          : SpaceRelativePathValueObject.tryParse(folder);
      if (folder.isNotEmpty && path == null) {
        return null;
      }
      return (path, target.substring(slash + 1));
    }
    final String? open = origin?.value;
    if (open == null || !open.contains('/')) {
      return (null, target);
    }
    return (
      SpaceRelativePathValueObject(open.substring(0, open.lastIndexOf('/'))),
      target,
    );
  }

  /// The folder a candidate sits in, relative to the space root — the
  /// space's own [spaceName] when it sits at the root.
  static String folderOf(
    SpaceRelativePathValueObject candidate,
    String spaceName,
  ) {
    final int slash = candidate.value.lastIndexOf('/');
    return slash < 0 ? spaceName : candidate.value.substring(0, slash);
  }

  /// [count] in superscript digits, as the board writes `²`.
  static String superscript(int count) => <String>[
    for (final String digit in '$count'.split(''))
      '⁰¹²³⁴⁵⁶⁷⁸⁹'[int.parse(digit)],
  ].join();

  @override
  ConsumerState<PreviewWikilinkWidget> createState() =>
      _PreviewWikilinkWidgetState();
}

class _PreviewWikilinkWidgetState extends ConsumerState<PreviewWikilinkWidget> {
  final OverlayPortalController _tip = OverlayPortalController();
  final LayerLink _anchor = LayerLink();

  /// The menu an ambiguous link opens, and the link it is measured from.
  final OverlayPortalController _candidates = OverlayPortalController();
  final GlobalKey _ambiguousLink = GlobalKey();

  /// The tip's way out, delayed so the pointer can cross the gap to it.
  Timer? _hiding;

  @override
  void dispose() {
    _hiding?.cancel();
    super.dispose();
  }

  void _showTip() {
    _hiding?.cancel();
    if (!_tip.isShowing) {
      setState(_tip.show);
    }
  }

  void _hideTipSoon() {
    _hiding?.cancel();
    _hiding = Timer(PreviewDesign.tipLinger, () {
      if (mounted && _tip.isShowing) {
        setState(_tip.hide);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final WikilinkTargetValueObject? target = ref.watch(
      previewLinksProvider.select(
        (PreviewLinksState links) => links.targetOf(widget.link),
      ),
    );
    final TomColors colors = TomColors.of(context);
    final String label = widget.link.shownAs;
    return switch (target) {
      null => Text(label, style: widget.style),
      WikilinkResolved() => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () =>
              ref.read(previewLinksProvider.notifier).follow(widget.link),
          child: Text(label, style: _underlined(colors.accent)),
        ),
      ),
      WikilinkMissing() => _missing(label, colors),
      WikilinkAmbiguous(
        candidates: final List<SpaceRelativePathValueObject> candidates,
      ) =>
        _ambiguous(label, candidates, colors),
    };
  }

  /// The ambiguous link, and the menu of its candidates it opens when
  /// pressed — a question to whoever follows it, never a guess.
  Widget _ambiguous(
    String label,
    List<SpaceRelativePathValueObject> candidates,
    TomColors colors,
  ) => OverlayPortal(
    controller: _candidates,
    overlayChildBuilder: (BuildContext context) => _menu(candidates),
    // One group with the menu, so pressing the link while it is open
    // closes it rather than closing and reopening it.
    child: TapRegion(
      groupId: _candidates,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(
            _candidates.isShowing ? _candidates.hide : _candidates.show,
          ),
          child: Text.rich(
            key: _ambiguousLink,
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: label, style: _underlined(colors.modified)),
                // The board's own glyph, at the prose's size and unlined: a
                // number of candidates is not part of the link's words.
                TextSpan(
                  text: PreviewWikilinkWidget.superscript(candidates.length),
                  style: widget.style.copyWith(color: colors.modified),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  /// The candidates, hung from the link's left edge just under its line.
  ///
  /// Placed by measuring the link rather than by a follower: a menu inside
  /// a `CompositedTransformFollower` cannot compute its paint transform.
  Widget _menu(List<SpaceRelativePathValueObject> candidates) {
    final RenderObject? link = _ambiguousLink.currentContext
        ?.findRenderObject();
    final RenderObject? overlay = Overlay.of(
      context,
    ).context.findRenderObject();
    if (link is! RenderBox || !link.hasSize || overlay is! RenderBox) {
      return const SizedBox.shrink();
    }
    final Offset at = link.localToGlobal(Offset.zero, ancestor: overlay);
    // The board measures from the words' own box, set at 1.2, not from the
    // prose's taller line.
    final double words =
        (widget.style.fontSize ?? PreviewDesign.body) *
        PreviewDesign.candidatesLine;
    final String space = ref.read(spaceSessionProvider)?.space.name ?? '';
    void hide() {
      if (mounted && _candidates.isShowing) {
        setState(_candidates.hide);
      }
    }

    return Positioned(
      left: at.dx,
      top:
          at.dy + (link.size.height + words) / 2 + PreviewDesign.candidatesDrop,
      child: TomMenuWidget(
        width: PreviewDesign.candidatesWidth,
        tapRegionGroupId: _candidates,
        onDismissed: hide,
        groups: <List<TomMenuEntry>>[
          <TomMenuEntry>[
            for (final SpaceRelativePathValueObject candidate in candidates)
              TomMenuEntry(
                glyph: TomGlyphEnum.file,
                label: candidate.name,
                detail: PreviewWikilinkWidget.folderOf(candidate, space),
                onSelected: () => ref
                    .read(previewLinksProvider.notifier)
                    .choose(widget.link, candidate),
              ),
          ],
        ],
      ),
    );
  }

  /// The link in [ink], underlined over whatever the prose already carries.
  TextStyle _underlined(Color ink) => widget.style.copyWith(
    color: ink,
    decorationColor: ink,
    decoration: TextDecoration.combine(<TextDecoration>[
      TextDecoration.underline,
      ?widget.style.decoration,
    ]),
  );

  /// The missing link, and the tip it raises when pointed at or clicked.
  Widget _missing(String label, TomColors colors) => CompositedTransformTarget(
    link: _anchor,
    child: OverlayPortal(
      controller: _tip,
      overlayChildBuilder: (BuildContext context) => Positioned(
        child: CompositedTransformFollower(
          link: _anchor,
          targetAnchor: Alignment.bottomLeft,
          offset: const Offset(-PreviewDesign.tipInset, PreviewDesign.tipDrop),
          child: Align(
            alignment: Alignment.topLeft,
            child: MouseRegion(
              onEnter: (_) => _hiding?.cancel(),
              onExit: (_) => _hideTipSoon(),
              child: PreviewWikilinkTipWidget(
                target: widget.link.target,
                onCreate: _create,
              ),
            ),
          ),
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _showTip(),
        onExit: (_) => _hideTipSoon(),
        child: GestureDetector(
          onTap: _showTip,
          child: Text(label, style: _underlined(colors.removed)),
        ),
      ),
    ),
  );

  /// Creates the document the link names, the way the `+` does, and opens
  /// it.
  Future<void> _create() async {
    final (SpaceRelativePathValueObject?, String)? where =
        PreviewWikilinkWidget.whereToCreate(
          widget.link,
          ref.read(spaceSessionProvider)?.openDocument,
        );
    if (where == null) {
      return;
    }
    setState(_tip.hide);
    await ref
        .read(fileTreeProvider.notifier)
        .createDocument(where.$1, where.$2);
  }
}

/// The tip under a missing link: what is wrong, and the way to fix it.
class PreviewWikilinkTipWidget extends StatelessWidget {
  /// Creates the tip for [target], calling [onCreate] on `Create it`.
  const PreviewWikilinkTipWidget({
    required this.target,
    required this.onCreate,
    super.key,
  });

  /// What the link names.
  final String target;

  /// What `Create it` does.
  final VoidCallback onCreate;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('target', target))
      ..add(ObjectFlagProperty<VoidCallback>.has('onCreate', onCreate));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    TextStyle words(Color ink, FontWeight weight) => TextStyle(
      fontFamily: TomFonts.sans,
      fontSize: PreviewDesign.tipText,
      height: 1,
      fontWeight: weight,
      color: ink,
    );
    // A material of its own: the overlay is under none.
    return Material(
      type: MaterialType.transparency,
      child: IntrinsicWidth(
        child: Container(
          height: PreviewDesign.tipHeight,
          constraints: const BoxConstraints(minWidth: PreviewDesign.tipWidth),
          padding: const EdgeInsets.symmetric(horizontal: PreviewDesign.tipPad),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(PreviewDesign.tipRadius),
            border: Border.all(color: colors.borderStrong),
          ),
          child: Row(
            children: <Widget>[
              Text(
                context.l10n.previewNoDocumentCalled(target),
                style: words(colors.textSecondary, FontWeight.w400),
              ),
              const SizedBox(width: PreviewDesign.tipPad),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onCreate,
                  child: Text(
                    context.l10n.previewCreateIt,
                    style: words(colors.accent, FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

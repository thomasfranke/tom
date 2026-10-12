/// Where the preview's wikilinks go, and going there.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/file_tree/file_tree_notifier.dart';
import 'package:tom_presentation/src/file_tree/file_tree_state.dart';
import 'package:tom_presentation/src/preview/preview_anchor_notifier.dart';
import 'package:tom_presentation/src/preview/preview_links_state.dart';
import 'package:tom_presentation/src/preview/preview_notifier.dart';
import 'package:tom_presentation/src/preview/preview_state.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'preview_links_notifier.g.dart';

/// The preview's wikilinks resolved against the file tree's listing
/// ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
///
/// Beside the preview rather than inside it, so only a surface that draws
/// links makes the tree exist: the listing is the tree's walk, read once per
/// space and again whenever TOM writes a file, never a second walk of its own.
@riverpod
class PreviewLinksNotifier extends _$PreviewLinksNotifier {
  /// Turns a link and the listing into a target.
  static const WikilinkResolverService resolver = WikilinkResolverService();

  @override
  PreviewLinksState build() {
    // The links of the whole parse, not of the conflict's sides: a marker is
    // a line of text, so both sides are already inside that parse.
    // The document's own path too, which is what `[[#heading]]` points at.
    final (SpaceRelativePathValueObject?, List<WikilinkValueObject>) drawn = ref
        .watch(
          previewProvider.select(
            (PreviewState preview) => switch (preview) {
              PreviewReady(
                document: final ParsedDocumentValueObject document,
              ) =>
                (document.document.path, document.wikilinks),
              _ => (null, const <WikilinkValueObject>[]),
            },
          ),
        );
    final (
      SpaceRelativePathValueObject? origin,
      List<WikilinkValueObject> links,
    ) = drawn;
    final List<SpaceEntryValueObject>? entries = ref.watch(
      fileTreeProvider.select(
        (FileTreeState tree) => switch (tree) {
          FileTreeReady(entries: final List<SpaceEntryValueObject> entries) =>
            entries,
          _ => null,
        },
      ),
    );
    if (entries == null || links.isEmpty) {
      return const PreviewLinksState();
    }
    return PreviewLinksState(
      targets: Map<WikilinkValueObject, WikilinkTargetValueObject>.unmodifiable(
        <WikilinkValueObject, WikilinkTargetValueObject>{
          for (final WikilinkValueObject link in links)
            link: resolver.resolve(link, entries, origin: origin),
        },
      ),
    );
  }

  /// Opens the document [link] resolves to, at its anchor's heading when it
  /// has one; nothing for a link that is missing, ambiguous, or not answered
  /// yet.
  ///
  /// The heading is looked for once that document is drawn, which is why
  /// the anchor is handed on rather than resolved here. `[[#heading]]` opens
  /// nothing: its document is already the one on screen, and showing it
  /// again would leave a version or a pull request being read.
  void follow(WikilinkValueObject link) {
    final SpaceRelativePathValueObject? destination = state
        .targetOf(link)
        ?.destination;
    if (destination == null) {
      return;
    }
    if (!link.isWithinDocument) {
      ref.read(spaceSessionProvider.notifier).show(destination);
    }
    if (link.anchor case final String anchor) {
      ref.read(previewAnchorProvider.notifier).request(destination, anchor);
    }
  }

  /// Opens [candidate], the document somebody chose among those an
  /// ambiguous [link] could mean; nothing when [link] does not offer it.
  void choose(
    WikilinkValueObject link,
    SpaceRelativePathValueObject candidate,
  ) {
    if (state.targetOf(link) case WikilinkAmbiguous(
      candidates: final List<SpaceRelativePathValueObject> candidates,
    ) when candidates.contains(candidate)) {
      ref.read(spaceSessionProvider.notifier).show(candidate);
    }
  }
}

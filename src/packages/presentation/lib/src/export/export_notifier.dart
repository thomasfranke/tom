/// Writes a tab's document out as PDF or HTML, and says where it went.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_providers.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/editor/held_buffers_notifier.dart';
import 'package:tom_presentation/src/export/export_providers.dart';
import 'package:tom_presentation/src/export/export_state.dart';
import 'package:tom_presentation/src/file_tree/file_tree_providers.dart';
import 'package:tom_presentation/src/preview/preview_providers.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'export_notifier.g.dart';

/// The export the tab's menu asked for (`docs/product/export/doc.md`).
///
/// **What is exported is the buffer, not the file**: the preview renders the
/// buffer, and the export is the preview's rendering. Kept alive because the
/// menu that starts it is gone before the file is written; emptied when
/// another document opens, which is the next thing happening.
@Riverpod(keepAlive: true)
class ExportNotifier extends _$ExportNotifier {
  @override
  ExportState build() {
    ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => (session?.space, session?.openDocument),
      ),
    );
    return const ExportState.idle();
  }

  /// Writes [path]'s document as [format] at [destination], the absolute
  /// path the save dialog answered.
  Future<void> export(
    SpaceRelativePathValueObject path,
    ExportFormatEnum format,
    String destination,
  ) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null) {
      return;
    }
    // Read before the first await: the menu that called this is gone by then.
    final ReadDocumentUseCase reading = ref.read(readDocumentProvider);
    final SplitDocumentUseCase splitting = ref.read(splitDocumentProvider);
    final ExportDocumentUseCase exporting = ref.read(exportDocumentProvider);
    final String? buffer = _bufferOf(path);
    state = ExportState.working(format: format, destination: destination);

    final DocumentEntity document;
    if (buffer != null) {
      document = DocumentEntity(path: path, content: buffer);
    } else {
      switch (await reading.read(space, path)) {
        case Failure<DocumentEntity, AppFailure>(:final AppFailure failure):
          return _fail(format, destination, failure);
        case Success<DocumentEntity, AppFailure>(:final DocumentEntity value):
          document = value;
      }
    }
    if (!ref.mounted) {
      return;
    }
    final ParsedDocumentValueObject parsed;
    switch (await splitting.split(document)) {
      case Failure<ParsedDocumentValueObject, AppFailure>(
        :final AppFailure failure,
      ):
        return _fail(format, destination, failure);
      case Success<ParsedDocumentValueObject, AppFailure>(
        :final ParsedDocumentValueObject value,
      ):
        parsed = value;
    }
    if (!ref.mounted) {
      return;
    }
    switch (await exporting.export(space, parsed, format, destination)) {
      case Failure<void, AppFailure>(:final AppFailure failure):
        return _fail(format, destination, failure);
      case Success<void, AppFailure>():
        if (ref.mounted) {
          state = ExportState.exported(
            format: format,
            destination: destination,
          );
        }
    }
  }

  /// Shows the folder the last export landed in, in the platform's file
  /// manager — the band's `Reveal`.
  Future<void> reveal() async {
    if (state case ExportExported(:final String destination)) {
      await ref.read(revealFolderProvider).reveal(folderOf(destination));
    }
  }

  /// Puts the band away.
  void dismiss() => state = const ExportState.idle();

  /// The folder [destination] is in, cut on either platform's separator.
  static String folderOf(String destination) {
    final int cut = destination.lastIndexOf(RegExp(r'[/\\]'));
    if (cut < 0) {
      return destination;
    }
    // At the root the folder is the separator itself.
    return destination.substring(0, cut == 0 ? 1 : cut);
  }

  /// The text a tab holds that the disk may not: the buffer on screen, or
  /// the one held for a tab that is not; null when only the disk has it.
  String? _bufferOf(SpaceRelativePathValueObject path) {
    final DocumentTab tab = DocumentTab.inSpace(path);
    if (ref.read(editorProvider) case final EditorReady open
        when open.tab == tab && !open.isDraft) {
      return open.source;
    }
    if (ref.read(heldBuffersProvider)[tab] case final EditorReady held) {
      return held.source;
    }
    return null;
  }

  void _fail(ExportFormatEnum format, String destination, AppFailure failure) {
    if (ref.mounted) {
      state = ExportState.failed(
        format: format,
        destination: destination,
        failure: failure,
      );
    }
  }
}

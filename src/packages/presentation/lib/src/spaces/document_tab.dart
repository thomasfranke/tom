/// What a tab names: a file of the space, of the repository, or the app's
/// preferences file.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'document_tab.freezed.dart';

/// One tab of the strip, told apart by where its path is relative to.
///
/// Cases and not one path, because `README.md` beside the space and
/// `README.md` inside it are two files, and an extension type cannot tell
/// them apart at runtime (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
@freezed
sealed class DocumentTab with _$DocumentTab {
  /// A file of the open space: a document the tree lists, or a changed file
  /// of any kind the changes list opened.
  const factory DocumentTab.inSpace(SpaceRelativePathValueObject path) =
      SpaceDocumentTab;

  /// A changed file of the repository outside the space, which only the
  /// changes list names; read and written through
  /// [SpaceEntity.repositorySpace].
  const factory DocumentTab.outside(RepoRelativePathValueObject path) =
      OutsideDocumentTab;

  /// The app's preferences file, its path relative to the app's own folder
  /// — a case of its own, since a space may hold a file by the same name.
  const factory DocumentTab.preferences(SpaceRelativePathValueObject path) =
      PreferencesDocumentTab;

  const DocumentTab._();

  /// The tab git's [path] opens in: the space's own when the space holds it,
  /// the repository's otherwise.
  static DocumentTab of(SpaceEntity space, RepoRelativePathValueObject path) =>
      switch (space.toSpaceRelative(path)) {
        final SpaceRelativePathValueObject inside => DocumentTab.inSpace(
          inside,
        ),
        null => DocumentTab.outside(path),
      };

  /// The path as written, relative to the space, the repository or the
  /// app's folder.
  String get value => switch (this) {
    SpaceDocumentTab(:final SpaceRelativePathValueObject path) ||
    PreferencesDocumentTab(
      :final SpaceRelativePathValueObject path,
    ) => path.value,
    OutsideDocumentTab(:final RepoRelativePathValueObject path) => path.value,
  };

  /// The file's name, which is what the tab says.
  String get name => value.split('/').last;

  /// What kind of file the tab holds, by its extension.
  FileKindEnum get kind => FileKindEnum.of(value);

  /// The path inside the frame [space] or its repository gives it: what the
  /// document use cases take. Null for the preferences file, which is in
  /// neither.
  ({SpaceEntity space, SpaceRelativePathValueObject path})? addressIn(
    SpaceEntity space,
  ) => switch (this) {
    SpaceDocumentTab(:final SpaceRelativePathValueObject path) => (
      space: space,
      path: path,
    ),
    OutsideDocumentTab(:final RepoRelativePathValueObject path) =>
      switch (space.repositorySpace) {
        final SpaceEntity whole => (
          space: whole,
          path: SpaceRelativePathValueObject(path.value),
        ),
        null => null,
      },
    PreferencesDocumentTab() => null,
  };
}

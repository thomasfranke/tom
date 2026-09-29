/// Which of the two things the box is asking about.
library;

/// The space's documents, or the one on screen.
///
/// Two scopes rather than two boxes, chosen by a control that is always
/// visible: which one is answering is said, never guessed from where the
/// cursor is (`docs/product/search/README.md`).
enum SearchScopeEnum {
  /// The buffer of the open document, as it is right now.
  thisFile,

  /// Every markdown file in the space, as the index has it.
  wholeSpace,
}

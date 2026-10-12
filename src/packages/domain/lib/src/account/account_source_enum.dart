/// Which of the machine's own tools a GitHub login was read from.
library;

/// Where an account came from — what the popover says after the login
/// (`docs/product/workspace/the-account/doc.md`).
enum AccountSourceEnum {
  /// The GitHub CLI, which holds a token per account.
  gh,

  /// Git's credential helper, which holds a token for HTTPS.
  git,

  /// An SSH key GitHub greets by name, which carries no token.
  ssh;

  /// Whether a login from here can ask GitHub what it may do — through
  /// `gh`, so only when `gh` is installed: SSH says who somebody is and
  /// nothing else.
  bool get holdsToken => this != ssh;
}

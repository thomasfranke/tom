/// The hosts a pull request can be opened on.
library;

/// A host the app recognises from a remote's address, and calls by name.
///
/// A remote that is none of these draws no action at all
/// (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
enum RemoteHostEnum {
  /// `github.com`.
  github(label: 'GitHub', domain: 'github.com'),

  /// `gitlab.com`.
  gitlab(label: 'GitLab', domain: 'gitlab.com'),

  /// `bitbucket.org`.
  bitbucket(label: 'Bitbucket', domain: 'bitbucket.org');

  const RemoteHostEnum({required this.label, required this.domain});

  /// The name a control says: `Open on GitHub instead`.
  final String label;

  /// The host part of every address it serves.
  final String domain;
}

/// A repository on a host the app recognises, read off a remote's address.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';
import 'package:tom_domain/src/pull_request/remote_host_enum.dart';

part 'remote_project_value_object.freezed.dart';

/// Which host, and which project on it: `github.com` and `owner/repo`.
///
/// The table of hosts is a domain rule (Decision 33); what it buys is the
/// host's own compare page, which is the way to open a pull request until
/// the app holds a token
/// (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
@freezed
abstract class RemoteProjectValueObject with _$RemoteProjectValueObject {
  /// A project.
  const factory RemoteProjectValueObject({
    /// Where it lives.
    required RemoteHostEnum host,

    /// Its path on [host], without `.git`: `owner/repo`, or `group/sub/repo`
    /// on GitLab.
    required String path,
  }) = _RemoteProjectValueObject;

  const RemoteProjectValueObject._();

  /// [address] as a project, or null when it names no host in
  /// [RemoteHostEnum] — HTTPS, `ssh://` and the `git@host:path` shorthand
  /// alike.
  static RemoteProjectValueObject? tryParse(String address) {
    final RegExpMatch? match = _address.firstMatch(address.trim());
    if (match == null) {
      return null;
    }
    // Two names because a pattern may not repeat one: the URL form's host
    // and the shorthand's.
    final String domain =
        (match.namedGroup('host') ?? match.namedGroup('host2')!).toLowerCase();
    final String path = match.namedGroup('path')!;
    for (final RemoteHostEnum host in RemoteHostEnum.values) {
      if (host.domain == domain && path.contains('/')) {
        return RemoteProjectValueObject(host: host, path: path);
      }
    }
    return null;
  }

  /// The project as the host writes it, without a scheme:
  /// `github.com/owner/repo`.
  String get label => '${host.domain}/$path';

  /// The project's own page on the host.
  Uri get page => Uri.https(host.domain, '/$path');

  /// The longest description a compare link carries, **encoded**.
  ///
  /// Browsers and hosts refuse an address much past eight thousand
  /// characters, and one CJK character encodes to nine; measured after
  /// encoding, a longer description stays in the draft, to be pasted.
  static const int bodyBudget = 6000;

  /// The host's page for proposing [head] onto [base], filled with [title]
  /// and [body] where the host reads them from the address.
  Uri compare({
    required BranchNameValueObject base,
    required BranchNameValueObject head,
    String title = '',
    String body = '',
  }) {
    final String? description =
        Uri.encodeQueryComponent(body).length <= bodyBudget ? body : null;
    return switch (host) {
      RemoteHostEnum.github => Uri.https(
        host.domain,
        '/$path/compare/${base.value}...${head.value}',
        <String, String>{
          'expand': '1',
          if (title.isNotEmpty) 'title': title,
          if (description != null && description.isNotEmpty)
            'body': description,
        },
      ),
      RemoteHostEnum.gitlab =>
        Uri.https(host.domain, '/$path/-/merge_requests/new', <String, String>{
          'merge_request[source_branch]': head.value,
          'merge_request[target_branch]': base.value,
          if (title.isNotEmpty) 'merge_request[title]': title,
          if (description != null && description.isNotEmpty)
            'merge_request[description]': description,
        }),
      // Bitbucket reads the two branches from the address and nothing else.
      RemoteHostEnum.bitbucket => Uri.https(
        host.domain,
        '/$path/pull-requests/new',
        <String, String>{'source': head.value, 'dest': base.value},
      ),
    };
  }

  /// `https://[user@]host[:port]/path[.git]`, `ssh://[user@]host[:port]/path`
  /// and `[user@]host:path`, with the host and the path named.
  static final RegExp _address = RegExp(
    r'^(?:(?:https?|ssh|git)://(?:[^@/]+@)?(?<host>[^/:]+)(?::\d+)?/'
    r'|(?:[^@/]+@)?(?<host2>[^/:]+):)'
    r'(?<path>[^?#]+?)(?:\.git)?/?$',
  );
}

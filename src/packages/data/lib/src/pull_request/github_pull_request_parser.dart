/// Reading what `gh` answers about pull requests.
library;

import 'dart:convert';

import 'package:tom_domain/tom_domain.dart';

/// Turns `gh pr list --json number,url,title` and the address `gh pr
/// create` prints into pull requests.
///
/// Total, like every parser here: an entry it cannot read is skipped, and
/// an answer it cannot read is none.
final class GithubPullRequestParser {
  /// Creates the parser.
  const GithubPullRequestParser();

  /// Every entry of [json] that carries a number, an address and a title.
  List<OpenedPullRequestValueObject> openPullRequests(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return const <OpenedPullRequestValueObject>[];
    }
    if (decoded is! List<Object?>) {
      return const <OpenedPullRequestValueObject>[];
    }
    return List<OpenedPullRequestValueObject>.unmodifiable(
      <OpenedPullRequestValueObject>[
        for (final Object? entry in decoded)
          if (entry case <String, Object?>{
            'number': final int number,
            'url': final String url,
            'title': final String title,
          } when Uri.tryParse(url) != null)
            OpenedPullRequestValueObject(
              number: number,
              address: Uri.parse(url),
              title: title,
            ),
      ],
    );
  }

  /// The pull request at [address] — `…/pull/123` — titled [title], or null
  /// when [address] names none.
  OpenedPullRequestValueObject? created(String address, String title) {
    final Uri? page = Uri.tryParse(address.trim());
    final int? number = int.tryParse(
      _number.firstMatch(page?.path ?? '')?.group(1) ?? '',
    );
    if (page == null || number == null) {
      return null;
    }
    return OpenedPullRequestValueObject(
      number: number,
      address: page,
      title: title,
    );
  }

  /// A pull request's path ends in `/pull/<number>`.
  static final RegExp _number = RegExp(r'/pull/(\d+)/?$');
}

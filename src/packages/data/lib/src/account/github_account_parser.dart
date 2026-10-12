/// Reading what `gh`, git, `ssh` and GitHub answer about an account.
library;

import 'dart:convert';

import 'package:tom_domain/tom_domain.dart';

/// Turns each tool's text into logins, a token, or access.
///
/// Total, like every parser here: what it cannot read is nothing, never a
/// throw — a `gh` that changed its report costs the accounts it lists, not
/// the popover.
final class GithubAccountParser {
  /// Creates the parser.
  const GithubAccountParser();

  /// The logins of `gh auth status` for [host], the active one first —
  /// its JSON, or the text report of a `gh` too old for `--json`.
  List<String> ghLogins(String report, String host) {
    final Object? decoded = _json(report);
    if (decoded is Map<String, Object?>) {
      final Object? hosts = decoded['hosts'];
      final Object? entries = hosts is Map<String, Object?>
          ? hosts[host]
          : null;
      if (entries is! List<Object?>) {
        return const <String>[];
      }
      final List<Map<String, Object?>> accounts = entries
          .whereType<Map<String, Object?>>()
          .where((Map<String, Object?> it) => it['login'] is String)
          .toList();
      bool active(Map<String, Object?> it) => it['active'] == true;
      return <String>{
        for (final Map<String, Object?> it in accounts.where(active))
          it['login']! as String,
        for (final Map<String, Object?> it in accounts) it['login']! as String,
      }.toList();
    }
    final RegExp line = RegExp(
      'Logged in to ${RegExp.escape(host)} (?:account|as) ([A-Za-z0-9-]+)',
    );
    return <String>{
      for (final RegExpMatch match in line.allMatches(report)) match.group(1)!,
    }.toList();
  }

  /// The `password` of a `git credential fill` answer — for GitHub, a
  /// token — or null when it carries none.
  String? credentialToken(String answer) => _field(answer, 'password');

  /// The `username` of a `git credential fill` answer when it can be a
  /// GitHub login — a helper that stored `x-access-token` or an e-mail
  /// stored no login — or null.
  String? credentialLogin(String answer) =>
      switch (_field(answer, 'username')) {
        final String name
            when _login.hasMatch(name) && name != 'x-access-token' =>
          name,
        _ => null,
      };

  /// The login GitHub greets an SSH key with, `Hi octocat!`, or null when it
  /// did not — a deploy key is greeted as `owner/repo`, which is no login.
  String? sshLogin(String greeting) => _greeting.firstMatch(greeting)?.group(1);

  /// The value of [key] in a `key=value` answer, or null when empty.
  static String? _field(String answer, String key) {
    for (final String line in const LineSplitter().convert(answer)) {
      if (line.startsWith('$key=') && line.length > key.length + 1) {
        return line.substring(key.length + 1);
      }
    }
    return null;
  }

  /// What GitHub allows a login to be.
  static final RegExp _login = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]*)$');

  /// The access a `GET /repos/{path}` body's `permissions` grants, or null
  /// when it carries none — which is what an anonymous answer looks like.
  RepositoryAccessValueObject? access(String body) => switch (_json(body)) {
    <String, Object?>{'permissions': final Map<String, Object?> permissions} =>
      RepositoryAccessValueObject.granted(
        pull: permissions['pull'] == true,
        push: permissions['push'] == true,
        admin: permissions['admin'] == true,
      ),
    _ => null,
  };

  static final RegExp _greeting = RegExp(r'Hi ([A-Za-z0-9-]+)!');

  static Object? _json(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }
}

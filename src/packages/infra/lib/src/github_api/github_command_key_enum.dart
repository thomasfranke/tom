/// Every `gh` command the GitHub capability can run, by name.
library;

import 'package:tom_core/tom_core.dart';

/// The `gh` commands [GithubApi](github_api.dart) runs, each as `gh`
/// receives it, a placeholder where a value goes ([Decision 38](../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
enum GithubCommandKeyEnum implements CommandKey {
  /// What a token may do on a repository.
  repository('gh api --hostname <host> repos/<repository>'),

  /// The open pull requests of a branch.
  openPullRequests(
    'gh pr list --repo <host>/<repository> --head <branch> --state open '
    '--json number,url,title',
  ),

  /// Opening a pull request.
  createPullRequest(
    'gh pr create --repo <host>/<repository> --base <branch> --head <branch> '
    '--title <title> --body-file -',
    isWrite: true,
  );

  const GithubCommandKeyEnum(this.template, {this.isWrite = false});

  @override
  final String template;

  @override
  final bool isWrite;
}

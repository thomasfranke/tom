/// Every git command the client can run, by name.
library;

import 'package:tom_core/tom_core.dart';

/// The git commands [GitClient](git_client.dart) runs, each as git receives
/// it ([Decision 38](../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
///
/// One value per call site's shape, so the whole set is enumerable and a
/// command the list does not hold cannot run. A placeholder stands where a
/// value goes; square brackets hold what [log] passes only when asked.
enum GitCommandKeyEnum implements CommandKey {
  /// Where the enclosing repository is.
  repositoryRoot('git rev-parse --show-toplevel'),

  /// What differs from `HEAD`.
  status('git status --porcelain=v2 --branch --untracked-files=all -z'),

  /// The commits of the branch, of a file, or since a revision.
  log(
    'git log --format=<format> [--max-count=<n>] [<revision>..HEAD] '
    '[-- <file>]',
  ),

  /// Every local branch.
  branches('git branch --format=<format>'),

  /// How far every branch stands from `HEAD`.
  branchStandings('git for-each-ref --format=<format> refs/heads refs/remotes'),

  /// How many commits `HEAD` has.
  commitCount('git rev-list --count HEAD'),

  /// How many commits the upstream has that a revision does not.
  upstreamCommitCount('git rev-list --count [<revision>..]@{upstream}'),

  /// A key of git's config, as git resolves it.
  configGet('git config --get <key>'),

  /// A key of the repository's own config.
  configLocalGet('git config --local --get <key>'),

  /// Writing a key of the repository's own config.
  configLocalSet('git config --local <key> <value>', isWrite: true),

  /// What changed since a branch was left, in lines.
  diffNumstat(
    'git -c diff.relative=false diff --numstat -z --no-renames '
    '<revision>...HEAD',
  ),

  /// What happened to each path since a branch was left.
  diffNameStatus(
    'git -c diff.relative=false diff --name-status -z --no-renames '
    '<revision>...HEAD',
  ),

  /// Every path a merge left conflicted.
  diffUnmerged(
    'git -c diff.relative=false diff --name-only --diff-filter=U -z',
  ),

  /// Where `HEAD` left a revision.
  mergeBase('git merge-base <revision> HEAD'),

  /// Whether a revision names a commit.
  revisionExists('git rev-parse --verify --quiet <revision>^{commit}'),

  /// The address `origin` is fetched from.
  remoteUrl('git remote get-url origin'),

  /// The branch `origin` calls its own `HEAD`.
  remoteHead('git symbolic-ref --quiet --short refs/remotes/origin/HEAD'),

  /// Whether `origin` has a branch by a given name.
  remoteBranchExists(
    'git rev-parse --verify --quiet refs/remotes/origin/<branch>',
  ),

  /// The branch `HEAD` points at.
  currentBranch('git symbolic-ref --quiet --short HEAD'),

  /// A file as a revision holds it.
  show('git show <revision>:<file>'),

  /// A file as the index holds it.
  showStaged('git show :<file>'),

  /// The commit `HEAD` names.
  head('git rev-parse --verify --quiet HEAD'),

  /// The git directory every worktree shares.
  gitDirectory('git rev-parse --git-common-dir'),

  /// Whether a merge is in progress.
  mergeHead('git rev-parse --verify --quiet MERGE_HEAD'),

  /// Where git keeps the message of the merge in progress.
  mergeMessagePath('git rev-parse --git-path MERGE_MSG'),

  /// Cloning an address into a folder.
  clone(
    'git -c protocol.ext.allow=never clone --progress -- <url> <folder>',
    isWrite: true,
  ),

  /// Staging files.
  add('git add -- <files>', isWrite: true),

  /// Unstaging files.
  restoreStaged('git restore --staged -- <files>', isWrite: true),

  /// Unstaging files before the first commit, where there is no `HEAD`.
  removeFromIndex(
    'git rm --cached --quiet -r --ignore-unmatch -- <files>',
    isWrite: true,
  ),

  /// Making the index `HEAD` again — the first half of discarding all.
  reset('git reset --quiet', isWrite: true),

  /// Putting every tracked file back as the index has it — the second half.
  restoreWorktreeAll('git restore --worktree -- :/', isWrite: true),

  /// Putting one file back as the index has it.
  restoreWorktree('git restore --worktree -- <file>', isWrite: true),

  /// Putting one file back as `HEAD` has it, staged or not.
  restoreFromHead(
    'git restore --staged --worktree --source=HEAD -- <file>',
    isWrite: true,
  ),

  /// Taking a never-committed file out of the index — the first half of
  /// deleting it.
  removeFromIndexForced(
    'git rm --cached -f --quiet --ignore-unmatch -- <file>',
    isWrite: true,
  ),

  /// Deleting a never-committed file off the disk — the second half.
  clean('git clean -f -x --quiet -- <file>', isWrite: true),

  /// Committing what is staged.
  commit('git commit --message <message>', isWrite: true),

  /// Starting a branch and switching to it.
  switchCreate('git switch --create <branch>', isWrite: true),

  /// Switching to a branch.
  switchBranch('git switch <branch>', isWrite: true),

  /// Updating the remote-tracking branches.
  fetch('git fetch', isWrite: true),

  /// Fetching and merging the upstream branch.
  pull('git pull --no-rebase', isWrite: true),

  /// Publishing the branch to its upstream.
  push('git push', isWrite: true),

  /// Publishing a branch for the first time.
  pushSetUpstream('git push --set-upstream origin <branch>', isWrite: true),

  /// Undoing the merge in progress.
  mergeAbort('git merge --abort', isWrite: true);

  const GitCommandKeyEnum(this.template, {this.isWrite = false});

  @override
  final String template;

  @override
  final bool isWrite;
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get panelExplorer => 'Explorer';

  @override
  String get panelGit => 'Git';

  @override
  String get panelHistory => 'History';

  @override
  String get panelPullRequest => 'Pull request';

  @override
  String get panelOverview => 'Overview';

  @override
  String get panelStatus => 'Status';

  @override
  String get modeSource => 'Source';

  @override
  String get modeSplit => 'Split';

  @override
  String get modePreview => 'Preview';

  @override
  String get commonAskingGit => 'Asking git…';

  @override
  String get commonNoSpaceOpen => 'No space is open.';

  @override
  String get commonNoSpaceOpenStatus => 'no space open';

  @override
  String get commonUnsaved => 'Unsaved';

  @override
  String get commonReload => 'Reload';

  @override
  String get commonPush => 'Push';

  @override
  String get commonPull => 'Pull';

  @override
  String get commonFetch => 'Fetch';

  @override
  String get commonSaveAndClose => 'Save and close';

  @override
  String get commonDiscardAndClose => 'Discard and close';

  @override
  String get commonTheOpenDocument => 'The open document';

  @override
  String commonHasUnsavedChanges(String name) {
    return '$name has unsaved changes.';
  }

  @override
  String get commonDetachedHead => 'detached HEAD';

  @override
  String get commonNoBranch => 'no branch';

  @override
  String get commonChooseADocument => 'Choose a document in the explorer.';

  @override
  String get commonReadingTheDocument => 'Reading the document…';

  @override
  String get documentNotFound => 'That document is no longer there.';

  @override
  String get documentPermissionDenied =>
      'TOM is not allowed to read that document.';

  @override
  String get documentNotUtf8 =>
      'That file is not UTF-8 text, so TOM will not open it.';

  @override
  String get documentUnreadable => 'That document could not be read.';

  @override
  String get gitNotInstalled => 'TOM could not find git on this machine.';

  @override
  String get gitNotARepository => 'That folder is not inside a Git repository.';

  @override
  String get gitTimedOut => 'Git took too long to answer.';

  @override
  String get conflictAcceptCurrent => 'Accept Current Change';

  @override
  String get conflictAcceptIncoming => 'Accept Incoming Change';

  @override
  String get conflictAcceptBoth => 'Accept Both Changes';

  @override
  String get conflictCurrentChange => 'Current Change';

  @override
  String get conflictIncomingChange => 'Incoming Change';

  @override
  String get fileStateModified => 'Modified';

  @override
  String get fileStateAdded => 'Added';

  @override
  String get fileStateDeleted => 'Deleted';

  @override
  String get fileStateRenamed => 'Renamed';

  @override
  String get fileStateUntracked => 'New — git has never been told about it';

  @override
  String get fileStateConflicted => 'Conflicted — resolve it before committing';

  @override
  String get revealInFinder => 'Reveal in Finder';

  @override
  String get revealInExplorer => 'Reveal in Explorer';

  @override
  String get revealInFiles => 'Show in Files';

  @override
  String get openRepositoryInFinder => 'Open repository in Finder';

  @override
  String get openRepositoryInExplorer => 'Open repository in Explorer';

  @override
  String get openRepositoryInFiles => 'Open repository in Files';

  @override
  String get whenJustNow => 'just now';

  @override
  String whenMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String whenHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String whenDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String whenMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String whenYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get preferencesTooltip => 'Preferences';

  @override
  String get preferencesTheme => 'THEME';

  @override
  String get preferencesThemeSystem => 'System';

  @override
  String get preferencesThemeLight => 'Light';

  @override
  String get preferencesThemeDark => 'Dark';

  @override
  String get preferencesLanguage => 'LANGUAGE';

  @override
  String get preferencesLanguageSystem => 'System';

  @override
  String get preferencesShowFormattingBar => 'Show the formatting bar';

  @override
  String get preferencesOpenFile => 'Open preferences.json';

  @override
  String preferencesChangedOnDisk(String name) {
    return '$name changed on disk while you were editing it.';
  }

  @override
  String get preferencesKeepMine => 'Keep mine';

  @override
  String get homeRecent => 'RECENT';

  @override
  String get homeForgetSpace => 'Forget this space';

  @override
  String get homeTagline => 'A Git client built for documentation, not code.';

  @override
  String get homeChooseFolder => 'Choose folder…';

  @override
  String get homeChooseAnotherFolder => 'Choose another folder…';

  @override
  String get homeOpening => 'Opening…';

  @override
  String get homeCloneFromUrl => 'Clone from URL';

  @override
  String get homeClone => 'Clone';

  @override
  String get homeCloning => 'Cloning…';

  @override
  String get homeCloneHint =>
      'Paste the address. You choose the folder next, and it opens as a space.';

  @override
  String get homeCloneStarting => 'Starting';

  @override
  String get homeCloneCounting => 'Counting objects';

  @override
  String get homeCloneReceiving => 'Receiving objects';

  @override
  String get homeCloneResolving => 'Resolving deltas';

  @override
  String get homeCloneUpdating => 'Updating files';

  @override
  String homeClonePhase(String stage, String folder) {
    return '$stage  —  into $folder';
  }

  @override
  String homeClonePhasePercent(String stage, int percent, String folder) {
    return '$stage · $percent%  —  into $folder';
  }

  @override
  String get homeCloneNoRepository => 'There is no repository at that address.';

  @override
  String homeCloneCredentials(String host) {
    return 'Git refused the credentials for $host. Sign in with your own git, then try again.';
  }

  @override
  String get homeCloneCredentialsAnywhere =>
      'Git refused the credentials for that address. Sign in with your own git, then try again.';

  @override
  String get homeCloneNoNetwork =>
      'No network — the address could not be reached.';

  @override
  String get homeCloneTimedOut =>
      'The address did not answer in time — try again.';

  @override
  String homeCloneFolderTaken(String folder) {
    return '$folder already exists — choose another folder.';
  }

  @override
  String get homeCloneNoGit => 'Git is not installed on this machine.';

  @override
  String get homeCloneFailed => 'Git could not clone that address.';

  @override
  String get homeRefusedFolderMissing => 'That folder is no longer there';

  @override
  String get homeRefusedFolderMissingWhy =>
      'It may be on a disk that is not connected, or it was moved or renamed outside TOM.';

  @override
  String get homeRefusedNoGit => 'TOM cannot find git on this machine';

  @override
  String get homeRefusedNoGitWhy =>
      'TOM drives the git you already have. Install it, or make sure it is on your PATH, and try again.';

  @override
  String get homeRefusedUnopened => 'That folder could not be opened';

  @override
  String get homeRefusedUnopenedWhy =>
      'Git or the disk refused it without saying why. Try it again, or choose another folder.';

  @override
  String shellChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes',
      one: '1 change',
    );
    return '$_temp0';
  }

  @override
  String shellCaret(int line, int column) {
    return 'Ln $line, Col $column';
  }

  @override
  String get shellSaving => 'Saving…';

  @override
  String get shellSaved => 'Saved';

  @override
  String get shellNotSaved => 'Not saved';

  @override
  String shellReadingVersion(String sha, String author, String when) {
    return 'Reading $sha · $author · $when';
  }

  @override
  String get shellBackToNow => 'Back to now';

  @override
  String get shellReadOnly => 'Read-only';

  @override
  String get shellKindMarkdown => 'Markdown';

  @override
  String get shellKindJson => 'JSON';

  @override
  String get shellKindYaml => 'YAML';

  @override
  String get shellKindToml => 'TOML';

  @override
  String get shellKindXml => 'XML';

  @override
  String get shellKindHtml => 'HTML';

  @override
  String get shellKindCss => 'CSS';

  @override
  String get shellKindJavaScript => 'JavaScript';

  @override
  String get shellKindTypeScript => 'TypeScript';

  @override
  String get shellKindDart => 'Dart';

  @override
  String get shellKindPython => 'Python';

  @override
  String get shellKindShell => 'Shell';

  @override
  String get shellKindPlainText => 'Plain text';

  @override
  String get shellKindBinary => 'Binary';

  @override
  String get workspaceShowExplorer => 'Show explorer';

  @override
  String get workspaceHideExplorer => 'Hide explorer';

  @override
  String get workspaceShowGit => 'Show git';

  @override
  String get workspaceHideGit => 'Hide git';

  @override
  String get workspaceNoRepository =>
      'This folder is not inside a Git repository.';

  @override
  String get workspaceNoRepositoryWorks => 'Reading and editing work as usual.';

  @override
  String get workspaceNoRepositoryUnversioned => 'Nothing here is versioned.';

  @override
  String get spacesCloseSpace => 'Close space';

  @override
  String get spacesRecentSpaces => 'RECENT SPACES';

  @override
  String get spacesUnsavedClosing =>
      'Closing the space leaves the window, and the edit that has not reached the disk goes with it.';

  @override
  String spacesUnsavedOpening(String space) {
    return 'Opening $space replaces what is on screen, and the edit that has not reached the disk goes with it.';
  }

  @override
  String get spacesSaveAndOpen => 'Save and open';

  @override
  String get spacesDiscardAndOpen => 'Discard and open';

  @override
  String get spacesStay => 'Stay in this space';

  @override
  String spacesUnsavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents have unsaved changes.',
      one: '1 document has unsaved changes.',
    );
    return '$_temp0';
  }

  @override
  String get spacesUnsavedClosingMany =>
      'Closing the space leaves the window, and the edits that have not reached the disk go with it.';

  @override
  String spacesUnsavedOpeningMany(String space) {
    return 'Opening $space replaces what is on screen, and the edits that have not reached the disk go with it.';
  }

  @override
  String get spacesSaveAllAndClose => 'Save all and close';

  @override
  String get spacesDiscardAllAndClose => 'Discard all and close';

  @override
  String get spacesSaveAllAndOpen => 'Save all and open';

  @override
  String get spacesDiscardAllAndOpen => 'Discard all and open';

  @override
  String spacesUnopened(String space) {
    return '$space could not be opened — has it moved?';
  }

  @override
  String get pullRequestProposingOnto => 'Proposing onto';

  @override
  String get pullRequestThisBranch => 'This branch';

  @override
  String pullRequestProposal(int commits, int documents) {
    String _temp0 = intl.Intl.pluralLogic(
      commits,
      locale: localeName,
      other: '$commits commits',
      one: '1 commit',
    );
    String _temp1 = intl.Intl.pluralLogic(
      documents,
      locale: localeName,
      other: '$documents documents',
      one: '1 document',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String pullRequestOpenOn(String host) {
    return 'Open on $host';
  }

  @override
  String get pullRequestPushing => 'Pushing…';

  @override
  String pullRequestOnBase(String base) {
    return 'On $base — nothing to propose';
  }

  @override
  String pullRequestOnBaseWhy(String base) {
    return 'This is $base, the branch a pull request goes into. Switch to another branch to propose it.';
  }

  @override
  String get pullRequestUnknownHost => 'origin is not on a known host';

  @override
  String get pullRequestUnknownHostWhy =>
      'origin is not on GitHub, GitLab or Bitbucket, so there is no page to open a pull request on.';

  @override
  String get pullRequestNoRemote => 'No remote to propose to';

  @override
  String get pullRequestNoRemoteWhy =>
      'This repository has no remote. A pull request is opened on the remote it would be merged into.';

  @override
  String get pullRequestDetached => 'Not on a branch';

  @override
  String get pullRequestDetachedWhy =>
      'HEAD points at a commit, not a branch. Switch to a branch to propose it.';

  @override
  String get pullRequestNoBase => 'origin names no branch to propose onto';

  @override
  String get pullRequestNoBaseWhy =>
      'origin names no default branch, and there is no main or master to propose onto.';

  @override
  String get pullRequestUnreadable => 'git could not be read';

  @override
  String get pullRequestUnreadableWhy =>
      'git could not be read here, so the branch is not known.';

  @override
  String pullRequestReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ready to open. $count commits pushed, nothing left to publish.',
      one: 'Ready to open. 1 commit pushed, nothing left to publish.',
    );
    return '$_temp0';
  }

  @override
  String pullRequestUncommitted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count documents are not committed. They would not be in this pull request — commit them first.',
      one:
          '1 document is not committed. They would not be in this pull request — commit them first.',
    );
    return '$_temp0';
  }

  @override
  String pullRequestUnpublished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commits not on the remote yet. Push before opening.',
      one: '1 commit not on the remote yet. Push before opening.',
    );
    return '$_temp0';
  }

  @override
  String get pullRequestUnpublishedBranch =>
      'This branch is not on the remote yet. Push it before opening.';

  @override
  String get pullRequestUntitled =>
      'The draft has no title — its first line is a # heading.';

  @override
  String pullRequestEmpty(String base) {
    return 'Nothing to propose yet: this branch has no commits over $base.';
  }

  @override
  String pullRequestNoCommitsOver(String base) {
    return 'No commits over $base';
  }

  @override
  String get pullRequestCreate => 'Create pull request';

  @override
  String get pullRequestCreating => 'Creating…';

  @override
  String pullRequestOpenOnInstead(String host) {
    return 'Open on $host instead';
  }

  @override
  String pullRequestView(int number, String host) {
    return 'View #$number on $host';
  }

  @override
  String pullRequestAlreadyOpen(int number, String host) {
    return 'Pull request #$number is open on $host — this draft is what it was opened with.';
  }

  @override
  String pullRequestNotCreatedUnreachable(String host) {
    return '$host could not be reached — the pull request was not opened.';
  }

  @override
  String pullRequestNotCreatedRefused(String host) {
    return '$host refused this account\'s token — the pull request was not opened.';
  }

  @override
  String pullRequestNotCreated(String host) {
    return '$host did not open the pull request.';
  }

  @override
  String get pullRequestReading => 'Reading the branch against its base…';

  @override
  String get pullRequestFailed =>
      'Git could not read this branch against its base — try another base.';

  @override
  String get pullRequestCounting => 'Counting what the branch did…';

  @override
  String pullRequestMinutes(int count) {
    return '$count min';
  }

  @override
  String get pullRequestToReview => 'to review';

  @override
  String get pullRequestWords => 'Words';

  @override
  String get pullRequestBlocks => 'Blocks';

  @override
  String get pullRequestDocuments => 'Documents';

  @override
  String get pullRequestCommits => 'Commits';

  @override
  String get pullRequestFolders => 'Folders';

  @override
  String get pullRequestMostChanged => 'Most changed';

  @override
  String pullRequestModified(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modified',
    );
    return '$_temp0';
  }

  @override
  String pullRequestAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count added',
    );
    return '$_temp0';
  }

  @override
  String pullRequestDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deleted',
    );
    return '$_temp0';
  }

  @override
  String pullRequestCommitsSince(int count, String when) {
    return '$count · the first $when';
  }

  @override
  String pullRequestParagraphs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paragraphs',
      one: '1 paragraph',
    );
    return '$_temp0';
  }

  @override
  String pullRequestHeadings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count headings',
      one: '1 heading',
    );
    return '$_temp0';
  }

  @override
  String pullRequestLists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lists',
      one: '1 list',
    );
    return '$_temp0';
  }

  @override
  String pullRequestTables(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables',
      one: '1 table',
    );
    return '$_temp0';
  }

  @override
  String pullRequestCodeBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count code blocks',
      one: '1 code block',
    );
    return '$_temp0';
  }

  @override
  String pullRequestQuotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quotes',
      one: '1 quote',
    );
    return '$_temp0';
  }

  @override
  String pullRequestRules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rules',
      one: '1 rule',
    );
    return '$_temp0';
  }

  @override
  String pullRequestHtmlBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count HTML blocks',
      one: '1 HTML block',
    );
    return '$_temp0';
  }

  @override
  String changesToResolve(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents to resolve',
      one: '1 document to resolve',
    );
    return '$_temp0';
  }

  @override
  String changesStagedOf(int staged, int total) {
    return '$staged of $total staged';
  }

  @override
  String get changesNothingChanged =>
      'Nothing has changed since the last commit.';

  @override
  String get changesStagedSection => 'STAGED';

  @override
  String get changesChangesSection => 'CHANGES';

  @override
  String get changesUnstageAll => 'Unstage all';

  @override
  String get changesStageAll => 'Stage all';

  @override
  String get changesMergeInProgress =>
      'A merge is in progress — resolve it first.';

  @override
  String get changesGitCouldNot => 'Git could not do that.';

  @override
  String get changesMenuTooltip => 'Git menu';

  @override
  String get changesOpenInTerminal => 'Open in terminal';

  @override
  String get changesDiscardAll => 'Discard all changes';

  @override
  String get changesDiscardAllQuestion => 'Discard all changes?';

  @override
  String changesDiscardAllGoesBack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents go back to the last commit.',
      one: '1 document goes back to the last commit.',
    );
    return '$_temp0';
  }

  @override
  String get changesDiscardAllKeepsNew => 'New files are kept, untracked.';

  @override
  String get changesKeepTheChanges => 'Keep the changes';

  @override
  String get changesDiscardChanges => 'Discard changes';

  @override
  String changesDiscardChangesTo(String name) {
    return 'Discard changes to $name?';
  }

  @override
  String get changesDiscardKeepsStaged =>
      'Everything not staged is lost. What is already staged stays.';

  @override
  String get changesDiscardSinceCommit =>
      'Everything changed since the last commit is lost, staged or not.';

  @override
  String get changesDelete => 'Delete';

  @override
  String changesDeleteFile(String name) {
    return 'Delete $name?';
  }

  @override
  String get changesDeleteNeverCommitted =>
      'It was never committed, so it cannot come back.';

  @override
  String get changesDiscardCancel => 'Cancel';

  @override
  String get changesSummaryHint => 'Summary';

  @override
  String get changesDescriptionHint => 'Description (optional)';

  @override
  String get changesCommit => 'Commit';

  @override
  String changesCommitTo(String branch) {
    return 'Commit to $branch';
  }

  @override
  String get changesCommitting => 'Committing…';

  @override
  String changesUpToDate(String upstream) {
    return 'Up to date with $upstream';
  }

  @override
  String changesBehind(int count, String upstream) {
    return '$count behind $upstream';
  }

  @override
  String changesAhead(int count, String upstream) {
    return '$count ahead of $upstream';
  }

  @override
  String changesAheadAndBehind(int ahead, int behind, String upstream) {
    return '$ahead ahead, $behind behind $upstream';
  }

  @override
  String get changesLinkNoNetwork => 'No network';

  @override
  String get changesLinkCredentialsRefused => 'Git refused the credentials';

  @override
  String get changesLinkNoRemote => 'No remote configured';

  @override
  String get changesLinkTimedOut => 'The remote did not answer';

  @override
  String get changesFetching => 'Fetching…';

  @override
  String get changesPulling => 'Pulling…';

  @override
  String get changesPushing => 'Pushing…';

  @override
  String get remoteTheRemote => 'the remote';

  @override
  String get remoteAbortThePull => 'Abort the pull';

  @override
  String get remotePullingWhatTheRemoteHas => 'Pulling what the remote has…';

  @override
  String get remoteTryAgain => 'Try again';

  @override
  String get remoteAbortQuestion => 'Abort the pull?';

  @override
  String get remoteAbortGoesBack =>
      'The space goes back to what it was before the pull.';

  @override
  String get remoteAbortStaysFetched =>
      'What arrived from the remote stays fetched.';

  @override
  String get remoteKeepTheConflict => 'Keep the conflict';

  @override
  String remoteAlreadyLevel(String upstream) {
    return 'Already level with $upstream — nothing arrived.';
  }

  @override
  String remotePulled(int count, String upstream) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commits',
      one: '1 commit',
    );
    return 'Pulled $_temp0 from $upstream.';
  }

  @override
  String remoteStillToPublish(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of yours are still to publish.',
      one: '1 of yours is still to publish.',
    );
    return '$_temp0';
  }

  @override
  String remoteStopped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents conflict.',
      one: '1 document conflict.',
    );
    return 'The pull stopped: $_temp0 Nothing you committed has been lost.';
  }

  @override
  String remoteStoppedShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents conflict.',
      one: '1 document conflict.',
    );
    return 'The pull stopped: $_temp0';
  }

  @override
  String remoteRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commits',
      one: '1 commit',
    );
    return 'Someone pushed $_temp0 first. Pull them, then push again — nothing you committed has been lost.';
  }

  @override
  String get remoteRejectedUncounted =>
      'Someone pushed first. Pull them, then push again — nothing you committed has been lost.';

  @override
  String get remoteNotAccepted => 'The remote would not accept this machine.';

  @override
  String get remoteCouldNotReach => 'git could not reach the remote.';

  @override
  String get remoteRefusedFetch => 'Git refused the fetch.';

  @override
  String get remoteRefusedPull => 'Git refused the pull.';

  @override
  String get remoteRefusedPush => 'Git refused the push.';

  @override
  String get remoteCostFetch => 'Nothing arrived.';

  @override
  String get remoteCostPull => 'Nothing changed here.';

  @override
  String get remoteCostPush =>
      'Nothing was published, and nothing you committed has been lost.';

  @override
  String remoteWouldOverwriteOne(String name) {
    return 'Git refused the pull: it would overwrite the uncommitted changes to $name. Nothing changed here — commit them, then try again.';
  }

  @override
  String remoteWouldOverwriteMany(int count) {
    return 'Git refused the pull: it would overwrite the uncommitted changes to $count files. Nothing changed here — commit them, then try again.';
  }

  @override
  String get remoteWouldOverwriteUncounted =>
      'Git refused the pull: it would overwrite changes that are not committed. Nothing changed here — commit them, then try again.';

  @override
  String get compareToLastCommit => 'Compared to the last commit';

  @override
  String compareTo(String base) {
    return 'Compared to $base';
  }

  @override
  String get compareDiff => 'Diff';

  @override
  String exportExporting(String name) {
    return 'Exporting $name…';
  }

  @override
  String exportExported(String name, String folder) {
    return 'Exported $name to $folder.';
  }

  @override
  String get exportReveal => 'Reveal';

  @override
  String exportFailed(String name, String reason) {
    return 'Could not export $name: $reason. Nothing was written.';
  }

  @override
  String get exportCannotWrite => 'that folder would not take the file';

  @override
  String get exportTooLarge => 'something in it is taller than a page';

  @override
  String exportUnsupported(String format) {
    return 'TOM has no $format exporter';
  }

  @override
  String get exportUnreadable => 'the document could not be read';

  @override
  String get historyScoped => 'scoped to this file, not the repo';

  @override
  String get historyOpenADocument => 'Open a document to see what changed it.';

  @override
  String get historyNoRecord => 'Git has no record of this file yet.';

  @override
  String get historyUnreadable => 'Git could not read this file\'s history.';

  @override
  String get historyNoMessage => '(no message)';

  @override
  String get branchesUnreadable => 'Git could not say what branches there are.';

  @override
  String get branchesFilterHint => 'Filter branches';

  @override
  String get branchesNoneByThatName => 'No branch by that name.';

  @override
  String get branchesRefused => 'Git refused that. Nothing has changed.';

  @override
  String get branchesCreateEllipsis => 'Create branch…';

  @override
  String get branchesNewNameHint => 'New branch name';

  @override
  String get branchesNameNotAccepted => 'Not a name git accepts';

  @override
  String get branchesNameTaken => 'There is already a branch called that';

  @override
  String branchesStartsFrom(String branch) {
    return 'Starts from $branch, and switches to it.';
  }

  @override
  String get branchesStartsFromHere =>
      'Starts from where you are, and switches to it.';

  @override
  String get branchesCreate => 'Create branch';

  @override
  String get branchesBackToTheList => 'Back to the list';

  @override
  String branchesSwitchingReplaces(String branch) {
    return 'Switching to $branch would replace it with the version on that branch.';
  }

  @override
  String get branchesSaveAndSwitch => 'Save and switch';

  @override
  String get branchesDiscardAndSwitch => 'Discard and switch';

  @override
  String get branchesStayOnThisBranch => 'Stay on this branch';

  @override
  String get editorUndo => 'Undo';

  @override
  String get editorRedo => 'Redo';

  @override
  String get editorHeading => 'Heading';

  @override
  String get editorBold => 'Bold';

  @override
  String get editorItalic => 'Italic';

  @override
  String get editorStrikethrough => 'Strikethrough';

  @override
  String get editorList => 'List';

  @override
  String get editorOrderedList => 'Ordered list';

  @override
  String get editorTaskList => 'Task list';

  @override
  String get editorQuote => 'Quote';

  @override
  String get editorCode => 'Code';

  @override
  String get editorTable => 'Table';

  @override
  String get editorRule => 'Rule';

  @override
  String get editorLink => 'Link';

  @override
  String get editorImage => 'Image';

  @override
  String get editorFootnote => 'Footnote';

  @override
  String get editorAlert => 'Alert';

  @override
  String get editorMoreFormatting => 'More formatting';

  @override
  String get editorCloseTabDiscards =>
      'Closing the tab discards the edit that has not reached the disk.';

  @override
  String get editorCloseTabDiskKept => 'The file on disk is unchanged.';

  @override
  String get editorKeepTabOpen => 'Keep the tab open';

  @override
  String get editorCloseTabTooltip => 'Close';

  @override
  String get editorExportAsPdf => 'Export as PDF…';

  @override
  String get editorExportAsHtml => 'Export as HTML…';

  @override
  String get editorCloseTab => 'Close tab';

  @override
  String get editorTabDeleted => '(deleted)';

  @override
  String get editorBinaryFile => 'A binary file — not shown as text.';

  @override
  String get editorCompletionHint =>
      '↑↓ to choose · Enter to insert · Esc to close';

  @override
  String get previewRemoved => 'Removed';

  @override
  String previewNoDocumentCalled(String target) {
    return 'No document called $target.';
  }

  @override
  String get previewCreateIt => 'Create it';

  @override
  String get previewDocumentEmpty => 'This document is empty.';

  @override
  String get searchThisFile => 'This file';

  @override
  String get searchWholeSpace => 'Whole space';

  @override
  String searchDocumentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
    );
    return '$_temp0';
  }

  @override
  String get searchReadingTheSpace => 'Reading the space…';

  @override
  String get searchNoDocumentSaysThat => 'No document says that.';

  @override
  String get searchIndexCorrupted =>
      'The index could not be built — reopen the space to try again.';

  @override
  String get searchFailed => 'This space could not be searched.';

  @override
  String get searchOpenADocument => 'Open a document to search inside it.';

  @override
  String get searchTypeToSearch => 'Type to search this document.';

  @override
  String searchNothingInDocument(String name) {
    return 'Nothing in $name says that.';
  }

  @override
  String searchOccurrenceCount(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count occurrences in $name',
      one: '1 occurrence in $name',
    );
    return '$_temp0';
  }

  @override
  String get searchReplaceAll => 'Replace all';

  @override
  String get searchReplaceThisOne => 'Replace this one';

  @override
  String get searchSkipThisOne => 'Skip this one';

  @override
  String get searchReplaceWith => 'Replace with';

  @override
  String get searchHint => 'Search';

  @override
  String get searchClear => 'Clear the search';

  @override
  String searchHideReplace(String keys) {
    return 'Hide replace ($keys)';
  }

  @override
  String searchShowReplace(String keys) {
    return 'Replace ($keys)';
  }

  @override
  String get fileTreeSearchCaption => 'SEARCH';

  @override
  String get fileTreeExplorerCaption => 'EXPLORER';

  @override
  String get fileTreeNewDocument => 'New document';

  @override
  String get fileTreeMenu => 'Explorer menu';

  @override
  String get fileTreeNewFolder => 'New folder';

  @override
  String get fileTreeCollapseAll => 'Collapse all';

  @override
  String get fileTreeReading => 'Reading the folder…';

  @override
  String get fileTreeFolderMissing => 'This folder is no longer there.';

  @override
  String get fileTreeAccessDenied => 'TOM is not allowed to read this folder.';

  @override
  String get fileTreeUnreadable => 'This folder could not be read.';

  @override
  String get fileTreeEmpty => 'This folder holds nothing yet.';

  @override
  String get accountTooltip => 'Account';

  @override
  String get accountCommitsAs => 'COMMITS AS';

  @override
  String get accountNameNotSet => 'Not set';

  @override
  String get accountIdentityMissing => 'git asks for a name and an email first';

  @override
  String get accountGithub => 'GITHUB';

  @override
  String get accountViaGh => 'via gh';

  @override
  String get accountViaGit => 'via git';

  @override
  String get accountViaSsh => 'via SSH';

  @override
  String get accountLoginViaGh =>
      'This computer\'s GitHub login, through gh — TOM keeps no copy.';

  @override
  String get accountLoginViaGit =>
      'This computer\'s GitHub login, through git — TOM keeps no copy.';

  @override
  String get accountLoginViaSsh =>
      'This computer\'s GitHub login, through SSH — TOM keeps no copy.';

  @override
  String get accountNoCredentials => 'No GitHub credentials on this computer';

  @override
  String get accountNoCredentialsHint =>
      'TOM uses what git and gh already have — run gh auth login, or push once over HTTPS.';

  @override
  String get accountThisRepository => 'THIS REPOSITORY';

  @override
  String get accountOpenRepository => 'Open on GitHub';

  @override
  String get accountColumnRead => 'READ';

  @override
  String get accountColumnPullRequest => 'PR';

  @override
  String get accountColumnPush => 'PUSH';

  @override
  String get accountColumnMerge => 'MERGE';

  @override
  String get accountColumnAdmin => 'ADMIN';

  @override
  String get accountAccessUnknown =>
      'What you can do here shows once git or gh can reach GitHub.';

  @override
  String get accountAccessSsh =>
      'SSH says who you are, not what you can do here.';

  @override
  String get accountAsking => 'Asking git and gh who you are…';

  @override
  String get accountAccessPending => 'Known once the answer is in.';

  @override
  String get accountCan => 'Yes';

  @override
  String get accountCannot => 'No';

  @override
  String get accountUnknown => 'Unknown';

  @override
  String get panelCommands => 'Commands';

  @override
  String commandsThisSession(int count) {
    return '$count this session';
  }

  @override
  String get commandsNoneYet => 'No command has run yet.';

  @override
  String get commandsCopy => 'Copy the command';

  @override
  String get commandsPrintedNothing => 'Printed nothing.';

  @override
  String commandsExit(int code) {
    return 'exit $code';
  }

  @override
  String get commandsUnfinished => 'did not finish';

  @override
  String get commandsDidNotRun => 'did not run';

  @override
  String commandsMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String commandsSeconds(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString s';
  }

  @override
  String commandsMinutes(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get workspaceShowBottom => 'Show the bottom panel';

  @override
  String get workspaceHideBottom => 'Hide the bottom panel';

  @override
  String get workspaceClosePanel => 'Close the panel';

  @override
  String get remoteShowTheCommand => 'Show the command';

  @override
  String get panelTerminal => 'Terminal';

  @override
  String terminalPlace(String shell, String folder) {
    return '$shell · $folder';
  }

  @override
  String get terminalFailed => 'The shell would not start.';

  @override
  String terminalExited(int code) {
    return 'The shell ended with $code. Press any key for another.';
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @panelExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get panelExplorer;

  /// The right column's first tab: changes, message, commit and remote.
  ///
  /// In en, this message translates to:
  /// **'Git'**
  String get panelGit;

  /// No description provided for @panelHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get panelHistory;

  /// No description provided for @panelPullRequest.
  ///
  /// In en, this message translates to:
  /// **'Pull request'**
  String get panelPullRequest;

  /// The pull request's second tab: what the branch did, counted.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get panelOverview;

  /// No description provided for @panelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get panelStatus;

  /// The view showing the markdown as written. One of Source · Split · Preview.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get modeSource;

  /// Source and preview side by side.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get modeSplit;

  /// The rendered document.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get modePreview;

  /// A panel's note while git is answering.
  ///
  /// In en, this message translates to:
  /// **'Asking git…'**
  String get commonAskingGit;

  /// A panel's note when no folder is open as a space.
  ///
  /// In en, this message translates to:
  /// **'No space is open.'**
  String get commonNoSpaceOpen;

  /// The status bar's words when no space is open; lower case, as the bar's segments are.
  ///
  /// In en, this message translates to:
  /// **'no space open'**
  String get commonNoSpaceOpenStatus;

  /// The mark on a document whose edit has not reached the disk.
  ///
  /// In en, this message translates to:
  /// **'Unsaved'**
  String get commonUnsaved;

  /// A menu row that reads the folder and git again.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get commonReload;

  /// The git verb, as a button. Kept as git's own word.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get commonPush;

  /// The git verb, as a button. Kept as git's own word.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get commonPull;

  /// The git verb, as a button. Kept as git's own word.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get commonFetch;

  /// No description provided for @commonSaveAndClose.
  ///
  /// In en, this message translates to:
  /// **'Save and close'**
  String get commonSaveAndClose;

  /// No description provided for @commonDiscardAndClose.
  ///
  /// In en, this message translates to:
  /// **'Discard and close'**
  String get commonDiscardAndClose;

  /// Stands in for a document's name when it has none, at the start of a sentence.
  ///
  /// In en, this message translates to:
  /// **'The open document'**
  String get commonTheOpenDocument;

  /// The title of a question asked before an unsaved edit would be lost.
  ///
  /// In en, this message translates to:
  /// **'{name} has unsaved changes.'**
  String commonHasUnsavedChanges(String name);

  /// Where HEAD points when it is not on a branch; git's own term.
  ///
  /// In en, this message translates to:
  /// **'detached HEAD'**
  String get commonDetachedHead;

  /// No description provided for @commonNoBranch.
  ///
  /// In en, this message translates to:
  /// **'no branch'**
  String get commonNoBranch;

  /// No description provided for @commonChooseADocument.
  ///
  /// In en, this message translates to:
  /// **'Choose a document in the explorer.'**
  String get commonChooseADocument;

  /// No description provided for @commonReadingTheDocument.
  ///
  /// In en, this message translates to:
  /// **'Reading the document…'**
  String get commonReadingTheDocument;

  /// No description provided for @documentNotFound.
  ///
  /// In en, this message translates to:
  /// **'That document is no longer there.'**
  String get documentNotFound;

  /// No description provided for @documentPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'TOM is not allowed to read that document.'**
  String get documentPermissionDenied;

  /// No description provided for @documentNotUtf8.
  ///
  /// In en, this message translates to:
  /// **'That file is not UTF-8 text, so TOM will not open it.'**
  String get documentNotUtf8;

  /// No description provided for @documentUnreadable.
  ///
  /// In en, this message translates to:
  /// **'That document could not be read.'**
  String get documentUnreadable;

  /// No description provided for @gitNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'TOM could not find git on this machine.'**
  String get gitNotInstalled;

  /// No description provided for @gitNotARepository.
  ///
  /// In en, this message translates to:
  /// **'That folder is not inside a Git repository.'**
  String get gitNotARepository;

  /// No description provided for @gitTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Git took too long to answer.'**
  String get gitTimedOut;

  /// VS Code's own words for keeping our side of a conflict.
  ///
  /// In en, this message translates to:
  /// **'Accept Current Change'**
  String get conflictAcceptCurrent;

  /// VS Code's own words for keeping their side of a conflict.
  ///
  /// In en, this message translates to:
  /// **'Accept Incoming Change'**
  String get conflictAcceptIncoming;

  /// VS Code's own words for keeping both sides of a conflict.
  ///
  /// In en, this message translates to:
  /// **'Accept Both Changes'**
  String get conflictAcceptBoth;

  /// No description provided for @conflictCurrentChange.
  ///
  /// In en, this message translates to:
  /// **'Current Change'**
  String get conflictCurrentChange;

  /// No description provided for @conflictIncomingChange.
  ///
  /// In en, this message translates to:
  /// **'Incoming Change'**
  String get conflictIncomingChange;

  /// No description provided for @fileStateModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get fileStateModified;

  /// No description provided for @fileStateAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get fileStateAdded;

  /// No description provided for @fileStateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get fileStateDeleted;

  /// No description provided for @fileStateRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed'**
  String get fileStateRenamed;

  /// Tooltip on the N mark: a file git does not track yet.
  ///
  /// In en, this message translates to:
  /// **'New — git has never been told about it'**
  String get fileStateUntracked;

  /// No description provided for @fileStateConflicted.
  ///
  /// In en, this message translates to:
  /// **'Conflicted — resolve it before committing'**
  String get fileStateConflicted;

  /// No description provided for @revealInFinder.
  ///
  /// In en, this message translates to:
  /// **'Reveal in Finder'**
  String get revealInFinder;

  /// Windows' file manager.
  ///
  /// In en, this message translates to:
  /// **'Reveal in Explorer'**
  String get revealInExplorer;

  /// Linux's file manager.
  ///
  /// In en, this message translates to:
  /// **'Show in Files'**
  String get revealInFiles;

  /// No description provided for @openRepositoryInFinder.
  ///
  /// In en, this message translates to:
  /// **'Open repository in Finder'**
  String get openRepositoryInFinder;

  /// No description provided for @openRepositoryInExplorer.
  ///
  /// In en, this message translates to:
  /// **'Open repository in Explorer'**
  String get openRepositoryInExplorer;

  /// No description provided for @openRepositoryInFiles.
  ///
  /// In en, this message translates to:
  /// **'Open repository in Files'**
  String get openRepositoryInFiles;

  /// A commit's age, under a minute.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get whenJustNow;

  /// No description provided for @whenMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String whenMinutesAgo(int count);

  /// No description provided for @whenHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String whenHoursAgo(int count);

  /// No description provided for @whenDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String whenDaysAgo(int count);

  /// No description provided for @whenMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String whenMonthsAgo(int count);

  /// No description provided for @whenYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String whenYearsAgo(int count);

  /// No description provided for @preferencesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesTooltip;

  /// A caption, in capitals as every panel caption is.
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get preferencesTheme;

  /// Follow the machine's appearance.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get preferencesThemeSystem;

  /// No description provided for @preferencesThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get preferencesThemeLight;

  /// No description provided for @preferencesThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get preferencesThemeDark;

  /// A caption, in capitals as every panel caption is.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get preferencesLanguage;

  /// Speak whatever the machine speaks.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get preferencesLanguageSystem;

  /// No description provided for @preferencesShowFormattingBar.
  ///
  /// In en, this message translates to:
  /// **'Show the formatting bar'**
  String get preferencesShowFormattingBar;

  /// preferences.json is a file name and stays as it is.
  ///
  /// In en, this message translates to:
  /// **'Open preferences.json'**
  String get preferencesOpenFile;

  /// The band over the preferences file's tab when a choice in the popover rewrote the file under unsaved edits.
  ///
  /// In en, this message translates to:
  /// **'{name} changed on disk while you were editing it.'**
  String preferencesChangedOnDisk(String name);

  /// Keeps the unsaved edits over the file that changed on disk; the next save writes them.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get preferencesKeepMine;

  /// Caption over Home's list of recent spaces, in capitals as every caption is.
  ///
  /// In en, this message translates to:
  /// **'RECENT'**
  String get homeRecent;

  /// Tooltip on the ✕ of a recent space: removes it from the list, not from disk.
  ///
  /// In en, this message translates to:
  /// **'Forget this space'**
  String get homeForgetSpace;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'A Git client built for documentation, not code.'**
  String get homeTagline;

  /// No description provided for @homeChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder…'**
  String get homeChooseFolder;

  /// No description provided for @homeChooseAnotherFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose another folder…'**
  String get homeChooseAnotherFolder;

  /// No description provided for @homeOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening…'**
  String get homeOpening;

  /// No description provided for @homeCloneFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Clone from URL'**
  String get homeCloneFromUrl;

  /// Button that starts git clone.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get homeClone;

  /// No description provided for @homeCloning.
  ///
  /// In en, this message translates to:
  /// **'Cloning…'**
  String get homeCloning;

  /// No description provided for @homeCloneHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the address. You choose the folder next, and it opens as a space.'**
  String get homeCloneHint;

  /// Git clone's phase, before it reports one.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get homeCloneStarting;

  /// Git clone's own phase name.
  ///
  /// In en, this message translates to:
  /// **'Counting objects'**
  String get homeCloneCounting;

  /// Git clone's own phase name.
  ///
  /// In en, this message translates to:
  /// **'Receiving objects'**
  String get homeCloneReceiving;

  /// Git clone's own phase name.
  ///
  /// In en, this message translates to:
  /// **'Resolving deltas'**
  String get homeCloneResolving;

  /// Git clone's own phase name: checking out.
  ///
  /// In en, this message translates to:
  /// **'Updating files'**
  String get homeCloneUpdating;

  /// Under the clone's progress bar: the phase, then the folder it lands in.
  ///
  /// In en, this message translates to:
  /// **'{stage}  —  into {folder}'**
  String homeClonePhase(String stage, String folder);

  /// Under the clone's progress bar: the phase, how far through it, and the folder it lands in.
  ///
  /// In en, this message translates to:
  /// **'{stage} · {percent}%  —  into {folder}'**
  String homeClonePhasePercent(String stage, int percent, String folder);

  /// No description provided for @homeCloneNoRepository.
  ///
  /// In en, this message translates to:
  /// **'There is no repository at that address.'**
  String get homeCloneNoRepository;

  /// No description provided for @homeCloneCredentials.
  ///
  /// In en, this message translates to:
  /// **'Git refused the credentials for {host}. Sign in with your own git, then try again.'**
  String homeCloneCredentials(String host);

  /// No description provided for @homeCloneCredentialsAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Git refused the credentials for that address. Sign in with your own git, then try again.'**
  String get homeCloneCredentialsAnywhere;

  /// No description provided for @homeCloneNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network — the address could not be reached.'**
  String get homeCloneNoNetwork;

  /// No description provided for @homeCloneTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The address did not answer in time — try again.'**
  String get homeCloneTimedOut;

  /// No description provided for @homeCloneFolderTaken.
  ///
  /// In en, this message translates to:
  /// **'{folder} already exists — choose another folder.'**
  String homeCloneFolderTaken(String folder);

  /// No description provided for @homeCloneNoGit.
  ///
  /// In en, this message translates to:
  /// **'Git is not installed on this machine.'**
  String get homeCloneNoGit;

  /// No description provided for @homeCloneFailed.
  ///
  /// In en, this message translates to:
  /// **'Git could not clone that address.'**
  String get homeCloneFailed;

  /// No description provided for @homeRefusedFolderMissing.
  ///
  /// In en, this message translates to:
  /// **'That folder is no longer there'**
  String get homeRefusedFolderMissing;

  /// No description provided for @homeRefusedFolderMissingWhy.
  ///
  /// In en, this message translates to:
  /// **'It may be on a disk that is not connected, or it was moved or renamed outside TOM.'**
  String get homeRefusedFolderMissingWhy;

  /// No description provided for @homeRefusedNoGit.
  ///
  /// In en, this message translates to:
  /// **'TOM cannot find git on this machine'**
  String get homeRefusedNoGit;

  /// No description provided for @homeRefusedNoGitWhy.
  ///
  /// In en, this message translates to:
  /// **'TOM drives the git you already have. Install it, or make sure it is on your PATH, and try again.'**
  String get homeRefusedNoGitWhy;

  /// No description provided for @homeRefusedUnopened.
  ///
  /// In en, this message translates to:
  /// **'That folder could not be opened'**
  String get homeRefusedUnopened;

  /// Home's refusal body for any failure that has no screen of its own.
  ///
  /// In en, this message translates to:
  /// **'Git or the disk refused it without saying why. Try it again, or choose another folder.'**
  String get homeRefusedUnopenedWhy;

  /// Status bar: how many files git reports as changed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change} other{{count} changes}}'**
  String shellChanges(int count);

  /// Status bar: the caret's line and column, as VS Code writes them.
  ///
  /// In en, this message translates to:
  /// **'Ln {line}, Col {column}'**
  String shellCaret(int line, int column);

  /// No description provided for @shellSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get shellSaving;

  /// No description provided for @shellSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get shellSaved;

  /// The mark when a save was refused by the disk.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get shellNotSaved;

  /// The bar above a past version of the document: which commit, whose, how old.
  ///
  /// In en, this message translates to:
  /// **'Reading {sha} · {author} · {when}'**
  String shellReadingVersion(String sha, String author, String when);

  /// Leaves a past version for the document as it is on disk.
  ///
  /// In en, this message translates to:
  /// **'Back to now'**
  String get shellBackToNow;

  /// Status bar, in place of Saved: a deleted file's last version or a binary file, which nothing typed reaches.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get shellReadOnly;

  /// Status bar: the open file's kind. A format's own name.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get shellKindMarkdown;

  /// No description provided for @shellKindJson.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get shellKindJson;

  /// No description provided for @shellKindYaml.
  ///
  /// In en, this message translates to:
  /// **'YAML'**
  String get shellKindYaml;

  /// No description provided for @shellKindToml.
  ///
  /// In en, this message translates to:
  /// **'TOML'**
  String get shellKindToml;

  /// No description provided for @shellKindXml.
  ///
  /// In en, this message translates to:
  /// **'XML'**
  String get shellKindXml;

  /// No description provided for @shellKindHtml.
  ///
  /// In en, this message translates to:
  /// **'HTML'**
  String get shellKindHtml;

  /// No description provided for @shellKindCss.
  ///
  /// In en, this message translates to:
  /// **'CSS'**
  String get shellKindCss;

  /// No description provided for @shellKindJavaScript.
  ///
  /// In en, this message translates to:
  /// **'JavaScript'**
  String get shellKindJavaScript;

  /// No description provided for @shellKindTypeScript.
  ///
  /// In en, this message translates to:
  /// **'TypeScript'**
  String get shellKindTypeScript;

  /// No description provided for @shellKindDart.
  ///
  /// In en, this message translates to:
  /// **'Dart'**
  String get shellKindDart;

  /// No description provided for @shellKindPython.
  ///
  /// In en, this message translates to:
  /// **'Python'**
  String get shellKindPython;

  /// Status bar: a shell script.
  ///
  /// In en, this message translates to:
  /// **'Shell'**
  String get shellKindShell;

  /// Status bar: a text file of no kind TOM names.
  ///
  /// In en, this message translates to:
  /// **'Plain text'**
  String get shellKindPlainText;

  /// Status bar: a file that is not text.
  ///
  /// In en, this message translates to:
  /// **'Binary'**
  String get shellKindBinary;

  /// No description provided for @workspaceShowExplorer.
  ///
  /// In en, this message translates to:
  /// **'Show explorer'**
  String get workspaceShowExplorer;

  /// No description provided for @workspaceHideExplorer.
  ///
  /// In en, this message translates to:
  /// **'Hide explorer'**
  String get workspaceHideExplorer;

  /// Tooltip on the toggle of the right column, git's.
  ///
  /// In en, this message translates to:
  /// **'Show git'**
  String get workspaceShowGit;

  /// No description provided for @workspaceHideGit.
  ///
  /// In en, this message translates to:
  /// **'Hide git'**
  String get workspaceHideGit;

  /// The right column of a space with no repository: the fact, alone in the column.
  ///
  /// In en, this message translates to:
  /// **'This folder is not inside a Git repository.'**
  String get workspaceNoRepository;

  /// Under the fact, what still works — said before what does not.
  ///
  /// In en, this message translates to:
  /// **'Reading and editing work as usual.'**
  String get workspaceNoRepositoryWorks;

  /// No description provided for @workspaceNoRepositoryUnversioned.
  ///
  /// In en, this message translates to:
  /// **'Nothing here is versioned.'**
  String get workspaceNoRepositoryUnversioned;

  /// Tooltip on the home button before the breadcrumb: leaves the space for Home.
  ///
  /// In en, this message translates to:
  /// **'Close space'**
  String get spacesCloseSpace;

  /// Caption in the breadcrumb's menu, in capitals as every caption is.
  ///
  /// In en, this message translates to:
  /// **'RECENT SPACES'**
  String get spacesRecentSpaces;

  /// No description provided for @spacesUnsavedClosing.
  ///
  /// In en, this message translates to:
  /// **'Closing the space leaves the window, and the edit that has not reached the disk goes with it.'**
  String get spacesUnsavedClosing;

  /// No description provided for @spacesUnsavedOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening {space} replaces what is on screen, and the edit that has not reached the disk goes with it.'**
  String spacesUnsavedOpening(String space);

  /// No description provided for @spacesSaveAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Save and open'**
  String get spacesSaveAndOpen;

  /// No description provided for @spacesDiscardAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Discard and open'**
  String get spacesDiscardAndOpen;

  /// No description provided for @spacesStay.
  ///
  /// In en, this message translates to:
  /// **'Stay in this space'**
  String get spacesStay;

  /// The question's title when more than one document is unsaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document has unsaved changes.} other{{count} documents have unsaved changes.}}'**
  String spacesUnsavedCount(int count);

  /// No description provided for @spacesUnsavedClosingMany.
  ///
  /// In en, this message translates to:
  /// **'Closing the space leaves the window, and the edits that have not reached the disk go with it.'**
  String get spacesUnsavedClosingMany;

  /// No description provided for @spacesUnsavedOpeningMany.
  ///
  /// In en, this message translates to:
  /// **'Opening {space} replaces what is on screen, and the edits that have not reached the disk go with it.'**
  String spacesUnsavedOpeningMany(String space);

  /// No description provided for @spacesSaveAllAndClose.
  ///
  /// In en, this message translates to:
  /// **'Save all and close'**
  String get spacesSaveAllAndClose;

  /// No description provided for @spacesDiscardAllAndClose.
  ///
  /// In en, this message translates to:
  /// **'Discard all and close'**
  String get spacesDiscardAllAndClose;

  /// No description provided for @spacesSaveAllAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Save all and open'**
  String get spacesSaveAllAndOpen;

  /// No description provided for @spacesDiscardAllAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Discard all and open'**
  String get spacesDiscardAllAndOpen;

  /// Under the breadcrumb menu's rows, when the chosen space did not open.
  ///
  /// In en, this message translates to:
  /// **'{space} could not be opened — has it moved?'**
  String spacesUnopened(String space);

  /// Caption over the base branch; drawn in capitals.
  ///
  /// In en, this message translates to:
  /// **'Proposing onto'**
  String get pullRequestProposingOnto;

  /// Caption over what the branch proposes; drawn in capitals.
  ///
  /// In en, this message translates to:
  /// **'This branch'**
  String get pullRequestThisBranch;

  /// No description provided for @pullRequestProposal.
  ///
  /// In en, this message translates to:
  /// **'{commits, plural, =1{1 commit} other{{commits} commits}} · {documents, plural, =1{1 document} other{{documents} documents}}'**
  String pullRequestProposal(int commits, int documents);

  /// Opens the compare page in the browser.
  ///
  /// In en, this message translates to:
  /// **'Open on {host}'**
  String pullRequestOpenOn(String host);

  /// No description provided for @pullRequestPushing.
  ///
  /// In en, this message translates to:
  /// **'Pushing…'**
  String get pullRequestPushing;

  /// No description provided for @pullRequestOnBase.
  ///
  /// In en, this message translates to:
  /// **'On {base} — nothing to propose'**
  String pullRequestOnBase(String base);

  /// No description provided for @pullRequestOnBaseWhy.
  ///
  /// In en, this message translates to:
  /// **'This is {base}, the branch a pull request goes into. Switch to another branch to propose it.'**
  String pullRequestOnBaseWhy(String base);

  /// origin is the git remote's name and stays as it is.
  ///
  /// In en, this message translates to:
  /// **'origin is not on a known host'**
  String get pullRequestUnknownHost;

  /// No description provided for @pullRequestUnknownHostWhy.
  ///
  /// In en, this message translates to:
  /// **'origin is not on GitHub, GitLab or Bitbucket, so there is no page to open a pull request on.'**
  String get pullRequestUnknownHostWhy;

  /// No description provided for @pullRequestNoRemote.
  ///
  /// In en, this message translates to:
  /// **'No remote to propose to'**
  String get pullRequestNoRemote;

  /// No description provided for @pullRequestNoRemoteWhy.
  ///
  /// In en, this message translates to:
  /// **'This repository has no remote. A pull request is opened on the remote it would be merged into.'**
  String get pullRequestNoRemoteWhy;

  /// No description provided for @pullRequestDetached.
  ///
  /// In en, this message translates to:
  /// **'Not on a branch'**
  String get pullRequestDetached;

  /// No description provided for @pullRequestDetachedWhy.
  ///
  /// In en, this message translates to:
  /// **'HEAD points at a commit, not a branch. Switch to a branch to propose it.'**
  String get pullRequestDetachedWhy;

  /// No description provided for @pullRequestNoBase.
  ///
  /// In en, this message translates to:
  /// **'origin names no branch to propose onto'**
  String get pullRequestNoBase;

  /// No description provided for @pullRequestNoBaseWhy.
  ///
  /// In en, this message translates to:
  /// **'origin names no default branch, and there is no main or master to propose onto.'**
  String get pullRequestNoBaseWhy;

  /// No description provided for @pullRequestUnreadable.
  ///
  /// In en, this message translates to:
  /// **'git could not be read'**
  String get pullRequestUnreadable;

  /// No description provided for @pullRequestUnreadableWhy.
  ///
  /// In en, this message translates to:
  /// **'git could not be read here, so the branch is not known.'**
  String get pullRequestUnreadableWhy;

  /// No description provided for @pullRequestReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Ready to open. 1 commit pushed, nothing left to publish.} other{Ready to open. {count} commits pushed, nothing left to publish.}}'**
  String pullRequestReady(int count);

  /// No description provided for @pullRequestUncommitted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document is not committed. They would not be in this pull request — commit them first.} other{{count} documents are not committed. They would not be in this pull request — commit them first.}}'**
  String pullRequestUncommitted(int count);

  /// No description provided for @pullRequestUnpublished.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 commit not on the remote yet. Push before opening.} other{{count} commits not on the remote yet. Push before opening.}}'**
  String pullRequestUnpublished(int count);

  /// No description provided for @pullRequestUnpublishedBranch.
  ///
  /// In en, this message translates to:
  /// **'This branch is not on the remote yet. Push it before opening.'**
  String get pullRequestUnpublishedBranch;

  /// No description provided for @pullRequestUntitled.
  ///
  /// In en, this message translates to:
  /// **'The draft has no title — its first line is a # heading.'**
  String get pullRequestUntitled;

  /// No description provided for @pullRequestEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to propose yet: this branch has no commits over {base}.'**
  String pullRequestEmpty(String base);

  /// The right column's summary of a branch with nothing over its base, in place of the commits.
  ///
  /// In en, this message translates to:
  /// **'No commits over {base}'**
  String pullRequestNoCommitsOver(String base);

  /// Opens the pull request on the host through the gh command-line tool, with the draft's title and body.
  ///
  /// In en, this message translates to:
  /// **'Create pull request'**
  String get pullRequestCreate;

  /// No description provided for @pullRequestCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get pullRequestCreating;

  /// Under Create pull request: opens the compare page in the browser instead.
  ///
  /// In en, this message translates to:
  /// **'Open on {host} instead'**
  String pullRequestOpenOnInstead(String host);

  /// Opens the pull request the branch already has, in the browser.
  ///
  /// In en, this message translates to:
  /// **'View #{number} on {host}'**
  String pullRequestView(int number, String host);

  /// No description provided for @pullRequestAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'Pull request #{number} is open on {host} — this draft is what it was opened with.'**
  String pullRequestAlreadyOpen(int number, String host);

  /// No description provided for @pullRequestNotCreatedUnreachable.
  ///
  /// In en, this message translates to:
  /// **'{host} could not be reached — the pull request was not opened.'**
  String pullRequestNotCreatedUnreachable(String host);

  /// No description provided for @pullRequestNotCreatedRefused.
  ///
  /// In en, this message translates to:
  /// **'{host} refused this account\'s token — the pull request was not opened.'**
  String pullRequestNotCreatedRefused(String host);

  /// Followed by Show the command, which opens what gh said.
  ///
  /// In en, this message translates to:
  /// **'{host} did not open the pull request.'**
  String pullRequestNotCreated(String host);

  /// No description provided for @pullRequestReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the branch against its base…'**
  String get pullRequestReading;

  /// No description provided for @pullRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Git could not read this branch against its base — try another base.'**
  String get pullRequestFailed;

  /// No description provided for @pullRequestCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting what the branch did…'**
  String get pullRequestCounting;

  /// The overview's headline: minutes of reading, above 'to review'.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String pullRequestMinutes(int count);

  /// No description provided for @pullRequestToReview.
  ///
  /// In en, this message translates to:
  /// **'to review'**
  String get pullRequestToReview;

  /// Overview section caption; drawn in capitals.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get pullRequestWords;

  /// Overview section caption; drawn in capitals.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get pullRequestBlocks;

  /// Overview section caption; drawn in capitals.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get pullRequestDocuments;

  /// Overview section caption; drawn in capitals.
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get pullRequestCommits;

  /// Overview section caption; drawn in capitals.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get pullRequestFolders;

  /// Overview section caption; drawn in capitals.
  ///
  /// In en, this message translates to:
  /// **'Most changed'**
  String get pullRequestMostChanged;

  /// Documents the branch modified.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} modified}}'**
  String pullRequestModified(int count);

  /// Documents the branch added.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} added}}'**
  String pullRequestAdded(int count);

  /// Documents the branch deleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} deleted}}'**
  String pullRequestDeleted(int count);

  /// How many commits, and how old the first one is.
  ///
  /// In en, this message translates to:
  /// **'{count} · the first {when}'**
  String pullRequestCommitsSince(int count, String when);

  /// No description provided for @pullRequestParagraphs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 paragraph} other{{count} paragraphs}}'**
  String pullRequestParagraphs(int count);

  /// No description provided for @pullRequestHeadings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 heading} other{{count} headings}}'**
  String pullRequestHeadings(int count);

  /// No description provided for @pullRequestLists.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 list} other{{count} lists}}'**
  String pullRequestLists(int count);

  /// No description provided for @pullRequestTables.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 table} other{{count} tables}}'**
  String pullRequestTables(int count);

  /// No description provided for @pullRequestCodeBlocks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 code block} other{{count} code blocks}}'**
  String pullRequestCodeBlocks(int count);

  /// No description provided for @pullRequestQuotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 quote} other{{count} quotes}}'**
  String pullRequestQuotes(int count);

  /// Horizontal rules (---) in markdown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule} other{{count} rules}}'**
  String pullRequestRules(int count);

  /// No description provided for @pullRequestHtmlBlocks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 HTML block} other{{count} HTML blocks}}'**
  String pullRequestHtmlBlocks(int count);

  /// Under the commit button while a merge still has conflicted documents.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document to resolve} other{{count} documents to resolve}}'**
  String changesToResolve(int count);

  /// Under the commit button: how many of the changed files go into the commit.
  ///
  /// In en, this message translates to:
  /// **'{staged} of {total} staged'**
  String changesStagedOf(int staged, int total);

  /// No description provided for @changesNothingChanged.
  ///
  /// In en, this message translates to:
  /// **'Nothing has changed since the last commit.'**
  String get changesNothingChanged;

  /// Caption of the files going into the commit, in capitals as every caption is.
  ///
  /// In en, this message translates to:
  /// **'STAGED'**
  String get changesStagedSection;

  /// Caption of the changed files not going into the commit.
  ///
  /// In en, this message translates to:
  /// **'CHANGES'**
  String get changesChangesSection;

  /// No description provided for @changesUnstageAll.
  ///
  /// In en, this message translates to:
  /// **'Unstage all'**
  String get changesUnstageAll;

  /// No description provided for @changesStageAll.
  ///
  /// In en, this message translates to:
  /// **'Stage all'**
  String get changesStageAll;

  /// No description provided for @changesMergeInProgress.
  ///
  /// In en, this message translates to:
  /// **'A merge is in progress — resolve it first.'**
  String get changesMergeInProgress;

  /// No description provided for @changesGitCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Git could not do that.'**
  String get changesGitCouldNot;

  /// No description provided for @changesMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Git menu'**
  String get changesMenuTooltip;

  /// No description provided for @changesOpenInTerminal.
  ///
  /// In en, this message translates to:
  /// **'Open in terminal'**
  String get changesOpenInTerminal;

  /// No description provided for @changesDiscardAll.
  ///
  /// In en, this message translates to:
  /// **'Discard all changes'**
  String get changesDiscardAll;

  /// No description provided for @changesDiscardAllQuestion.
  ///
  /// In en, this message translates to:
  /// **'Discard all changes?'**
  String get changesDiscardAllQuestion;

  /// No description provided for @changesDiscardAllGoesBack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document goes back to the last commit.} other{{count} documents go back to the last commit.}}'**
  String changesDiscardAllGoesBack(int count);

  /// No description provided for @changesDiscardAllKeepsNew.
  ///
  /// In en, this message translates to:
  /// **'New files are kept, untracked.'**
  String get changesDiscardAllKeepsNew;

  /// No description provided for @changesKeepTheChanges.
  ///
  /// In en, this message translates to:
  /// **'Keep the changes'**
  String get changesKeepTheChanges;

  /// The ↶ at the end of a changes row, and the action that confirms it.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get changesDiscardChanges;

  /// No description provided for @changesDiscardChangesTo.
  ///
  /// In en, this message translates to:
  /// **'Discard changes to {name}?'**
  String changesDiscardChangesTo(String name);

  /// No description provided for @changesDiscardKeepsStaged.
  ///
  /// In en, this message translates to:
  /// **'Everything not staged is lost. What is already staged stays.'**
  String get changesDiscardKeepsStaged;

  /// No description provided for @changesDiscardSinceCommit.
  ///
  /// In en, this message translates to:
  /// **'Everything changed since the last commit is lost, staged or not.'**
  String get changesDiscardSinceCommit;

  /// The ↶ on a file git never committed, and the action that confirms it.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get changesDelete;

  /// No description provided for @changesDeleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String changesDeleteFile(String name);

  /// No description provided for @changesDeleteNeverCommitted.
  ///
  /// In en, this message translates to:
  /// **'It was never committed, so it cannot come back.'**
  String get changesDeleteNeverCommitted;

  /// No description provided for @changesDiscardCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get changesDiscardCancel;

  /// Hint in the commit message's first line.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get changesSummaryHint;

  /// Hint in the commit message's body.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get changesDescriptionHint;

  /// The commit button when HEAD is on no branch.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get changesCommit;

  /// The commit button, naming the branch the commit lands on.
  ///
  /// In en, this message translates to:
  /// **'Commit to {branch}'**
  String changesCommitTo(String branch);

  /// The commit button while the commit runs.
  ///
  /// In en, this message translates to:
  /// **'Committing…'**
  String get changesCommitting;

  /// No description provided for @changesUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date with {upstream}'**
  String changesUpToDate(String upstream);

  /// How many commits the remote has that this branch does not.
  ///
  /// In en, this message translates to:
  /// **'{count} behind {upstream}'**
  String changesBehind(int count, String upstream);

  /// How many commits this branch has that the remote does not.
  ///
  /// In en, this message translates to:
  /// **'{count} ahead of {upstream}'**
  String changesAhead(int count, String upstream);

  /// No description provided for @changesAheadAndBehind.
  ///
  /// In en, this message translates to:
  /// **'{ahead} ahead, {behind} behind {upstream}'**
  String changesAheadAndBehind(int ahead, int behind, String upstream);

  /// No description provided for @changesLinkNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network'**
  String get changesLinkNoNetwork;

  /// No description provided for @changesLinkCredentialsRefused.
  ///
  /// In en, this message translates to:
  /// **'Git refused the credentials'**
  String get changesLinkCredentialsRefused;

  /// No description provided for @changesLinkNoRemote.
  ///
  /// In en, this message translates to:
  /// **'No remote configured'**
  String get changesLinkNoRemote;

  /// No description provided for @changesLinkTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The remote did not answer'**
  String get changesLinkTimedOut;

  /// The Fetch button while it runs.
  ///
  /// In en, this message translates to:
  /// **'Fetching…'**
  String get changesFetching;

  /// The Pull button while it runs.
  ///
  /// In en, this message translates to:
  /// **'Pulling…'**
  String get changesPulling;

  /// The Push button while it runs.
  ///
  /// In en, this message translates to:
  /// **'Pushing…'**
  String get changesPushing;

  /// Stands in for the upstream's name when the branch tracks none.
  ///
  /// In en, this message translates to:
  /// **'the remote'**
  String get remoteTheRemote;

  /// No description provided for @remoteAbortThePull.
  ///
  /// In en, this message translates to:
  /// **'Abort the pull'**
  String get remoteAbortThePull;

  /// No description provided for @remotePullingWhatTheRemoteHas.
  ///
  /// In en, this message translates to:
  /// **'Pulling what the remote has…'**
  String get remotePullingWhatTheRemoteHas;

  /// No description provided for @remoteTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get remoteTryAgain;

  /// No description provided for @remoteAbortQuestion.
  ///
  /// In en, this message translates to:
  /// **'Abort the pull?'**
  String get remoteAbortQuestion;

  /// No description provided for @remoteAbortGoesBack.
  ///
  /// In en, this message translates to:
  /// **'The space goes back to what it was before the pull.'**
  String get remoteAbortGoesBack;

  /// No description provided for @remoteAbortStaysFetched.
  ///
  /// In en, this message translates to:
  /// **'What arrived from the remote stays fetched.'**
  String get remoteAbortStaysFetched;

  /// No description provided for @remoteKeepTheConflict.
  ///
  /// In en, this message translates to:
  /// **'Keep the conflict'**
  String get remoteKeepTheConflict;

  /// No description provided for @remoteAlreadyLevel.
  ///
  /// In en, this message translates to:
  /// **'Already level with {upstream} — nothing arrived.'**
  String remoteAlreadyLevel(String upstream);

  /// No description provided for @remotePulled.
  ///
  /// In en, this message translates to:
  /// **'Pulled {count, plural, =1{1 commit} other{{count} commits}} from {upstream}.'**
  String remotePulled(int count, String upstream);

  /// Follows remotePulled: how many of this branch's own commits are not pushed yet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 of yours is still to publish.} other{{count} of yours are still to publish.}}'**
  String remoteStillToPublish(int count);

  /// No description provided for @remoteStopped.
  ///
  /// In en, this message translates to:
  /// **'The pull stopped: {count, plural, =1{1 document conflict.} other{{count} documents conflict.}} Nothing you committed has been lost.'**
  String remoteStopped(int count);

  /// No description provided for @remoteStoppedShort.
  ///
  /// In en, this message translates to:
  /// **'The pull stopped: {count, plural, =1{1 document conflict.} other{{count} documents conflict.}}'**
  String remoteStoppedShort(int count);

  /// A push the remote refused because it has commits this branch lacks.
  ///
  /// In en, this message translates to:
  /// **'Someone pushed {count, plural, =1{1 commit} other{{count} commits}} first. Pull them, then push again — nothing you committed has been lost.'**
  String remoteRejected(int count);

  /// No description provided for @remoteRejectedUncounted.
  ///
  /// In en, this message translates to:
  /// **'Someone pushed first. Pull them, then push again — nothing you committed has been lost.'**
  String get remoteRejectedUncounted;

  /// No description provided for @remoteNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'The remote would not accept this machine.'**
  String get remoteNotAccepted;

  /// No description provided for @remoteCouldNotReach.
  ///
  /// In en, this message translates to:
  /// **'git could not reach the remote.'**
  String get remoteCouldNotReach;

  /// No description provided for @remoteRefusedFetch.
  ///
  /// In en, this message translates to:
  /// **'Git refused the fetch.'**
  String get remoteRefusedFetch;

  /// No description provided for @remoteRefusedPull.
  ///
  /// In en, this message translates to:
  /// **'Git refused the pull.'**
  String get remoteRefusedPull;

  /// No description provided for @remoteRefusedPush.
  ///
  /// In en, this message translates to:
  /// **'Git refused the push.'**
  String get remoteRefusedPush;

  /// Follows a failed fetch.
  ///
  /// In en, this message translates to:
  /// **'Nothing arrived.'**
  String get remoteCostFetch;

  /// Follows a failed pull.
  ///
  /// In en, this message translates to:
  /// **'Nothing changed here.'**
  String get remoteCostPull;

  /// Follows a failed push.
  ///
  /// In en, this message translates to:
  /// **'Nothing was published, and nothing you committed has been lost.'**
  String get remoteCostPush;

  /// The band when git will not pull over one file's uncommitted changes.
  ///
  /// In en, this message translates to:
  /// **'Git refused the pull: it would overwrite the uncommitted changes to {name}. Nothing changed here — commit them, then try again.'**
  String remoteWouldOverwriteOne(String name);

  /// The band when git will not pull over several files' uncommitted changes.
  ///
  /// In en, this message translates to:
  /// **'Git refused the pull: it would overwrite the uncommitted changes to {count} files. Nothing changed here — commit them, then try again.'**
  String remoteWouldOverwriteMany(int count);

  /// The same band when git named no file.
  ///
  /// In en, this message translates to:
  /// **'Git refused the pull: it would overwrite changes that are not committed. Nothing changed here — commit them, then try again.'**
  String get remoteWouldOverwriteUncounted;

  /// No description provided for @compareToLastCommit.
  ///
  /// In en, this message translates to:
  /// **'Compared to the last commit'**
  String get compareToLastCommit;

  /// The branch the diff marks are measured against.
  ///
  /// In en, this message translates to:
  /// **'Compared to {base}'**
  String compareTo(String base);

  /// The chip that turns the diff marks on and off; git's own word.
  ///
  /// In en, this message translates to:
  /// **'Diff'**
  String get compareDiff;

  /// No description provided for @exportExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting {name}…'**
  String exportExporting(String name);

  /// No description provided for @exportExported.
  ///
  /// In en, this message translates to:
  /// **'Exported {name} to {folder}.'**
  String exportExported(String name, String folder);

  /// Shows the exported file in the platform's file manager.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get exportReveal;

  /// reason is one of the exportCannotWrite… messages, lower case.
  ///
  /// In en, this message translates to:
  /// **'Could not export {name}: {reason}. Nothing was written.'**
  String exportFailed(String name, String reason);

  /// No description provided for @exportCannotWrite.
  ///
  /// In en, this message translates to:
  /// **'that folder would not take the file'**
  String get exportCannotWrite;

  /// No description provided for @exportTooLarge.
  ///
  /// In en, this message translates to:
  /// **'something in it is taller than a page'**
  String get exportTooLarge;

  /// No description provided for @exportUnsupported.
  ///
  /// In en, this message translates to:
  /// **'TOM has no {format} exporter'**
  String exportUnsupported(String format);

  /// No description provided for @exportUnreadable.
  ///
  /// In en, this message translates to:
  /// **'the document could not be read'**
  String get exportUnreadable;

  /// A note under the history list; lower case, as a note.
  ///
  /// In en, this message translates to:
  /// **'scoped to this file, not the repo'**
  String get historyScoped;

  /// No description provided for @historyOpenADocument.
  ///
  /// In en, this message translates to:
  /// **'Open a document to see what changed it.'**
  String get historyOpenADocument;

  /// No description provided for @historyNoRecord.
  ///
  /// In en, this message translates to:
  /// **'Git has no record of this file yet.'**
  String get historyNoRecord;

  /// No description provided for @historyUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Git could not read this file\'s history.'**
  String get historyUnreadable;

  /// Stands in for a commit whose subject is empty.
  ///
  /// In en, this message translates to:
  /// **'(no message)'**
  String get historyNoMessage;

  /// No description provided for @branchesUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Git could not say what branches there are.'**
  String get branchesUnreadable;

  /// No description provided for @branchesFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter branches'**
  String get branchesFilterHint;

  /// No description provided for @branchesNoneByThatName.
  ///
  /// In en, this message translates to:
  /// **'No branch by that name.'**
  String get branchesNoneByThatName;

  /// No description provided for @branchesRefused.
  ///
  /// In en, this message translates to:
  /// **'Git refused that. Nothing has changed.'**
  String get branchesRefused;

  /// Opens the form that names a new branch.
  ///
  /// In en, this message translates to:
  /// **'Create branch…'**
  String get branchesCreateEllipsis;

  /// No description provided for @branchesNewNameHint.
  ///
  /// In en, this message translates to:
  /// **'New branch name'**
  String get branchesNewNameHint;

  /// No description provided for @branchesNameNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'Not a name git accepts'**
  String get branchesNameNotAccepted;

  /// No description provided for @branchesNameTaken.
  ///
  /// In en, this message translates to:
  /// **'There is already a branch called that'**
  String get branchesNameTaken;

  /// No description provided for @branchesStartsFrom.
  ///
  /// In en, this message translates to:
  /// **'Starts from {branch}, and switches to it.'**
  String branchesStartsFrom(String branch);

  /// No description provided for @branchesStartsFromHere.
  ///
  /// In en, this message translates to:
  /// **'Starts from where you are, and switches to it.'**
  String get branchesStartsFromHere;

  /// No description provided for @branchesCreate.
  ///
  /// In en, this message translates to:
  /// **'Create branch'**
  String get branchesCreate;

  /// No description provided for @branchesBackToTheList.
  ///
  /// In en, this message translates to:
  /// **'Back to the list'**
  String get branchesBackToTheList;

  /// No description provided for @branchesSwitchingReplaces.
  ///
  /// In en, this message translates to:
  /// **'Switching to {branch} would replace it with the version on that branch.'**
  String branchesSwitchingReplaces(String branch);

  /// No description provided for @branchesSaveAndSwitch.
  ///
  /// In en, this message translates to:
  /// **'Save and switch'**
  String get branchesSaveAndSwitch;

  /// No description provided for @branchesDiscardAndSwitch.
  ///
  /// In en, this message translates to:
  /// **'Discard and switch'**
  String get branchesDiscardAndSwitch;

  /// No description provided for @branchesStayOnThisBranch.
  ///
  /// In en, this message translates to:
  /// **'Stay on this branch'**
  String get branchesStayOnThisBranch;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get editorUndo;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get editorRedo;

  /// A formatting-bar button's tooltip: make the line a heading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get editorHeading;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get editorBold;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get editorItalic;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get editorStrikethrough;

  /// A formatting-bar button's tooltip: a bulleted list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get editorList;

  /// A formatting-bar button's tooltip: a numbered list.
  ///
  /// In en, this message translates to:
  /// **'Ordered list'**
  String get editorOrderedList;

  /// A formatting-bar button's tooltip: a list of checkboxes.
  ///
  /// In en, this message translates to:
  /// **'Task list'**
  String get editorTaskList;

  /// A formatting-bar button's tooltip: a block quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get editorQuote;

  /// A formatting-bar button's tooltip: a fenced code block.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get editorCode;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get editorTable;

  /// A formatting-bar button's tooltip: a horizontal rule (---).
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get editorRule;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get editorLink;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get editorImage;

  /// A formatting-bar button's tooltip.
  ///
  /// In en, this message translates to:
  /// **'Footnote'**
  String get editorFootnote;

  /// A formatting-bar button's tooltip: a GitHub alert block (> [!NOTE]).
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get editorAlert;

  /// Tooltip on the ⋯ that holds the buttons a narrow row cannot.
  ///
  /// In en, this message translates to:
  /// **'More formatting'**
  String get editorMoreFormatting;

  /// No description provided for @editorCloseTabDiscards.
  ///
  /// In en, this message translates to:
  /// **'Closing the tab discards the edit that has not reached the disk.'**
  String get editorCloseTabDiscards;

  /// No description provided for @editorCloseTabDiskKept.
  ///
  /// In en, this message translates to:
  /// **'The file on disk is unchanged.'**
  String get editorCloseTabDiskKept;

  /// No description provided for @editorKeepTabOpen.
  ///
  /// In en, this message translates to:
  /// **'Keep the tab open'**
  String get editorKeepTabOpen;

  /// Tooltip on a tab's close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get editorCloseTabTooltip;

  /// No description provided for @editorExportAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF…'**
  String get editorExportAsPdf;

  /// No description provided for @editorExportAsHtml.
  ///
  /// In en, this message translates to:
  /// **'Export as HTML…'**
  String get editorExportAsHtml;

  /// No description provided for @editorCloseTab.
  ///
  /// In en, this message translates to:
  /// **'Close tab'**
  String get editorCloseTab;

  /// After a tab's struck-through name: the file is gone from the disk.
  ///
  /// In en, this message translates to:
  /// **'(deleted)'**
  String get editorTabDeleted;

  /// The whole body of a tab whose file is not text.
  ///
  /// In en, this message translates to:
  /// **'A binary file — not shown as text.'**
  String get editorBinaryFile;

  /// Under the wikilink completion list: the keys that drive it. Key names stay as on the keyboard.
  ///
  /// In en, this message translates to:
  /// **'↑↓ to choose · Enter to insert · Esc to close'**
  String get editorCompletionHint;

  /// Tooltip on the R mark beside a block the diff removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get previewRemoved;

  /// A wikilink that points at nothing.
  ///
  /// In en, this message translates to:
  /// **'No document called {target}.'**
  String previewNoDocumentCalled(String target);

  /// Creates the document a missing wikilink names.
  ///
  /// In en, this message translates to:
  /// **'Create it'**
  String get previewCreateIt;

  /// No description provided for @previewDocumentEmpty.
  ///
  /// In en, this message translates to:
  /// **'This document is empty.'**
  String get previewDocumentEmpty;

  /// One of the two search scopes: This file · Whole space.
  ///
  /// In en, this message translates to:
  /// **'This file'**
  String get searchThisFile;

  /// One of the two search scopes: every document in the open folder.
  ///
  /// In en, this message translates to:
  /// **'Whole space'**
  String get searchWholeSpace;

  /// How many documents matched the search.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document} other{{count} documents}}'**
  String searchDocumentCount(int count);

  /// No description provided for @searchReadingTheSpace.
  ///
  /// In en, this message translates to:
  /// **'Reading the space…'**
  String get searchReadingTheSpace;

  /// No description provided for @searchNoDocumentSaysThat.
  ///
  /// In en, this message translates to:
  /// **'No document says that.'**
  String get searchNoDocumentSaysThat;

  /// No description provided for @searchIndexCorrupted.
  ///
  /// In en, this message translates to:
  /// **'The index could not be built — reopen the space to try again.'**
  String get searchIndexCorrupted;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'This space could not be searched.'**
  String get searchFailed;

  /// No description provided for @searchOpenADocument.
  ///
  /// In en, this message translates to:
  /// **'Open a document to search inside it.'**
  String get searchOpenADocument;

  /// No description provided for @searchTypeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search this document.'**
  String get searchTypeToSearch;

  /// No description provided for @searchNothingInDocument.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {name} says that.'**
  String searchNothingInDocument(String name);

  /// How many times the search matched in the open document.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 occurrence in {name}} other{{count} occurrences in {name}}}'**
  String searchOccurrenceCount(int count, String name);

  /// No description provided for @searchReplaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get searchReplaceAll;

  /// No description provided for @searchReplaceThisOne.
  ///
  /// In en, this message translates to:
  /// **'Replace this one'**
  String get searchReplaceThisOne;

  /// No description provided for @searchSkipThisOne.
  ///
  /// In en, this message translates to:
  /// **'Skip this one'**
  String get searchSkipThisOne;

  /// Hint in the replace box.
  ///
  /// In en, this message translates to:
  /// **'Replace with'**
  String get searchReplaceWith;

  /// Hint in the search box.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear the search'**
  String get searchClear;

  /// Tooltip on the replace toggle while the replace box is open; keys is the shortcut.
  ///
  /// In en, this message translates to:
  /// **'Hide replace ({keys})'**
  String searchHideReplace(String keys);

  /// Tooltip on the replace toggle; keys is the shortcut.
  ///
  /// In en, this message translates to:
  /// **'Replace ({keys})'**
  String searchShowReplace(String keys);

  /// The left column's caption while it shows search results; capitals, as every panel caption.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get fileTreeSearchCaption;

  /// The left column's caption over the file tree; capitals, as every panel caption.
  ///
  /// In en, this message translates to:
  /// **'EXPLORER'**
  String get fileTreeExplorerCaption;

  /// Tooltip on the + beside the explorer's caption.
  ///
  /// In en, this message translates to:
  /// **'New document'**
  String get fileTreeNewDocument;

  /// Tooltip on the explorer's ⋮.
  ///
  /// In en, this message translates to:
  /// **'Explorer menu'**
  String get fileTreeMenu;

  /// No description provided for @fileTreeNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get fileTreeNewFolder;

  /// No description provided for @fileTreeCollapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get fileTreeCollapseAll;

  /// No description provided for @fileTreeReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the folder…'**
  String get fileTreeReading;

  /// No description provided for @fileTreeFolderMissing.
  ///
  /// In en, this message translates to:
  /// **'This folder is no longer there.'**
  String get fileTreeFolderMissing;

  /// No description provided for @fileTreeAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'TOM is not allowed to read this folder.'**
  String get fileTreeAccessDenied;

  /// No description provided for @fileTreeUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This folder could not be read.'**
  String get fileTreeUnreadable;

  /// No description provided for @fileTreeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This folder holds nothing yet.'**
  String get fileTreeEmpty;

  /// No description provided for @accountTooltip.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTooltip;

  /// Caption over git's user.name and user.email; capitals, as every caption.
  ///
  /// In en, this message translates to:
  /// **'COMMITS AS'**
  String get accountCommitsAs;

  /// No description provided for @accountNameNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get accountNameNotSet;

  /// Under 'Not set': git refuses to commit without user.name and user.email.
  ///
  /// In en, this message translates to:
  /// **'git asks for a name and an email first'**
  String get accountIdentityMissing;

  /// No description provided for @accountGithub.
  ///
  /// In en, this message translates to:
  /// **'GITHUB'**
  String get accountGithub;

  /// After a login: the account was read from the gh command-line tool. gh is a program's name.
  ///
  /// In en, this message translates to:
  /// **'via gh'**
  String get accountViaGh;

  /// No description provided for @accountViaGit.
  ///
  /// In en, this message translates to:
  /// **'via git'**
  String get accountViaGit;

  /// No description provided for @accountViaSsh.
  ///
  /// In en, this message translates to:
  /// **'via SSH'**
  String get accountViaSsh;

  /// Under the account: the login belongs to the machine's own gh, and TOM stores nothing.
  ///
  /// In en, this message translates to:
  /// **'This computer\'s GitHub login, through gh — TOM keeps no copy.'**
  String get accountLoginViaGh;

  /// No description provided for @accountLoginViaGit.
  ///
  /// In en, this message translates to:
  /// **'This computer\'s GitHub login, through git — TOM keeps no copy.'**
  String get accountLoginViaGit;

  /// No description provided for @accountLoginViaSsh.
  ///
  /// In en, this message translates to:
  /// **'This computer\'s GitHub login, through SSH — TOM keeps no copy.'**
  String get accountLoginViaSsh;

  /// No description provided for @accountNoCredentials.
  ///
  /// In en, this message translates to:
  /// **'No GitHub credentials on this computer'**
  String get accountNoCredentials;

  /// gh auth login is a command and stays as it is.
  ///
  /// In en, this message translates to:
  /// **'TOM uses what git and gh already have — run gh auth login, or push once over HTTPS.'**
  String get accountNoCredentialsHint;

  /// No description provided for @accountThisRepository.
  ///
  /// In en, this message translates to:
  /// **'THIS REPOSITORY'**
  String get accountThisRepository;

  /// Tooltip on the repository's name: opens its page in the browser.
  ///
  /// In en, this message translates to:
  /// **'Open on GitHub'**
  String get accountOpenRepository;

  /// No description provided for @accountColumnRead.
  ///
  /// In en, this message translates to:
  /// **'READ'**
  String get accountColumnRead;

  /// Column: may open a pull request here. An abbreviation; keep it short.
  ///
  /// In en, this message translates to:
  /// **'PR'**
  String get accountColumnPullRequest;

  /// No description provided for @accountColumnPush.
  ///
  /// In en, this message translates to:
  /// **'PUSH'**
  String get accountColumnPush;

  /// No description provided for @accountColumnMerge.
  ///
  /// In en, this message translates to:
  /// **'MERGE'**
  String get accountColumnMerge;

  /// No description provided for @accountColumnAdmin.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get accountColumnAdmin;

  /// No description provided for @accountAccessUnknown.
  ///
  /// In en, this message translates to:
  /// **'What you can do here shows once git or gh can reach GitHub.'**
  String get accountAccessUnknown;

  /// No description provided for @accountAccessSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH says who you are, not what you can do here.'**
  String get accountAccessSsh;

  /// In the GitHub section while the first reading is out: gh checks its tokens online, which takes seconds. git and gh are programs' names.
  ///
  /// In en, this message translates to:
  /// **'Asking git and gh who you are…'**
  String get accountAsking;

  /// Under the five dashes while the first reading is out: the permissions are not unknown, only not answered yet.
  ///
  /// In en, this message translates to:
  /// **'Known once the answer is in.'**
  String get accountAccessPending;

  /// What a screen reader says for a ticked column.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get accountCan;

  /// No description provided for @accountCannot.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get accountCannot;

  /// What a screen reader says for a column nobody could read.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get accountUnknown;

  /// The bottom panel's first tab: every command the app ran, as it ran it.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get panelCommands;

  /// After the tabs: how many commands ran since the window opened.
  ///
  /// In en, this message translates to:
  /// **'{count} this session'**
  String commandsThisSession(int count);

  /// No description provided for @commandsNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No command has run yet.'**
  String get commandsNoneYet;

  /// Tooltip on the copy glyph a row shows under the pointer.
  ///
  /// In en, this message translates to:
  /// **'Copy the command'**
  String get commandsCopy;

  /// An open row whose command wrote no output.
  ///
  /// In en, this message translates to:
  /// **'Printed nothing.'**
  String get commandsPrintedNothing;

  /// A failed command's exit code, before its duration.
  ///
  /// In en, this message translates to:
  /// **'exit {code}'**
  String commandsExit(int code);

  /// A command killed for its time, in place of the exit code.
  ///
  /// In en, this message translates to:
  /// **'did not finish'**
  String get commandsUnfinished;

  /// A program that could not even be started — not installed — in place of the exit code.
  ///
  /// In en, this message translates to:
  /// **'did not run'**
  String get commandsDidNotRun;

  /// No description provided for @commandsMilliseconds.
  ///
  /// In en, this message translates to:
  /// **'{value} ms'**
  String commandsMilliseconds(int value);

  /// No description provided for @commandsSeconds.
  ///
  /// In en, this message translates to:
  /// **'{value} s'**
  String commandsSeconds(double value);

  /// No description provided for @commandsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} s'**
  String commandsMinutes(int minutes, int seconds);

  /// Tooltip on the toggle between the two column toggles: the commands, and later a terminal.
  ///
  /// In en, this message translates to:
  /// **'Show the bottom panel'**
  String get workspaceShowBottom;

  /// No description provided for @workspaceHideBottom.
  ///
  /// In en, this message translates to:
  /// **'Hide the bottom panel'**
  String get workspaceHideBottom;

  /// Tooltip on the × at the right of the bottom panel's tabs.
  ///
  /// In en, this message translates to:
  /// **'Close the panel'**
  String get workspaceClosePanel;

  /// A failure band's second action: opens the commands panel on the command that failed.
  ///
  /// In en, this message translates to:
  /// **'Show the command'**
  String get remoteShowTheCommand;

  /// The bottom panel's second tab: the person's own shell, at the repository's root.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get panelTerminal;

  /// After the tabs while the terminal shows: the shell's name and the folder it opened in, the home folder spelled ~.
  ///
  /// In en, this message translates to:
  /// **'{shell} · {folder}'**
  String terminalPlace(String shell, String folder);

  /// The terminal's body when the person's shell could not be started.
  ///
  /// In en, this message translates to:
  /// **'The shell would not start.'**
  String get terminalFailed;

  /// Written into the terminal, dimmed, when the shell exits; the next key starts a new one.
  ///
  /// In en, this message translates to:
  /// **'The shell ended with {code}. Press any key for another.'**
  String terminalExited(int code);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

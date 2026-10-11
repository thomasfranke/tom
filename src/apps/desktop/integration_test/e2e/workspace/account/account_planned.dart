/// Planned, not written: the account. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedAccount() {
  plannedScenario(
    'Reads the account through gh',
    group: 'Workspace',
    submenu: 'Account',
    describe:
        'Initials, name and email; via gh; with gh api refusing five dashes; '
        'with it answering ticks and dashes; Esc and a click outside; no '
        'token in the commands.',
    survey: '4-33',
    rule:
        'workspace/the-account/doc.md — TOM signs nobody in; it reads what '
        'gh already knows.',
    control: 'the account button and its popover',
    fixture: 'docs-proposing with the fake gh answering api repos/acme/docs',
    steps: <String>[
      'the popover shows initials, name and email',
      'it says via gh',
      'with gh api refusing the five permissions read as dashes',
      'with gh api answering they read as ticks and dashes',
      'Esc and a click outside close it',
      'the Commands panel holds no token',
    ],
  );
  plannedScenario(
    'Chooses which GitHub account a repository uses',
    group: 'Workspace',
    submenu: 'Account',
    describe:
        'Two logins listed and nothing else; the choice is in the '
        'repository git config and survives a relaunch; another repository '
        'is unaffected.',
    survey: '4-34',
    rule:
        'workspace/the-account/doc.md — the account is chosen per '
        'repository (tom.githubAccount).',
    control: 'the account select in the popover',
    fixture: 'docs-proposing and docs-in-repo; the fake gh takes two logins',
    steps: <String>[
      'two logins are listed',
      'choosing the second writes tom.githubAccount',
      'a relaunch keeps it',
      'another repository still shows its own',
    ],
  );
  plannedScenario(
    'Knows an SSH login and not what it may do',
    group: 'Workspace',
    submenu: 'Account',
    describe:
        'A fake ssh on the bare PATH: via SSH, five dashes, the line saying '
        'so.',
    survey: '5-14',
    rule:
        'workspace/the-account/doc.md — an SSH login proves a key, not '
        'permissions.',
    control: 'the account popover',
    fixture: 'docs-proposing with a fake ssh',
    steps: <String>[
      'the popover says via SSH',
      'the five permissions read as dashes',
      'the line says what is not known',
    ],
  );
  plannedScenario(
    'Reads the account with nothing known',
    group: 'Workspace',
    submenu: 'Account',
    describe:
        'Adds to Says who commits: the name and email, the hint, no '
        'repository section for an origin that is not GitHub, the Home '
        'popover in its own step.',
    survey: '5-17',
    rule: 'workspace/the-account/doc.md — with no login nothing is claimed.',
    control: 'the account popover on Home and in a space',
    fixture: 'docs-in-repo',
    steps: <String>[
      'the popover shows the git name and email',
      'the hint says nothing is known without a login',
      'no repository section for a non-GitHub origin',
      'the popover on Home',
    ],
  );
  plannedScenario(
    'Says a git identity is not set',
    group: 'Workspace',
    submenu: 'Account',
    describe:
        'With no user.name and user.email, the account says Not set and '
        'git is asked for both first.',
    survey: '5-21',
    rule: 'workspace/the-account/doc.md — Not set is said.',
    control: 'the account popover',
    fixture: 'docs-in-repo with the identity removed from its config',
    steps: <String>[
      'the popover says Not set',
      'git was asked for both name and email',
    ],
  );
}

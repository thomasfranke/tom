import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const BranchBaseService service = BranchBaseService();

  BranchNameValueObject name(String value) => BranchNameValueObject(value);

  BranchRefValueObject local(String branch) =>
      BranchRefValueObject(name: name(branch));

  BranchRefValueObject remote(String branch) =>
      BranchRefValueObject(name: name(branch), remote: 'origin');

  BranchStandingValueObject standing(
    BranchRefValueObject branch, {
    required int behind,
    int ahead = 0,
    bool sharesHistory = true,
  }) => BranchStandingValueObject(
    branch: branch,
    ahead: ahead,
    behind: behind,
    sharesHistory: sharesHistory,
  );

  group('compares against HEAD', () {
    test('when detached', () {
      expect(
        service.choose(
          current: null,
          standings: <BranchStandingValueObject>[
            standing(local('main'), behind: 1),
          ],
        ),
        isNull,
      );
    });

    test('on the default branch, whatever else is near', () {
      expect(
        service.choose(
          current: name('main'),
          defaultBranch: name('main'),
          standings: <BranchStandingValueObject>[
            standing(local('old-feature'), behind: 1),
          ],
        ),
        isNull,
      );
    });

    test('when no other branch is there to have come from', () {
      expect(
        service.choose(
          current: name('notes'),
          upstream: name('origin/notes'),
          standings: <BranchStandingValueObject>[
            standing(local('notes'), behind: 0),
            standing(remote('notes'), behind: 2),
          ],
        ),
        isNull,
      );
    });
  });

  group('deduced', () {
    test('is the branch HEAD has come the least way from', () {
      expect(
        service.choose(
          current: name('feat/glossary'),
          defaultBranch: name('main'),
          standings: <BranchStandingValueObject>[
            standing(local('main'), behind: 3),
            standing(local('develop'), behind: 1),
            standing(local('feat/glossary'), behind: 0),
          ],
        ),
        local('develop'),
      );
    });

    test('is never a branch that already holds HEAD and more', () {
      // `feat/notes` was started from here and moved on: it came *from*
      // develop, so it is no base of develop's.
      expect(
        service.choose(
          current: name('develop'),
          defaultBranch: name('main'),
          standings: <BranchStandingValueObject>[
            standing(local('feat/notes'), behind: 0, ahead: 2),
            standing(local('main'), behind: 4),
          ],
        ),
        local('main'),
      );
    });

    test('takes a branch at the very same commit', () {
      // Started outside TOM and not committed on yet.
      expect(
        service.choose(
          current: name('feat/new'),
          defaultBranch: name('main'),
          standings: <BranchStandingValueObject>[
            standing(local('develop'), behind: 0),
            standing(local('main'), behind: 2),
          ],
        ),
        local('develop'),
      );
    });

    test('is never an unrelated history', () {
      expect(
        service.choose(
          current: name('feat/notes'),
          standings: <BranchStandingValueObject>[
            standing(local('gh-pages'), behind: 1, sharesHistory: false),
            standing(local('main'), behind: 2),
          ],
        ),
        local('main'),
      );
    });

    test('skips the branch\'s own upstream and its copy on a remote', () {
      expect(
        service.choose(
          current: name('feat/notes'),
          upstream: name('origin/feat/notes'),
          standings: <BranchStandingValueObject>[
            standing(remote('feat/notes'), behind: 1),
            standing(
              BranchRefValueObject(
                name: name('feat/notes'),
                remote: 'upstream',
              ),
              behind: 1,
            ),
            standing(local('main'), behind: 2),
          ],
        ),
        local('main'),
      );
    });

    test('a tie goes to the default branch', () {
      expect(
        service.choose(
          current: name('feat/notes'),
          defaultBranch: name('main'),
          standings: <BranchStandingValueObject>[
            standing(local('another'), behind: 1),
            standing(remote('main'), behind: 1),
          ],
        ),
        remote('main'),
      );
    });

    test('then to a local branch over a remote\'s copy', () {
      expect(
        service.choose(
          current: name('feat/notes'),
          defaultBranch: name('main'),
          standings: <BranchStandingValueObject>[
            standing(remote('develop'), behind: 1),
            standing(local('develop'), behind: 1),
          ],
        ),
        local('develop'),
      );
    });

    test('the local name wins when both point at the default branch', () {
      expect(
        service.choose(
          current: name('feat/notes'),
          defaultBranch: name('main'),
          standings: <BranchStandingValueObject>[
            standing(remote('main'), behind: 2),
            standing(local('main'), behind: 2),
          ],
        ),
        local('main'),
      );
    });

    test('a tie nothing else breaks goes by name, whatever the order', () {
      final List<BranchStandingValueObject> standings =
          <BranchStandingValueObject>[
            standing(local('zeta'), behind: 1),
            standing(local('alpha'), behind: 1),
          ];

      expect(
        service.choose(current: name('feat/notes'), standings: standings),
        local('alpha'),
      );
      expect(
        service.choose(
          current: name('feat/notes'),
          standings: standings.reversed.toList(),
        ),
        local('alpha'),
      );
    });
  });

  group('recorded', () {
    test('wins over a nearer branch', () {
      expect(
        service.choose(
          current: name('feat/notes'),
          recorded: name('main'),
          standings: <BranchStandingValueObject>[
            standing(local('develop'), behind: 1),
            standing(local('main'), behind: 3),
          ],
        ),
        local('main'),
      );
    });

    test('is the remote\'s copy when only that is left', () {
      expect(
        service.choose(
          current: name('feat/notes'),
          recorded: name('develop'),
          standings: <BranchStandingValueObject>[
            standing(remote('develop'), behind: 2),
            standing(local('main'), behind: 1),
          ],
        ),
        remote('develop'),
      );
    });

    test('is deduced past once the branch it names is gone', () {
      expect(
        service.choose(
          current: name('feat/notes'),
          recorded: name('deleted'),
          standings: <BranchStandingValueObject>[
            standing(local('main'), behind: 1),
          ],
        ),
        local('main'),
      );
    });

    test('does not survive being on the default branch', () {
      expect(
        service.choose(
          current: name('main'),
          defaultBranch: name('main'),
          recorded: name('develop'),
          standings: <BranchStandingValueObject>[
            standing(local('develop'), behind: 1),
          ],
        ),
        isNull,
      );
    });
  });

  test('a remote copy is named the way git resolves it', () {
    expect(remote('develop').spec, 'origin/develop');
    expect(local('develop').spec, 'develop');
  });
}

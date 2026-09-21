import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  // The normal case, and the one the rest of the app gets wrong if the
  // conversions are wrong: a folder inside a repository that holds code.
  final Space nested = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  // The other case: the repository itself was opened.
  final Space atRoot = Space(
    root: '/code/app',
    repositoryRoot: '/code/app',
    name: 'app',
  );

  group('construction', () {
    test('accepts a repository that encloses the folder', () {
      expect(nested.root, '/code/app/docs');
      expect(atRoot.repositoryRoot, atRoot.root);
    });

    test('refuses a repository that does not enclose the folder', () {
      expect(
        () => Space(
          root: '/code/app/docs',
          repositoryRoot: '/code/other',
          name: 'docs',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('is not fooled by a sibling with a shared prefix', () {
      // `/code/app-docs` starts with `/code/app` as a string and is a
      // different folder. The separator is what makes it a containment test.
      expect(
        () => Space(
          root: '/code/app-docs',
          repositoryRoot: '/code/app',
          name: 'app-docs',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts the two spellings the OS and git each produce', () {
      // The folder picker returns backslashes; `git rev-parse` returns
      // forward slashes and may lower-case the drive letter. Same folder.
      expect(
        Space(
          root: r'C:\code\app\docs',
          repositoryRoot: 'c:/code/app',
          name: 'docs',
        ).rootWithinRepository?.value,
        'docs',
      );
    });

    test('accepts a repository path with a trailing separator', () {
      expect(
        Space(
          root: '/code/app/docs',
          repositoryRoot: '/code/app/',
          name: 'docs',
        ).rootWithinRepository?.value,
        'docs',
      );
    });
  });

  group('rootWithinRepository', () {
    test('is where the folder sits inside the repository', () {
      expect(nested.rootWithinRepository?.value, 'docs');
      expect(
        Space(
          root: '/code/app/docs/public',
          repositoryRoot: '/code/app',
          name: 'public',
        ).rootWithinRepository?.value,
        'docs/public',
      );
    });

    test('is null when the repository itself was opened', () {
      expect(atRoot.rootWithinRepository, isNull);
    });
  });

  group('toRepoRelative', () {
    test('prefixes the folder git does not know it is inside', () {
      expect(
        nested.toRepoRelative(SpaceRelativePath('guide.md')).value,
        'docs/guide.md',
      );
      expect(
        nested.toRepoRelative(SpaceRelativePath('adr/001.md')).value,
        'docs/adr/001.md',
      );
    });

    test('changes nothing when the space is the repository', () {
      expect(
        atRoot.toRepoRelative(SpaceRelativePath('docs/guide.md')).value,
        'docs/guide.md',
      );
    });
  });

  group('toSpaceRelative', () {
    test('drops the prefix for a path inside the space', () {
      expect(
        nested.toSpaceRelative(RepoRelativePath('docs/guide.md'))?.value,
        'guide.md',
      );
    });

    test('answers null for a path the space does not contain', () {
      // Not a failure: git reports the whole repository, so a status on a
      // space opened at `docs/` routinely names source files.
      expect(nested.toSpaceRelative(RepoRelativePath('lib/main.dart')), isNull);
    });

    test('is not fooled by a sibling folder with a shared prefix', () {
      expect(
        nested.toSpaceRelative(RepoRelativePath('docs-old/guide.md')),
        isNull,
      );
    });

    test('answers null for the prefix itself, which names no document', () {
      expect(nested.toSpaceRelative(RepoRelativePath('docs')), isNull);
    });

    test('round-trips with toRepoRelative', () {
      final SpaceRelativePath path = SpaceRelativePath('adr/001.md');
      expect(nested.toSpaceRelative(nested.toRepoRelative(path)), path);
    });
  });

  group('relativize', () {
    test('turns what a listing reports back into a space path', () {
      expect(
        nested.relativize('/code/app/docs/adr/001.md')?.value,
        'adr/001.md',
      );
    });

    test('accepts the other platform spelling', () {
      final Space windows = Space(
        root: r'C:\code\app\docs',
        repositoryRoot: r'C:\code\app',
        name: 'docs',
      );

      expect(windows.relativize(r'C:\code\app\docs\a.md')?.value, 'a.md');
      expect(windows.relativize('c:/code/app/docs/a.md')?.value, 'a.md');
    });

    test('answers null for the root itself, which names no entry', () {
      expect(nested.relativize('/code/app/docs'), isNull);
    });

    test('answers null for anything outside the space', () {
      expect(nested.relativize('/code/app/lib/main.dart'), isNull);
      expect(nested.relativize('/etc/passwd'), isNull);
    });

    test('is not fooled by a sibling with a shared prefix', () {
      expect(nested.relativize('/code/app/docs-old/a.md'), isNull);
    });

    test('round-trips with absolutePathOf', () {
      final SpaceRelativePath path = SpaceRelativePath('adr/001.md');
      expect(nested.relativize(nested.absolutePathOf(path)), path);
    });
  });

  group('absolutePathOf', () {
    test('joins onto the root the user opened', () {
      expect(
        nested.absolutePathOf(SpaceRelativePath('adr/001.md')),
        '/code/app/docs/adr/001.md',
      );
    });

    test('keeps the separators the platform gave it', () {
      expect(
        Space(
          root: r'C:\code\app\docs',
          repositoryRoot: r'C:\code\app',
          name: 'docs',
        ).absolutePathOf(SpaceRelativePath('adr/001.md')),
        r'C:\code\app\docs\adr\001.md',
      );
    });

    test('does not double the separator on a root that ends with one', () {
      expect(
        Space(
          root: '/code/app/',
          repositoryRoot: '/code/app',
          name: 'app',
        ).absolutePathOf(SpaceRelativePath('a.md')),
        '/code/app/a.md',
      );
    });
  });

  group('nameOfFolder', () {
    test('is the last segment of the path', () {
      expect(Space.nameOfFolder('/code/app/docs'), 'docs');
      expect(Space.nameOfFolder('/code/app/docs/'), 'docs');
      expect(Space.nameOfFolder(r'C:\code\app\docs'), 'docs');
    });

    test('falls back to the path itself when there is no segment', () {
      expect(Space.nameOfFolder('/'), '/');
    });
  });

  group('equality', () {
    // Built at runtime: const instances are canonicalised, which would make
    // this pass with no generated `==` at all.
    Space spaceNamed(String name) =>
        Space(root: '/code/app', repositoryRoot: '/code/app', name: name);

    test('compares by value', () {
      expect(spaceNamed('app'), spaceNamed('app'));
      expect(spaceNamed('app').hashCode, spaceNamed('app').hashCode);
      expect(spaceNamed('app'), isNot(spaceNamed('docs')));
    });
  });
}

/// Wikilinks over a real folder: the links out of the real parser, the
/// listing out of [SpaceRepositoryImpl] on a real disk, and the resolver and
/// the completion deciding over both — names as a disk really holds them.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String root;
  late SpaceEntity space;
  late SpaceRepositoryImpl spaces;

  const MarkdownBlockReaderImpl reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );
  const WikilinkResolverService resolver = WikilinkResolverService();
  const WikilinkCompletionService completion = WikilinkCompletionService();

  void put(String relativePath) {
    File('$root/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('# ${relativePath.split('/').last}\n');
  }

  /// The space as the tree would list it, off the disk.
  Future<List<SpaceEntryValueObject>> listing() async {
    final Result<List<SpaceEntryValueObject>, SpaceFailure> listed =
        await spaces.entries(space);
    return (listed as Success<List<SpaceEntryValueObject>, SpaceFailure>).value;
  }

  /// The one link [markdown] holds, read by the real parser.
  Future<WikilinkValueObject> linkOf(String markdown) async {
    final Result<ParsedDocumentValueObject, DocumentFailure> read = await reader
        .read(
          DocumentEntity(
            path: SpaceRelativePathValueObject('index.md'),
            content: markdown,
          ),
        );
    return (read as Success<ParsedDocumentValueObject, DocumentFailure>)
        .value
        .wikilinks
        .single;
  }

  /// What `[[written]]` in a document points at in the folder on disk.
  Future<WikilinkTargetValueObject> resolve(String written) async =>
      resolver.resolve(await linkOf('See [[$written]].\n'), await listing());

  Matcher resolvedTo(String path) => WikilinkTargetValueObject.resolved(
    SpaceRelativePathValueObject(path),
  ).toMatcher();

  /// What `[[` offers once [typed] follows it.
  Future<List<WikilinkCandidateValueObject>> offered(String typed) async {
    final String buffer = 'See [[$typed';
    return completion
        .complete(buffer, buffer.length, await listing())!
        .candidates;
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_wikilinks_');
    final String repositoryRoot = tempDir.resolveSymbolicLinksSync().replaceAll(
      r'\',
      '/',
    );
    root = '$repositoryRoot/docs';
    Directory(root).createSync();
    space = SpaceEntity(
      root: root,
      repositoryRoot: repositoryRoot,
      name: 'docs',
    );
    spaces = SpaceRepositoryImpl(
      spaces: SpaceDataSource(
        filesystem: const DartIoFilesystemImpl(),
        // A listing never asks git; one that did would fail here.
        gitClientFor: (String folder) =>
            throw StateError('a listing asked git about $folder'),
      ),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('a name', () {
    test('finds its document wherever it sits, the `.md` optional', () async {
      put('technical/architecture.md');
      put('readme.md');

      expect(
        await resolve('architecture'),
        resolvedTo('technical/architecture.md'),
      );
      expect(
        await resolve('architecture.md'),
        resolvedTo('technical/architecture.md'),
      );
    });

    test('is what somebody remembered: its case on disk does not '
        'matter', () async {
      put('technical/Architecture.MD');
      put('README.md');

      expect(
        await resolve('architecture'),
        resolvedTo('technical/Architecture.MD'),
      );
      expect(await resolve('ReadMe'), resolvedTo('README.md'));
    });

    test('with a space, a dash or an emoji is one name', () async {
      put('guides/release notes.md');
      put('guides/-draft.md');
      put('ideas \u{1F4A1}.md');

      expect(
        await resolve('release notes'),
        resolvedTo('guides/release notes.md'),
      );
      expect(await resolve('-draft'), resolvedTo('guides/-draft.md'));
      expect(
        await resolve('ideas \u{1F4A1}'),
        resolvedTo('ideas \u{1F4A1}.md'),
      );
    });

    test('with an accent finds the file written the same way', () async {
      put('revisão/ação.md');

      expect(await resolve('ação'), resolvedTo('revisão/ação.md'));
      expect(await resolve('AÇÃO'), resolvedTo('revisão/ação.md'));
    });

    test(
      'typed composed finds a file whose name the disk holds decomposed, '
      'and the reverse',
      () async {
        // `ação` as a letter and a combining mark — how a name arrives from
        // an HFS+ volume or a repository committed on one.
        put('decomposed/ação.md');
        put('composed/revisão.md');

        expect(
          (await resolve('ação')).destination?.value,
          startsWith('decomposed/'),
        );
        expect(
          (await resolve('revisão')).destination?.value,
          startsWith('composed/'),
        );
      },
      skip:
          'defect N-01 (new, to judge): the resolver compares code units, so '
          'a name typed in one normal form misses a file stored in the other',
    );

    test('held twice is ambiguous, and names both', () async {
      put('product/export/doc.md');
      put('product/wikilinks/doc.md');

      expect(
        await resolve('doc'),
        WikilinkTargetValueObject.ambiguous(<SpaceRelativePathValueObject>[
          SpaceRelativePathValueObject('product/export/doc.md'),
          SpaceRelativePathValueObject('product/wikilinks/doc.md'),
        ]),
      );
    });

    test('nobody has is missing', () async {
      put('readme.md');

      expect(
        await resolve('roadmap'),
        const WikilinkTargetValueObject.missing(),
      );
    });
  });

  group('a path', () {
    test('finds exactly the document written, among namesakes', () async {
      put('product/export/doc.md');
      put('product/wikilinks/doc.md');

      expect(
        await resolve('product/wikilinks/doc'),
        resolvedTo('product/wikilinks/doc.md'),
      );
    });

    test('through a folder with a space', () async {
      put('release notes/2026/first draft.md');

      expect(
        await resolve('release notes/2026/first draft'),
        resolvedTo('release notes/2026/first draft.md'),
      );
    });

    test('is what the disk said: another case is another path', () async {
      put('technical/architecture.md');

      expect(
        await resolve('Technical/Architecture'),
        const WikilinkTargetValueObject.missing(),
      );
    });
  });

  group('what is never a target', () {
    test('a folder, even one called like a document', () async {
      put('architecture.md/inside.txt');

      expect(
        await resolve('architecture'),
        const WikilinkTargetValueObject.missing(),
      );
      expect(await offered('arch'), isEmpty);
    });

    test('a file that is not markdown', () async {
      put('architecture.txt');
      put('architecture.pdf');
      put('architecture');

      expect(
        await resolve('architecture'),
        const WikilinkTargetValueObject.missing(),
      );
      expect(await offered('arch'), isEmpty);
    });

    test(
      'anything under `.git`, a folder or the file a worktree has',
      () async {
        put('.git/description.md');
        put('vendored/.git/notes.md');
        put('readme.md');

        expect(
          await resolve('description'),
          const WikilinkTargetValueObject.missing(),
        );
        expect(
          await resolve('notes'),
          const WikilinkTargetValueObject.missing(),
        );
        expect(
          <String>[
            for (final WikilinkCandidateValueObject candidate in await offered(
              '',
            ))
              candidate.path.value,
          ],
          <String>['readme.md'],
        );
      },
    );

    test('a temporary a crashed save left beside its document', () async {
      put('guide.md');
      put('guide.md.4242.7.tom-tmp');

      expect(await resolve('guide'), resolvedTo('guide.md'));
      expect(await offered('guide'), hasLength(1));
    });
  });

  group('a document in a dotfolder', () {
    test('is a target like any other', () async {
      put('.notes/hidden.md');

      expect(await resolve('hidden'), resolvedTo('.notes/hidden.md'));
      expect((await offered('hid')).single.target, 'hidden');
    });
  });

  group('what `[[` writes', () {
    test('is the name for a document the space holds once', () async {
      put('technical/architecture.md');
      put('readme.md');

      expect(await offered('arch'), <WikilinkCandidateValueObject>[
        WikilinkCandidateValueObject(
          path: SpaceRelativePathValueObject('technical/architecture.md'),
          target: 'architecture',
        ),
      ]);
    });

    test('is the path for a name the space holds twice', () async {
      put('product/export/doc.md');
      put('product/wikilinks/doc.md');

      expect(
        <String>[
          for (final WikilinkCandidateValueObject candidate in await offered(
            'doc',
          ))
            candidate.target,
        ],
        <String>['product/export/doc', 'product/wikilinks/doc'],
      );
    });

    test('is the path too when the two differ only by case', () async {
      put('a/Guide.md');
      put('b/guide.md');

      expect(
        <String>[
          for (final WikilinkCandidateValueObject candidate in await offered(
            'gui',
          ))
            candidate.target,
        ],
        <String>['a/Guide', 'b/guide'],
      );
    });

    test('always resolves to the document that was chosen: every candidate '
        'of a real folder, written into a document and read back', () async {
      for (final String path in <String>[
        'readme.md',
        'README/index.md',
        'product/export/doc.md',
        'product/wikilinks/doc.md',
        'guides/release notes.md',
        'guides/-draft.md',
        'guides/Getting Started.MD',
        'revisão/ação.md',
        '.notes/hidden.md',
        'deep/er/and/deeper/still.md',
        'v1.2/notes.v2.md',
      ]) {
        put(path);
      }
      final List<SpaceEntryValueObject> entries = await listing();

      final List<WikilinkCandidateValueObject> candidates = await offered('');
      expect(candidates, hasLength(11));

      for (final WikilinkCandidateValueObject candidate in candidates) {
        expect(
          resolver.resolve(
            await linkOf('See [[${candidate.target}]].\n'),
            entries,
          ),
          WikilinkTargetValueObject.resolved(candidate.path),
          reason: '[[${candidate.target}]]',
        );
      }
    });

    test('resolves for a document at the root that shares its name with one '
        'in a folder', () async {
      put('readme.md');
      put('archive/readme.md');
      final List<SpaceEntryValueObject> entries = await listing();
      final List<WikilinkCandidateValueObject> candidates = await offered(
        'read',
      );

      // Both, or the loop below proves nothing.
      expect(candidates, hasLength(2));
      for (final WikilinkCandidateValueObject candidate in candidates) {
        expect(
          resolver.resolve(
            await linkOf('See [[${candidate.target}]].\n'),
            entries,
          ),
          WikilinkTargetValueObject.resolved(candidate.path),
          reason: '[[${candidate.target}]]',
        );
      }
    });

    test('a name holding a character the link syntax reads — `#`, `|` — is '
        'not offered, and everything that is offered resolves', () async {
      // Written into a link, `#` starts an anchor and `|` a label: the
      // parser would cut the name there (decision D29). An ordinary
      // markdown link still reaches these.
      put('languages/c# notes.md');
      put('either|or.md');
      put('c#/intro.md');
      put('plain.md');
      final List<SpaceEntryValueObject> entries = await listing();
      final List<WikilinkCandidateValueObject> candidates = await offered('');

      expect(<String>[
        for (final WikilinkCandidateValueObject it in candidates) it.target,
      ], unorderedEquals(<String>['plain', 'intro']));
      for (final WikilinkCandidateValueObject candidate in candidates) {
        expect(
          resolver.resolve(
            await linkOf('See [[${candidate.target}]].\n'),
            entries,
          ),
          WikilinkTargetValueObject.resolved(candidate.path),
          reason: '[[${candidate.target}]]',
        );
      }
    });
  });
}

extension on WikilinkTargetValueObject {
  /// Equality as a matcher, so a helper can hand one back.
  Matcher toMatcher() => equals(this);
}

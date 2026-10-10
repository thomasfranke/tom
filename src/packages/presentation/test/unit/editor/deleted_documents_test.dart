import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late ProviderContainer container;
  late _Holding editor;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject guide = SpaceRelativePathValueObject(
    'guide.md',
  );
  final RepoRelativePathValueObject build = RepoRelativePathValueObject(
    'ci/build.yml',
  );

  GitStatusValueObject statusOf(Map<String, FileStateEnum> entries) =>
      GitStatusValueObject(
        branch: BranchNameValueObject('main'),
        upstream: null,
        ahead: 0,
        behind: 0,
        entries: <StatusEntryValueObject>[
          for (final MapEntry<String, FileStateEnum> each in entries.entries)
            StatusEntryValueObject(
              path: RepoRelativePathValueObject(each.key),
              state: each.value,
              isStaged: false,
            ),
        ],
        isDetached: false,
      );

  setUp(() {
    container = ProviderContainer(
      overrides: <Override>[
        editorProvider.overrideWith(() => editor = _Holding()),
      ],
    );
    addTearDown(container.dispose);
    container.read(editorProvider);
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(guide)
      ..keep(DocumentTab.inSpace(guide))
      ..showOutside(build);
  });

  Set<DocumentTab> deleted() => container.read(deletedDocumentsProvider);

  test('an open tab git reports deleted is deleted, inside or outside', () {
    container
        .read(spaceSessionProvider.notifier)
        .observe(
          statusOf(<String, FileStateEnum>{
            'docs/guide.md': FileStateEnum.deleted,
            'ci/build.yml': FileStateEnum.deleted,
            'docs/other.md': FileStateEnum.deleted,
          }),
        );

    expect(deleted(), <DocumentTab>{
      DocumentTab.inSpace(guide),
      DocumentTab.outside(build),
    });
  });

  test('a file git reports otherwise is not', () {
    container
        .read(spaceSessionProvider.notifier)
        .observe(
          statusOf(<String, FileStateEnum>{
            'docs/guide.md': FileStateEnum.modified,
          }),
        );

    expect(deleted(), isEmpty);
  });

  test('the buffer on screen found gone counts too', () {
    editor.held = EditorState.ready(
      saved: DocumentEntity(
        path: SpaceRelativePathValueObject(build.value),
        content: 'on: push\n',
      ),
      source: 'on: push\n',
      isOutside: true,
      isDeleted: true,
    );

    expect(deleted(), <DocumentTab>{DocumentTab.outside(build)});
  });
}

/// An editor whose buffer the test sets.
final class _Holding extends EditorNotifier {
  @override
  EditorState build() => const EditorState.empty();

  EditorState get held => state;

  set held(EditorState next) => state = next;
}

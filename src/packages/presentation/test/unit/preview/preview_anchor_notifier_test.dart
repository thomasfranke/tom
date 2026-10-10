import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );
  final SpaceRelativePathValueObject setup = SpaceRelativePathValueObject(
    'setup.md',
  );

  const BlockValueObject troubleshooting = BlockValueObject(
    startLine: 4,
    endLine: 4,
    source: '## Troubleshooting',
    kind: BlockKindEnum.heading,
  );

  /// [path] parsed, a title, a paragraph and the troubleshooting heading.
  ParsedDocumentValueObject drawn(SpaceRelativePathValueObject path) =>
      ParsedDocumentValueObject(
        document: DocumentEntity(path: path, content: '…'),
        blocks: <BlockValueObject>[
          const BlockValueObject(
            startLine: 0,
            endLine: 0,
            source: '# Setup',
            kind: BlockKindEnum.heading,
          ),
          const BlockValueObject(
            startLine: 2,
            endLine: 2,
            source: 'Install it.',
            kind: BlockKindEnum.paragraph,
          ),
          troubleshooting,
        ],
        linkDefinitions: '',
      );

  PreviewAnchorNotifier notifier() =>
      container.read(previewAnchorProvider.notifier);

  PreviewAnchor? waiting() => container.read(previewAnchorProvider);

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen<PreviewAnchor?>(previewAnchorProvider, (_, _) {});
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(setup);
  });

  test('the document it waits for hands over the heading, once', () {
    notifier().request(setup, 'Troubleshooting');

    expect(notifier().take(drawn(setup)), troubleshooting);
    expect(waiting(), isNull);
    expect(notifier().take(drawn(setup)), isNull);
  });

  test('an anchor that names no heading is used up all the same', () {
    notifier().request(setup, 'deployment');

    expect(notifier().take(drawn(setup)), isNull);
    expect(waiting(), isNull);
  });

  test('the document it was pressed in, still drawn, leaves it waiting', () {
    notifier().request(setup, 'Troubleshooting');

    expect(notifier().take(drawn(index)), isNull);
    expect(waiting(), isNotNull);
  });

  test('another document opened before it was drawn drops it', () {
    notifier().request(setup, 'Troubleshooting');
    container.read(spaceSessionProvider.notifier).show(index);

    expect(notifier().take(drawn(index)), isNull);
    expect(waiting(), isNull);
  });

  test('another space drops it', () {
    notifier().request(setup, 'Troubleshooting');

    container
        .read(spaceSessionProvider.notifier)
        .open(
          SpaceEntity(
            root: '/code/other',
            repositoryRoot: '/code/other',
            name: 'other',
          ),
        );

    expect(waiting(), isNull);
  });
}

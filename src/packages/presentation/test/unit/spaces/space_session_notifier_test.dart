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
  final SpaceEntity notes = SpaceEntity(
    root: '/code/notes',
    repositoryRoot: '/code/notes',
    name: 'notes',
  );

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  SpaceSessionNotifier session() =>
      container.read(spaceSessionProvider.notifier);

  test('nothing is open until something opens it', () {
    expect(container.read(spaceSessionProvider), isNull);
  });

  test('a space survives with nobody listening', () {
    // Riverpod disposes a provider nobody listens to, and the session is
    // written by Home — the screen on its way out.
    session().open(docs);

    expect(container.read(spaceSessionProvider)?.space, docs);
  });

  test('a space opens with no document showing', () {
    session().open(docs);

    expect(container.read(spaceSessionProvider)?.openDocument, isNull);
  });

  test('showing a document keeps the space', () {
    session().open(docs);

    session().show(SpaceRelativePathValueObject('guides/writing.md'));

    expect(
      container.read(spaceSessionProvider),
      SpaceSessionState(
        space: docs,
        openDocument: SpaceRelativePathValueObject('guides/writing.md'),
      ),
    );
  });

  test('another space does not inherit the open document', () {
    session().open(docs);
    session().show(SpaceRelativePathValueObject('index.md'));

    session().open(notes);

    expect(container.read(spaceSessionProvider)?.openDocument, isNull);
  });

  test('showing a document with nothing open changes nothing', () {
    session().show(SpaceRelativePathValueObject('index.md'));

    expect(container.read(spaceSessionProvider), isNull);
  });
}

import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late ProviderContainer container;

  final Space docs = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final Space notes = Space(
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
    // The reason `build` keeps it alive: the session is written by Home, a
    // screen that is on its way out at exactly that moment. Riverpod
    // disposes a provider as soon as nothing listens, and a session disposed
    // between the write and the first panel would leave the window on Home.
    session().open(docs);

    expect(container.read(spaceSessionProvider)?.space, docs);
  });

  test('a space opens with no document showing', () {
    session().open(docs);

    expect(container.read(spaceSessionProvider)?.openDocument, isNull);
  });

  test('showing a document keeps the space', () {
    session().open(docs);

    session().show(SpaceRelativePath('guides/writing.md'));

    expect(
      container.read(spaceSessionProvider),
      SpaceSessionState(
        space: docs,
        openDocument: SpaceRelativePath('guides/writing.md'),
      ),
    );
  });

  test('another space does not inherit the open document', () {
    // A path is only meaningful inside the space it is relative to: carrying
    // it across would point the editor at a file the new space may not hold.
    session().open(docs);
    session().show(SpaceRelativePath('index.md'));

    session().open(notes);

    expect(container.read(spaceSessionProvider)?.openDocument, isNull);
  });

  test('showing a document with nothing open changes nothing', () {
    session().show(SpaceRelativePath('index.md'));

    expect(container.read(spaceSessionProvider), isNull);
  });
}

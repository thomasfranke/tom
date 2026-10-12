import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  WorkspaceNotifier workspace() => container.read(workspaceProvider.notifier);

  WorkspaceState state() => container.read(workspaceProvider);

  test('both columns start open, at the width the shell chooses', () {
    expect(state().showingExplorer, isTrue);
    expect(state().showingAside, isTrue);
    expect(state().explorerWidth, isNull);
    expect(state().asidePanel, isNull);
  });

  test('each toggle puts its own column away and brings it back', () {
    workspace().toggleExplorer();
    expect(state().showingExplorer, isFalse);
    expect(state().showingAside, isTrue);

    workspace().toggleAside();
    expect(state().showingAside, isFalse);

    workspace()
      ..toggleExplorer()
      ..toggleAside();
    expect(state().showingExplorer, isTrue);
    expect(state().showingAside, isTrue);
  });

  test('the switch shows the panel it names', () {
    workspace().showAsidePanel('tom.history');

    expect(state().asidePanel, 'tom.history');
  });

  group('the panel under the document', () {
    test('starts closed, and its toggle opens and closes it', () {
      expect(state().showingBottom, isFalse);

      workspace().toggleBottom();
      expect(state().showingBottom, isTrue);
      expect(state().showingExplorer, isTrue);

      workspace().toggleBottom();
      expect(state().showingBottom, isFalse);
    });

    test('opening it on a tab shows that tab', () {
      workspace().showBottomPanel('tom.commands');

      expect(state().showingBottom, isTrue);
      expect(state().bottomPanel, 'tom.commands');
    });
  });

  group('dragging the left column', () {
    test('a width inside the bounds is kept as dragged', () {
      workspace().widenExplorer(300);

      expect(state().explorerWidth, 300);
    });

    test('past the narrowest it stops there', () {
      workspace().widenExplorer(20);

      expect(state().explorerWidth, WorkspaceNotifier.narrowest);
    });

    test('past the widest it stops there', () {
      workspace().widenExplorer(2000);

      expect(state().explorerWidth, WorkspaceNotifier.widest);
    });
  });

  group('dragging the right column', () {
    test('a width inside the bounds is kept as dragged', () {
      workspace().widenAside(360);

      expect(state().asideWidth, 360);
    });

    test('past the narrowest it stops there', () {
      workspace().widenAside(20);

      expect(state().asideWidth, WorkspaceNotifier.asideNarrowest);
    });

    test('past the widest it stops there', () {
      workspace().widenAside(2000);

      expect(state().asideWidth, WorkspaceNotifier.asideWidest);
    });

    test('leaves the left column where it was', () {
      workspace()
        ..widenExplorer(300)
        ..widenAside(360);

      expect(state().explorerWidth, 300);
    });
  });

  group('dragging the panel under the document', () {
    test('it opens at no height of its own, the shell’s', () {
      expect(state().bottomHeight, isNull);
    });

    test('a height inside the bounds is kept as dragged', () {
      workspace().raiseBottom(400);

      expect(state().bottomHeight, 400);
    });

    test('past the lowest it stops there', () {
      workspace().raiseBottom(10);

      expect(state().bottomHeight, WorkspaceNotifier.bottomLowest);
    });

    test('past what the window allows it stops there', () {
      workspace().raiseBottom(900, highest: 500);

      expect(state().bottomHeight, 500);
    });

    test('a window too short for anything still leaves the lowest', () {
      workspace().raiseBottom(300, highest: 40);

      expect(state().bottomHeight, WorkspaceNotifier.bottomLowest);
    });
  });
}

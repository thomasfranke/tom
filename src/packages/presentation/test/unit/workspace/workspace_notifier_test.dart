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
}

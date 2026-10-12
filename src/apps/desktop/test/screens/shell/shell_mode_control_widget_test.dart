/// The modes over a change that is not a document: source only for text,
/// none for a binary file, all three for a deleted document.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_control_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  /// Mounts the control with [path] on screen and the editor holding [state].
  Future<void> pumpModes(
    WidgetTester tester,
    String path,
    EditorState state, {
    DocumentModeEnum? mode,
  }) async {
    container = ProviderContainer(
      overrides: <Override>[editorProvider.overrideWith(() => _Holding(state))],
    );
    addTearDown(container.dispose);
    final SpaceSessionNotifier session =
        container.read(spaceSessionProvider.notifier)
          ..open(docs)
          ..show(SpaceRelativePathValueObject(path));
    if (mode != null) {
      session.look(mode);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: Center(child: ShellModeControlWidget())),
        ),
      ),
    );
    await tester.pump();
  }

  EditorState holding(
    String path, {
    bool deleted = false,
    bool binary = false,
  }) => EditorState.ready(
    saved: DocumentEntity(
      path: SpaceRelativePathValueObject(path),
      content: binary ? '' : 'text\n',
    ),
    source: binary ? '' : 'text\n',
    isDeleted: deleted,
    isBinary: binary,
  );

  TextStyle styleOf(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!;

  bool isChosen(WidgetTester tester, String label) =>
      styleOf(tester, label).fontWeight == FontWeight.w600;

  bool isAvailable(WidgetTester tester, String label) =>
      styleOf(tester, label).color != TomColors.light.textMuted;

  testWidgets('a text file is source, and the two that render are off', (
    WidgetTester tester,
  ) async {
    await pumpModes(tester, 'mkdocs.yml', holding('mkdocs.yml'));

    expect(isChosen(tester, 'Source'), isTrue);
    expect(isAvailable(tester, 'Split'), isFalse);
    expect(isAvailable(tester, 'Preview'), isFalse);

    await tester.tap(find.text('Preview'));
    await tester.pump();
    expect(
      container.read(spaceSessionProvider)?.drawnMode,
      DocumentModeEnum.source,
    );
  });

  testWidgets('a binary file chooses none and offers none', (
    WidgetTester tester,
  ) async {
    // No text to show in any of the three.
    await pumpModes(
      tester,
      'logo.png',
      holding('logo.png', binary: true),
      mode: DocumentModeEnum.source,
    );

    for (final String label in <String>['Source', 'Split', 'Preview']) {
      expect(isChosen(tester, label), isFalse, reason: label);
      expect(isAvailable(tester, label), isFalse, reason: label);
    }

    await tester.tap(find.text('Preview'));
    await tester.pump();
    expect(container.read(spaceSessionProvider)?.mode, DocumentModeEnum.source);
  });

  testWidgets('a deleted document is in preview, with all three offered', (
    WidgetTester tester,
  ) async {
    await pumpModes(
      tester,
      'guide.md',
      holding('guide.md', deleted: true),
      mode: DocumentModeEnum.preview,
    );

    expect(isChosen(tester, 'Preview'), isTrue);
    for (final String label in <String>['Source', 'Split', 'Preview']) {
      expect(isAvailable(tester, label), isTrue, reason: label);
    }
  });
}

/// An editor that holds the one buffer it was given.
final class _Holding extends EditorNotifier {
  _Holding(this._state);

  final EditorState _state;

  @override
  EditorState build() => _state;
}

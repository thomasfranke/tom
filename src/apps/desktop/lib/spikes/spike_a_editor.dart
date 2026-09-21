/// Spike A — can `re_editor` carry TOM's source mode?
///
/// **Answered.** The verdict is [Decision
/// 18](../../../../../docs/technical/decisions/018-source-mode-uses-re-editor.md):
/// `re_editor` carries source mode and the `TextField` fallback is
/// withdrawn.
///
/// **A spike, not a feature.** Nothing here is wired into the product — it
/// is a second entrypoint, unreachable from `main.dart` by construction
/// rather than by a flag.
///
/// It is kept rather than deleted for one reason, and it states when it
/// goes, the way a feature flag has to (`CONTRIBUTING.md`). The reason: the
/// named risk in Decision 18 is a Flutter upgrade breaking the package —
/// the spike already hit exactly that on `^0.7.0`, where `TextInputClient`
/// had grown `onFocusReceived` — and this is what re-answers the question in
/// an afternoon instead of a weekend. **It goes when M0 ships source mode
/// with its own tests**, which will cover the same ground against the real
/// editor.
///
/// Run it:
///
/// ```bash
/// cd src/apps/desktop
/// flutter run -d macos -t lib/spikes/spike_a_editor.dart
/// ```
///
/// Debug, not profile: `--profile` and `--release` are blocked for macOS by
/// a `flutter_tools` 3.44.5 / Xcode 27 incompatibility, tracked in the
/// roadmap's open questions. Debug is the slower mode, so the numbers are a
/// floor.
///
/// What the roadmap asks it to answer, in order: a 2000+ line markdown file,
/// desktop shortcuts, selection, find/replace, typing latency. The first and
/// the last are measured here; the middle three need a person at the
/// keyboard, and the checklist on the right is what they work through.
///
/// **Measured against the fallback, not against a number.** The roadmap's
/// plan B is a plain `TextField` (`docs/technical/dependencies.md`), so the
/// harness can run either:
///
/// ```bash
/// flutter run -d macos -t lib/spikes/spike_a_editor.dart
/// flutter run -d macos -t lib/spikes/spike_a_editor.dart \
///     --dart-define=SPIKE_CONTROL=true
/// ```
///
/// Both runs are in the same build mode on the same machine with the same
/// document, which is what makes the comparison mean something — an absolute
/// millisecond count from a debug build would not.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:tom_desktop/spikes/spike_a/find_panel.dart';
import 'package:tom_desktop/spikes/spike_a/frame_metrics.dart';
import 'package:tom_desktop/spikes/spike_a/markdown_fixture.dart';

/// Whether to run the fallback instead of `re_editor`.
///
/// The control arm of the experiment: a plain `TextField` holding the same
/// document, so the editor's cost can be read against the cost of the thing
/// the roadmap would fall back to.
const bool kControl = bool.fromEnvironment('SPIKE_CONTROL');

/// How many lines the fixture should hold.
///
/// The roadmap asks for 2000+; a much larger value answers the question the
/// roadmap does not ask, which is whether the cost grows with the file or
/// falls off a cliff somewhere above it.
const int kLines = int.fromEnvironment('SPIKE_LINES', defaultValue: 2400);

/// Starts the spike harness.
void main() => runApp(const SpikeAApp());

/// The harness application.
class SpikeAApp extends StatelessWidget {
  /// Creates the harness.
  const SpikeAApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: kControl ? 'Spike A — control' : 'Spike A — re_editor',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
    home: const _Harness(),
  );
}

class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final CodeLineEditingController _controller = CodeLineEditingController();
  final TextEditingController _plain = TextEditingController();
  final CodeScrollController _scrollController = CodeScrollController();

  /// Late, because it has to be handed the editor's own controller — a
  /// find panel over a different one finds nothing, which is exactly the
  /// bug this spike hit first.
  late final CodeFindController _findController = CodeFindController(
    _controller,
  );
  final FrameRecorder _recorder = FrameRecorder();
  final List<String> _log = <String>[];

  Timer? _typing;
  int _typed = 0;
  String _document = '';

  @override
  void initState() {
    super.initState();
    _load();
    // Let the first frames settle before measuring anything: the very first
    // frame of an app includes shader warm-up that no later frame pays.
    Timer(const Duration(seconds: 15), () => unawaited(_measureAll()));
  }

  @override
  void dispose() {
    _typing?.cancel();
    _plain.dispose();
    _controller.dispose();
    _findController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads the fixture and times what that costs.
  ///
  /// Two numbers, because they answer different questions: setting the text
  /// is parsing plus the controller's own bookkeeping, and the frame that
  /// follows is what the user actually waits for.
  void _load() {
    _document = buildMarkdownFixture(lines: kLines);
    final int lines = '\n'.allMatches(_document).length + 1;
    final Stopwatch watch = Stopwatch()..start();
    if (kControl) {
      _plain.text = _document;
    } else {
      _controller.text = _document;
    }
    final Duration set = watch.elapsed;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _note(
        '${kControl ? 'CONTROL (TextField)' : 're_editor'} · '
        'loaded $lines lines, ${_document.length ~/ 1024}KB · '
        'controller.text ${_ms(set)} · first frame after it '
        '${_ms(watch.elapsed)}',
      );
    });
  }

  /// Types [count] characters into the middle of the document.
  ///
  /// The measurement the roadmap calls typing latency. Every character is
  /// its own edit, at a rate no person reaches, which is the point: if the
  /// frames hold here they hold for a human.
  Future<void> _measureTyping({int count = 120}) async {
    if (kControl) {
      _plain.selection = TextSelection.collapsed(
        offset: _plain.text.length ~/ 2,
      );
    } else {
      _controller
        ..selectLine(_controller.lineCount ~/ 2)
        ..moveCursorToLineEnd();
    }
    _recorder.start();
    _typed = 0;
    final Completer<void> done = Completer<void>();
    _typing = Timer.periodic(const Duration(milliseconds: 16), (Timer timer) {
      if (kControl) {
        _typeIntoControl();
      } else {
        _controller.replaceSelection('a');
      }
      _typed++;
      if (_typed >= count) {
        timer.cancel();
        done.complete();
      }
    });
    await done.future;
    // One more frame, so the last edit is included.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _note(
      '${kControl ? 'CONTROL' : 're_editor'} typing $count chars — '
      '${_recorder.stop()}',
    );
  }

  /// Inserts one character at the caret of the control field.
  void _typeIntoControl() {
    final int at = _plain.selection.baseOffset;
    final String text = _plain.text;
    _plain
      ..text = '${text.substring(0, at)}a${text.substring(at)}'
      ..selection = TextSelection.collapsed(offset: at + 1);
  }

  /// Scrolls the whole document and times the frames.
  ///
  /// Skipped for the control: a `TextField` has no addressable line, so
  /// there is nothing equivalent to scroll to.
  Future<void> _measureScrolling() async {
    if (kControl) {
      _note('scrolling — not comparable for the control, skipped');
      return;
    }
    _recorder.start();
    for (int line = 0; line < _controller.lineCount; line += 40) {
      _controller.makePositionVisible(CodeLinePosition(index: line, offset: 0));
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _note('scrolling the whole file — ${_recorder.stop()}');
  }

  /// Drives find and replace through the controller, and reports what it
  /// found.
  ///
  /// One of the roadmap's five criteria, and the one that looked like it
  /// needed a person: it does not. The controller is drivable, so the
  /// question "does find work on a file this size" has an answer that does
  /// not depend on anyone's patience.
  Future<void> _measureFind() async {
    if (kControl) {
      _note('find — the fallback has none, which is the finding');
      return;
    }
    final CodeFindController find = _findController..findMode();
    find.findInputController.text = 'Section';
    await Future<void>.delayed(const Duration(seconds: 1));
    final CodeFindResult? result = find.value?.result;
    _note('find "Section" — ${result?.matches.length ?? 0} matches');

    final Stopwatch watch = Stopwatch()..start();
    find.replaceMode();
    find.replaceInputController.text = 'Chapter';
    await Future<void>.delayed(const Duration(milliseconds: 500));
    find.replaceAllMatches();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final int left = _controller.text.split('Section').length - 1;
    _note('replace all — ${_ms(watch.elapsed)}, $left occurrences left');
    find.close();
  }

  /// Runs every automatic measurement, in order.
  ///
  /// The first run happens on its own, so a `--profile` build reports
  /// without anyone clicking anything.
  Future<void> _measureAll() async {
    await _measureTyping();
    await _measureScrolling();
    await _measureFind();
    _note('done');
  }

  /// Records a measurement, on screen and on stdout.
  ///
  /// stdout because the numbers that matter come from a `--profile` run,
  /// where nobody is watching the window: debug-mode frame times say more
  /// about the assertions Flutter is running than about the editor.
  void _note(String line) {
    debugPrint('SPIKE_A · $line');
    setState(() => _log.insert(0, line));
  }

  static String _ms(Duration duration) =>
      '${(duration.inMicroseconds / 1000).toStringAsFixed(1)}ms';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        kControl
            ? 'Spike A — the fallback: a plain TextField'
            : 'Spike A — re_editor as source mode',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _measureTyping,
          child: const Text('Measure typing'),
        ),
        TextButton(
          onPressed: _measureScrolling,
          child: const Text('Measure scrolling'),
        ),
        FilledButton(onPressed: _measureAll, child: const Text('Measure all')),
        const SizedBox(width: 12),
      ],
    ),
    body: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(flex: 3, child: kControl ? _buildControl() : _buildEditor()),
        const VerticalDivider(width: 1),
        SizedBox(width: 380, child: _buildSidePanel()),
      ],
    ),
  );

  Widget _buildEditor() => CodeEditor(
    controller: _controller,
    scrollController: _scrollController,
    findController: _findController,
    wordWrap: false,
    autofocus: true,
    style: CodeEditorStyle(
      fontSize: 13,
      fontFamily: 'Menlo',
      codeTheme: CodeHighlightTheme(
        languages: <String, CodeHighlightThemeMode>{
          'markdown': CodeHighlightThemeMode(mode: langMarkdown),
        },
        theme: atomOneLightTheme,
      ),
    ),
    indicatorBuilder:
        (
          BuildContext context,
          CodeLineEditingController controller,
          CodeChunkController chunkController,
          ValueNotifier<CodeIndicatorValue?> notifier,
        ) => Row(
          children: <Widget>[
            DefaultCodeLineNumber(controller: controller, notifier: notifier),
            DefaultCodeChunkIndicator(
              width: 20,
              controller: chunkController,
              notifier: notifier,
            ),
          ],
        ),
    findBuilder:
        (BuildContext context, CodeFindController controller, bool readOnly) =>
            SpikeFindPanel(controller: controller, readOnly: readOnly),
    leadingDivider: Container(width: 1, color: Colors.black12),
  );

  /// The fallback the roadmap names: a plain scrolling text field.
  ///
  /// No line numbers, no highlighting, no find — which is the point. If this
  /// is the faster of the two, the question becomes what the difference buys.
  Widget _buildControl() => Padding(
    padding: const EdgeInsets.all(8),
    child: TextField(
      controller: _plain,
      maxLines: null,
      expands: true,
      autofocus: true,
      style: const TextStyle(fontFamily: 'Menlo', fontSize: 13),
      decoration: const InputDecoration(border: InputBorder.none),
    ),
  );

  Widget _buildSidePanel() => ListView(
    padding: const EdgeInsets.all(16),
    children: <Widget>[
      const Text(
        'Measured automatically',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      for (final String line in _log)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableText(
            line,
            style: const TextStyle(fontFamily: 'Menlo', fontSize: 11),
          ),
        ),
      const Divider(height: 32),
      const Text(
        'By hand — the roadmap asks for these',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      for (final String item in _checklist)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(item, style: const TextStyle(fontSize: 12)),
        ),
    ],
  );

  static const List<String> _checklist = <String>[
    '⌘F / ⌘⌥F — find, then replace. Does the panel find every match?',
    '⌘Z / ⇧⌘Z — undo and redo, after a run of typing.',
    '⌘↑ / ⌘↓ — jump to the start and the end of the file.',
    '⌥← / ⌥→ — move by word. ⇧⌥← extends the selection by word.',
    '⌘L — select the line. ⌥↑ / ⌥↓ — move the line.',
    '⇧ + click — extend a selection to where you clicked.',
    'Double click a word, triple click a line.',
    'Drag-select past the bottom edge — does it auto-scroll?',
    'Tab / ⇧Tab on a multi-line selection — indent and outdent.',
    '⌘S — the editor claims a save shortcut; does it reach us?',
    'Right-click — is there a context menu, and is it ours?',
    'Type an accented character with a dead key (´ then a).',
  ];
}

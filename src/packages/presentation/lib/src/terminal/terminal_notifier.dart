/// The open space's one shell, for the Terminal tab.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';
import 'package:tom_presentation/src/terminal/terminal_providers.dart';
import 'package:tom_presentation/src/terminal/terminal_state.dart';

part 'terminal_notifier.g.dart';

/// Starts the space's shell the first time the tab is drawn, keeps it while
/// the tab is away, and ends it with the space
/// (`docs/product/workspace/terminal/doc.md`).
///
/// **Kept alive**, because the panel is built only while its tab is chosen:
/// a shell owned by the widget would die on every switch to `Commands`.
/// What it drew is kept as text ([transcript]) for the emulator the next
/// panel builds, since the emulator itself is a widget's.
@Riverpod(keepAlive: true)
class TerminalNotifier extends _$TerminalNotifier {
  /// Starts the person's shell.
  StartTerminalUseCase get startTerminal => ref.read(startTerminalProvider);

  /// How much of what the shell drew is kept for the next panel, in
  /// characters; the oldest goes first, a whole chunk at a time.
  static const int kept = 256 * 1024;

  SpaceEntity? _space;
  TerminalSizeValueObject? _size;
  TerminalSessionPort? _session;
  StreamSubscription<String>? _reading;
  StreamController<String> _output = StreamController<String>.broadcast();
  final List<String> _chunks = <String>[];
  int _held = 0;

  /// Which space's shell is the current one, so an answer about the space
  /// just left cannot land on the next one.
  int _generation = 0;

  @override
  TerminalState build() {
    _space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    _generation++;
    _size = null;
    _chunks.clear();
    _held = 0;
    final StreamController<String> output = _output =
        StreamController<String>.broadcast();
    // Another space, or none: the shell goes with the space it was for.
    ref.onDispose(() {
      _end();
      unawaited(output.close());
    });
    return const TerminalState.initial();
  }

  /// What the shell has drawn so far, for an emulator that was not there.
  String get transcript => _chunks.join();

  /// What it draws from now on.
  Stream<String> get output => _output.stream;

  /// The tab is drawn at [size]: the shell starts the first time, and is
  /// told the new size after.
  Future<void> show(TerminalSizeValueObject size) async {
    _size = size;
    switch (state) {
      case TerminalInitial():
        await _start();
      case TerminalRunning():
        _session?.resize(size);
      case TerminalStarting() || TerminalExited() || TerminalFailed():
        break;
    }
  }

  /// Hands [input] to the shell — or, once it has ended, starts another
  /// instead: the key that does so is not typed into the new one.
  void write(String input) {
    if (state is TerminalExited) {
      unawaited(_start());
      return;
    }
    _session?.write(input);
  }

  Future<void> _start() async {
    final SpaceEntity? space = _space;
    final TerminalSizeValueObject? size = _size;
    if (space == null || size == null) {
      return;
    }
    final int generation = _generation;
    state = const TerminalState.starting();
    final Result<TerminalSessionPort, AppFailure> result = await startTerminal
        .start(space, size);
    // The space asked again, not only the generation: a rebuild may hand the
    // provider a new notifier, and this one's count would not have moved.
    if (!ref.mounted ||
        generation != _generation ||
        ref.read(spaceSessionProvider)?.space != space) {
      if (result case Success<TerminalSessionPort, AppFailure>(
        value: final TerminalSessionPort orphan,
      )) {
        orphan.close();
      }
      return;
    }
    switch (result) {
      case Success<TerminalSessionPort, AppFailure>(
        value: final TerminalSessionPort session,
      ):
        _session = session;
        _reading = session.output.listen(_received);
        state = TerminalState.running(
          shell: session.shell,
          folder: session.folder,
        );
        unawaited(session.exited.then((int code) => _ended(session, code)));
      case Failure<TerminalSessionPort, AppFailure>(
        failure: final AppFailure failure,
      ):
        state = TerminalState.failed(failure);
    }
  }

  void _received(String text) {
    _chunks.add(text);
    _held += text.length;
    while (_held > kept && _chunks.length > 1) {
      _held -= _chunks.removeAt(0).length;
    }
    _output.add(text);
  }

  void _ended(TerminalSessionPort session, int code) {
    if (!ref.mounted || !identical(session, _session)) {
      return;
    }
    _end();
    state = TerminalState.exited(
      shell: session.shell,
      folder: session.folder,
      code: code,
    );
  }

  void _end() {
    unawaited(_reading?.cancel());
    _reading = null;
    _session?.close();
    _session = null;
  }
}

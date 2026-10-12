/// A process that says what a test scripted and never touches the machine.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// What a scripted process does: prints [out] and [err], then exits with
/// [exit] — or, with [hang], prints and never ends until it is killed.
final class Said {
  const Said({
    this.exit = 0,
    this.out = '',
    this.err = '',
    this.hang = false,
    this.errLines = const <String>[],
    this.outBytes,
  });

  final int exit;
  final String out;
  final String err;
  final bool hang;

  /// Stderr lines given one after the other (a clone's progress).
  final List<String> errLines;

  /// Raw stdout, when the text is not valid UTF-8.
  final List<int>? outBytes;
}

/// A [Process] over what [Said] scripted.
final class ScriptedProcess implements Process {
  ScriptedProcess(this._said) {
    scheduleMicrotask(_play);
  }

  final Said _said;
  final StreamController<List<int>> _out = StreamController<List<int>>();
  final StreamController<List<int>> _err = StreamController<List<int>>();
  final Completer<int> _exit = Completer<int>();

  /// Whether [kill] was called.
  bool killed = false;

  Future<void> _play() async {
    if (killed) {
      return;
    }
    if (_said.out.isNotEmpty || _said.outBytes != null) {
      _out.add(_said.outBytes ?? utf8.encode(_said.out));
    }
    if (_said.err.isNotEmpty) {
      _err.add(utf8.encode(_said.err));
    }
    for (final String line in _said.errLines) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      if (killed) {
        return;
      }
      _err.add(utf8.encode('$line\n'));
    }
    if (_said.hang) {
      return;
    }
    await _out.close();
    await _err.close();
    if (!_exit.isCompleted) {
      _exit.complete(_said.exit);
    }
  }

  @override
  int get pid => 4242;

  @override
  Future<int> get exitCode => _exit.future;

  @override
  Stream<List<int>> get stdout => _out.stream;

  @override
  Stream<List<int>> get stderr => _err.stream;

  @override
  IOSink get stdin => throw UnsupportedError('a scripted process has no stdin');

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    unawaited(_out.close());
    unawaited(_err.close());
    if (!_exit.isCompleted) {
      _exit.complete(-9);
    }
    return true;
  }
}

/// One start that a [ScriptedProcess] answered.
final class StartedCall {
  const StartedCall(
    this.executable,
    this.arguments,
    this.workingDirectory,
    this.environment,
  );

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;
  final Map<String, String>? environment;

  String get line => arguments.join(' ');
}

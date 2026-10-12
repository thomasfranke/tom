/// The domain's terminal contract, over the pseudo-terminal.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/terminal/terminal_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [TerminalRepository] over a [TerminalDataSource]: bytes become text here,
/// and the capability's failure passes through, since the product names
/// none of its own.
final class TerminalRepositoryImpl implements TerminalRepository {
  /// Creates the repository over [source].
  const TerminalRepositoryImpl({required this.source});

  /// Where shells are started.
  final TerminalDataSource source;

  @override
  Future<Result<TerminalSessionPort, AppFailure>> start(
    String folder,
    TerminalSizeValueObject size,
  ) async => switch (await source.start(
    folder,
    columns: size.columns,
    rows: size.rows,
  )) {
    Success<PseudoTerminalProcess, PseudoTerminalFailure>(
      value: final PseudoTerminalProcess process,
    ) =>
      Success<TerminalSessionPort, AppFailure>(_Session(process, folder)),
    Failure<PseudoTerminalProcess, PseudoTerminalFailure>(
      failure: final PseudoTerminalFailure failure,
    ) =>
      Failure<TerminalSessionPort, AppFailure>(failure),
  };
}

/// One process, read as text.
final class _Session implements TerminalSessionPort {
  _Session(this._process, this.folder)
    : output = _process.output
          // One decoder for the whole stream, so a character split across
          // two chunks is joined rather than replaced.
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .asBroadcastStream() {
    exited = _process.exitCode.whenComplete(() => _closed = true);
  }

  final PseudoTerminalProcess _process;

  bool _closed = false;

  @override
  final String folder;

  @override
  final Stream<String> output;

  @override
  String get shell {
    final String last = _process.executable
        .split(RegExp(r'[/\\]'))
        .lastWhere((String it) => it.isNotEmpty, orElse: () => '');
    return last.toLowerCase().endsWith('.exe')
        ? last.substring(0, last.length - 4)
        : last;
  }

  @override
  late final Future<int> exited;

  @override
  void write(String input) {
    if (!_closed) {
      _process.write(Uint8List.fromList(utf8.encode(input)));
    }
  }

  @override
  void resize(TerminalSizeValueObject size) {
    if (!_closed) {
      _process.resize(size.columns, size.rows);
    }
  }

  // Once: a shell that has ended has given its pid back, and another
  // process may already be wearing it.
  @override
  void close() {
    if (!_closed) {
      _closed = true;
      _process.kill();
    }
  }
}

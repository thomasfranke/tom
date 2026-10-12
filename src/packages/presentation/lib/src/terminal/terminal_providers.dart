/// What the Terminal tab is wired from, declared where the tab's state lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_presentation/src/terminal/terminal_state.dart';

part 'terminal_providers.g.dart';

/// Starts the person's shell for a space.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
StartTerminalUseCase startTerminal(Ref ref) => throw StateError(
  'startTerminalProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// The person's home folder, which the terminal's head spells `~`
/// ([terminalPlaceOf]); null, the default, spells every folder in full.
@Riverpod(keepAlive: true)
String? homeFolder(Ref ref) => null;

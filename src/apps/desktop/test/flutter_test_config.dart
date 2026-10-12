/// What every widget test of the app also proves: each widget that reaches
/// the screen can describe itself.
///
/// Every widget answers `debugFillProperties`, and a getter that throws there
/// breaks the inspector and `debugDumpApp` — never a test. So each frame of a
/// test describes the widgets of a class it has not met yet, and a
/// description that throws or answers with an error fails the test.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hooks the check into the frames of every test in this file.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  // One widget of each class is enough: the properties a class reports are
  // the same statements whichever instance is asked.
  final Set<Type> described = <Type>{};

  void describe(Element element) {
    if (described.add(element.widget.runtimeType)) {
      try {
        final DiagnosticsNode node = element.widget.toDiagnosticsNode();
        for (final DiagnosticsNode property in node.getProperties()) {
          if (property.level == DiagnosticLevel.error) {
            throw StateError(
              '${element.widget.runtimeType}.${property.name} is an error',
            );
          }
          // Reading the value is what a getter that throws fails on.
          property.toDescription();
        }
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'the app\'s widget tests',
            context: ErrorDescription(
              'while describing ${element.widget.runtimeType}',
            ),
          ),
        );
      }
    }
    element.visitChildren(describe);
  }

  binding.addPersistentFrameCallback((Duration _) {
    final Element? root = binding.rootElement;
    if (root != null) {
      describe(root);
    }
  });
  await testMain();
}

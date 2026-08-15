/// The composition root.
///
/// This is the one place in the workspace allowed to know both a contract and
/// the thing that satisfies it. Every other package receives its dependencies
/// through constructors and never learns which implementation it was handed,
/// which is the property the package graph exists to guarantee and what
/// `src/test/architecture_test.dart` checks on every run.
library;

import 'package:flutter/material.dart';

/// Builds the object graph and starts the app.
///
/// Wiring goes here: construct the infrastructure implementations, hand them
/// to the repositories, hand those to the use cases, and expose the result to
/// presentation. Nothing is wired yet — the layers are empty by design, and
/// the first thing to arrive is the extensible shell (M0, `docs/mvp.md`).
void main() => runApp(const TomApp());

/// The application shell.
class TomApp extends StatelessWidget {
  /// Creates the application shell.
  const TomApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    title: 'TOM',
    debugShowCheckedModeBanner: false,
    home: _Placeholder(),
  );
}

/// Deliberately not the app.
///
/// It exists so `flutter run` proves the workspace resolves and builds end to
/// end. What replaces it is registered through modules rather than hardcoded
/// here — see `docs/patterns/extension-modules.md`.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('TOM', style: TextStyle(fontSize: 40)),
          SizedBox(height: 8),
          Text('Team-Oriented Markdown'),
          SizedBox(height: 24),
          Text('Skeleton only — no milestone has been built yet.'),
        ],
      ),
    ),
  );
}

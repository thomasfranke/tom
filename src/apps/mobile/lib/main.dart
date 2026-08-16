/// The mobile composition root.
///
/// Reserved skeleton for Phase 3 (docs/product/roadmap.md) — desktop is the
/// reference platform until 1.0 ships. Nothing is wired yet; when it is, this
/// mirrors apps/desktop/lib/main.dart: construct the mobile-specific
/// infrastructure implementations, hand them to the repositories shared with
/// desktop, and expose the result to the shared tom_presentation state.
library;

import 'package:flutter/material.dart';

/// Builds the object graph and starts the app.
void main() => runApp(const TomMobileApp());

/// The application shell.
class TomMobileApp extends StatelessWidget {
  /// Creates the application shell.
  const TomMobileApp({super.key});

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
/// end. Real screens arrive with Phase 3, drawn from the job rather than
/// ported from the desktop layout — see Decision 14.
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
          Text('Mobile — reserved for Phase 3, not built yet.'),
        ],
      ),
    ),
  );
}

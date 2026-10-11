/// The band an export leaves: where the file went, or why there is none.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/export/export_band_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Export export;

  Future<void> pumpBand(WidgetTester tester, ExportState state) async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[exportProvider.overrideWith(() => export)],
    );
    export = _Export(state);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(
            body: Column(children: <Widget>[ExportBandWidget()]),
          ),
        ),
      ),
    );
  }

  testWidgets('with nothing exported the band takes no room', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester, const ExportState.idle());

    expect(find.byType(NoticeBandWidget), findsNothing);
  });

  testWidgets('while it writes, it says so and offers nothing', (
    WidgetTester tester,
  ) async {
    await pumpBand(
      tester,
      const ExportState.working(
        format: ExportFormatEnum.pdf,
        destination: '/out/roadmap.pdf',
      ),
    );

    expect(find.text('Exporting roadmap.pdf…'), findsOneWidget);
    expect(find.text('Reveal'), findsNothing);
    // Still in flight is neither a refusal nor a result, so it wears the
    // accent (`docs/product/workspace/feedback/doc.md`).
    final NoticeBandWidget band = tester.widget(find.byType(NoticeBandWidget));
    final TomColors colors = TomColors.of(
      tester.element(find.byType(NoticeBandWidget)),
    );
    expect(band.ink, colors.accent);
    expect(band.fill, colors.accentSoft);
  });

  testWidgets('a written file is named with its folder, and can be revealed', (
    WidgetTester tester,
  ) async {
    await pumpBand(
      tester,
      const ExportState.exported(
        format: ExportFormatEnum.pdf,
        destination: '/out/roadmap.pdf',
      ),
    );

    expect(find.text('Exported roadmap.pdf to /out.'), findsOneWidget);
    expect(
      tester.widget<NoticeBandWidget>(find.byType(NoticeBandWidget)).fill,
      TomColors.light.addedSoft,
    );
    await tester.tap(find.text('Reveal'));
    expect(export.reveals, 1);
  });

  testWidgets('a refusal says why, and that nothing was written', (
    WidgetTester tester,
  ) async {
    await pumpBand(
      tester,
      const ExportState.failed(
        format: ExportFormatEnum.pdf,
        destination: '/out/roadmap.pdf',
        failure: ExportTooLarge(ExportFormatEnum.pdf),
      ),
    );

    expect(
      find.text(
        'Could not export roadmap.pdf: something in it is taller than a '
        'page. Nothing was written.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<NoticeBandWidget>(find.byType(NoticeBandWidget)).fill,
      TomColors.light.removedSoft,
    );
  });
}

/// An export standing in [initial], counting the reveals asked for.
final class _Export extends ExportNotifier {
  _Export(this.initial);

  final ExportState initial;
  int reveals = 0;

  @override
  ExportState build() => initial;

  @override
  Future<void> reveal() async => reveals++;
}

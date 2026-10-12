import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/command_action_label.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  final AppLocalizations english = lookupAppLocalizations(const Locale('en'));
  final AppLocalizations portuguese = lookupAppLocalizations(
    const Locale('pt'),
  );

  test('every action is named, and no two share a name', () {
    final List<String> names = <String>[
      for (final CommandActionEnum action in CommandActionEnum.values)
        action.label(english),
    ];

    expect(names, everyElement(isNotEmpty));
    expect(names.toSet(), hasLength(CommandActionEnum.values.length));
  });

  test('the words follow the language', () {
    expect(CommandActionEnum.openSpace.label(english), 'Opening the space');
    expect(CommandActionEnum.openSpace.label(portuguese), 'Abrindo o espaço');
    expect(CommandActionEnum.stage.label(portuguese), 'Preparar (stage)');
    for (final CommandActionEnum action in CommandActionEnum.values) {
      expect(action.label(portuguese), isNotEmpty, reason: action.name);
    }
  });
}

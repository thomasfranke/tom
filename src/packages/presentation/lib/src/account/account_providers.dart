/// What the account popover is wired from, declared where it lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'account_providers.g.dart';

/// Reads who the person is, here and on GitHub.
@riverpod
ReadAccountUseCase readAccount(Ref ref) => throw StateError(
  'readAccountProvider has no default. The composition root overrides it — '
  'see runTom() in tom_desktop.',
);

/// Records which account this repository is used with.
@riverpod
ChooseAccountUseCase chooseAccount(Ref ref) => throw StateError(
  'chooseAccountProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

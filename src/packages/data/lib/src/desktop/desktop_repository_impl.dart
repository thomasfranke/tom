/// The domain's desktop contract, over the desktop shell.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/desktop/desktop_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [DesktopRepository] over a [DesktopDataSource]; the capability's failure
/// passes through, since the product names none of its own.
final class DesktopRepositoryImpl implements DesktopRepository {
  /// Creates the repository over [source].
  const DesktopRepositoryImpl({required this.source});

  /// Where folders are handed over.
  final DesktopDataSource source;

  @override
  Future<Result<void, AppFailure>> reveal(String folder) async =>
      _widened(await source.reveal(folder));

  @override
  Future<Result<void, AppFailure>> openTerminal(String folder) async =>
      _widened(await source.openTerminal(folder));

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async =>
      _widened(await source.openUrl(address));

  static Result<void, AppFailure> _widened(
    Result<void, DesktopShellFailure> result,
  ) => switch (result) {
    Success<void, DesktopShellFailure>() => const Success<void, AppFailure>(
      null,
    ),
    Failure<void, DesktopShellFailure>(
      failure: final DesktopShellFailure failure,
    ) =>
      Failure<void, AppFailure>(failure),
  };
}

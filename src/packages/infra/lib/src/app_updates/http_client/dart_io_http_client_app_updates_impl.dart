/// The `dart:io` implementation of [AppUpdates].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/app_updates/app_updates.dart';
import 'package:tom_infra/src/app_updates/app_updates_failure.dart';

/// [AppUpdates] over `HttpClient`, with no package: one GET.
///
/// Nothing is sent but the request for the release — no identifier, no
/// version, no machine; `User-Agent` is the one header GitHub insists on.
final class DartIoHttpClientAppUpdatesImpl implements AppUpdates {
  /// Asks [endpoint], giving up after [timeout].
  const DartIoHttpClientAppUpdatesImpl({
    required this.endpoint,
    this.timeout = const Duration(seconds: 10),
  });

  /// Where the latest release is answered, as GitHub's
  /// `/repos/<owner>/<name>/releases/latest`.
  final Uri endpoint;

  /// How long to wait for the whole answer.
  final Duration timeout;

  @override
  Future<Result<String?, AppUpdatesFailure>> latest() async {
    final HttpClient client = HttpClient()..connectionTimeout = timeout;
    try {
      final HttpClientRequest request = await client
          .getUrl(endpoint)
          .timeout(timeout);
      request.headers
        ..set(HttpHeaders.userAgentHeader, 'TOM')
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      final HttpClientResponse response = await request.close().timeout(
        timeout,
      );
      final String body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);
      return switch (response.statusCode) {
        200 => Success<String?, AppUpdatesFailure>(body),
        // Nothing published yet: GitHub's way of saying there is no latest.
        404 => const Success<String?, AppUpdatesFailure>(null),
        final int status => Failure<String?, AppUpdatesFailure>(
          AppUpdatesFailure.unreachable('status $status'),
        ),
      };
    } on Object catch (error) {
      return Failure<String?, AppUpdatesFailure>(
        AppUpdatesFailure.unreachable(error.toString()),
      );
    } finally {
      client.close(force: true);
    }
  }
}

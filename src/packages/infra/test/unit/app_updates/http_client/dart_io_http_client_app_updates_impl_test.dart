/// [DartIoHttpClientAppUpdatesImpl] against a server on the loopback address
/// only: a real socket, but nothing outside the machine is reached.
library;

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late HttpServer server;
  late List<HttpHeaders> seen;
  late FutureOr<void> Function(HttpRequest request) answer;

  setUp(() async {
    seen = <HttpHeaders>[];
    answer = (HttpRequest request) => request.response.close();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0)
      ..listen((HttpRequest request) async {
        seen.add(request.headers);
        await answer(request);
      });
    addTearDown(() => server.close(force: true));
  });

  AppUpdates updates({Duration timeout = const Duration(seconds: 5)}) =>
      DartIoHttpClientAppUpdatesImpl(
        endpoint: Uri.parse('http://127.0.0.1:${server.port}/releases/latest'),
        timeout: timeout,
      );

  AppUpdatesFailure failure(Result<String?, AppUpdatesFailure> result) =>
      (result as Failure<String?, AppUpdatesFailure>).failure;

  test(
    'a 200 is its body, verbatim, asked for with a user agent only',
    () async {
      answer = (HttpRequest request) {
        request.response
          ..statusCode = 200
          ..write('{"tag_name":"v1.2.0"}');
        return request.response.close();
      };

      final Result<String?, AppUpdatesFailure> got = await updates().latest();

      expect(
        (got as Success<String?, AppUpdatesFailure>).value,
        '{"tag_name":"v1.2.0"}',
      );
      expect(seen.single.value(HttpHeaders.userAgentHeader), 'TOM');
      expect(
        seen.single.value(HttpHeaders.acceptHeader),
        'application/vnd.github+json',
      );
      expect(seen.single.value(HttpHeaders.authorizationHeader), isNull);
    },
  );

  test('a 404 is no release yet, not a failure', () async {
    answer = (HttpRequest request) {
      request.response.statusCode = 404;
      return request.response.close();
    };

    final Result<String?, AppUpdatesFailure> got = await updates().latest();

    expect((got as Success<String?, AppUpdatesFailure>).value, isNull);
  });

  test('any other status is unreachable and says which', () async {
    answer = (HttpRequest request) {
      request.response.statusCode = 503;
      return request.response.close();
    };

    expect(failure(await updates().latest()).toString(), contains('503'));
  });

  test('a server that never answers is given up on', () async {
    final Completer<void> forever = Completer<void>();
    answer = (HttpRequest request) => forever.future;

    final Result<String?, AppUpdatesFailure> got = await updates(
      timeout: const Duration(milliseconds: 80),
    ).latest();

    expect(got, isA<Failure<String?, AppUpdatesFailure>>());
    forever.complete();
  });

  test('nobody listening is unreachable', () async {
    final int port = server.port;
    await server.close(force: true);

    final Result<String?, AppUpdatesFailure> got =
        await DartIoHttpClientAppUpdatesImpl(
          endpoint: Uri.parse('http://127.0.0.1:$port/x'),
          timeout: const Duration(seconds: 2),
        ).latest();

    expect(got, isA<Failure<String?, AppUpdatesFailure>>());
  });
}

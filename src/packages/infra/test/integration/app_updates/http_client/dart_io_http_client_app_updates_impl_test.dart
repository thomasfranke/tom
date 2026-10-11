/// [DartIoHttpClientAppUpdatesImpl] against a real server on a real socket:
/// no GitHub, but everything between the code and the wire is real.
library;

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late HttpServer server;
  late List<HttpRequest> seen;
  late FutureOr<void> Function(HttpRequest request) answer;

  setUp(() async {
    seen = <HttpRequest>[];
    answer = (HttpRequest request) => request.response.close();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0)
      ..listen((HttpRequest request) async {
        seen.add(request);
        await answer(request);
      });
    addTearDown(() => server.close(force: true));
  });

  AppUpdates updates({Duration? timeout}) => DartIoHttpClientAppUpdatesImpl(
    endpoint: Uri.parse('http://127.0.0.1:${server.port}/releases/latest'),
    timeout: timeout ?? const Duration(seconds: 5),
  );

  test('a release is the body, verbatim', () async {
    answer = (HttpRequest request) {
      request.response
        ..statusCode = 200
        ..write('{"tag_name":"v1.2.0","html_url":"https://x/y"}');
      return request.response.close();
    };

    final Result<String?, AppUpdatesFailure> got = await updates().latest();

    expect(got, isA<Success<String?, AppUpdatesFailure>>());
    expect(
      (got as Success<String?, AppUpdatesFailure>).value,
      '{"tag_name":"v1.2.0","html_url":"https://x/y"}',
    );
  });

  test('asks with a user agent and nothing that identifies the machine', () {
    answer = (HttpRequest request) {
      request.response.statusCode = 200;
      return request.response.close();
    };

    return updates().latest().then((_) {
      final HttpHeaders headers = seen.single.headers;
      expect(headers.value(HttpHeaders.userAgentHeader), 'TOM');
      expect(headers.value(HttpHeaders.authorizationHeader), isNull);
      expect(headers.value(HttpHeaders.cookieHeader), isNull);
      expect(seen.single.method, 'GET');
    });
  });

  test('a 404 is no release yet, not a failure', () async {
    answer = (HttpRequest request) {
      request.response.statusCode = 404;
      return request.response.close();
    };

    final Result<String?, AppUpdatesFailure> got = await updates().latest();

    expect(got, isA<Success<String?, AppUpdatesFailure>>());
    expect((got as Success<String?, AppUpdatesFailure>).value, isNull);
  });

  test('a 500 is the host not answering', () async {
    answer = (HttpRequest request) {
      request.response.statusCode = 500;
      return request.response.close();
    };

    final Result<String?, AppUpdatesFailure> got = await updates().latest();

    expect(got, isA<Failure<String?, AppUpdatesFailure>>());
  });

  test('a silence past the time given is the host not answering', () async {
    answer = (HttpRequest request) => Completer<void>().future; // never answers

    final Result<String?, AppUpdatesFailure> got = await updates(
      timeout: const Duration(milliseconds: 300),
    ).latest();

    expect(got, isA<Failure<String?, AppUpdatesFailure>>());
  });

  test('nobody listening is the host not answering', () async {
    final int port = server.port;
    await server.close(force: true);

    final Result<String?, AppUpdatesFailure> got =
        await DartIoHttpClientAppUpdatesImpl(
          endpoint: Uri.parse('http://127.0.0.1:$port/'),
        ).latest();

    expect(got, isA<Failure<String?, AppUpdatesFailure>>());
  });
}

/// A release endpoint on the scenario's own machine: a real server on a real
/// socket, so the real `HttpClient` implementation runs and GitHub is never
/// reached — the way `gh` is a script on the run's PATH.
library;

import 'dart:async';
import 'dart:io';

/// Answers what a scenario says, and remembers how often it was asked.
final class FakeReleases {
  FakeReleases._(this._server);

  final HttpServer _server;

  /// The status the next ask is answered with.
  int status = 404;

  /// The body, when the status is 200.
  String body = '';

  /// How many times the endpoint was asked.
  int asked = 0;

  /// Where the app is told to ask.
  Uri get address => Uri.parse(
    'http://127.0.0.1:${_server.port}/repos/thomasfranke/tom/releases/latest',
  );

  /// Starts it, answering 404 until a scenario says otherwise.
  static Future<FakeReleases> start() async {
    final FakeReleases fake = FakeReleases._(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    );
    unawaited(fake._serve());
    return fake;
  }

  /// Answers [tag] as the latest release.
  void publish(String tag) {
    status = 200;
    body =
        '{"tag_name":"$tag","html_url":'
        '"https://github.com/thomasfranke/tom/releases/tag/$tag"}';
  }

  /// Answers nothing but an error, as GitHub down would.
  void breakDown() {
    status = 503;
    body = '';
  }

  /// Stops listening.
  Future<void> stop() => _server.close(force: true);

  Future<void> _serve() async {
    await for (final HttpRequest request in _server) {
      asked++;
      request.response.statusCode = status;
      if (status == 200) {
        request.response.write(body);
      }
      await request.response.close();
    }
  }
}

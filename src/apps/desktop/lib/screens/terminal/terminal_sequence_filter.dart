/// Rewrites the few escape sequences `xterm` 4.0.0 reads wrongly.
library;

/// Rewrites what a program writes into what `xterm` 4.0.0 gets right, one
/// chunk at a time, holding back an escape sequence cut by a chunk's end.
///
/// Three faults, each seen in a real Claude Code session:
///
/// - `CSI > 4 m` (xterm's `modifyOtherKeys`) is read as SGR 4, so every cell
///   after it is underlined. A private-prefixed `m` is not SGR and is dropped.
/// - SGR 22 (normal intensity) clears faint only, so bold never ends. It is
///   sent as `21;22`, 21 being the one that clears bold there.
/// - Colon sub-parameters (`4:3`, `38:2::r:g:b`) are not understood at all;
///   they become `4`/`24` and the semicolon form.
final class TerminalSequenceFilter {
  /// What a chunk ended in the middle of, to be completed by the next.
  String _pending = '';

  /// A sequence that has not ended after this many characters is not one.
  static const int _longest = 256;

  /// [chunk], rewritten.
  String filter(String chunk) {
    final String text = _pending + chunk;
    _pending = '';
    final StringBuffer out = StringBuffer();
    int i = 0;
    while (i < text.length) {
      final int esc = text.indexOf('\x1b[', i);
      if (esc < 0) {
        // A lone ESC at the end may be the start of one.
        if (text.endsWith('\x1b')) {
          out.write(text.substring(i, text.length - 1));
          _pending = '\x1b';
        } else {
          out.write(text.substring(i));
        }
        break;
      }
      out.write(text.substring(i, esc));
      int end = esc + 2;
      while (end < text.length && !_isFinal(text.codeUnitAt(end))) {
        end++;
      }
      if (end >= text.length) {
        if (text.length - esc <= _longest) {
          _pending = text.substring(esc);
        } else {
          out.write(text.substring(esc));
        }
        break;
      }
      out.write(_rewrite(text.substring(esc + 2, end), text[end]));
      i = end + 1;
    }
    return out.toString();
  }

  /// A CSI ends at a byte in `@`…`~`.
  static bool _isFinal(int unit) => unit >= 0x40 && unit <= 0x7e;

  static String _rewrite(String body, String last) {
    if (last != 'm') {
      return '\x1b[$body$last';
    }
    if (body.isNotEmpty && '<=>?'.contains(body[0])) {
      return '';
    }
    if (!body.contains(':') && !body.contains('22')) {
      return '\x1b[${body}m';
    }
    final List<String> params = body.split(';');
    final List<String> out = <String>[];
    for (int i = 0; i < params.length; i++) {
      final String param = params[i];
      if (param.contains(':')) {
        out.addAll(_colon(param));
        continue;
      }
      out.add(param == '22' ? '21;22' : param);
      // The values after 38/48/58 are numbers, not attributes.
      final int skip = switch (param) {
        '38' ||
        '48' ||
        '58' => i + 1 < params.length && params[i + 1] == '5' ? 2 : 4,
        _ => 0,
      };
      for (int k = 0; k < skip && i + 1 < params.length; k++) {
        out.add(params[++i]);
      }
    }
    return '\x1b[${out.join(';')}m';
  }

  /// One colon-separated parameter, as semicolon ones.
  static List<String> _colon(String param) {
    final List<String> parts = param.split(':');
    switch (parts.first) {
      case '4':
        return <String>[parts.length > 1 && parts[1] == '0' ? '24' : '4'];
      case '38' || '48' || '58':
        // `38:2::r:g:b` carries a colour-space slot, `38:2:r:g:b` does not.
        final List<String> rest = parts.sublist(1);
        if (rest.length >= 4 && rest.first == '2') {
          return <String>[parts.first, '2', ...rest.sublist(rest.length - 3)];
        }
        return <String>[parts.first, ...rest];
      default:
        return <String>[parts.first];
    }
  }
}

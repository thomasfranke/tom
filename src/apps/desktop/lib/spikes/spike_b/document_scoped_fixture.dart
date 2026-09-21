/// The markdown that only makes sense as a whole document.
library;

/// A document whose blocks depend on things declared elsewhere in it.
///
/// The repository's own documentation does not exercise this: it uses inline
/// links throughout, so every block in it happens to stand alone. That is a
/// property of how this project writes markdown, not of markdown — and a
/// spike that only measured the corpus it had would have answered the
/// question with an accident.
///
/// Every construct here is document-scoped by the CommonMark spec or the
/// GitHub extensions:
///
/// - a **reference link**, whose target is defined at the bottom;
/// - a **reference image**, same;
/// - a **collapsed** and a **shortcut** reference, the two forms that carry
///   no explicit label;
/// - a **footnote** reference, whose body is elsewhere;
/// - a **setext heading**, which is only a heading because of the line
///   *after* it;
/// - a **lazy continuation** line, which belongs to the block above it;
/// - a **fenced block** whose fence closes several lines later.
const String documentScopedFixture = '''
# Reference links and friends

A paragraph using a [reference link][spec] and a [collapsed one][] and a
[shortcut]. It also shows a reference image: ![the logo][logo]

A paragraph with a footnote reference.[^why]

A setext heading
================

A paragraph whose second line is a lazy
continuation of the first.

```dart
// A fence that closes three lines down.
final int answer = 42;
```

[^why]: Because the body of a footnote is not where the reference is.

[spec]: https://spec.commonmark.org/ "CommonMark"
[collapsed one]: https://example.com/collapsed
[shortcut]: https://example.com/shortcut
[logo]: https://example.com/logo.png "The logo"
''';

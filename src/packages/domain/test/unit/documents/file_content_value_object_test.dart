import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
    'assets/logo.png',
  );

  FileContentValueObject of(List<int> bytes) =>
      FileContentValueObject.ofBytes(path, Uint8List.fromList(bytes));

  test('text is held as the document it decodes to', () {
    expect(
      of(utf8.encode('name: café\n')),
      FileContentValueObject.text(
        DocumentEntity(path: path, content: 'name: café\n'),
      ),
    );
  });

  test('an empty file is text', () {
    expect(
      of(<int>[]),
      FileContentValueObject.text(DocumentEntity(path: path, content: '')),
    );
  });

  test('a zero byte near the start is binary, as git decides', () {
    expect(
      of(<int>[0x89, 0x50, 0x4E, 0x47, 0x00, 0x01]),
      const FileContentValueObject.binary(),
    );
  });

  test('bytes that are not UTF-8 are binary, with no zero among them', () {
    expect(
      of(<int>[0xFF, 0xD8, 0xFF, 0xE0, 0x4A, 0x46]),
      const FileContentValueObject.binary(),
    );
  });

  test('a replacement character somebody typed is text, not a trace', () {
    final String typed = 'see ${String.fromCharCode(0xFFFD)} here\n';
    expect(
      of(utf8.encode(typed)),
      FileContentValueObject.text(DocumentEntity(path: path, content: typed)),
    );
  });

  test('the 8 KB are counted in bytes, not in characters', () {
    // 4,000 two-byte characters fill the window exactly, so a zero after
    // them is the 8,001st byte and only the 4,001st character.
    final List<int> past = <int>[...utf8.encode('é' * 4000), 0x00];
    expect(of(past), isA<FileContentText>());

    final List<int> inside = <int>[...utf8.encode('é' * 3999), 0x61, 0x00];
    expect(of(inside), const FileContentValueObject.binary());
  });
}

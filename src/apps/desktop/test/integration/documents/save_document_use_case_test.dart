/// A save as the composition root wires it, over a real folder: the disk is
/// asked before it is written (`docs/product/editor/source-mode/doc.md`).
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late Directory temp;
  late SpaceEntity space;
  late File file;
  late ProviderContainer container;

  final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
    'guides/writing.md',
  );

  setUp(() {
    temp = Directory.systemTemp.createTempSync('tom_save_');
    final String root = '${temp.resolveSymbolicLinksSync()}/docs';
    file = File('$root/guides/writing.md')
      ..createSync(recursive: true)
      ..writeAsStringSync('# As it was read\n');
    space = SpaceEntity(root: root, repositoryRoot: null, name: 'docs');
    container = ProviderContainer(overrides: <Override>[...appOverrides]);
    addTearDown(() {
      container.dispose();
      temp.deleteSync(recursive: true);
    });
  });

  SaveDocumentUseCase save() => container.read(saveDocumentProvider);

  DocumentEntity mine() => DocumentEntity(path: path, content: '# Mine\n');

  test('a file nobody touched since it was read is written', () async {
    final Result<void, AppFailure> saved = await save().save(
      space,
      mine(),
      replacing: '# As it was read\n',
    );

    expect(saved, isA<Success<void, AppFailure>>());
    expect(file.readAsStringSync(), '# Mine\n');
  });

  test('a file another program wrote meanwhile is refused, and stays as '
      'that program left it', () async {
    file.writeAsStringSync('# Theirs\n');

    final Result<void, AppFailure> saved = await save().save(
      space,
      mine(),
      replacing: '# As it was read\n',
    );

    expect(
      (saved as Failure<void, AppFailure>).failure,
      isA<DocumentExternalChangeConflict>(),
    );
    expect(file.readAsStringSync(), '# Theirs\n');
  });

  test('bytes that are no longer text are a change too', () async {
    file.writeAsBytesSync(<int>[0xff, 0xfe, 0x00, 0xc3]);

    final Result<void, AppFailure> saved = await save().save(
      space,
      mine(),
      replacing: '# As it was read\n',
    );

    expect(
      (saved as Failure<void, AppFailure>).failure,
      isA<DocumentExternalChangeConflict>(),
    );
    expect(file.readAsBytesSync(), <int>[0xff, 0xfe, 0x00, 0xc3]);
  });

  test('a file deleted meanwhile is written again', () async {
    file.deleteSync();

    final Result<void, AppFailure> saved = await save().save(
      space,
      mine(),
      replacing: '# As it was read\n',
    );

    expect(saved, isA<Success<void, AppFailure>>());
    expect(file.readAsStringSync(), '# Mine\n');
  });

  group('what a save replaces is the text, and nothing else', () {
    const Object posixOnly = 'links and modes are POSIX here';

    test('a document that is a symbolic link stays one, and the file it '
        'points at is written', () async {
      final File shared = File('${temp.path}/shared/writing.md')
        ..createSync(recursive: true)
        ..writeAsStringSync('# As it was read\n');
      file.deleteSync();
      Link(file.path).createSync(shared.path);

      final Result<void, AppFailure> saved = await save().save(
        space,
        mine(),
        replacing: '# As it was read\n',
      );

      expect(saved, isA<Success<void, AppFailure>>());
      expect(
        FileSystemEntity.typeSync(file.path, followLinks: false),
        FileSystemEntityType.link,
      );
      expect(shared.readAsStringSync(), '# Mine\n');
    }, skip: Platform.isWindows ? posixOnly : false);

    for (final String mode in const <String>['600', '755']) {
      test(
        'a document that was $mode is still $mode',
        () async {
          Process.runSync('chmod', <String>[mode, file.path]);

          await save().save(space, mine(), replacing: '# As it was read\n');

          expect(file.readAsStringSync(), '# Mine\n');
          expect((file.statSync().mode & 0x1ff).toRadixString(8), mode);
        },
        skip: Platform.isWindows ? posixOnly : false,
      );
    }
  });

  test('Keep mine is a save that asks nothing: it writes over', () async {
    file.writeAsStringSync('# Theirs\n');

    final Result<void, AppFailure> saved = await save().save(space, mine());

    expect(saved, isA<Success<void, AppFailure>>());
    expect(file.readAsStringSync(), '# Mine\n');
  });
}

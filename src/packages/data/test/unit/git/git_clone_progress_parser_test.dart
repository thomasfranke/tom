/// [GitCloneProgressParser] over lines `git clone --progress` really prints.
library;

import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const GitCloneProgressParser parser = GitCloneProgressParser();

  CloneProgressValueObject at(CloneStageEnum stage, [int? percent]) =>
      CloneProgressValueObject(stage: stage, percent: percent);

  test('the first line starts the clone, with no fraction', () {
    expect(
      parser.parse("Cloning into '/tmp/docs'..."),
      at(CloneStageEnum.starting),
    );
  });

  test("the remote's three titles are one stage", () {
    expect(
      parser.parse('remote: Enumerating objects: 9, done.'),
      at(CloneStageEnum.preparing),
    );
    // Git pads a progress line with spaces to wipe the longer one before it.
    expect(
      parser.parse('remote: Counting objects:  11% (1/9)        '),
      at(CloneStageEnum.preparing, 11),
    );
    expect(
      parser.parse('remote: Compressing objects: 100% (3/3), done.'),
      at(CloneStageEnum.preparing, 100),
    );
  });

  test('receiving, resolving and checking out carry their fraction', () {
    expect(
      parser.parse('Receiving objects:  40% (2/5), 1.20 KiB | 1.20 MiB/s'),
      at(CloneStageEnum.receiving, 40),
    );
    expect(
      parser.parse('Resolving deltas: 100% (1/1), done.'),
      at(CloneStageEnum.resolving, 100),
    );
    expect(
      parser.parse('Updating files:  75% (3/4)'),
      at(CloneStageEnum.checkingOut, 75),
    );
  });

  test('a line that names no stage is not progress', () {
    expect(
      parser.parse('warning: You appear to have cloned an empty repository.'),
      isNull,
    );
    expect(parser.parse('done.'), isNull);
    expect(parser.parse(''), isNull);
  });
}

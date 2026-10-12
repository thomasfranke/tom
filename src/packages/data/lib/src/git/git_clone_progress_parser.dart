/// Turning a line of `git clone --progress` into a [CloneProgressValueObject].
library;

import 'package:tom_domain/tom_domain.dart';

/// The reader of what `GitClient.clone` hands its progress callback, one
/// line at a time.
///
/// Total: a line naming no stage is null rather than an error, because
/// git's progress is for people and changes wording between versions;
/// `LC_ALL=C` keeps it English.
final class GitCloneProgressParser {
  /// A stateless parser, so one instance serves the whole app.
  const GitCloneProgressParser();

  /// The stage each of git's titles belongs to. `remote:` is stripped first,
  /// since the remote's three titles are one stage to the person waiting.
  static const Map<String, CloneStageEnum> _stages = <String, CloneStageEnum>{
    'Cloning into': CloneStageEnum.starting,
    'Enumerating objects': CloneStageEnum.preparing,
    'Counting objects': CloneStageEnum.preparing,
    'Compressing objects': CloneStageEnum.preparing,
    'Receiving objects': CloneStageEnum.receiving,
    'Resolving deltas': CloneStageEnum.resolving,
    'Updating files': CloneStageEnum.checkingOut,
  };

  /// The first `NN%` on a line.
  static final RegExp _percent = RegExp(r'(\d{1,3})%');

  /// [line] as progress, or null when it reports none.
  CloneProgressValueObject? parse(String line) {
    String text = line.trim();
    if (text.startsWith('remote:')) {
      text = text.substring('remote:'.length).trimLeft();
    }
    for (final MapEntry<String, CloneStageEnum> stage in _stages.entries) {
      if (text.startsWith(stage.key)) {
        final int? percent = int.tryParse(
          _percent.firstMatch(text)?.group(1) ?? '',
        );
        return CloneProgressValueObject(
          stage: stage.value,
          percent: percent != null && percent <= 100 ? percent : null,
        );
      }
    }
    return null;
  }
}

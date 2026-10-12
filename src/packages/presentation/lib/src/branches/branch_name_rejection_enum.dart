/// Why a typed name cannot start a branch.
library;

import 'package:tom_domain/tom_domain.dart';

/// What is wrong with the draft as a new branch's name.
///
/// Decided here and worded by the screen, which alone knows the language
/// ([Decision 34](../../../../../../docs/technical/decisions/034-the-interface-is-localised-with-gen-l10n.md)).
enum BranchNameRejectionEnum {
  /// Git would refuse the name itself.
  notAName,

  /// A branch by that name already exists.
  taken;

  /// Why [draft] is not a branch that could be started among [branches], or
  /// null when it is — an empty draft included, since nothing is typed yet.
  static BranchNameRejectionEnum? of(
    String draft,
    List<BranchEntity> branches,
  ) {
    if (draft.isEmpty) {
      return null;
    }
    if (BranchNameValueObject.tryParse(draft) == null) {
      return notAName;
    }
    if (branches.any((BranchEntity it) => it.name.value == draft)) {
      return taken;
    }
    return null;
  }
}

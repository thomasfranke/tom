/// Which commands the person allowed to run without being asked.
library;

/// The list of `git-approvals.json`: a command's key, and whether it may
/// run unasked (`docs/product/git-workflow/approvals/doc.md`).
///
/// **A key the list does not hold is `false`**, as is a value that is not
/// a yes: nothing is allowed until the person allowed it. An `extension
/// type` per [Decision 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md).
extension type const ApprovalsValueObject(Map<String, bool> allowed) {
  /// The list nobody has written anything into.
  static const ApprovalsValueObject none = ApprovalsValueObject(
    <String, bool>{},
  );

  /// Whether the command named [key] may run without asking.
  bool allows(String key) => allowed[key] ?? false;
}

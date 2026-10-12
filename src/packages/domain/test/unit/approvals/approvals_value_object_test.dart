import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('the list allows only what it says yes to', () {
    const ApprovalsValueObject list = ApprovalsValueObject(<String, bool>{
      'git fetch': true,
      'git push': false,
    });

    expect(list.allows('git fetch'), isTrue);
    expect(list.allows('git push'), isFalse);
    expect(list.allows('git pull --no-rebase'), isFalse, reason: 'not held');
  });

  test('a list nobody wrote allows nothing', () {
    expect(ApprovalsValueObject.none.allows('git fetch'), isFalse);
  });

  test('nobody is asked until somebody chooses: the mode starts automatic', () {
    expect(
      PreferencesValueObject.defaults.gitApprovals,
      GitApprovalModeEnum.automatic,
    );
  });
}

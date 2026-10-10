/// The count beside `Git` in the right column's tabs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_count_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// How many changes git reports — the status bar's own number, so the two
/// never disagree — and nothing when there are none.
class ChangesTabCountWidget extends ConsumerWidget {
  /// Creates the count.
  const ChangesTabCountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int count = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.git?.entries.length ?? 0,
      ),
    );
    return count == 0
        ? const SizedBox.shrink()
        : ChangesCountWidget(count: count);
  }
}

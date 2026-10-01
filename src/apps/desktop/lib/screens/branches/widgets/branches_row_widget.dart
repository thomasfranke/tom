/// One branch in the list.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A branch, and whether it is the one checked out.
///
/// The current one is drawn rather than hidden, because the list is also how
/// you read where you are.
class BranchesRowWidget extends ConsumerWidget {
  /// Creates the row for [branch].
  const BranchesRowWidget({required this.branch, super.key});

  /// The branch this row is.
  final BranchEntity branch;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BranchEntity>('branch', branch));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: BranchesDesign.rowPitch,
      child: Align(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BranchesDesign.rowInset,
          ),
          child: Material(
            color: branch.isCurrent ? colors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(BranchesDesign.radius),
            child: InkWell(
              // Clicking where you already are is neither an error nor an
              // action; the notifier does nothing.
              onTap: () => unawaited(
                ref.read(branchesProvider.notifier).choose(branch.name),
              ),
              borderRadius: BorderRadius.circular(BranchesDesign.radius),
              child: SizedBox(
                height: BranchesDesign.rowHeight,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      branch.name.value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: BranchesDesign.label,
                        height: 1.4,
                        fontWeight: branch.isCurrent
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: branch.isCurrent
                            ? colors.accent
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

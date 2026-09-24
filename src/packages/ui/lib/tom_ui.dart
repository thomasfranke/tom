/// The look, shared by every application: colour roles, metrics, the brand
/// marks and the components both of them draw.
///
/// Nothing outside `lib/src/` is importable from another package, so this
/// file is the whole public surface.
library;

export 'src/theme/tom_colors.dart';
export 'src/theme/tom_metrics.dart';
export 'src/theme/tom_theme.dart';
export 'src/widgets/commit_trunk_log.dart';
export 'src/widgets/commit_trunk_widget.dart';
export 'src/widgets/milestone_chip_widget.dart';
export 'src/widgets/tom_wordmark_widget.dart';

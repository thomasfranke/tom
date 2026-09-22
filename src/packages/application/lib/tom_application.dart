/// Use cases: orchestration between the domain and its repositories.
///
/// One per operation, named for the operation with the role last, and the
/// file named after the class — the shape the Flutter team's own
/// architecture sample uses (`BookingCreateUseCase`).
///
/// Nothing outside `lib/src/` is importable from another package, so this
/// file is the whole public surface.
library;

export 'src/documents/read_document_usecase.dart';
export 'src/spaces/forget_recent_space_usecase.dart';
export 'src/spaces/list_recent_spaces_usecase.dart';
export 'src/spaces/list_space_entries_usecase.dart';
export 'src/spaces/open_space_usecase.dart';
export 'src/use_case.dart';

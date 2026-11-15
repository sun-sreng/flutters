/// Flutter UI toolkit for the gmana ecosystem: design tokens, widgets, form
/// fields, spinners, and Flutter extensions.
///
/// Re-exports `package:gmana/gmana.dart`, so one import covers the pure Dart
/// toolkit too. The functional `State` monad is left out because it would
/// clash with Flutter's `State`; import `package:gmana/functional.dart` with a
/// prefix to use it. Topic libraries: `extensions.dart`, `form.dart`, and
/// `spinner.dart`.
library;

export 'package:gmana/gmana.dart' hide State;

export 'src/design_system/colors.dart';
export 'src/design_system/font_weight.dart';
export 'src/design_system/motion.dart';
export 'src/design_system/radius.dart';
export 'src/design_system/spacing.dart';
export 'src/design_system/tone.dart';
export 'extensions.dart';
export 'form.dart';
export 'spinner.dart';
export 'src/utils/locale.dart';
export 'src/utils/register_error_handler.dart';
export 'src/widgets/app_bar.dart';
export 'src/widgets/avatar.dart';
export 'src/widgets/banner.dart';
export 'src/widgets/button.dart';
export 'src/widgets/card.dart';
export 'src/widgets/divider.dart';
export 'src/widgets/empty_state.dart';
export 'src/widgets/gap.dart';
export 'src/widgets/grid.dart';
export 'src/widgets/list_tile.dart';
export 'src/widgets/responsive_builder.dart';
export 'src/widgets/star_rating_bar.dart';
export 'src/widgets/tag.dart';
export 'src/widgets/text_field.dart';

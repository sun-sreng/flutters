import 'wave_spinner.dart';

@Deprecated('Use WaveSpinner instead.')
class GSpinner extends WaveSpinner {
  const GSpinner({
    super.key,
    required super.color,
    super.trackColor,
    super.waveColor,
    super.size,
    super.duration,
    super.curve,
    super.child,
    super.controller,
  });
}

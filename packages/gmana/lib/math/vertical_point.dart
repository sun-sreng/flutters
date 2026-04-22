import 'wave_vertical_offset.dart' show waveVerticalOffset;

export 'wave_vertical_offset.dart' show waveVerticalOffset;

/// Backward-compatible wrapper for [waveVerticalOffset].
@Deprecated('Use waveVerticalOffset instead.')
double verticalPoint({
  required double value,
  required double verticalShift,
  required double amplitude,
  required double phaseShift,
  required double waveLength,
}) {
  return waveVerticalOffset(
    value: value,
    verticalShift: verticalShift,
    amplitude: amplitude,
    phaseShift: phaseShift,
    waveLength: waveLength,
  );
}

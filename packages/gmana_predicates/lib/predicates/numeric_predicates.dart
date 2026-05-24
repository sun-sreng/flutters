/// Returns `true` if the numeric value of [str] is divisible by [n].
///
/// Both [str] and [n] are parsed as `double`; returns `false` on parse failure
/// or when [n] is zero.
bool isDivisibleBy(String str, String n) {
  try {
    return double.parse(str) % double.parse(n) == 0;
  } catch (_) {
    return false;
  }
}

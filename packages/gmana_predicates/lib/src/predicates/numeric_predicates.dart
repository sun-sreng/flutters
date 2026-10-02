/// Returns `true` if the numeric value of [str] is divisible by [n].
///
/// Both [str] and [n] are parsed as `double`; returns `false` on parse failure
/// or when [n] is zero.
bool isDivisibleBy(String str, String n) {
  try {
    final divisor = double.parse(n);
    if (divisor == 0) return false;
    return double.parse(str) % divisor == 0;
  } catch (_) {
    return false;
  }
}

/// Returns `true` if [str] represents an even integer.
bool isEven(String str) {
  final val = int.tryParse(str);
  return val != null && val % 2 == 0;
}

/// Returns `true` if [str] represents an odd integer.
bool isOdd(String str) {
  final val = int.tryParse(str);
  return val != null && val % 2 != 0;
}

/// Returns `true` if the numeric value of [str] is greater than zero.
bool isPositive(String str) {
  final val = double.tryParse(str);
  return val != null && val > 0;
}

/// Returns `true` if the numeric value of [str] is less than zero.
bool isNegative(String str) {
  final val = double.tryParse(str);
  return val != null && val < 0;
}

/// Returns `true` if the numeric value of [str] is exactly zero.
bool isZero(String str) {
  final val = double.tryParse(str);
  return val != null && val == 0;
}

/// Returns `true` if the numeric value of [str] is within [`min`, `max`] (inclusive).
bool isInRange(String str, num min, num max) {
  final val = double.tryParse(str);
  return val != null && val >= min && val <= max;
}

/// Returns `true` if [n] is a prime integer.
bool isPrime(int n) {
  if (n <= 1) return false;
  if (n <= 3) return true;
  if (n % 2 == 0 || n % 3 == 0) return false;
  for (var i = 5; i * i <= n; i += 6) {
    if (n % i == 0 || n % (i + 2) == 0) return false;
  }
  return true;
}

/// Returns `true` if [str] represents a prime integer.
bool isPrimeString(String str) {
  final val = int.tryParse(str);
  return val != null && isPrime(val);
}

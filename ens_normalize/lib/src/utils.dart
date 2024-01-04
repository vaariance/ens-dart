part of 'ens_normalize_base.dart';

String hexCodePoint(int codePoint) {
  validCodePoint(codePoint);
  return codePoint.toRadixString(16).toUpperCase().padLeft(2, '0');
}

String quoteCodePoint(int codePoint) {
  String hexCode = hexCodePoint(codePoint);
  return "{$hexCode}";
}

void validCodePoint(int codePoint) {
  assert(codePoint >= 0 && codePoint <= 1114111);
}

Runes explodeCodePoint(String s) {
  return s.runes;
}

String strFromCodePoints(List<int> codePoints) {
  const chunk = 4096;
  int len = codePoints.length;

  if (len < chunk) {
    return String.fromCharCodes(codePoints);
  }

  StringBuffer result = StringBuffer();

  for (int i = 0; i < len; i += chunk) {
    result.write(String.fromCharCodes(codePoints.skip(i).take(chunk)));
  }

  return result.toString();
}

int compareArrays(List<num> a, List<num> b) {
  int n = a.length;
  int c = n - b.length;

  for (int i = 0; c == 0 && i < n; i++) {
    c = a[i].compareTo(b[i]);
  }

  return c;
}

T randomChoice<T>(List<T> v, {Random? rng}) {
  return v[(rng ?? Random()).nextInt(v.length)];
}

List<T> randomSample<T>(List<T> v, int n, {Random? rng}) {
  if (n > v.length) {
    throw ArgumentError('Sample size cannot be greater than population size');
  }

  List<T> result = List.of(v);
  for (int i = 0; i < n; i++) {
    int j = i + (rng ?? Random()).nextInt(v.length - i);
    T temp = result[i];
    result[i] = result[j];
    result[j] = temp;
  }
  return result.sublist(0, n);
}

part of 'ens_normalize_base.dart';

String hexCp(int cp) {
  validCodePoint(cp);
  return cp.toRadixString(16).toUpperCase().padLeft(2, '0');
}

String quoteCp(int cp) {
  String hexCode = hexCp(cp);
  return "{$hexCode}";
}

void validCodePoint(int cp) {
  assert(cp >= 0 && cp <= 1114111);
}

Runes explodeCp(String s) {
  return s.runes;
}

String strFromCps(List<int> cps) {
  const chunk = 4096;
  int len = cps.length;

  if (len < chunk) {
    return String.fromCharCodes(cps);
  }

  StringBuffer result = StringBuffer();

  for (int i = 0; i < len; i += chunk) {
    result.write(String.fromCharCodes(cps.skip(i).take(chunk)));
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

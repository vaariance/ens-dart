import 'dart:convert';
import 'dart:math';

// import 'package:ens_normalize/src/ens_normalize_base.dart' show compareArrays;

const MAX_LINEAR = 251;

Map<String, dynamic> bestArithmetic(Iterable<int> symbols, {int max = 128}) {
  Map<String, dynamic>? bestResult;
  for (int n = 0; n <= max; n++) {
    final encodedData = encodeArithmetic(symbols, n);
    if (bestResult == null || encodedData.length < bestResult['data'].length) {
      bestResult = {'data': encodedData, 'symbols': n};
    }
  }
  return bestResult!;
}

List<int> bytesFromBits(List<int> v) {
  if (v.length & 7 != 0) {
    throw ArgumentError('Input list length must be divisible by 8');
  }

  final bytes = <int>[];
  for (int i = 0; i < v.length; i += 8) {
    int byte = 0;
    for (int j = 0; j < 8; j++) {
      byte |= v[i + j] << (7 - j);
    }
    bytes.add(byte);
  }

  return bytes;
}

List<int> encodeArithmetic(Iterable<int> symbols, int linear) {
  if (symbols.isEmpty) {
    throw ArgumentError('No symbols provided');
  }
  if (linear < 0) {
    throw ArgumentError('Linear symbols must be non-negative');
  }
  if (linear > MAX_LINEAR) {
    throw ArgumentError('Too many linear symbols');
  }

  final payload = <int>[];
  List<int> freq = List.filled(linear + 4, 0);

  final encodedSymbols = symbols.map((x) {
    if (x >= linear) {
      x -= linear;
      if (x < 0x100) {
        payload.add(x);
        return linear + 1;
      }
      x -= 0x100;
      if (x < 0x10000) {
        payload.addAll([x >> 8, x & 0xFF]);
        return linear + 2;
      }
      x -= 0x10000;
      payload.addAll([x >> 16, (x >> 8) & 0xFF, x & 0xFF]);
      return linear + 3;
    } else {
      return x + 1;
    }
  }).toList();

  encodedSymbols.add(0);

  if (freq.length > 255) throw RangeError("frequency length exceeds 255");

  for (int x in encodedSymbols) {
    freq[x]++;
  }

  freq = freq.map((x) => max(1, x)).toList();

  List<int> acc = [0];
  int total = 0;
  for (int i = 0; i < freq.length; i++) {
    acc.add(total += freq[i]);
  }

  const int N = 31;
  const int FULL = 2147483648;
  const int HALF = FULL >>> 1;
  const int QRTR = HALF >> 1;
  const int MASK = FULL - 1;

  int low = 0;
  int range = FULL;
  int underflow = 0;
  List<int> bits = [];

  for (int x in encodedSymbols) {
    int a = low + (range * acc[x] / total).floor();
    int b = low + (range * acc[x + 1] / total).floor() - 1;

    while (((a ^ b) & HALF) == 0) {
      int bit = a >>> (N - 1);
      bits.add(bit);
      for (; underflow > 0; underflow--) {
        bits.add(bit ^ 1);
      }
      a = (a << 1) & MASK;
      b = (b << 1) & MASK | 1;
    }

    while ((a & ~b & QRTR) != 0) {
      underflow++;
      a = (a << 1) ^ HALF;
      b = ((b ^ HALF) << 1) | HALF | 1;
    }

    low = a;
    range = 1 + b - a;
  }

  bits.add(1);
  while (bits.length & 7 != 0) {
    bits.add(0);
  }

  List<int> header = [];
  freq[0] = freq.length;
  freq.add(payload.length);
  for (int n in freq) {
    header.addAll([n >> 8, n & 0xFF]);
  }

  return header + payload + bytesFromBits(bits);
}

Map<K, List<T>> groupBy<T, K>(Iterable<T> v, K Function(T) fn,
    {Map<K, List<T>>? ret}) {
  ret ??= {};
  for (var x in v) {
    var key = fn(x);
    ret.putIfAbsent(key, () => []).add(x);
  }
  return ret;
}

List<List<T>> splitBetween<T>(List<T> v, bool Function(T a, T b) fn) {
  List<List<T>> ret = [];
  int start = 0;

  for (int i = 1; i < v.length; i++) {
    if (fn(v[i - 1], v[i])) {
      ret.add(v.sublist(start, i));
      start = i;
    }
  }

  if (start < v.length) {
    ret.add(v.sublist(start));
  }

  return ret;
}

Map<String, List<List<dynamic>>> splitLinear(
    List<dynamic> mapped, num dx, num dy) {
  List<List<dynamic>> linear = [];

  if (mapped.isEmpty) {
    return {'linear': [], 'nonlinear': []};
  }

  if (mapped is! List<List<dynamic>>) {
    throw TypeError();
  }

  mapped = mapped.map((row) => List.of(row)).toList();

  for (int i = 0; i < mapped.length; i++) {
    final row0 = mapped[i];
    int x0 = row0[0];
    List<int> ys0 = List<int>.from(row0[1]);
    if (x0 == -1) continue;
    final group = [row0];

    next:
    for (var j = i; j < mapped.length; j++) {
      final row = mapped[j];
      final x = row[0];
      final ys = row[1];
      if (x == -1) continue;
      final x1 = x0 + group.length * dx;
      if (x < x1) continue;
      if (x > x1) break;
      for (var k = 0; k < ys0.length; k++) {
        if (ys0[k] + group.length * dy != ys[k]) continue next;
      }
      group.add(row);
    }
    if (group.length > 1) {
      for (var v in group) {
        v[0] = -1;
      }
      linear.add([x0, group.length, ys0]);
    }
  }
  return {
    "linear": linear,
    "nonlinear": mapped.where((v) => v[0] >= 0).toList()
  };
}

String unsafeBtoa(List<int> v) {
  String base64String = base64.encode(v).replaceAll(RegExp('=+\$'), '');
  return base64String;
}

class Encoder {
  List<int> values;

  Encoder(this.values);

  void array(Iterable<int> v) {
    for (int x in v) {
      unsigned(x);
    }
  }

  void ascending(Iterable<int> v) {
    int prev = 0;
    for (int x in v) {
      unsigned(x - prev);
      prev = x + 1;
    }
  }

  Map<String, dynamic> compressed() {
    return bestArithmetic(values);
  }

  void deltas(Iterable<int> v) {
    int prev = 0;
    for (int x in v) {
      signed(x - prev);
      prev = x;
    }
  }

  void positive(int i) => unsigned(i - 1);

  void positiveCounts(Iterable<int> v) {
    for (int x in v) {
      positive(x);
    }
  }

  void signed(int i) => unsigned(i < 0 ? ~(i << 1) : (i << 1));

  void unsigned(int x) {
    if (x < 0) {
      throw ArgumentError('Expected unsigned integer: $x');
    }
    values.add(x);
  }

  // // Todo: add _sortMap function
  // void writeMapped(List<List<int>> linearSpecs, List<List<dynamic>> mapped) {
  //   Map<int, List<List<dynamic>>> newMap =
  //       groupBy<List<dynamic>, int>(mapped, (ys) => ys[1].length, ret: {})
  //           .map((k, v) => _sortMap(k, v));

  //   for (List<int> spec in linearSpecs) {
  //     int w;
  //     int dx;
  //     int dy;
  //     [w, dx, dy] = spec;

  //     if (!(dx > 0)) throw ArgumentError('expected positive dx: $dx');
  //     if (w >= newMap.length) {
  //       print("linear spec not used: out of bounds: $w");
  //       continue;
  //     }

  //     final split = splitLinear(newMap[w]!, dx, dy);
  //     List<List<dynamic>> linear = split["linear"]!;
  //     List<List<dynamic>> nonlinear = split["nolinear"]!;

  //     if (linear.isEmpty) {
  //       print("linear spec not used: empty: $w $dx $dy");
  //       continue;
  //     }

  //     newMap[w] = nonlinear;
  //     unsigned(w);
  //     positive(dx);
  //     unsigned(dy);

  //     for (var v in linear) {
  //       unsigned(v[1]);
  //     }
  //     unsigned(0);
  //     // writeTransposed(linear.map(([x, _, ys]) => [x, ...ys]).sort(compare_arrays));
  //   }

  //   unsigned(0); // eol

  //   newMap.forEach((w, m) {
  //     if (m.isEmpty) return;
  //     unsigned(1 + w);
  //     positive(m.length);
  //     //writeTransposed(m.map(([x, ys]) => [x, ...ys]).sort(compare_arrays));
  //   });

  //   unsigned(0); // eol
  // }

  void writeMember(Iterable<int> v) {
    if (v is Set) {
      v = [...v];
    } else if (v is List) {
      v = [...Set.from(v)];
    } else {
      throw ArgumentError('expected set or array');
    }
    _checkUnsigned(v.toList());
    int prev = 0;
    (v as List<int>).sort((a, b) => a - b);
    for (List<int> run in splitBetween<int>(v, (a, b) => b - a > 1)) {
      unsigned(run[0] - prev);
      unsigned(run.length);
      prev = run[run.length - 1] + 2;
    }
    unsigned(0);
    unsigned(0);
  }

  void writeTransposed(List<List<int>> m) {
    if (m.isEmpty) return;
    int w = m[0].length;
    for (int i = 0; i < w; i++) {
      deltas(m.map((v) => v[i]));
    }
  }

  void _checkUnsigned(List<int> values) {
    if (values.any((x) => x < 0)) {
      throw ArgumentError('Expected unsigned integer in Iterable');
    }
  }
}

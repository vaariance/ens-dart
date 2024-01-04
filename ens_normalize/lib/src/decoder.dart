import 'dart:typed_data';

List<int> decodeArithmetic(List<int> bytes) {
  if ((bytes.length & 7) != 0) {
    bytes.addAll(List.filled(8 - (bytes.length & 7), 0));
  }

  int pos = 0;
  int u16() {
    return (bytes[pos++] << 8) | bytes[pos++];
  }

  int symbolCount = u16();
  int total = 1;
  List<int> acc = [0, 1];
  for (int i = 1; i < symbolCount; i++) {
    acc.add(total += u16());
  }

  int skip = u16();
  int posPayload = pos;
  pos += skip;

  int readWidth = 0;
  int readBuffer = 0;
  int readBit() {
    if (readWidth == 0) {
      readBuffer = (readBuffer << 8) | bytes[pos++];
      readWidth = 8;
    }
    return (readBuffer >> --readWidth) & 1;
  }

  int N = 31;
  int FULL = 2147483648;
  int HALF = FULL >>> 1;
  int QRTR = HALF >> 1;
  int MASK = FULL - 1;

  int register = 0;
  for (int i = 0; i < N; i++) {
    register = (register << 1) | readBit();
  }

  List<int> symbols = [];
  int low = 0;
  int range = FULL;
  while (true) {
    int value = (((register - low + 1) * total - 1) / range).floor();
    int start = 0;
    int end = symbolCount;
    while (end - start > 1) {
      int mid = (start + end) >>> 1;
      if (value < acc[mid]) {
        end = mid;
      } else {
        start = mid;
      }
    }
    if (start == 0) break;
    symbols.add(start);
    int a = low + ((range * acc[start]) / total).floor();
    int b = low + ((range * acc[start + 1]) / total).floor() - 1;
    while (((a ^ b) & HALF) == 0) {
      register = (register << 1) & MASK | readBit();
      a = (a << 1) & MASK;
      b = (b << 1) & MASK | 1;
    }
    while ((a & ~b & QRTR) != 0) {
      register =
          (register & HALF) | ((register << 1) & (MASK >>> 1)) | readBit();
      a = (a << 1) ^ HALF;
      b = ((b ^ HALF) << 1) | HALF | 1;
    }
    low = a;
    range = 1 + b - a;
  }
  final offset = symbolCount - 4;
  return symbols.map((x) {
    switch (x - offset) {
      case 3:
        return offset +
            0x10100 +
            ((bytes[posPayload++] << 16) |
                (bytes[posPayload++] << 8) |
                bytes[posPayload++]);
      case 2:
        return offset +
            0x100 +
            ((bytes[posPayload++] << 8) | bytes[posPayload++]);
      case 1:
        return offset + bytes[posPayload++];
      default:
        return x - 1;
    }
  }).toList();
}

List<T> readArrayWhile<T>(T? Function() next) {
  final v = <T>[];
  while (true) {
    final x = next();
    if (x == null || x == 0) break;
    v.add(x);
  }
  return v;
}

List<int> readAscending(int n, int? Function() next) {
  int x = -1;
  List<int> v = List<int>.generate(n, (i) => x += 1 + next()!);
  return v;
}

int? Function() readCompressedPayload(String s) {
  return readPayload(decodeArithmetic(unsafeAtob(s)));
}

List<int> readCounts(int n, int? Function() next) {
  List<int> v = List<int>.generate(n, (i) => 1 + next()!);
  return v;
}

List<int> readDeltas(int n, int? Function() next) {
  int x = 0;
  List<int> v = List<int>.generate(n, (i) => x += signed(next()));
  return v;
}

List<List<dynamic>> readLinearTable(int w, int? Function() next) {
  final dx = 1 + next()!;
  final dy = next()!;
  final vN = readArrayWhile(next);
  final m = readTransposed(vN.length, 1 + w, next);
  return m.expand((v) {
    final x = v[0];
    final ys = v.sublist(1);
    return List.generate(vN[m.lastIndexOf(v)], (j) {
      final jDy = j * dy;
      return [x + j * dx, ys.map((y) => y + jDy).toList()];
    });
  }).toList();
}

List<dynamic> readMapped(int? Function() next) {
  List<List<List<dynamic>>> ret = [];
  while (true) {
    int? w = next();
    if (w == 0) break;
    if (w != null) {
      ret.add(readLinearTable(w, next));
    }
  }
  while (true) {
    int? w = next(); // Handle potential null from next()
    if (w == null || w - 1 < 0) break;
    ret.add(readReplacementTable(w - 1, next));
  }
  return ret.flat();
}

List<int> readMemberArray(int? Function() next, List<int> lookup) {
  List<int> v = readAscending(next()!, next);
  int n = next()!;
  List<int> vX = readAscending(n, next);
  List<int> vN = readCounts(n, next);
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < vN[i]; j++) {
      v.add(vX[i] + j);
    }
  }
  return lookup.isNotEmpty ? v.map((x) => lookup[x]).toList() : v;
}

T? Function() readPayload<T>(List<T> v) {
  int pos = 0;
  return () => pos < v.length ? v[pos++] : null;
}

List<List<dynamic>> readReplacementTable(int w, int? Function() next) {
  int n = 1 + next()!;
  List<List<int>> m = readTransposed(n, 1 + w, next);
  return m.map((v) => [v[0], v.sublist(1)]).toList();
}

List<int> readSorted(int? Function() next, [int prev = 0]) {
  List<int> ret = [];
  while (true) {
    int? x = next();
    int? n = next();
    if (n == null) break;
    prev += x ?? 0;
    for (int i = 0; i < n; i++) {
      ret.add(prev + i);
    }
    prev += n + 1;
  }
  return ret;
}

List<List<int>> readSortedArrays(int? Function() next) {
  return readArrayWhile<List<int>>(() {
    final v = readSorted(next);
    if (v.isNotEmpty) return v;
    return null;
  });
}

List<List<int>> readTransposed(int n, int w, int? Function() next) {
  final m = List.generate(n, (_) => <int>[]);
  for (int i = 0; i < w; i++) {
    readDeltas(n, next).forEachIndexed((x, index) => m[index].add(x));
  }
  return m;
}

List<List<int>> readTrie(int? Function() next) {
  List<List<int>> ret = [];
  List<int> sorted = readSorted(next);

  Map<String, dynamic> decode(List<int> Q) {
    final S = next();
    final B = readArrayWhile(() {
      final codePoints = readSorted(next).map((i) => sorted[i]).toList();
      if (codePoints.isNotEmpty) return decode(codePoints);
    });
    return {'S': S, 'B': B, 'Q': Q};
  }

  void expand(Map<String, dynamic> node, List<int> codePoints, {int? saved}) {
    int? S = node['S'];
    bool sN = S != null;
    if (sN && S & 4 != 0 && saved == codePoints.last) return;
    if (sN && S & 2 != 0) saved = codePoints.last;
    if (sN && S & 1 != 0) ret.add(codePoints);

    List<Map<String, dynamic>> B = node['B'];
    for (final br in B) {
      List<int> Q = br['Q'];
      for (final codePoint in Q) {
        expand(br, [...codePoints, codePoint], saved: saved);
      }
    }
  }

  expand(decode([]), []);
  return ret;
}

int signed(int? i) {
  return i == null
      ? 0
      : (i & 1) != 0
          ? (~i >> 1)
          : (i >> 1);
}

List<int> unsafeAtob(String s) {
  List<int> lookup = List.filled(256, 0);
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
      .runes
      .toList()
      .asMap()
      .forEach((i, c) => lookup[c] = i);

  int n = s.length;
  Uint8List ret = Uint8List((6 * n) >> 3);

  for (int i = 0, pos = 0, width = 0, carry = 0; i < n; i++) {
    carry = (carry << 6) | lookup[s.codeUnitAt(i)];
    width += 6;
    if (width >= 8) {
      ret[pos++] = (carry >> (width -= 8));
    }
  }

  return List.from(ret);
}

extension ArrayExtensions<T> on List<T> {
  List flat({int level = 1}) {
    final result = [];
    _flatten(this, result, level);
    return result;
  }

  void _flatten(List? list, List result, int level) {
    if (list == null) return;
    for (final item in list) {
      if (item is List && level > 0) {
        _flatten(item, result, level - 1);
      } else {
        result.add(item);
      }
    }
  }
}

extension IterableExtensions<E> on Iterable<E> {
  void forEachIndexed(void Function(E element, int index) action) {
    var index = 0;
    for (final element in this) {
      action(element, index);
      index++;
    }
  }
}

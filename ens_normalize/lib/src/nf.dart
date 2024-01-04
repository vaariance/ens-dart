part of 'ens_normalize_base.dart';

const S0 = 0xAC00;
const L0 = 0x1100;
const V0 = 0x1161;
const T0 = 0x11A7;
const L_COUNT = 19;
const V_COUNT = 21;
const T_COUNT = 28;
const N_COUNT = V_COUNT * T_COUNT;
const S_COUNT = L_COUNT * N_COUNT;
const S1 = S0 + S_COUNT;
const L1 = L0 + L_COUNT;
const V1 = V0 + V_COUNT;
const T1 = T0 + T_COUNT;

int unpackCharCode(int packed) {
  return (packed >> 24) & 0xFF;
}

int unpackCodePoint(int packed) {
  return packed & 0xFFFFFF;
}

Map<int, int?>? SHIFTED_RANK;
Set<dynamic> EXCLUSIONS = Set.of({});
Map<int, dynamic> DECOMP = {};
Map<int, dynamic> RECOMP = {};

bool isHangul(int codePoint) {
  return codePoint >= S0 && codePoint < S1;
}

void init() {
  // Uncomment for performance measurement:
  // Stopwatch stopwatch = Stopwatch()..start();

  final r = readCompressedPayload(COMPRESSED_NF);
  final s = readSortedArrays(r);
  SHIFTED_RANK = Map.fromEntries(
      s.expand((v) => v.map((x) => MapEntry(x, (s.lastIndexOf(v) + 1) << 24))));
  EXCLUSIONS = Set.from(readSorted(r));

  for (List<dynamic> entry in readMapped(r)) {
    int codePoint = entry[0];
    List<int> codePoints = entry[1];

    if (!EXCLUSIONS.contains(codePoint) && codePoints.length == 2) {
      int a = codePoints[0];
      int b = codePoints[1];
      RECOMP.putIfAbsent(a, () => {})[b] =
          codePoint; // Create nested maps for RECOMP
    }

    DECOMP[codePoint] =
        codePoints.reversed.toList(); // Store reversed list in DECOMP
  }

  // Uncomment for performance measurement:
  // print('Elapsed time: ${stopwatch.elapsedMilliseconds} ms');
}

int composePair(int a, int b) {
  if (a >= L0 && a < L1 && b >= V0 && b < V1) {
    return S0 + (a - L0) * N_COUNT + (b - V0) * T_COUNT;
  } else if (isHangul(a) && b > T0 && b < T1 && (a - S0) % T_COUNT == 0) {
    return a + (b - T0);
  } else {
    final recomp = RECOMP[a];
    if (recomp != null) {
      int? value = recomp[b];
      if (value != null) {
        return value;
      }
    }
    return -1;
  }
}

List<int> decomposed(List<int> codePoints) {
  if (SHIFTED_RANK == null) init();

  List<int> ret = [];
  List<int> buf = [];
  bool checkOrder = false;

  void add(int codePoint) {
    final charCode = SHIFTED_RANK?[codePoint];
    if (charCode != null) {
      checkOrder = true;
      codePoint |= charCode;
    }
    ret.add(codePoint);
  }

  for (int codePoint in codePoints) {
    while (true) {
      if (codePoint < 0x80) {
        ret.add(codePoint);
      } else if (isHangul(codePoint)) {
        int sIndex = codePoint - S0;
        int lIndex = sIndex ~/ N_COUNT;
        int vIndex = (sIndex % N_COUNT) ~/ T_COUNT;
        int tIndex = sIndex % T_COUNT;
        add(L0 + lIndex);
        add(V0 + vIndex);
        if (tIndex > 0) add(T0 + tIndex);
      } else {
        List<int>? mapped = DECOMP[codePoint];
        if (mapped != null) {
          buf.addAll(mapped);
        } else {
          add(codePoint);
        }
      }
      if (buf.isEmpty) break;
      codePoint = buf.removeLast();
    }
  }

  if (checkOrder && ret.length > 1) {
    int prevCharCode = unpackCharCode(ret[0]);
    for (int i = 1; i < ret.length; i++) {
      int charCode = unpackCharCode(ret[i]);
      if (charCode == 0 || prevCharCode <= charCode) {
        prevCharCode = charCode;
        continue;
      }
      int j = i - 1;
      while (true) {
        int tmp = ret[j + 1];
        ret[j + 1] = ret[j];
        ret[j] = tmp;
        if (j == 0) break;
        prevCharCode = unpackCharCode(ret[--j]);
        if (prevCharCode <= charCode) break;
      }
      prevCharCode = unpackCharCode(ret[i]);
    }
  }
  return ret;
}

List<int> composedFromDecomposed(List<int> v) {
  final ret = <int>[];
  final stack = <int>[];
  int prevCodePoint = -1;
  int prevCharCode = 0;

  for (int packed in v) {
    int charCode = unpackCharCode(packed);
    int codePoint = unpackCodePoint(packed);
    if (prevCodePoint == -1) {
      if (charCode == 0) {
        prevCodePoint = codePoint;
      } else {
        ret.add(codePoint);
      }
    } else if (prevCharCode > 0 && prevCharCode >= charCode) {
      if (charCode == 0) {
        ret.addAll([prevCodePoint, ...stack]);
        stack.length = 0;
        prevCodePoint = codePoint;
      } else {
        stack.add(codePoint);
      }
      prevCharCode = charCode;
    } else {
      int composed = composePair(prevCodePoint, codePoint);
      if (composed >= 0) {
        prevCodePoint = composed;
      } else if (prevCharCode == 0 && charCode == 0) {
        ret.add(prevCodePoint);
        prevCodePoint = codePoint;
      } else {
        stack.add(codePoint);
        prevCharCode = charCode;
      }
    }
  }
  if (prevCodePoint >= 0) {
    ret.addAll([prevCodePoint, ...stack]);
  }
  return ret;
}

List<int> nfd(List<int> codePoints) {
  return decomposed(codePoints).map(unpackCodePoint).toList();
}

List<int> nfc(List<int> codePoints) {
  return composedFromDecomposed(decomposed(codePoints));
}

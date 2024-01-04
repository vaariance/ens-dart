import 'package:ens_normalize/src/decoder.dart';
import 'package:ens_normalize/src/include_ens.dart';
import 'package:test/test.dart';

void main() {
  group('decodeArithmetic function', () {
    test('decodes complex arithemetic output', () {
      var bytes = [
        0,
        6,
        0,
        1,
        0,
        1,
        0,
        2,
        0,
        1,
        0,
        1,
        0,
        4,
        98,
        254,
        155,
        62,
        58,
        224
      ];
      var decoded = decodeArithmetic(bytes);
      expect(decoded, [0, 100, 256, 40000]);
    });
  });
  test("decodes simple encoded arithmetic", () {
    var bytes = [0, 8, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 41, 193];
    var decoded = decodeArithmetic(bytes);
    expect(decoded, [0, 1, 2, 3]);
  });

  group("singed int", () {
    test("returns a valid signed value for positive int", () {
      int pint = 5;
      var res = signed(pint);
      expect(res, -3);
    });

    test("returns a valid signed value for negative int", () {
      int nint = -3;
      var res = signed(nint);
      expect(res, 1);
    });
  });

  test("unsafe atob", () {
    String bytes = "peter";
    var res = unsafeAtob(bytes);
    expect(res, [165, 235, 94]);
  });

  test(" reads a payload", () {
    var bytes = [0, 1, 2, 3];
    var res = readPayload(bytes);
    expect(res(), 0);
    expect(res(), 1);
  });

  test("returns the next value from a compressed payload", () {
    String bytes = "AAgAAQABAAEAAQABAAEAAQAAKcE";
    var res = readCompressedPayload(bytes);
    // AAgAAQABAAEAAQABAAEAAQAAKcE => [0, 8, 0, 1, ... 0, 41, 193] => [0,1,2,3]
    expect(res(), 0);
    expect(res(), 1);
    expect(res(), 2);
    expect(res(), 3);
  });

  group("with iterator function", () {
    late int? Function() fn;
    setUp(() {
      var bytes = [0, 1, 2, 3];
      fn = readPayload(bytes);
    });

    test("reads count", () {
      var res = readCounts(3, fn);
      expect(res, [1, 2, 3]);
    });

    test("reads ascending", () {
      var res = readAscending(4, fn);
      expect(res, [0, 2, 5, 9]);
    });

    test("read deltas", () {
      var res = readDeltas(4, fn);
      expect(res, [0, -1, 0, -2]);
    });

    test("read sorted", () {
      var res = readSorted(fn);
      expect(res, [0, 4, 5, 6]);
    });

    test("read member array", () {
      var res = readMemberArray(fn, []);
      expect(res, [2, 3, 4, 5]);
    });

    test("read transposed", () {
      var res = readTransposed(1, 4, fn);
      expect(res, [
        [0, -1, 1, -2]
      ]);
    });

    test("read replacement table", () {
      var res = readReplacementTable(4, fn);
      expect(res, [
        [
          -1,
          [1, -2, 0, 0]
        ]
      ]);
    });

    test("read array while", () {
      var res = readArrayWhile(fn);
      expect(res, []);
    });

    test("read sorted array", () {
      var res = readSortedArrays(fn);
      expect(res, [
        [0, 4, 5, 6]
      ]);
    });

    test("read trie", () {
      var res = readTrie(fn);
      expect(res, []);
    });

    test("read linear table", () {
      var res = readLinearTable(4, fn);
      expect(res, [
        [
          0,
          [0, 0, 0, 0]
        ],
        [
          1,
          [1, 1, 1, 1]
        ],
        [
          0,
          [0, 0, 0, 0]
        ],
        [
          1,
          [1, 1, 1, 1]
        ],
        [
          2,
          [2, 2, 2, 2]
        ]
      ]);
    });
  });

  test("read mapped", () {
    var bytes = readCompressedPayload(COMPRESSED);
    var res = readMapped(bytes);
    expect(res.first, [
      7300,
      [1090]
    ]);
  });
}

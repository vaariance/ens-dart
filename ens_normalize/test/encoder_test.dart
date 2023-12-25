import 'dart:convert';

import 'package:ens_normalize/src/encoder.dart';
import 'package:test/test.dart';

void main() {
  group('groupBy function', () {
    test('it groups numbers by parity', () {
      var numbers = [1, 2, 3, 4, 5, 6];
      var grouped = groupBy(numbers, (x) => x % 2 == 0 ? 'even' : 'odd');
      expect(grouped['even'], [2, 4, 6]);
      expect(grouped['odd'], [1, 3, 5]);
    });

    test('it groups strings by length', () {
      var words = ['hello', 'world', 'programming', 'dart'];
      var grouped = groupBy(words, (x) => x.length);
      expect(grouped[5], ['hello', 'world']);
      expect(grouped[11], ['programming']);
      expect(grouped[4], ['dart']);
    });
  });

  group('splitBetween function', () {
    test('it splits on even numbers', () {
      List<int> input = [1, 3, 4, 6, 8, 9, 10, 13, 15];
      List<List<int>> result =
          splitBetween(input, (a, b) => a % 2 == 0 && b % 2 == 0);

      expect(result, [
        [1, 3, 4],
        [6],
        [8, 9, 10, 13, 15]
      ]);
    });

    test('it splits on differences of 2', () {
      List<int> input = [1, 3, 5, 7, 10, 12, 14, 17];
      List<List<int>> result = splitBetween(input, (a, b) => b - a == 2);

      expect(result, [
        [1],
        [3],
        [5],
        [7, 10],
        [12],
        [14, 17]
      ]);
    });
  });

  group('splitLinear function', () {
    test('splits simple linear sequences', () {
      var mapped = [
        [
          1,
          [2, 3, 4]
        ],
        [
          2,
          [3, 4, 5]
        ],
        [
          3,
          [4, 5, 6]
        ],
        [
          5,
          [6, 7, 8]
        ],
        [
          6,
          [7, 8, 9]
        ],
        [
          7,
          [8, 9, 10]
        ],
      ];
      var result = splitLinear(mapped, 3, 3);
      expect(result['linear'], [
        [
          2,
          2,
          [3, 4, 5]
        ],
        [
          3,
          2,
          [4, 5, 6]
        ]
      ]);
      expect(result['nonlinear'], [
        [
          1,
          [2, 3, 4]
        ],
        [
          7,
          [8, 9, 10]
        ]
      ]);
    });

    test('handles empty input', () {
      var mapped = [];
      var result = splitLinear(mapped, 3, 3);
      expect(result['linear'], []);
      expect(result['nonlinear'], []);
    });
  });

  group('bytesFromBits function', () {
    test('converts simple bits to bytes', () {
      var bits = [0, 1, 1, 0, 1, 0, 0, 1];
      var bytes = bytesFromBits(bits);
      expect(bytes, [0x69]);
    });

    test('handles multiple bytes', () {
      var bits = [1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1];
      var bytes = bytesFromBits(bits);
      expect(bytes, [0xB8, 0xD7]);
    });

    test('throws error for invalid length', () {
      var bits = [1, 0, 1, 1, 1, 0];
      expect(() => bytesFromBits(bits), throwsArgumentError);
    });

    test('handles empty input', () {
      List<int> bits = [];
      var bytes = bytesFromBits(bits);
      expect(bytes, []);
    });
  });

  group('unsafeBtoa function', () {
    test('encodes simple bytes', () {
      var bytes = utf8.encode("peter");
      var encoded = unsafeBtoa(bytes);
      expect(encoded, 'cGV0ZXI');
    });

    test('handles multiple bytes', () {
      var bytes = [0, 17, 34, 42, 72, 65];
      var encoded = unsafeBtoa(bytes);
      expect(encoded, 'ABEiKkhB');
    });

    test('removes trailing padding', () {
      var bytes = [1, 2];
      var encoded = unsafeBtoa(bytes);
      expect(encoded, 'AQI');
    });
  });

  group('encodeArithmetic function', () {
    test('encodes simple linear symbols', () {
      var symbols = [0, 1, 2, 3];
      var encoded = encodeArithmetic(symbols, 4);
      expect(encoded,
          [0, 8, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 41, 193]);
    });

    test('encodes mixed linear and non-linear symbols', () {
      var symbols = [0, 100, 256, 40000];
      var encoded = encodeArithmetic(symbols, 2);
      expect(encoded, [
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
      ]);
    });

    test('handles multiple bytes', () {
      var bits = [1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1];
      var bytes = encodeArithmetic(bits, 5);
      expect(bytes, [
        0,
        9,
        0,
        6,
        0,
        10,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        0,
        97,
        66,
        117,
        128
      ]);
    });
  });

  group('bestArithmetic function', () {
    test('finds best encoding for all linear symbols', () {
      var symbols = [0, 1, 2, 3];
      var best = bestArithmetic(symbols);
      expect(best['symbols'], 0);
      expect(best['data'], [0, 4, 0, 4, 0, 1, 0, 1, 0, 4, 0, 1, 2, 3, 80]);
    });

    test('finds best encoding for mixed linear and non-linear', () {
      var symbols = [0, 100, 256, 40000];
      var best = bestArithmetic(symbols);
      expect(best['symbols'], 0);
      expect(best['data'],
          [0, 4, 0, 2, 0, 2, 0, 1, 0, 6, 0, 100, 0, 0, 155, 64, 76]);
    });
  });
}

import 'dart:math';

import 'package:ens_normalize/ens_normalize.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockRandom extends Mock implements Random {
  int nextIntReturns = 0;

  @override
  int nextInt(int max) => nextIntReturns;
}

void main() {
  MockRandom random = MockRandom();

  group('hex_cp function', () {
    test('it returns the correct hex code point for single-digit values', () {
      expect(hexCp(4), '04');
      expect(hexCp(12), '0C');
      expect(hexCp(15), '0F');
    });

    test('it returns the correct hex code point for multi-digit values', () {
      expect(hexCp(100), '64');
      expect(hexCp(255), 'FF');
      expect(hexCp(1234), '4D2');
    });

    test('it returns padded hex code points for values less than 16', () {
      expect(hexCp(1), '01');
      expect(hexCp(9), '09');
    });

    test('it handles invalid input gracefully', () {
      expect(() => hexCp(null as dynamic), throwsA(isA<TypeError>()));
    });
  });

  group('quote_cp function', () {
    // Basic quotes
    test('it quotes standard ASCII characters', () {
      expect(quoteCp(65), '{41}'); // A
      expect(quoteCp(97), '{61}'); // a
      expect(quoteCp(48), '{30}'); // 0
      expect(quoteCp(57), '{39}'); // 9
      expect(quoteCp(32), '{20}'); // Space
      expect(quoteCp(58), '{3A}'); // :
    });

    test('it quotes extended ASCII characters', () {
      expect(quoteCp(160), '{A0}'); // Non-breaking space
      expect(quoteCp(169), '{A9}'); // Copyright symbol
      expect(quoteCp(174), '{AE}'); // Registered trademark symbol
    });

    test('it quotes Unicode characters', () {
      expect(quoteCp(0x20AC), '{20AC}'); // Euro sign
      expect(quoteCp(0x1F603), '{1F603}'); // Smiling Face with Open Mouth
      expect(quoteCp(0x1F680), '{1F680}'); // Rocket emoji
      expect(quoteCp(0xA000), '{A000}'); // Yi syllable
    });

    test('it quotes code point 0', () {
      expect(quoteCp(0), '{00}');
    });

    test('it handles invalid input gracefully', () {
      expect(() => quoteCp(null as dynamic), throwsA(isA<TypeError>()));
      expect(() => quoteCp('hello' as dynamic), throwsA(isA<TypeError>()));
      expect(() => quoteCp(-1), throwsA(isA<AssertionError>()));
    });
  });

  group('explode_cp function', () {
    test('it explodes basic ASCII strings', () {
      expect(explodeCp('hello'), [0x68, 0x65, 0x6C, 0x6C, 0x6F]);
      expect(explodeCp('123'), [0x31, 0x32, 0x33]);
    });

    test('it explodes strings with extended characters', () {
      expect(explodeCp('€'), [0x20AC]);
      expect(explodeCp('™'), [0x2122]);
    });

    test('it explodes strings with surrogate pairs', () {
      expect(explodeCp('\u{1F4A9}'), [0x1F4A9]);
      expect(explodeCp('\u{1F600}'), [0x1F600]);
    });

    test('it handles empty strings', () {
      expect(explodeCp(''), []);
    });
  });

  group('str_from_cps function', () {
    test('it converts small lists of code points to strings', () {
      expect(strFromCps([0x68, 0x65, 0x6C, 0x6C, 0x6F]), 'hello');
      expect(strFromCps([0x61, 0x62, 0x63]), 'abc');
    });

    test('it handles large lists of code points by chunking', () {
      List<int> longCps = List.generate(10000, (i) => 65 + i);
      String longString = strFromCps(longCps);
      expect(longString.length, 10000);
      expect(longString.startsWith('ABCDEFGHIJKLMNOPQRSTUVWXYZ'), isTrue);
    });

    test('it handles surrogate pairs correctly', () {
      expect(strFromCps([0x1F4A9]), '\u{1F4A9}'); // Pile of Poo emoji
      expect(strFromCps([0x1F600]), '\u{1F600}'); // Grinning Face emoji
    });
  });

  group('compare_arrays function', () {
    test('it returns 0 for equal arrays', () {
      expect(compareArrays([1, 2, 3], [1, 2, 3]), 0);
      expect(compareArrays([1.5, 3.14, 2.71], [1.5, 3.14, 2.71]), 0);
    });

    test('it returns a positive value for greater array lengths', () {
      expect(compareArrays([1, 2, 3], [1, 2]), 1);
      expect(compareArrays([1.5, 3.14], [1.5]), 1);
    });

    test('it returns a negative value for lesser array lengths', () {
      expect(compareArrays([1, 2], [1, 2, 3]), -1);
      expect(compareArrays([1.5], [1.5, 3.14]), -1);
    });

    test('it compares elements in ascending order', () {
      expect(compareArrays([1, 3, 2], [1, 2, 3]), 1);
      expect(compareArrays([3.14, 1.5, 2.71], [1.5, 2.71, 3.14]), 1);
    });

    test('it handles different numeric types', () {
      expect(compareArrays([1, 2.5, 4], [1, 2, 4]), 1);
      expect(compareArrays([3.14, 2], [3, 4.5]), 1);
    });

    test('it handles empty arrays', () {
      expect(compareArrays([], []), 0);
      expect(compareArrays([], [1, 2]), -2);
      expect(compareArrays([1, 2], []), 2);
    });
  });

  group('randomChoice function', () {
    test('it chooses a random element from a list', () {
      var fruits = ['apple', 'banana', 'cherry'];
      var chosenFruit = randomChoice(fruits);
      expect(fruits.contains(chosenFruit), true);
    });

    test('it can use a custom random number generator', () {
      var numbers = [10, 20, 30];
      random.nextIntReturns = 1;
      var chosenNumber = randomChoice(numbers, rng: random);
      expect(chosenNumber, 20);
    });
  });

  group('randomSample function', () {
    test('it samples a random subset of a list', () {
      var originalList = ['apple', 'banana', 'cherry', 'mango', 'kiwi'];
      var sample = randomSample(originalList, 3);
      expect(sample.length, 3);
      expect(Set.of(sample).intersection(Set.of(originalList)), Set.of(sample));
    });

    test('it throws an error for a sample size greater than the list length',
        () {
      expect(() => randomSample([1, 2, 3], 4), throwsArgumentError);
    });
  });
}

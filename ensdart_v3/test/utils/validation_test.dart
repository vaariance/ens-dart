import 'dart:convert';

import 'package:ensdart/src/errors/errors.dart';
import 'package:ensdart/src/utils/validation.dart';
import 'package:test/test.dart';

const labelsMock = {
  '0x68371d7e884c168ae2022c82bd837d51837718a7f7dfb7aa3f753074a35e1d87':
      'something',
  '0x4f5b812789fc606be1b3b16908db13fc7a9adf7ca72641f84d75b47069d3d7f0': 'eth',
};

final labelsMockJSON = jsonEncode(labelsMock);

void main() {
  group('validateName', () {
    test("should throw if the name has an empty label", () {
      expect(() => validateName('foo..bar'),
          throwsA(isA<NameWithEmptyLabelsError>()));

      expect(() => validateName('.foo.bar'),
          throwsA(isA<NameWithEmptyLabelsError>()));

      expect(() => validateName('foo.bar.'),
          throwsA(isA<NameWithEmptyLabelsError>()));
    });
    test('should allow names with [root] as a label', () {
      expect(validateName('[root]'), equals('[root]'));
    });
    test(
        'should throw if the name has [root] as a label and is not the only label',
        () {
      expect(() => validateName('foo.[root].bar'),
          throwsA(isA<RootNameIncludesOtherLabelsError>()));
    });
    test('should normalise the name', () {
      expect(validateName('aAaaA.eth'), equals('aaaaa.eth'));
    });
    test('should return the normalised name', () {
      expect(validateName('swAgCity.eth'), equals('swagcity.eth'));
    });
  });

  group("parseInput", () {
    test('should parse the input', () {
      expect(parseInput('bar.eth'), isA<ParsedInputResult>());
    });
    test('should return a normalised name', () {
      expect(parseInput('bAr.etH').normalized, equals('bar.eth'));
    });
    test('should parse the input if it is invalid', () {
      expect(parseInput('bar..eth'), isA<ParsedInputResult>());
    });
    test('should return type as label if input is a label', () {
      expect(parseInput('bar').type, equals('label'));
    });

    group("should return correct value", () {
      group("isShort", () {
        test('should return true if input is label and less than 3 characters',
            () {
          expect(parseInput('ba').isShort, equals(true));
        });
        test('handles input is emoji', () {
          expect(parseInput('🇺🇸').isShort, isTrue);
          expect(parseInput('🏳️‍🌈').isShort, isFalse);
        });
        test('should return false if input is label and 3 characters', () {
          expect(parseInput('bar').isShort, isFalse);
        });
        test(
            "should return true if input is 2LD .eth name and label is less than 3 characters",
            () {
          expect(parseInput('ba.eth').isShort, isTrue);
        });
        test(
            'should return false if input is 2LD .eth name and label is 3 characters',
            () {
          expect(parseInput('bar.eth').isShort, isFalse);
        });
        test(
            'should return true if input is 2LD other name and label is less than 3 characters',
            () {
          expect(parseInput('ba.com').isShort, isTrue);
        });
        test(
            'should return true if input is 3LD .eth name and label is less than 3 characters',
            () {
          expect(parseInput('ba.bar.eth').isShort, isTrue);
        });
      });
      group("is2LD", () {
        test('should return true if input is 2LD name', () {
          expect(parseInput('bar.eth').is2LD, isTrue);
        });
        test('should return false if input is 3LD name', () {
          expect(parseInput('bar.foo.eth').is2LD, isFalse);
        });
        test('should return false if input is label', () {
          expect(parseInput('bar').is2LD, isFalse);
        });
      });
      group("isETH", () {
        test('should return true if input is .eth name', () {
          expect(parseInput('bar.eth').isETH, isTrue);
        });
        test('should return false if input is other name', () {
          expect(parseInput('bar.com').isETH, isFalse);
        });
      });
    });
  });
}

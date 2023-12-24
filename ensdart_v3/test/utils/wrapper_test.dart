import 'package:ensdart/src/errors/errors.dart';
import 'package:ensdart/src/utils/wrapper.dart';
import 'package:test/test.dart';

void main() {
  group('Test wrapper expiryToBigInt util', () {
    test('returns default value when expiry is null', () {
      expect(expiryToBigInt(null), BigInt.zero);
    });
    test('allows custom default value', () {
      expect(expiryToBigInt(null, defaultValue: BigInt.from(123)),
          BigInt.from(123));
    });
    test('returns bigint expiry when expiry is bigint', () {
      expect(expiryToBigInt(BigInt.from(123)), BigInt.from(123));
    });
    test('returns bigint expiry when expiry is string', () {
      expect(expiryToBigInt('123'), BigInt.from(123));
    });
    test('returns bigint expiry when expiry is integer', () {
      expect(expiryToBigInt(123), BigInt.from(123));
    });
    test('returns bigint expiry when expiry is date', () {
      expect(expiryToBigInt(DateTime.fromMillisecondsSinceEpoch(123000)),
          BigInt.from(123));
    });
    test('throws when expiry is not bigint, string, number or Date', () {
      expect(() => expiryToBigInt(true), throwsA(isA<TypeError>()));
    });
  });
  group('Test wrapper wrappedLabelLengthCheck util', () {
    test('does not throw exception when label is less than or equal 255 bytes',
        () {
      expect(
          () => wrappedLabelLengthCheck(
              Iterable.generate(255, (_) => 'a').join()),
          returnsNormally);
    });
    test('throws exception when label is greater than 255 bytes', () {
      expect(
          () => wrappedLabelLengthCheck(
              Iterable.generate(256, (_) => 'a').join()),
          throwsA(isA<WrappedLabelTooLargeError>()));
    });
  });
}

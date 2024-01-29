import 'package:ensdart/src/errors/errors.dart';
import 'package:ensdart/src/utils/labels.dart';
import 'package:test/test.dart';

void main() {
  group('decodeLabelhash', () {
    test("decodes label hash", () {
      expect(
          decodeLabelhash(
              '[9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658]'),
          equals(
              "0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658"));
    });
    test("throws error when label does not start with [", () {
      expect(
          () => decodeLabelhash(
                '9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658]',
              ),
          throwsA(isA<InvalidEncodedLabelError>()));
    });
    test("throws error when label does not end with ]", () {
      expect(
          () => decodeLabelhash(
                '[9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658',
              ),
          throwsA(isA<InvalidEncodedLabelError>()));
    });
    test("throws error when label length is not 66", () {
      expect(
          () => decodeLabelhash(
                '[9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb65]',
              ),
          throwsA(isA<InvalidEncodedLabelError>()));
    });
  });
  group("encodeLabelhash", () {
    test("encodes labelhash", () {
      expect(
          encodeLabelhash(
            '0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658',
          ),
          equals(
              '[9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658]'));
    });
    test("throws error when labelhash does not start with 0x", () {
      expect(
          () => encodeLabelhash(
                '9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658',
              ),
          throwsA(isA<InvalidLabelhashError>()));
    });
    test("throws error when labelhash length is not 66", () {
      expect(
          () => encodeLabelhash(
                '0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb65',
              ),
          throwsA(isA<InvalidLabelhashError>()));
    });
  });
  group("isEncodedLabelhash", () {
    test("returns true when labelhash is encoded", () {
      expect(
          isEncodedLabelhash(
            '[9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658]',
          ),
          isTrue);
    });
    test("returns false when labelhash is not encoded", () {
      expect(isEncodedLabelhash('sdfsdfsd'), isFalse);
    });
  });
}

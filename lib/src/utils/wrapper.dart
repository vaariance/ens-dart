import 'package:ensdart/src/errors/errors.dart';
import 'package:ensdart/src/utils/helpers.dart';

final BigInt MAX_EXPIRY = BigInt.from(2).pow(64) - BigInt.one;

class CustomTypeError extends TypeError {
  String message;
  CustomTypeError(this.message);
}

BigInt expiryToBigInt(dynamic expiry, {BigInt? defaultValue}) {
  if (expiry == null) return defaultValue ?? BigInt.zero;

  if (expiry is BigInt) {
    return expiry;
  } else if (expiry is String || expiry is int) {
    return BigInt.parse(expiry.toString());
  } else if (expiry is DateTime) {
    return BigInt.from(expiry.millisecondsSinceEpoch ~/ 1000);
  }

  throw CustomTypeError('Expiry must be a BigInt, String, num, or DateTime');
}

void wrappedLabelLengthCheck(String label) {
  final bytes = stringToBytes(label);
  if (bytes.length > 255) {
    throw WrappedLabelTooLargeError(label: label, byteLength: bytes.length);
  }
}

import 'package:ensdart/src/errors/errors.dart';

import 'helpers.dart';

String decodeLabelhash(String hash) {
  if (!(hash.startsWith('[') && hash.endsWith(']'))) {
    throw InvalidEncodedLabelError(
        label: hash,
        details:
            'Expected encoded labelhash to start and end with square brackets');
  }

  if (hash.length != 66) {
    throw InvalidEncodedLabelError(
        label: hash,
        details: 'Expected encoded labelhash to have a length of 66');
  }
  return "0x${hash.substring(1, hash.length - 1)}";
}

String encodeLabelhash(String hash) {
  if (!hash.startsWith('0x')) {
    throw InvalidLabelhashError(
      labelhash: hash,
      details: 'Expected labelhash to start with 0x',
    );
  }

  if (hash.length != 66) {
    throw InvalidLabelhashError(
      labelhash: hash,
      details: 'Expected labelhash to have a length of 66',
    );
  }

  return "[${hash.substring(2)}]";
}

bool isEncodedLabelhash(String hash) {
  return hash.startsWith('[') && hash.endsWith(']') && hash.length == 66;
}

/// TODO: remove this code
String saveLabel(String label) {
  final hash = labelHash(label.toLowerCase());
  return hash;
}

String checkLabel(String hash) {
  if (isEncodedLabelhash(hash)) {
    return decodeLabelhash(hash);
  }
  return hash;
}

bool checkIsDecrypted(dynamic string) {
  return string is List<String> || string is String
      ? !string.contains('[')
      : false;
}

String decryptName(String name) {
  return name.split('.').map((label) => checkLabel(label)).join('.');
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:web3dart/crypto.dart';

Uint8List stringToBytes(String input, {int size = -1}) {
  List<int> bytes = utf8.encode(input);

  if (size > 0) {
    bytes = List<int>.from(bytes, growable: false)
      ..length = size
      ..fillRange(bytes.length, size, 0);
  }

  return Uint8List.fromList(bytes);
}

bool isHex(String input) {
  return RegExp(r'^0x[a-fA-F0-9]+$').hasMatch(input);
}

String? encodedLabelToLabelhash(String label) {
  if (label.length != 66) return null;
  if (!label.startsWith('[')) return null;
  if (!label.endsWith(']')) return null;
  String hash = '0x${label.substring(1, 65)}';
  if (!isHex(hash)) return null;
  return hash;
}

String labelHash(String label) {
  final result = Uint8List(32);
  if (label.isEmpty) {
    return bytesToHex(result);
  }
  return encodedLabelToLabelhash(label) ??
      bytesToHex(keccak256(stringToBytes(label)));
}

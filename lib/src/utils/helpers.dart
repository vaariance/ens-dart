import 'dart:convert';
import 'dart:typed_data';

Uint8List stringToBytes(String input, {int size = -1}) {
  List<int> bytes = utf8.encode(input);

  if (size > 0) {
    bytes = List<int>.from(bytes, growable: false)
      ..length = size
      ..fillRange(bytes.length, size, 0);
  }

  return Uint8List.fromList(bytes);
}

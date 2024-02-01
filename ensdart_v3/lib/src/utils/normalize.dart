import 'dart:typed_data';

import 'package:ens_normalize/ens_normalize.dart';
import 'package:web3dart/crypto.dart';

import 'helpers.dart';
import 'labels.dart';

export 'package:ens_normalize/ens_normalize.dart';

final ENSNormalize ensn = ENSNormalize();

extension ENSNormalizeExtension on ENSNormalize {
  String nameHash(String name) {
    Uint8List result = Uint8List(32);
    if (name.isEmpty) {
      return bytesToHex(result);
    }

    final labels = name.split('.');
    for (var i = labels.length - 1; i >= 0; i -= 1) {
      Uint8List labelSha;
      if (isEncodedLabelhash(labels[i])) {
        labelSha = hexToBytes(decodeLabelhash(labels[i]));
      } else {
        final normalized = normalize(labels[i]);
        labelSha = keccak256(stringToBytes(normalized));
      }
      final bb = BytesBuilder();
      bb.add(result);
      bb.add(labelSha);
      result = keccak256(bb.toBytes());
    }
    return bytesToHex(result, include0x: true);
  }
}

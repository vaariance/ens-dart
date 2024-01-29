import 'dart:typed_data';

import 'package:ens_normalize/ens_normalize.dart';
import 'package:web3dart/crypto.dart';

import 'helpers.dart';
import 'labels.dart';

Future<ENSNormalize> ensn() async {
  return await ENSNormalize.getInstance();
}

Future<String> nameHash(String name) async {
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
      final normalized = (await ensn()).normalize(labels[i]);
      labelSha = keccak256(stringToBytes(normalized));
    }
    final bb = BytesBuilder();
    bb.add(result);
    bb.add(labelSha);
    result = keccak256(bb.toBytes());
  }
  return bytesToHex(result);
}

// class Normalizer extends ENSNormalize {
//   Normalizer(): super._internal();
// }

void main() async {
  final nh = await nameHash('test.eth');
  print(nh);
}

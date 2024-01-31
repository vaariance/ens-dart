import 'package:ensdart/src/utils/normalize.dart';

import 'package:test/test.dart';

void main() {
  group('namehash', () {
    test("returns namehash for name", () async {
      final nh = ENSNormalize();
      expect(
          nh.nameHash('test.eth'),
          equals(
              "0xeb4f647bea6caa36333c816d7b46fdcb05f9466ecacc140ea8c66faf15b3d9f1"));
    }, timeout: Timeout.factor(2));
  });
}

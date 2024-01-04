import 'ens_normalize_base.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

Runes nf(List<int> codePoints, String form) {
  return explodeCodePoint(strFromCodePoints(codePoints).normalize(form: form));
}

Runes nfc(List<int> codePoints) {
  return nf(codePoints, 'NFC');
}

Runes nfd(List<int> codePoints) {
  return nf(codePoints, 'NFD');
}

extension NormalizationExtension on String {
  String normalize({String? form}) {
    switch (form) {
      case 'NFC':
        return unorm.nfc(this);
      case 'NFD':
        return unorm.nfd(this);
      case 'NFKC':
        return unorm.nfkc(this);
      case 'NFKD':
        return unorm.nfkd(this);
      default:
        return unorm.nfc(this);
    }
  }
}

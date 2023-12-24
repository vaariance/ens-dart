enum NameType {
  tld,
  eth2ld,
  ethSubname,
  other2ld,
  otherSubname,
  root,
  ethTld,
}

extension NameTypeFromString on String {
  NameType? fromString() {
    final lowerCaseType = toLowerCase();
    return NameType.values
        .firstWhere((type) => type.toString().toLowerCase() == lowerCaseType);
  }
}

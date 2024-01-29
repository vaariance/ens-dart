import 'package:ens_normalize/ens_normalize.dart';

void main() async {
  ENSNormalize ensn = ENSNormalize();

  final normalized = ensn.normalize('Nick.ETH');
  print(normalized); // nick.eth

  final isNormalizable = ensn.isNormalizable('Nick.ETH');
  print(isNormalizable); // true

  final cured = ensn.cure('Ni‍ck?.ETH');
  print(cured); // nick.eth

  final beautified = ensn.beautify('1⃣2⃣.eth');
  print(beautified); // 1️⃣2️⃣.eth

  final tokens = ensn.tokenize('Nàme‍🧙‍♂.eth');
  print(tokens);
  // [
  // Instance of 'TokenMapped',
  // Instance of 'TokenNFC',
  // Instance of 'TokenValid',
  // Instance of 'TokenDisallowed',
  // Instance of 'TokenEmoji',
  // Instance of 'TokenStop',
  // Instance of 'TokenValid']

  final normalizations = ensn.normalizations('Nàme🧙‍♂️.eth');
  print(normalizations);
  // [
  // NormalizableSequence(code="NormalizableSequenceType", index=0, sequence="N", suggested="n"),
  // NormalizableSequence(code="NormalizableSequenceType", index=1, sequence="🧙‍♂️", suggested="🧙‍♂")
  // ]

  final ensProcessResult = ensn.ensProcess(
    "Nàme🧙‍♂️1⃣.eth",
    doNormalize: true,
    doBeautify: true,
    doTokenize: true,
    doNormalizations: true,
    doCure: true,
  );
  print(ensProcessResult); // Instance of 'ENSProcessResult'
}

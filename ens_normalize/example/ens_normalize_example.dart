import 'package:ens_normalize/ens_normalize.dart';

void main() async {
  ENSNormalize ensn = await ENSNormalize.getInstance();

  ensn.normalize('Nick.ETH');
  // nick.eth

  ensn.isNormalizable('Nick.ETH');
  // true

  ensn.cure('Ni‍ck?.ETH');
  // nick.eth

  ensn.beautify('1⃣2⃣.eth');
  // 1️⃣2️⃣.eth

  ensn.tokenize('Nàme‍🧙‍♂.eth');
  // [
  // Instance of 'TokenMapped',
  // Instance of 'TokenNFC',
  // Instance of 'TokenValid',
  // Instance of 'TokenDisallowed',
  // Instance of 'TokenEmoji',
  // Instance of 'TokenStop',
  // Instance of 'TokenValid']

  ensn.normalizations('Nàme🧙‍♂️.eth');
  // [
  // NormalizableSequence(code="NormalizableSequenceType", index=0, sequence="N", suggested="n"),
  // NormalizableSequence(code="NormalizableSequenceType", index=1, sequence="🧙‍♂️", suggested="🧙‍♂")
  // ]

  ensn.ensProcess(
    "Nàme🧙‍♂️1⃣.eth",
    doNormalize: true,
    doBeautify: true,
    doTokenize: true,
    doNormalizations: true,
    doCure: true,
  );
  // Instance of 'ENSProcessResult'
}

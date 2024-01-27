# ENS Normalize Dart

* Dart implementation of [ENSIP-15 - the ENS Name Normalization Standard](https://docs.ens.domains/ens-improvement-proposals/ensip-15-normalization-standard).
  * This library is being maintained by the team at [Variance](https://variance.space).
* Passes **100%** of the [official validation tests](https://github.com/adraffy/ens-normalize.js/tree/main/validate).
* [Javascript reference implementation](https://github.com/adraffy/ens-normalize.js).
* Adapted from [JavaScript implementation version 1.9.0](https://github.com/adraffy/ens-normalize.js/tree/562d3f6d8cf28caf042d7163e3aa522dfcd925dc) and [Python implementation version 3.0.7](https://github.com/namehash/ens-normalize-python/tree/0f93e5b06c55eeaac9d046a4c9696cb968af4fc5).

## Contraints

Uses Dart Isolates to spawn `NORMALIZATION` in a separate thread. Causing the use of `Future` for asynchronously declaring the base class.

## Getting started

```sh
dart pub add ens_normalize
```

## Usage

```dart
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
```

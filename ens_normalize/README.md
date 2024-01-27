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

    ensn.ensNormalize('Nick.ETH')
    // 'nick.eth'

    ensn.isEnsNormalizable('Nick.ETH')
    // True

    ensn.ensCure('Ni‍ck?.ETH')
    // 'nick.eth'
    // ZWJ and '?' are removed, no error is raised

    ensn.ensBeautify('1⃣2⃣.eth')
    // '1️⃣2️⃣.eth'

    ensn.ensTokenize('Nàme‍🧙‍♂.eth')
    // [TokenMapped(cp=78, cps=[110], type='mapped'),
    //  TokenNFC(input=[97, 768], cps=[224], type='nfc'),
    //  TokenValid(cps=[109, 101], type='valid'),
    //  TokenDisallowed(cp=8205, type='disallowed'),
    //  TokenEmoji(emoji=[129497, 8205, 9794, 65039],
    //             input=[129497, 8205, 9794],
    //             cps=[129497, 8205, 9794],
    //             type='emoji'),
    //  TokenStop(cp=46, type='stop'),
    //  TokenValid(cps=[101, 116, 104], type='valid')]

    ensn.ensNormalizations('Nàme🧙‍♂️.eth')
    // [NormalizableSequence(code="MAPPED", index=0, sequence="N", suggested="n"),
    //  NormalizableSequence(code="FE0F", index=4, sequence="🧙‍♂️", suggested="🧙‍♂")]

    // use only the do_* flags you need
    ensn.ensProcess("Nàme🧙‍♂️1⃣.eth",
    doNormalize=True,
    doBeautify=True,
    doTokenize=True,
    doNormalizations=True,
    doCure=True,
    )
}
```

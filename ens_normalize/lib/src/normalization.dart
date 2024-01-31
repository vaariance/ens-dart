import 'dart:convert';
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ens_normalize_base.dart';

part 'normalization.freezed.dart';
part 'normalization.g.dart';

@freezed
class NORMALIZATION with _$NORMALIZATION {
  const factory NORMALIZATION({
    required String unicodeVersion,
    required Set<int> ignored,
    required Map<int, List<int>> mapped,
    required Set<int> cm,
    required List<List<int>> emoji,
    required Set<int> nfcCheck,
    required Map<int, String> fenced,
    required List<int> escape,
    required List<Group> groups,
    required Set<int> valid,
    @WholeMapConverter() required Map<int, dynamic> wholeMap,
    required int nsmMax,
    required Set<int> nsm,
    required Map<String, String> emojiFe0fLookup,
    @RegExpConverter() required RegExp emojiRegex,
  }) = _NORMALIZATION;

  factory NORMALIZATION.fromJson(Map<String, dynamic> json) =>
      _$NORMALIZATIONFromJson(json);

  factory NORMALIZATION.fromSpecJsonPath(String specJsonPath) {
    var spec = jsonDecode(File(specJsonPath).readAsStringSync());
    var unicodeVersion = spec['unicode'];
    var ignored = Set<int>.from(spec['ignored']);
    var mapped = {
      for (var entry in spec['mapped'])
        entry[0] as int: List<int>.from(entry[1])
    };
    var cm = Set<int>.from(spec['cm']);
    var emoji = [for (var list in spec['emoji']) List<int>.from(list)];
    var nfcCheck = Set<int>.from(spec['nfc_check']);
    var fenced = {
      for (var list in spec['fenced']) list[0] as int: list[1] as String
    };
    var escape = List<int>.from(spec['escape']);
    var groups = readGroups(List<Map<String, dynamic>>.from(spec['groups']));
    var valid = computeValid(groups);
    var wholeMap = groupNamesToIds(
        groups, Map<int, dynamic>.from(dictKeysToInt(spec['whole_map'])));
    var nsmMax = spec['nsm_max'];
    var nsm = Set<int>.from(spec['nsm']);
    cm.remove(CP_FE0F);
    var emojiFe0fLookup = createEmojiFe0fLookup(
        [for (var cps in emoji) String.fromCharCodes(cps)]);
    var emojiRegex = RegExp(createEmojiRegexPattern(
        [for (var cps in emoji) String.fromCharCodes(cps)]));

    return NORMALIZATION(
      unicodeVersion: unicodeVersion,
      ignored: ignored,
      mapped: mapped,
      cm: cm,
      emoji: emoji,
      nfcCheck: nfcCheck,
      fenced: fenced,
      escape: escape,
      groups: groups,
      valid: valid,
      wholeMap: wholeMap,
      nsmMax: nsmMax,
      nsm: nsm,
      emojiFe0fLookup: emojiFe0fLookup,
      emojiRegex: emojiRegex,
    );
  }
}

class RegExpConverter implements JsonConverter<RegExp, String> {
  const RegExpConverter();

  @override
  RegExp fromJson(String json) => RegExp(json);

  @override
  String toJson(RegExp data) => data.pattern;
}

class WholeMapConverter
    implements JsonConverter<Map<int, dynamic>, Map<String, dynamic>> {
  const WholeMapConverter();

  @override
  Map<int, dynamic> fromJson(Map<String, dynamic> json) =>
      Map<int, dynamic>.from(dictKeysToInt(json));

  @override
  Map<String, dynamic> toJson(Map<int, dynamic> data) =>
      Map<String, dynamic>.from(dictKeysToString(data));
}

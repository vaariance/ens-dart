// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'normalization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NORMALIZATIONImpl _$$NORMALIZATIONImplFromJson(Map<String, dynamic> json) =>
    _$NORMALIZATIONImpl(
      unicodeVersion: json['unicodeVersion'] as String,
      ignored: (json['ignored'] as List<dynamic>).map((e) => e as int).toSet(),
      mapped: (json['mapped'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k), (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      cm: (json['cm'] as List<dynamic>).map((e) => e as int).toSet(),
      emoji: (json['emoji'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
          .toList(),
      nfcCheck:
          (json['nfcCheck'] as List<dynamic>).map((e) => e as int).toSet(),
      fenced: (json['fenced'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
      groups: (json['groups'] as List<dynamic>)
          .map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
      valid: (json['valid'] as List<dynamic>).map((e) => e as int).toSet(),
      wholeMap: const WholeMapConverter()
          .fromJson(json['wholeMap'] as Map<String, dynamic>),
      nsmMax: json['nsmMax'] as int,
      nsm: (json['nsm'] as List<dynamic>).map((e) => e as int).toSet(),
      emojiFe0fLookup: Map<String, String>.from(json['emojiFe0fLookup'] as Map),
      emojiRegex:
          const RegExpConverter().fromJson(json['emojiRegex'] as String),
    );

Map<String, dynamic> _$$NORMALIZATIONImplToJson(_$NORMALIZATIONImpl instance) =>
    <String, dynamic>{
      'unicodeVersion': instance.unicodeVersion,
      'ignored': instance.ignored.toList(),
      'mapped': instance.mapped.map((k, e) => MapEntry(k.toString(), e)),
      'cm': instance.cm.toList(),
      'emoji': instance.emoji,
      'nfcCheck': instance.nfcCheck.toList(),
      'fenced': instance.fenced.map((k, e) => MapEntry(k.toString(), e)),
      'groups': instance.groups,
      'valid': instance.valid.toList(),
      'wholeMap': const WholeMapConverter().toJson(instance.wholeMap),
      'nsmMax': instance.nsmMax,
      'nsm': instance.nsm.toList(),
      'emojiFe0fLookup': instance.emojiFe0fLookup,
      'emojiRegex': const RegExpConverter().toJson(instance.emojiRegex),
    };

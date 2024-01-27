// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
// ignore_for_file: constant_identifier_names

// credits #1: https://github.com/namehash/ens-normalize-python
// credits #2: https://github.com/adraffy/ens-normalize.js

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:tuple/tuple.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

const CP_APOSTROPHE = 8217;

const CP_FE0F = 0xFE0F;

const CP_MIDDLE_DOT = 12539;

const CP_SLASH = 8260;

const CP_STOP = 0x2E;

const CP_XI_CAPITAL = 0x39E;

const CP_XI_SMALL = 0x3BE;

const TY_DISALLOWED = 'disallowed';

const TY_EMOJI = 'emoji';

const TY_IGNORED = 'ignored';

const TY_MAPPED = 'mapped';

const TY_NFC = 'nfc';

const TY_STOP = 'stop';

const TY_VALID = 'valid';

late NormalizationData NORMALIZATION;

final simpleNameRegex = RegExp(r'^[a-z0-9]+(?:\.[a-z0-9]+)*$');

final specJsonZippedPath = "${Directory.current.path}/spec.json.gz";

List<Token> collapseValidTokens(List<Token> tokens) {
  var out = <Token>[];
  var i = 0;
  while (i < tokens.length) {
    if (tokens[i].type == TY_VALID) {
      var j = i + 1;
      while (j < tokens.length && tokens[j].type == TY_VALID) {
        j += 1;
      }
      out.add(
        TokenValid(
          cps: [for (var k = i; k < j; k++) ...tokens[k].cps],
        ),
      );
      i = j;
    } else {
      out.add(tokens[i]);
      i += 1;
    }
  }
  return out;
}

Set<int> computeValid(List<Map<String, dynamic>> groups) {
  var valid = <int>{};
  for (var g in groups) {
    valid.addAll(g['V']);
  }
  valid.addAll(nfPartial(valid.toList(), 'NFD').runes);
  return valid;
}

bool cpsRequiresCheck(List<int> cps) {
  return cps.any((cp) => NORMALIZATION.nfcCheck.contains(cp));
}

Map<String, String> createEmojiFe0fLookup(List<String> emojis) {
  var lookup = HashMap<String, String>();
  for (var emoji in emojis) {
    lookup[filterFe0f(emoji)] = emoji;
  }
  return lookup;
}

String createEmojiRegexPattern(List<String> emojis) {
  var fe0f = RegExp.escape('\uFE0F');

  String makeEmoji(String emoji) {
    return RegExp.escape(emoji).replaceAll(fe0f, '$fe0f?');
  }

  int order(String emoji) {
    return filterFe0f(emoji).length;
  }

  emojis.sort((a, b) => order(b).compareTo(order(a)));

  return emojis.map(makeEmoji).join('|');
}

Tuple2<List<Map<String, dynamic>>?, CurableSequence?> determineGroup(
    Iterable<int> unique, List<int> cps) {
  var groups = NORMALIZATION.groups;
  for (var cp in unique) {
    var gs = groups.where((g) => g['V'].contains(cp)).toList();
    if (gs.isEmpty) {
      if (groups == NORMALIZATION.groups) {
        return Tuple2(
            null,
            CurableSequence(
              type: CurableSequenceType.disallowed,
              index: cps.indexOf(cp),
              sequence: String.fromCharCode(cp),
              suggested: '',
            ));
      } else {
        return Tuple2(
            null,
            CurableSequence(
              type: CurableSequenceType.confMixed,
              index: cps.indexOf(cp),
              sequence: String.fromCharCode(cp),
              suggested: '',
              meta: metaForConfMixed(groups[0], cp),
            ));
      }
    }
    groups = gs;
    if (groups.length == 1) {
      break;
    }
  }
  return Tuple2(groups, null);
}

dynamic dictKeysToInt(dynamic d) {
  if (d is Map) {
    return {for (var key in d.keys) tryStrToInt(key): dictKeysToInt(d[key])};
  }
  return d;
}

dynamic dictKeysToString(dynamic d) {
  if (d is Map) {
    return {for (var key in d.keys) tryIntToStr(key): dictKeysToString(d[key])};
  }
  return d;
}

String filterFe0f(String text) {
  return text.replaceAll('\uFE0F', '');
}

int? findGroupId(List<Map<dynamic, dynamic>> groups, String name) {
  for (var i = 0; i < groups.length; i++) {
    if (groups[i]['name'] == name) {
      return i;
    }
  }
  return null;
}

List<NormalizableSequence> findNormalizations(List<Token> tokens) {
  var warnings = <NormalizableSequence>[];
  NormalizableSequenceType? warning;
  var start = 0;
  String? disallowed;
  String? suggestion;
  for (var tok in tokens) {
    if (tok.type == TY_MAPPED) {
      warning = NormalizableSequenceType.mapped;
      disallowed = String.fromCharCode(tok.cp!);
      suggestion = strFromCodePoints(tok.cps);
    } else if (tok.type == TY_IGNORED) {
      warning = NormalizableSequenceType.ignored;
      disallowed = String.fromCharCode(tok.cp!);
      suggestion = '';
    } else if (tok.type == TY_EMOJI) {
      if ((tok as TokenEmoji).input != tok.cps) {
        warning = NormalizableSequenceType.fe0f;
        disallowed = strFromCodePoints(tok.input);
        suggestion = strFromCodePoints(tok.cps);
      }
    } else if (tok.type == TY_NFC) {
      warning = NormalizableSequenceType.nfc;
      disallowed = strFromCodePoints((tok as TokenNFC).input);
      suggestion = strFromCodePoints(tok.cps);
    } else if (tok.type == TY_VALID) {
      continue;
    } else {
      // TY_STOP
      continue;
    }
    if (warning != null) {
      warnings.add(NormalizableSequence(
          type: warning,
          index: start,
          sequence: disallowed!,
          suggested: suggestion!));
      warning = null;
    }
    start += 1;
  }
  return warnings;
}

Map<int, dynamic> groupNamesToIds(
    List<Map<String, dynamic>> groups, Map<int, dynamic> wholeMap) {
  for (var v in wholeMap.values) {
    if (v is Map) {
      for (var k in v['M'].keys) {
        for (var i = 0; i < v['M'][k].length; i++) {
          var id = findGroupId(groups, v['M'][k][i]);
          assert(id != null);
          v['M'][k][i] = id;
        }
      }
    }
  }
  return wholeMap;
}

String hexCodePoint(int codePoint) {
  validCodePoint(codePoint);
  return codePoint.toRadixString(16).toUpperCase().padLeft(2, '0');
}

Future<void> loadNormalizationDataJson(String zipPath) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_isolateEntry, [receivePort.sendPort, zipPath]);
  NORMALIZATION = await receivePort.first;
}

CurableSequence makeFencedError(List<int> cps, int start, int end) {
  var suggested = '';
  CurableSequenceType type;
  if (start == 0) {
    type = CurableSequenceType.fencedLeading;
  } else if (end == cps.length) {
    type = CurableSequenceType.fencedTrailing;
  } else {
    type = CurableSequenceType.fencedMulti;
    suggested = String.fromCharCode(cps[start]);
  }
  return CurableSequence(
    type: type,
    index: start,
    sequence:
        cps.sublist(start, end).map((cp) => String.fromCharCode(cp)).join(),
    suggested: suggested,
  );
}

Map<String, String> metaForConfMixed(Map<String, dynamic> g, int cp) {
  List? s1 = NORMALIZATION.groups
      .where((group) => group['V'].contains(cp))
      .map((group) => group['name'])
      .toList();
  s1 = s1.isNotEmpty ? s1[0] : null;
  var s2 = g['name'];
  if (s1 != null) {
    return {
      'scripts': '$s1/$s2',
      'script1': ' from the $s1 script',
      'script2': ' from the $s2 script',
    };
  } else {
    return {
      'scripts': '$s2 plus other scripts',
      'script1': '',
      'script2': ' from the $s2 script',
    };
  }
}

Runes nf(List<int> codePoints, String form) {
  return strToCodePoints(strFromCodePoints(codePoints).normalize(form: form));
}

Runes nfc(List<int> codePoints) {
  return nf(codePoints, 'NFC');
}

Runes nfd(List<int> codePoints) {
  return nf(codePoints, 'NFD');
}

String nfPartial(List<int> codePoints, String form) {
  return String.fromCharCodes(codePoints).normalize(form: form);
}

List<Token> normalizeTokens(List<Token> tokens) {
  var i = 0;
  var start = -1;
  while (i < tokens.length) {
    var token = tokens[i];
    if (token.type == TY_VALID || token.type == TY_MAPPED) {
      if (cpsRequiresCheck(token.cps)) {
        var end = i + 1;
        for (var pos = end; pos < tokens.length; pos++) {
          if (tokens[pos].type == TY_VALID || tokens[pos].type == TY_MAPPED) {
            if (!cpsRequiresCheck(tokens[pos].cps)) {
              break;
            }
            end = pos + 1;
          } else if (tokens[pos].type != TY_IGNORED) {
            break;
          }
        }
        if (start < 0) {
          start = i;
        }
        var slice = tokens.sublist(start, end);
        var cps = [
          for (var tok in slice)
            if (tok.type == TY_VALID || tok.type == TY_MAPPED) ...tok.cps
        ];
        var str0 =
            strFromCodePoints(cps); // Todo: use String.fromCharCodes(cps)
        var str = str0.normalize();
        if (str0 == str) {
          i = end - 1;
        } else {
          tokens.replaceRange(start, end,
              [TokenNFC(input: cps, cps: strToCodePoints(str).toList())]);
          i = start;
        }
        start = -1;
      } else {
        start = i;
      }
    } else if (token.type != TY_IGNORED) {
      start = -1;
    }
    i += 1;
  }
  return collapseValidTokens(tokens);
}

void offsetErrStart(CurableSequence? err, List<Token> tokens) {
  if (err == null) {
    return;
  }
  int i = 0;
  int offset = 0;
  for (var tok in tokens) {
    if (i >= err.index) {
      break;
    }
    if (tok.type == TY_IGNORED || tok.type == TY_DISALLOWED) {
      offset += 1;
    } else if (tok.type == TY_EMOJI) {
      offset += (tok as TokenEmoji).input.length - 1;
      i += 1;
    } else if (tok.type == TY_NFC) {
      offset += (tok as TokenNFC).input.length - tok.cps.length;
      i += tok.cps.length;
    } else if (tok.type == TY_MAPPED) {
      offset += 1 - tok.cps.length;
      i += tok.cps.length;
    } else if (tok.type == TY_STOP) {
      i += 1;
    } else {
      i += tok.cps.length;
    }
  }
  err.index += offset;
}

DisallowedSequence? postCheck(
    String name, List<bool> labelIsGreek, String input) {
  if (input.isEmpty) {
    return null;
  }
  DisallowedSequence? e = postCheckEmpty(name, input);
  if (e != null) {
    return e;
  }
  var labelOffset = 0;
  for (var label in name.split('.')) {
    var isGreek = [false];
    var cps = strToCodePoints(label).toList();
    e = postCheckUnderscore(label) ??
        postCheckHyphen(label) ??
        postCheckCmLeadingEmoji(cps) ??
        postCheckFenced(cps) ??
        postCheckGroupWhole(cps, isGreek);
    labelIsGreek.add(isGreek[0]);
    if (e != null) {
      if (e is CurableSequence) {
        e.index = labelOffset + (e.index);
      }
      return e;
    }
    labelOffset += label.length + 1;
  }
  return null;
}

CurableSequence? postCheckCmLeadingEmoji(List<int> cps) {
  for (var i = 0; i < cps.length; i++) {
    if (NORMALIZATION.cm.contains(cps[i])) {
      if (i == 0) {
        return CurableSequence(
          type: CurableSequenceType.cmStart,
          index: i,
          sequence: String.fromCharCode(cps[i]),
          suggested: '',
        );
      } else {
        var prev = cps[i - 1];
        if (prev == CP_FE0F) {
          return CurableSequence(
            type: CurableSequenceType.cmEmoji,
            index: i,
            sequence: String.fromCharCode(cps[i]),
            suggested: '',
          );
        }
      }
    }
  }
  return null;
}

CurableSequence? postCheckEmpty(String name, String input) {
  if (name.isEmpty) {
    return CurableSequence(
      type: CurableSequenceType.emptyLabel,
      index: 0,
      sequence: input,
      suggested: '',
    );
  }
  if (name.startsWith('.')) {
    return CurableSequence(
      type: CurableSequenceType.emptyLabel,
      index: 0,
      sequence: '.',
      suggested: '',
    );
  }
  if (name.endsWith('.')) {
    return CurableSequence(
      type: CurableSequenceType.emptyLabel,
      index: name.length - 1,
      sequence: '.',
      suggested: '',
    );
  }
  var i = name.indexOf('..');
  if (i >= 0) {
    return CurableSequence(
      type: CurableSequenceType.emptyLabel,
      index: i,
      sequence: '..',
      suggested: '.',
    );
  }
  return null;
}

CurableSequence? postCheckFenced(List<int> cps) {
  var cp = cps[0];
  var prev = NORMALIZATION.fenced[cp];
  if (prev != null) {
    return makeFencedError(cps, 0, 1);
  }

  var n = cps.length;
  var last = -1;
  for (var i = 1; i < n; i++) {
    cp = cps[i];
    var match = NORMALIZATION.fenced[cp];
    if (match != null) {
      if (last == i) {
        return makeFencedError(cps, i - 1, i + 1);
      }
      last = i + 1;
    }
  }

  if (last == n) {
    return makeFencedError(cps, n - 1, n);
  }
  return null;
}

DisallowedSequence? postCheckGroup(
    Map<String, dynamic> g, List<int> cps, List<int> input) {
  var v = g['V'];
  var m = g['M'];
  for (var cp in cps) {
    if (!v.contains(cp)) {
      return CurableSequence(
        type: CurableSequenceType.confMixed,
        index: input.indexOf(cp),
        sequence: String.fromCharCode(cp),
        suggested: '',
        meta: metaForConfMixed(g, cp),
      );
    }
  }
  if (m) {
    var decomposed = nfc(cps).toList();
    var i = 1;
    var e = decomposed.length;
    while (i < e) {
      if (NORMALIZATION.nsm.contains(decomposed[i])) {
        var j = i + 1;
        while (j < e && NORMALIZATION.nsm.contains(decomposed[j])) {
          if (j - i + 1 > NORMALIZATION.nsmMax) {
            return DisallowedSequence(DisallowedSequenceType.nsmTooMany);
          }
          for (var k = i; k < j; k++) {
            if (decomposed[k] == decomposed[j]) {
              return DisallowedSequence(DisallowedSequenceType.nsmRepeated);
            }
          }
          j += 1;
        }
        i = j;
      }
      i += 1;
    }
  }
  return null;
}

DisallowedSequence? postCheckGroupWhole(List<int> cps, List<bool> isGreek) {
  var cpsNoFe0f = cps.where((cp) => cp != CP_FE0F).toList();
  var unique = cpsNoFe0f.toSet();
  List<Map<String, dynamic>>? g;
  CurableSequence? e;
  Map<String, dynamic>? h;
  var result = determineGroup(unique, cps);
  g = result.item1;
  e = result.item2;
  if (e != null) {
    return e;
  }
  h = g![0];
  isGreek[0] = h['name'] == 'Greek';
  return postCheckGroup(h, cpsNoFe0f, cps) ?? postCheckWhole(h, unique);
}

CurableSequence? postCheckHyphen(String label) {
  if (label.length >= 4 &&
      label.runes.every((cp) => cp < 0x80) &&
      label[2] == '-' &&
      label[3] == '-') {
    return CurableSequence(
      type: CurableSequenceType.hyphen,
      index: 2,
      sequence: '--',
      suggested: '',
    );
  }
  return null;
}

CurableSequence? postCheckUnderscore(String label) {
  var inMiddle = false;
  for (var i = 0; i < label.length; i++) {
    if (label[i] != '_') {
      inMiddle = true;
    } else if (inMiddle) {
      var cnt = 1;
      while (i + cnt < label.length && label[i + cnt] == '_') {
        cnt += 1;
      }
      return CurableSequence(
        type: CurableSequenceType.underscore,
        index: i,
        sequence: '_' * cnt,
        suggested: '',
      );
    }
  }
  return null;
}

DisallowedSequence? postCheckWhole(
    Map<String, dynamic> group, Iterable<int> cps) {
  List<int>? maker;
  var shared = <int>[];
  for (var cp in cps) {
    var whole = NORMALIZATION.wholeMap[cp];
    if (whole == 1) {
      return null;
    }
    if (whole != null) {
      var set_ = whole['M'][cp];
      if (maker != null) {
        maker = maker.where((g) => set_.contains(g)).toList();
      } else {
        maker = set_.toList();
      }
      if (maker != null && maker.isEmpty) {
        return null;
      }
    } else {
      shared.add(cp);
    }
  }
  if (maker != null) {
    for (var gInd in maker) {
      var g = NORMALIZATION.groups[gInd];
      if (shared.every((cp) => g['V'].contains(cp))) {
        return DisallowedSequence(
          DisallowedSequenceType.confWhole,
          meta: {
            'script1': group['name'],
            'script2': g['name'],
          },
        );
      }
    }
  }
  return null;
}

String quoteCodePoint(int codePoint) {
  String hexCode = hexCodePoint(codePoint);
  return "{$hexCode}";
}

List<Map<String, dynamic>> readGroups(List<Map<String, dynamic>> groups) {
  return groups.map((g) {
    return {
      'name': g['name'],
      'P': Set<int>.from(g['primary']),
      'Q': Set<int>.from(g['secondary']),
      'V': Set<int>.from(g['primary'] + g['secondary']),
      'M': !g.containsKey('cm'),
    };
  }).toList();
}

String strFromCodePoints(List<int> codePoints) {
  const chunk = 4096;
  int len = codePoints.length;

  if (len < chunk) {
    return String.fromCharCodes(codePoints);
  }

  StringBuffer result = StringBuffer();

  for (int i = 0; i < len; i += chunk) {
    result.write(String.fromCharCodes(codePoints.skip(i).take(chunk)));
  }

  return result.toString();
}

Runes strToCodePoints(String s) {
  return s.runes;
}

String tokens2beautified(List<Token> tokens, List<bool> labelIsGreek) {
  var s = <String>[];
  var labelIndex = 0;
  var labelStart = 0;
  for (var i = 0; i <= tokens.length; i++) {
    if (i < tokens.length && tokens[i].type != TY_STOP) {
      continue;
    }
    var labelEnd = i;

    for (var j = labelStart; j < labelEnd; j++) {
      var tok = tokens[j];
      if (tok.type == TY_IGNORED || tok.type == TY_DISALLOWED) {
        continue;
      } else if (tok.type == TY_EMOJI) {
        s.add(strFromCodePoints((tok as TokenEmoji).emoji));
      } else if (tok.type == TY_STOP) {
        s.add(String.fromCharCode(tok.cp!));
      } else {
        if (!labelIsGreek[labelIndex]) {
          s.add(strFromCodePoints(tok.cps
              .map((cp) => cp == CP_XI_SMALL ? CP_XI_CAPITAL : cp)
              .toList()));
        } else {
          s.add(strFromCodePoints(tok.cps));
        }
      }
    }

    labelStart = i;
    labelIndex += 1;
  }

  return s.join();
}

String tokens2str(List<Token> tokens, String Function(Token)? emojiFn) {
  var t = <String>[];
  for (var tok in tokens) {
    if (tok.type == TY_IGNORED || tok.type == TY_DISALLOWED) {
      continue;
    } else if (tok.type == TY_EMOJI) {
      t.add(emojiFn != null ? emojiFn(tok) : "");
    } else if (tok.type == TY_STOP) {
      t.add(String.fromCharCode(tok.cp!));
    } else {
      t.add(strFromCodePoints(tok.cps));
    }
  }
  return t.join();
}

dynamic tryIntToStr(x) {
  try {
    return x.toString();
  } catch (e) {
    return x;
  }
}

dynamic tryStrToInt(x) {
  try {
    return int.parse(x);
  } catch (e) {
    return x;
  }
}

void validCodePoint(int codePoint) {
  assert(codePoint >= 0 && codePoint <= 1114111);
}

NormalizationData _decodeAndParseZippedJson(String path) {
  List<int> zipped = File(path).absolute.readAsBytesSync();
  List<int> decompress = gzip.decode(zipped);
  String decoded = utf8.decode(decompress);
  return NormalizationData.fromJson(decoded);
}

void _isolateEntry(dynamic message) {
  final SendPort sendPort = message[0];
  final String path = message[1];
  final result = _decodeAndParseZippedJson(path);
  sendPort.send(result);
}

class CurableSequence extends DisallowedSequence {
  int index;
  final String sequence;
  final String suggested;

  CurableSequence(
      {required CurableSequenceTypeBase type,
      required this.index,
      required this.sequence,
      required this.suggested,
      Map<String, String> meta = const {}})
      : super(type, meta: meta);

  String get sequenceInfo {
    return (type as CurableSequenceTypeBase)
        .sequenceInfo
        .replaceAll('{sequence}', sequence)
        .replaceAll('{suggested}', suggested);
  }

  @override
  String toString() {
    return '$runtimeType(code="$code", index=$index, sequence="$sequence", suggested="$suggested")';
  }
}

class CurableSequenceType extends CurableSequenceTypeBase {
  static final underscore = CurableSequenceType(
      'Contains an underscore in a disallowed position',
      'An underscore is only allowed at the start of a label');
  static final hyphen = CurableSequenceType(
      "Contains the sequence '--' in a disallowed position",
      'Hyphens are disallowed at the 2nd and 3rd positions of a label');
  static final emptyLabel = CurableSequenceType(
      'Contains a disallowed empty label',
      'Empty labels are not allowed, e.g. abc..eth');
  static final cmStart = CurableSequenceType(
      'Contains a combining mark in a disallowed position at the start of the label',
      'A combining mark is disallowed at the start of a label');
  static final cmEmoji = CurableSequenceType(
      'Contains a combining mark in a disallowed position after an emoji',
      'A combining mark is disallowed after an emoji');
  static final disallowed = CurableSequenceType(
      'Contains a disallowed character', 'This character is disallowed');
  static final invisible = CurableSequenceType(
      'Contains a disallowed invisible character',
      'This invisible character is disallowed');
  static final fencedLeading = CurableSequenceType(
      'Contains a disallowed character at the start of a label',
      'This character is disallowed at the start of a label');
  static final fencedMulti = CurableSequenceType(
      'Contains a disallowed consecutive sequence of characters',
      'Characters in this sequence cannot be placed next to each other');
  static final fencedTrailing = CurableSequenceType(
      'Contains a disallowed character at the end of a label',
      'This character is disallowed at the end of a label');
  static final confMixed = CurableSequenceType(
      'Contains visually confusing characters from multiple scripts ({scripts})',
      'This character{script1} is disallowed because it is visually confusing with another character{script2}');

  CurableSequenceType(super.generalInfo, super.sequenceInfo);
}

abstract class CurableSequenceTypeBase extends DisallowedSequenceTypeBase {
  final String sequenceInfo;

  CurableSequenceTypeBase(super.generalInfo, this.sequenceInfo);
}

class DisallowedSequence implements Exception {
  final DisallowedSequenceTypeBase type;
  final Map<String, String> meta;

  DisallowedSequence(this.type, {this.meta = const {}});

  String get code {
    return type.code;
  }

  String get generalInfo {
    return type.generalInfo;
  }

  @override
  String toString() {
    return '$runtimeType(code="$code")';
  }
}

class DisallowedSequenceType extends DisallowedSequenceTypeBase {
  static final nsmRepeated =
      DisallowedSequenceType('Contains a repeated non-spacing mark');
  static final nsmTooMany =
      DisallowedSequenceType('Contains too many consecutive non-spacing marks');
  static final confWhole = DisallowedSequenceType(
      'Contains visually confusing characters from {script1} and {script2} scripts');

  DisallowedSequenceType(super.generalInfo);
}

abstract class DisallowedSequenceTypeBase {
  static int _valueCount = 0;

  final int value;
  final String generalInfo;

  DisallowedSequenceTypeBase(this.generalInfo) : value = _valueCount++;

  String get code => runtimeType.toString();
}

class ENSNormalize {
  static bool _initialized = false;

  ENSNormalize._internal();

  static Future<ENSNormalize> getInstance() async {
    _initialized == false ? await _initialize() : null;
    return ENSNormalize._internal();
  }

  void requireInitialized() {
    if (!_initialized) {
      throw Exception('NORMALIZATION not initialized');
    }
  }

  String ensBeautify(String text) {
    var res = ensProcess(text, doBeautify: true);
    if (res.error != null) {
      throw res.error!;
    }
    return res.beautified!;
  }

  String ensCure(String text) {
    return _ensCure(text).item1;
  }

  List<NormalizableSequence> ensNormalizations(String input) {
    var res = ensProcess(input, doNormalizations: true);
    if (res.error != null) {
      throw res.error!;
    }
    return res.normalizations!;
  }

  String ensNormalize(String text) {
    var res = ensProcess(text, doNormalize: true);
    if (res.error != null) {
      throw res.error!;
    }
    return res.normalized!;
  }

  ENSProcessResult ensProcess(
    String input, {
    bool doNormalize = false,
    bool doBeautify = false,
    bool doTokenize = false,
    bool doNormalizations = false,
    bool doCure = false,
  }) {
    requireInitialized();
    if (simpleNameRegex.hasMatch(input)) {
      List<Token>? tokens;
      if (doTokenize) {
        tokens = [];
        var currentCps = <int>[];
        for (var c in input.runes) {
          if (c == CP_STOP) {
            tokens.add(TokenValid(cps: currentCps));
            tokens.add(TokenStop());
            currentCps = [];
          } else {
            currentCps.add(c);
          }
        }
        tokens.add(TokenValid(cps: currentCps));
      }
      return ENSProcessResult(
        normalized: doNormalize ? input : null,
        beautified: doBeautify ? input : null,
        tokens: tokens,
        cured: doCure ? input : null,
        cures: doCure ? [] : null,
        error: null,
        normalizations: doNormalizations ? [] : null,
      );
    }
    var tokens = <Token>[];
    DisallowedSequence? error;
    var inputCur = 0;
    var emojiIter = NORMALIZATION.emojiRegex.allMatches(input).iterator;
    var nextEmojiMatch = emojiIter.moveNext() ? emojiIter.current : null;

    while (inputCur < input.length) {
      if (nextEmojiMatch != null && nextEmojiMatch.start == inputCur) {
        var emoji = nextEmojiMatch.group(0)!;
        inputCur = nextEmojiMatch.end;
        nextEmojiMatch = emojiIter.moveNext() ? emojiIter.current : null;
        var emojiNoFe0f = filterFe0f(emoji);
        var emojiFe0f = NORMALIZATION.emojiFe0fLookup[emojiNoFe0f]!;
        tokens.add(
          TokenEmoji(
            emoji: strToCodePoints(emojiFe0f).toList(),
            input: strToCodePoints(emoji).toList(),
            cps: strToCodePoints(emojiNoFe0f).toList(),
          ),
        );
        continue;
      }
      var c = input[inputCur];
      var cp = c.codeUnitAt(0);
      inputCur += 1;
      if (cp == CP_STOP) {
        tokens.add(TokenStop());
        continue;
      }
      if (NORMALIZATION.valid.contains(cp)) {
        tokens.add(
          TokenValid(
            cps: [cp],
          ),
        );
        continue;
      }
      if (NORMALIZATION.ignored.contains(cp)) {
        tokens.add(
          TokenIgnored(
            cp: cp,
          ),
        );
        continue;
      }
      var mapping = NORMALIZATION.mapped[cp];
      if (mapping != null) {
        tokens.add(
          TokenMapped(
            cp: cp,
            cps: mapping,
          ),
        );
        continue;
      }
      error ??= CurableSequence(
        type: c == '\u200d' || c == '\u200c'
            ? CurableSequenceType.invisible
            : CurableSequenceType.disallowed,
        index: inputCur - 1,
        sequence: c,
        suggested: '',
      );

      tokens.add(
        TokenDisallowed(
          cp: cp,
        ),
      );
    }

    tokens = normalizeTokens(tokens);
    var normalizations = doNormalizations ? findNormalizations(tokens) : null;
    List<bool> labelIsGreek = [];
    if (error == null) {
      var emojisAsFe0f = tokens2str(tokens, (tok) => '\uFE0F');
      error = postCheck(emojisAsFe0f, labelIsGreek, input);
      if (error is CurableSequence) {
        offsetErrStart(error, tokens);
      }
    }
    String? normalized;
    String? beautified;
    if (error == null) {
      normalized = doNormalize ? tokens2str(tokens, null) : null;
      beautified = doBeautify ? tokens2beautified(tokens, labelIsGreek) : null;
    }
    tokens = doTokenize ? tokens : [];

    String? cured;
    List<CurableSequence>? cures;
    if (doCure) {
      try {
        var result = _ensCure(input);
        cured = result.item1;
        cures = result.item2;
      } on DisallowedSequence {
        // pass
      }
    }

    return ENSProcessResult(
      normalized: normalized,
      beautified: beautified,
      tokens: tokens,
      cured: cured,
      cures: cures,
      error: error,
      normalizations: normalizations,
    );
  }

  List<Token> ensTokenize(String input) {
    return ensProcess(input, doTokenize: true).tokens!;
  }

  static Future<void> _initialize() async {
    await loadNormalizationDataJson(specJsonZippedPath);
    _initialized = true;
  }

  bool isEnsNormalizable(String name) {
    return ensProcess(name).error == null;
  }

  bool isEnsNormalized(String name) {
    return ensProcess(name, doNormalize: true).normalized == name;
  }

  Tuple2<String, List<CurableSequence>> _ensCure(String text) {
    requireInitialized();
    var cures = <CurableSequence>[];
    for (var i = 0; i < 2 * text.length + 1; i++) {
      try {
        return Tuple2(ensNormalize(text), cures);
      } on CurableSequence catch (e) {
        text = text.substring(0, e.index) +
            e.suggested +
            text.substring(e.index + e.sequence.length);
        cures.add(e);
      }
    }
    throw DisallowedSequence(DisallowedSequenceType(
        'ens_cure() exceeded max iterations. Please report this as a bug along with the input string.'));
  }
}

class ENSProcessResult {
  final String? normalized;
  final String? beautified;
  final List<Token>? tokens;
  final String? cured;
  final List<CurableSequence>? cures;
  final DisallowedSequence? error;
  final List<NormalizableSequence>? normalizations;

  ENSProcessResult(
      {this.normalized,
      this.beautified,
      this.tokens,
      this.cured,
      this.cures,
      this.error,
      this.normalizations});
}

class NormalizableSequence extends CurableSequence {
  NormalizableSequence(
      {required NormalizableSequenceType type,
      required int index,
      required String sequence,
      required String suggested,
      Map<String, String> meta = const {}})
      : super(
            type: type,
            index: index,
            sequence: sequence,
            suggested: suggested,
            meta: meta);
}

class NormalizableSequenceType extends CurableSequenceTypeBase {
  static final ignored = NormalizableSequenceType(
      'Contains disallowed "ignored" characters that have been removed',
      'This character is ignored during normalization and has been automatically removed');
  static final mapped = NormalizableSequenceType(
      'Contains a disallowed character that has been replaced by a normalized sequence',
      'This character is disallowed and has been automatically replaced by a normalized sequence');
  static final fe0f = NormalizableSequenceType(
      'Contains a disallowed variant of an emoji which has been replaced by an equivalent normalized emoji',
      'This emoji has been automatically fixed to remove an invisible character');
  static final nfc = NormalizableSequenceType(
      'Contains a disallowed sequence that is not "NFC normalized" which has been replaced by an equivalent normalized sequence',
      'This sequence has been automatically normalized into NFC canonical form');

  NormalizableSequenceType(super.generalInfo, super.sequenceInfo);
}

class NormalizationData {
  late String unicodeVersion;
  late Set<int> ignored;
  late Map<int, List<int>> mapped;
  late Set<int> cm;
  late List<List<int>> emoji;
  late Set<int> nfcCheck;
  late Map<int, String> fenced;
  late List<Map<String, dynamic>> groups;
  late Set<int> valid;
  late Map<int, dynamic> wholeMap;
  late int nsmMax;
  late Set<int> nsm;
  late Map<String, String> emojiFe0fLookup;
  late RegExp emojiRegex;

  NormalizationData({
    required this.unicodeVersion,
    required this.ignored,
    required this.mapped,
    required this.cm,
    required this.emoji,
    required this.nfcCheck,
    required this.fenced,
    required this.groups,
    required this.valid,
    required this.wholeMap,
    required this.nsmMax,
    required this.nsm,
    required this.emojiFe0fLookup,
    required this.emojiRegex,
  });

  factory NormalizationData.fromJson(String source) {
    return NormalizationData.fromMap(json.decode(source));
  }

  factory NormalizationData.fromMap(Map<String, dynamic> json) {
    return NormalizationData(
      unicodeVersion: json['unicodeVersion'],
      ignored: (json['ignored'] as List).cast<int>().toSet(),
      mapped: (json['mapped'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), List<int>.from(value))),
      cm: (json['cm'] as List).cast<int>().toSet(),
      emoji: (json['emoji'] as List).map((e) => List<int>.from(e)).toList(),
      nfcCheck: (json['nfcCheck'] as List).cast<int>().toSet(),
      fenced: (json['fenced'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), value.toString())),
      groups: (json['groups'] as List).map((group) {
        return {
          'name': group['name'] as String,
          'P': (group['P'] as List).toSet(),
          'Q': (group['Q'] as List).toSet(),
          'V': (group['V'] as List).toSet(),
          'M': group['M'] as bool,
        };
      }).toList(),
      valid: (json['valid'] as List<dynamic>).cast<int>().toSet(),
      wholeMap: Map<int, dynamic>.from(dictKeysToInt(json['wholeMap'])),
      nsmMax: json['nsmMax'],
      nsm: (json['nsm'] as List<dynamic>).cast<int>().toSet(),
      emojiFe0fLookup:
          (json['emojiFe0fLookup'] as Map<String, dynamic>).map((key, value) {
        return MapEntry(key, value.toString());
      }),
      emojiRegex: RegExp(json['emojiRegex']),
    );
  }

  factory NormalizationData.fromSpecJsonPath(String specJsonPath) {
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

    return NormalizationData(
      unicodeVersion: unicodeVersion,
      ignored: ignored,
      mapped: mapped,
      cm: cm,
      emoji: emoji,
      nfcCheck: nfcCheck,
      fenced: fenced,
      groups: groups,
      valid: valid,
      wholeMap: wholeMap,
      nsmMax: nsmMax,
      nsm: nsm,
      emojiFe0fLookup: emojiFe0fLookup,
      emojiRegex: emojiRegex,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'unicodeVersion': unicodeVersion,
      'ignored': ignored.toList(),
      'mapped':
          mapped.map((key, value) => MapEntry(key.toString(), value.toList())),
      'cm': cm.toList(),
      'emoji': emoji.map((e) => e.toList()).toList(),
      'nfcCheck': nfcCheck.toList(),
      'fenced': fenced.map((key, value) => MapEntry(key.toString(), value)),
      'groups': groups.map((group) {
        return {
          'name': group['name'],
          'P': group['P'].toList(),
          'Q': group['Q'].toList(),
          'V': group['V'].toList(),
          'M': group['M'],
        };
      }).toList(),
      'valid': valid.toList(),
      'wholeMap': dictKeysToString(wholeMap),
      'nsmMax': nsmMax,
      'nsm': nsm.toList(),
      'emojiFe0fLookup': emojiFe0fLookup,
      'emojiRegex': emojiRegex.pattern,
    };
  }
}

class Token {
  final int? cp;
  final List<int> cps;
  final String type;

  const Token({this.cp, this.cps = const [], required this.type});
}

class TokenDisallowed extends Token {
  TokenDisallowed({required super.cp}) : super(type: TY_DISALLOWED);
}

class TokenEmoji extends Token {
  final List<int> emoji;
  final List<int> input;

  TokenEmoji({required this.emoji, required this.input, required super.cps})
      : super(type: TY_EMOJI);
}

class TokenIgnored extends Token {
  TokenIgnored({required super.cp}) : super(type: TY_IGNORED);
}

class TokenMapped extends Token {
  TokenMapped({required super.cp, required super.cps}) : super(type: TY_MAPPED);
}

class TokenNFC extends Token {
  final List<int> input;

  TokenNFC({required this.input, required super.cps}) : super(type: TY_NFC);
}

class TokenStop extends Token {
  TokenStop() : super(cp: CP_STOP, type: TY_STOP);
}

class TokenValid extends Token {
  TokenValid({required super.cps}) : super(type: TY_VALID);
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

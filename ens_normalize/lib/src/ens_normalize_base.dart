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

import 'normalization.dart';
import 'spec.dart';

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

late NORMALIZATION normalizationData;

final simpleNameRegex = RegExp(r'^[a-z0-9]+(?:\.[a-z0-9]+)*$');

final specJsonZippedPath = "${Directory.current.path}/spec.json.gz";

/// Combine cps from continuous valid tokens into single tokens.
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

/// Compute the set of valid codepoints from the spec.json file.
Set<int> computeValid(List<Group> groups) {
  var valid = <int>{};
  for (var g in groups) {
    valid.addAll(g.V);
  }
  valid.addAll(nfPartial(valid.toList(), 'NFD').runes);
  return valid;
}

/// Create a lookup table for recreating FE0F emojis from non-FE0F emojis.
Map<String, String> createEmojiFe0fLookup(List<String> emojis) {
  var lookup = HashMap<String, String>();
  for (var emoji in emojis) {
    lookup[_filterFe0f(emoji)] = emoji;
  }
  return lookup;
}

String createEmojiRegexPattern(List<String> emojis) {
  var fe0f = RegExp.escape('\uFE0F');

  String makeEmoji(String emoji) {
    return RegExp.escape(emoji).replaceAll(fe0f, '$fe0f?');
  }

  int order(String emoji) {
    return _filterFe0f(emoji).length;
  }

  emojis.sort((a, b) => order(b).compareTo(order(a)));

  return emojis.map(makeEmoji).join('|');
}

/// Recursively convert dictionary keys to integers (for JSON parsing).
dynamic dictKeysToInt(dynamic d) {
  if (d is Map) {
    return {for (var key in d.keys) _tryStrToInt(key): dictKeysToInt(d[key])};
  }
  return d;
}

/// Recursively convert dictionary keys to string (for JSON parsing).
dynamic dictKeysToString(dynamic d) {
  if (d is Map) {
    return {
      for (var key in d.keys) _tryIntToStr(key): dictKeysToString(d[key])
    };
  }
  return d;
}

/// Convert group names to group ids in the whole_map for faster lookup.
Map<int, dynamic> groupNamesToIds(
    List<Group> groups, Map<int, dynamic> wholeMap) {
  for (var v in wholeMap.values) {
    if (v is Map) {
      for (var k in v['M'].keys) {
        for (var i = 0; i < v['M'][k].length; i++) {
          var id = _findGroupId(groups, v['M'][k][i]);
          assert(id != null);
          v['M'][k][i] = id;
        }
      }
    }
  }
  return wholeMap;
}

/// applies the specified Unicode Normalization Form to a list of codepoints
/// and returns the result as a `Runes`
Runes nf(List<int> codePoints, String form) {
  return _strToCodePoints(_strFromCodePoints(codePoints).normalize(form: form));
}

/// applies the NFC Unicode Normalization to a list of codepoints
/// and returns the result as a `Runes`
Runes nfc(List<int> codePoints) {
  return nf(codePoints, 'NFC');
}

/// applies the NFD Unicode Normalization to a list of codepoints
/// and returns the result as a `Runes`
Runes nfd(List<int> codePoints) {
  return nf(codePoints, 'NFD');
}

/// applies the specified Unicode Normalization to a list of codepoints
/// and returns the result as a `string`
String nfPartial(List<int> codePoints, String form) {
  return String.fromCharCodes(codePoints).normalize(form: form);
}

/// https://github.com/namehash/ens-normalize-python/blob/main/ens_normalize/normalization.py
///
///  This function returns a list of [Token] objects that describe the modifications applied by ENS normalization to the input string.
///
/// Args:
///   tokens (List<Token>): A list of Token objects.
List<Token> normalizeTokens(List<Token> tokens) {
  var i = 0;
  var start = -1;
  while (i < tokens.length) {
    var token = tokens[i];
    if (token.type == TY_VALID || token.type == TY_MAPPED) {
      if (_cpsRequiresCheck(token.cps)) {
        var end = i + 1;
        for (var pos = end; pos < tokens.length; pos++) {
          if (tokens[pos].type == TY_VALID || tokens[pos].type == TY_MAPPED) {
            if (!_cpsRequiresCheck(tokens[pos].cps)) {
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
        var str0 = _strFromCodePoints(cps);
        var str = str0.normalize();
        if (str0 == str) {
          i = end - 1;
        } else {
          tokens.replaceRange(start, end,
              [TokenNFC(input: cps, cps: _strToCodePoints(str).toList())]);
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

///  Read and parse the groups field from the spec.json file.
List<Group> readGroups(List<Map<String, dynamic>> groups) {
  return groups.map((g) => Group.fromRawJson(g)).toList();
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
        s.add(_strFromCodePoints((tok as TokenEmoji).emoji));
      } else if (tok.type == TY_STOP) {
        s.add(String.fromCharCode(tok.cp!));
      } else {
        if (!labelIsGreek[labelIndex]) {
          s.add(_strFromCodePoints(tok.cps
              .map((cp) => cp == CP_XI_SMALL ? CP_XI_CAPITAL : cp)
              .toList()));
        } else {
          s.add(_strFromCodePoints(tok.cps));
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
      t.add(_strFromCodePoints(tok.cps));
    }
  }
  return t.join();
}

bool _cpsRequiresCheck(List<int> cps) {
  return cps.any((cp) => normalizationData.nfcCheck.contains(cp));
}

NORMALIZATION _decodeAndParseSpec() {
  final b64 = utf8.decode(base64Url.decode(spec));
  return NORMALIZATION.fromJson(jsonDecode(b64));
}

Tuple2<List<Group>?, CurableSequence?> _determineGroup(
    Iterable<int> unique, List<int> cps) {
  var groups = normalizationData.groups;
  for (var cp in unique) {
    var gs = groups.where((g) => g.V.contains(cp)).toList();
    if (gs.isEmpty) {
      if (groups == normalizationData.groups) {
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
              meta: _metaForConfMixed(groups[0], cp),
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

/// Remove all FE0F from text.
String _filterFe0f(String text) {
  return text.replaceAll('\uFE0F', '');
}

/// Find the index of a group by name.
int? _findGroupId(List<Group> groups, String name) {
  for (var i = 0; i < groups.length; i++) {
    if (groups[i].name == name) {
      return i;
    }
  }
  return null;
}

List<NormalizableSequence> _findNormalizations(List<Token> tokens) {
  var warnings = <NormalizableSequence>[];
  NormalizableSequenceType? warning;
  var start = 0;
  String? disallowed;
  String? suggestion;
  for (var tok in tokens) {
    if (tok.type == TY_MAPPED) {
      warning = NormalizableSequenceType.mapped;
      disallowed = String.fromCharCode(tok.cp!);
      suggestion = _strFromCodePoints(tok.cps);
    } else if (tok.type == TY_IGNORED) {
      warning = NormalizableSequenceType.ignored;
      disallowed = String.fromCharCode(tok.cp!);
      suggestion = '';
    } else if (tok.type == TY_EMOJI) {
      if ((tok as TokenEmoji).input != tok.cps) {
        warning = NormalizableSequenceType.fe0f;
        disallowed = _strFromCodePoints(tok.input);
        suggestion = _strFromCodePoints(tok.cps);
      }
    } else if (tok.type == TY_NFC) {
      warning = NormalizableSequenceType.nfc;
      disallowed = _strFromCodePoints((tok as TokenNFC).input);
      suggestion = _strFromCodePoints(tok.cps);
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

void _isolateEntry(dynamic message) {
  final SendPort sendPort = message[0];
  final result = _decodeAndParseSpec();
  sendPort.send(result);
}

/// Loads `NormalizationData` from a zip file.
Future<void> _loadNormalizationDataJson() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_isolateEntry, [receivePort.sendPort]);
  normalizationData = await receivePort.first;
}

CurableSequence _makeFencedError(List<int> cps, int start, int end) {
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

/// Create metadata for the CONF_MIXED error.
Map<String, String> _metaForConfMixed(Group g, int cp) {
  List? s1 = normalizationData.groups
      .where((group) => group.V.contains(cp))
      .map((group) => group.name)
      .toList();
  s1 = s1.isNotEmpty ? s1[0] : null;
  var s2 = g.name;
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

/// Output of post_check() is not input aligned.
///  This function offsets the error index (in-place) to match the input characters.
void _offsetErrStart(CurableSequence? err, List<Token> tokens) {
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

DisallowedSequence? _postCheck(
    String name, List<bool> labelIsGreek, String input) {
  if (input.isEmpty) {
    return null;
  }
  DisallowedSequence? e = _postCheckEmpty(name, input);
  if (e != null) {
    return e;
  }
  var labelOffset = 0;
  for (var label in name.split('.')) {
    var isGreek = [false];
    var cps = _strToCodePoints(label).toList();
    e = _postCheckUnderscore(label) ??
        _postCheckHyphen(label) ??
        _postCheckCmLeadingEmoji(cps) ??
        _postCheckFenced(cps) ??
        _postCheckGroupWhole(cps, isGreek);
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

CurableSequence? _postCheckCmLeadingEmoji(List<int> cps) {
  for (var i = 0; i < cps.length; i++) {
    if (normalizationData.cm.contains(cps[i])) {
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

CurableSequence? _postCheckEmpty(String name, String input) {
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

CurableSequence? _postCheckFenced(List<int> cps) {
  var cp = cps[0];
  var prev = normalizationData.fenced[cp];
  if (prev != null) {
    return _makeFencedError(cps, 0, 1);
  }

  var n = cps.length;
  var last = -1;
  for (var i = 1; i < n; i++) {
    cp = cps[i];
    var match = normalizationData.fenced[cp];
    if (match != null) {
      if (last == i) {
        return _makeFencedError(cps, i - 1, i + 1);
      }
      last = i + 1;
    }
  }

  if (last == n) {
    return _makeFencedError(cps, n - 1, n);
  }
  return null;
}

DisallowedSequence? _postCheckGroup(Group g, List<int> cps, List<int> input) {
  var v = g.V;
  var m = g.M;
  for (var cp in cps) {
    if (!v.contains(cp)) {
      return CurableSequence(
        type: CurableSequenceType.confMixed,
        index: input.indexOf(cp),
        sequence: String.fromCharCode(cp),
        suggested: '',
        meta: _metaForConfMixed(g, cp),
      );
    }
  }
  if (m) {
    var decomposed = nfc(cps).toList();
    var i = 1;
    var e = decomposed.length;
    while (i < e) {
      if (normalizationData.nsm.contains(decomposed[i])) {
        var j = i + 1;
        while (j < e && normalizationData.nsm.contains(decomposed[j])) {
          if (j - i + 1 > normalizationData.nsmMax) {
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

DisallowedSequence? _postCheckGroupWhole(List<int> cps, List<bool> isGreek) {
  var cpsNoFe0f = cps.where((cp) => cp != CP_FE0F).toList();
  var unique = cpsNoFe0f.toSet();
  List<Group>? g;
  CurableSequence? e;
  Group? h;
  var result = _determineGroup(unique, cps);
  g = result.item1;
  e = result.item2;
  if (e != null) {
    return e;
  }
  h = g![0];
  isGreek[0] = h.name == 'Greek';
  return _postCheckGroup(h, cpsNoFe0f, cps) ?? _postCheckWhole(h, unique);
}

CurableSequence? _postCheckHyphen(String label) {
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

CurableSequence? _postCheckUnderscore(String label) {
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

DisallowedSequence? _postCheckWhole(Group group, Iterable<int> cps) {
  List<int>? maker;
  var shared = <int>[];
  for (var cp in cps) {
    var whole = normalizationData.wholeMap[cp];
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
      var g = normalizationData.groups[gInd];
      if (shared.every((cp) => g.V.contains(cp))) {
        return DisallowedSequence(
          DisallowedSequenceType.confWhole,
          meta: {
            'script1': group.name,
            'script2': g.name,
          },
        );
      }
    }
  }
  return null;
}

/// Convert a list of integer codepoints to string.
String _strFromCodePoints(List<int> codePoints) {
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

/// Convert text to a list of integer codepoints.
Runes _strToCodePoints(String s) {
  return s.runes;
}

dynamic _tryIntToStr(x) {
  try {
    return x.toString();
  } catch (e) {
    return x;
  }
}

dynamic _tryStrToInt(x) {
  try {
    return int.parse(x);
  } catch (e) {
    return x;
  }
}

///  An unnormalized sequence containing a normalization suggestion that is automatically applied using `cure`.
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

/// An unnormalized sequence without any normalization suggestion.
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

  /// Synchronously gets an instance of ENSNormalize
  /// e.g
  /// ```dart
  /// ENSNormalize ensn = ENSNormalize();
  /// ```
  ///
  /// parses NormalizationData on main thread.
  factory ENSNormalize() {
    normalizationData = _decodeAndParseSpec();
    _initialized = true;
    return ENSNormalize._internal();
  }

  ENSNormalize._internal();

  /// Apply ENS normalization with beautification to a string.
  ///
  /// Raises `DisallowedSequence` if the input cannot be normalized.
  /// e.g
  /// ```dart
  /// ENSNormalize ensn = await ENSNormalize.getInstance();
  /// String beautified = ensn.beautify('1⃣2⃣.eth'); // 1️⃣2️⃣.eth
  /// ```
  String beautify(String text) {
    var res = ensProcess(text, doBeautify: true);
    if (res.error != null) {
      throw res.error!;
    }
    return res.beautified!;
  }

  /// Apply ENS normalization to a string. If the result is not normalized then this function
  ///  will try to make the input normalized by removing all disallowed characters.

  ///  Raises `DisallowedSequence` if one is encountered and cannot be cured.
  /// e.g
  /// ```dart
  /// ENSNormalize ensn = await ENSNormalize.getInstance();
  /// String normalized = ensn.cure('Ni‍ck?.ETH'); // nick.eth
  /// ```
  String cure(String text) {
    return _cure(text).item1;
  }

  /// Used to compute
  ///
  ///  - `ens_normalize`
  ///  - `ens_beautify`
  ///  - `ens_tokenize`
  ///  - `ens_normalizations`
  ///  - `ens_cure`
  ///  in one go.
  ///
  ///  Returns `ENSProcessResult` with the following fields:
  ///  - `normalized`: normalized name or `None` if input cannot be normalized or `do_normalize` is `False`
  ///  - `beautified`: beautified name or `None` if input cannot be normalized or `do_beautify` is `False`
  ///  - `tokens`: list of `Token` objects or `None` if `do_tokenize` is `False`
  ///  - `cured`: cured name or `None` if input cannot be cured or `do_cure` is `False`
  ///  - `cures`: list of fixed `CurableSequence` objects or `None` if input cannot be cured or `do_cure` is `False`
  ///  - `error`: `DisallowedSequence` or `CurableSequence` or `None` if input is valid
  ///  - `normalizations`: list of `NormalizableSequence` objects or `None` if `do_normalizations` is `False`
  /// e.g
  /// ```dart
  /// ENSNormalize ensn = await ENSNormalize.getInstance();
  ///  ensn.ensProcess(
  ///     "Nàme🧙‍♂️1⃣.eth",
  ///     doNormalize: true,
  ///     doBeautify: true,
  ///     doTokenize: true,
  ///     doNormalizations: true,
  ///     doCure: true,
  ///   );
  ///  // Instance of 'ENSProcessResult'
  ///  ```
  ENSProcessResult ensProcess(
    String input, {
    bool doNormalize = false,
    bool doBeautify = false,
    bool doTokenize = false,
    bool doNormalizations = false,
    bool doCure = false,
  }) {
    _requireInitialized();
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
    var emojiIter = normalizationData.emojiRegex.allMatches(input).iterator;
    var nextEmojiMatch = emojiIter.moveNext() ? emojiIter.current : null;

    while (inputCur < input.length) {
      if (nextEmojiMatch != null && nextEmojiMatch.start == inputCur) {
        var emoji = nextEmojiMatch.group(0)!;
        inputCur = nextEmojiMatch.end;
        nextEmojiMatch = emojiIter.moveNext() ? emojiIter.current : null;
        var emojiNoFe0f = _filterFe0f(emoji);
        var emojiFe0f = normalizationData.emojiFe0fLookup[emojiNoFe0f]!;
        tokens.add(
          TokenEmoji(
            emoji: _strToCodePoints(emojiFe0f).toList(),
            input: _strToCodePoints(emoji).toList(),
            cps: _strToCodePoints(emojiNoFe0f).toList(),
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
      if (normalizationData.valid.contains(cp)) {
        tokens.add(
          TokenValid(
            cps: [cp],
          ),
        );
        continue;
      }
      if (normalizationData.ignored.contains(cp)) {
        tokens.add(
          TokenIgnored(
            cp: cp,
          ),
        );
        continue;
      }
      var mapping = normalizationData.mapped[cp];
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
    var normalizations = doNormalizations ? _findNormalizations(tokens) : null;
    List<bool> labelIsGreek = [];
    if (error == null) {
      var emojisAsFe0f = tokens2str(tokens, (tok) => '\uFE0F');
      error = _postCheck(emojisAsFe0f, labelIsGreek, input);
      if (error is CurableSequence) {
        _offsetErrStart(error, tokens);
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
        var result = _cure(input);
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

  /// Checks if the input string is ENS normalizable
  /// (i.e. `normalize(name)` will not raise `DisallowedSequence`).
  /// e.g
  ///
  /// ```dart
  /// ENSNormalize ensn = await ENSNormalize.getInstance();
  /// ensn.isNormalizable('Nick.ETH'); // true
  /// ```
  bool isNormalizable(String name) {
    return ensProcess(name).error == null;
  }

  /// Checks if the input string is already ENS normalized
  /// (i.e. `ens_normalize(name) == name`).
  /// e.g
  ///
  /// ```dart
  /// ENSNormalize ensn = await ENSNormalize.getInstance();
  /// ensn.isNormalized('Nick.ETH'); // true
  ///```
  bool isNormalized(String name) {
    return ensProcess(name, doNormalize: true).normalized == name;
  }

  /// This function returns a list of [NormalizableSequence] objects
  ///  that describe the modifications applied by ENS normalization to the input string.

  ///  Raises `DisallowedSequence` if the input cannot be normalized.
  /// e.g
  ///
  /// ```dart
  /// ENSNormalize ensn = await ENSNormalize.getInstance();
  /// List<NormalizableSequence> normalizations = ensn.normalizations(text);
  /// // [
  // // NormalizableSequence(code="NormalizableSequenceType", index=0, sequence="N", suggested="n"),
  // // NormalizableSequence(code="NormalizableSequenceType", index=1, sequence="🧙‍♂️", suggested="🧙‍♂")
  // // ]
  /// ```
  List<NormalizableSequence> normalizations(String input) {
    var res = ensProcess(input, doNormalizations: true);
    if (res.error != null) {
      throw res.error!;
    }
    return res.normalizations!;
  }

  /// Apply ENS normalization to a string.
  ///
  ///  Raises DisallowedSequence if the input cannot be normalized.
  /// e.g
  /// ```dart
  /// ENSNormalize ensn = await ENSNormalize.getInstance();
  /// String normalized = ensn.normalize('Nick.ETH');
  /// // nick.eth
  /// ```
  String normalize(String text) {
    var res = ensProcess(text, doNormalize: true);
    if (res.error != null) {
      throw res.error!;
    }
    return res.normalized!;
  }

  /// Tokenize a string using ENS normalization.

  ///  Returns a list of tokens.

  ///  Each token contains a `type` field and other fields depending on the type.
  ///  All codepoints are represented as integers.
  ///
  /// Token types and their fields:
  ///  - valid
  ///     - cps: list of codepoints
  ///  - mapped
  ///     - cp: input codepoint
  ///  - cps: list of output codepoints
  ///     - ignored
  ///     - cp: codepoint
  ///  - disallowed
  ///     - cp: codepoint
  ///  - emoji
  ///     - emoji: 'pretty' version of the emoji codepoints (with FE0F)
  ///     - input: raw input codepoints
  ///     - cps: text version of the emoji codepoints (without FE0F)
  ///  - stop:
  ///     - cp: 0x2E
  ///  - nfc
  ///     - input: input codepoints
  ///     - cps: output codepoints (after NFC normalization)
  ///
  /// e.g
  ///
  /// ```dart
  ///    ENSNormalize ensn = await ENSNormalize.getInstance();
  ///    var tokens = ensn.tokenize('Nàme‍🧙‍♂.eth');
  /// ```
  List<Token> tokenize(String input) {
    return ensProcess(input, doTokenize: true).tokens!;
  }

  Tuple2<String, List<CurableSequence>> _cure(String text) {
    _requireInitialized();
    var cures = <CurableSequence>[];
    for (var i = 0; i < 2 * text.length + 1; i++) {
      try {
        return Tuple2(normalize(text), cures);
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

  void _requireInitialized() {
    if (!_initialized) {
      throw Exception('NORMALIZATION not initialized');
    }
  }

  /// Asynchronously gets an instance of ENSNormalize
  /// e.g
  /// ```dart
  /// await ENSNormalize.getInstance();
  /// ```
  ///
  /// parses NormalizationData on a separate Isolate.
  static Future<ENSNormalize> getInstance() async {
    _initialized == false ? await _initialize() : null;
    return ENSNormalize._internal();
  }

  static Future<void> _initialize() async {
    await _loadNormalizationDataJson();
    _initialized = true;
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

class Group {
  final String name;
  final Set<int> P;
  final Set<int> Q;
  final Set<int> V;
  final bool M;

  Group(this.name, this.P, this.Q, this.V, this.M);

  factory Group.fromJson(Map<String, dynamic> map) {
    return Group(
      map['name'] as String,
      Set<int>.from(map['P']),
      Set<int>.from(map['Q']),
      Set<int>.from(map['V']),
      map['M'] as bool,
    );
  }

  factory Group.fromRawJson(Map<String, dynamic> map) {
    return Group(
      map['name'] as String,
      Set<int>.from(map['primary']),
      Set<int>.from(map['secondary']),
      Set<int>.from(map['primary'] + map['secondary']),
      !map.containsKey('cm'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'P': P.toList(),
      'Q': Q.toList(),
      'V': V.toList(),
      'M': M,
    };
  }
}

/// An unnormalized sequence containing a normalization suggestion that is automatically applied using `normalize` and `cure`.
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

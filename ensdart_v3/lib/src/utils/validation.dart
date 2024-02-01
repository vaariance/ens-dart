import 'package:ensdart/src/errors/errors.dart';
import 'package:ensdart/src/utils/labels.dart';

import 'constants.dart';
import 'normalize.dart';

String validateName(String name) {
  final nameArray = name.split('.');
  final normalisedArray = nameArray.map((label) {
    if (label.isEmpty) {
      throw NameWithEmptyLabelsError(name: name);
    }
    if (label == "[root]") {
      if (name != label) {
        throw RootNameIncludesOtherLabelsError(name: name);
      }
      return label;
    }
    return isEncodedLabelhash(label)
        ? checkLabel(label)
        : ensn.normalize(label);
  });
  final normalisedName = normalisedArray.join('.');
  return normalisedName;
}

class ParsedInputResult {
  String type;
  String? normalized;
  bool isValid;
  bool isShort;
  bool is2LD;
  bool isETH;
  List labelDataList;

  ParsedInputResult({
    required this.type,
    this.normalized,
    required this.isValid,
    required this.isShort,
    required this.is2LD,
    required this.isETH,
    required this.labelDataList,
  }) : assert(type == "name" || type == "label");
}

ParsedInputResult parseInput(String input) {
  String nameReference = input;
  bool isValid = false;

  try {
    nameReference = validateName(input);
    isValid = true;
    // ignore: empty_catches
  } catch (e) {}

  final normalizedName = isValid ? nameReference : null;

  final labels = nameReference.split('.');
  final tld = labels[labels.length - 1];
  final isETH = tld == "eth";
  final labelDataList = ensn.split(nameReference);
  final isShort = labelDataList[0].output.length < MINIMUM_DOT_ETH_CHARS;

  if (labels.length == 1) {
    return ParsedInputResult(
        type: "label",
        isValid: isValid,
        isShort: isShort,
        is2LD: false,
        isETH: isETH,
        labelDataList: labelDataList.toList());
  }

  final is2LD = labels.length == 2;
  return ParsedInputResult(
      type: "name",
      normalized: normalizedName,
      isValid: isValid,
      isShort: isShort,
      is2LD: is2LD,
      isETH: isETH,
      labelDataList: labelDataList.toList());
}

bool checkIsDotEth(List<String> labels) {
  return labels.length == 2 && labels[1] == "eth";
}

import 'dart:convert';
import 'dart:io';

import 'package:ens_normalize/src/normalization.dart';

final specJsonPath = '${Directory.current.path}/spec.json';
final indexJsPath =
    '${Directory.current.path}/node_modules/@adraffy/ens-normalize/dist/index.mjs';

void addWholeMapExport() {
  var content = File(indexJsPath).readAsStringSync();

  content += '\n\n// added by update_ens.dart\ninit();\nexport {WHOLE_MAP};\n';

  File(indexJsPath).writeAsStringSync(content);
}

void generate() {
  final data = NORMALIZATION.fromSpecJsonPath(specJsonPath);
  final spec = base64Url.encode(utf8.encode(jsonEncode(data.toJson())));
  File('../lib/src/spec.dart')
      .writeAsStringSync('const String spec = \'$spec\';');
}

void main() {
  Process.runSync('pnpm', ['install']);
  addWholeMapExport();
  Process.runSync('node', ['update-ens.js']);
  generate();
}

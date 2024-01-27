import 'dart:convert';
import 'dart:io';

import 'package:ens_normalize/src/ens_normalize_base.dart';

final specJsonPath = '${Directory.current.path}/spec.json';
final indexJsPath =
    '${Directory.current.path}/node_modules/@adraffy/ens-normalize/dist/index.mjs';

void addWholeMapExport() {
  var content = File(indexJsPath).readAsStringSync();

  content += '\n\n// added by update_ens.dart\ninit();\nexport {WHOLE_MAP};\n';

  File(indexJsPath).writeAsStringSync(content);
}

void generateZip() {
  var data = NormalizationData.fromSpecJsonPath(specJsonPath);
  List<int> encoded = utf8.encode(data.toJson());
  List<int> compressed = gzip.encode(encoded);
  File('../lib/src/spec.json.gz').writeAsBytesSync(compressed);
}

void main() {
  Process.runSync('pnpm', ['install']);
  addWholeMapExport();
  Process.runSync('node', ['update-ens.js']);
  generateZip();
}

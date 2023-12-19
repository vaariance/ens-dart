import 'dart:io';

import 'package:pubspec_yaml/pubspec_yaml.dart';

class Version {
  final String version;
  final String name;

  Version()
      : version = Version._version(),
        name = Version._name();

  String getVersion() => "$name: $version";

  static String _version() {
    final pubspecYaml = File('pubspec.yaml').readAsStringSync().toPubspecYaml();
    final version = pubspecYaml.version;
    if (version.hasValue) {
      return version.toString();
    }
    throw Exception("Version not found");
  }

  static String _name() {
    final pubspecYaml = File('pubspec.yaml').readAsStringSync().toPubspecYaml();
    return pubspecYaml.name;
  }
}

import 'dart:io';

import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

/// Utilities to help dealing with paths to common package files.
extension PackageIOUtils on Directory {
  /// The pubspec file of this package.
  File get pubspec => File(join(path, 'pubspec.yaml'));

  /// The package config file of this package.
  File get packageConfig =>
      File(join(path, '.dart_tool', 'package_config.json'));
}

/// Try parsing the pubspec of the given directory.
///
/// If the parsing fails for any reason, returns null.
Pubspec? tryParsePubspecSync(Directory directory) {
  try {
    return parsePubspecSync(directory);
  } catch (_) {
    return null;
  }
}

/// Parse the pubspec of the given directory.
///
/// Throws if the parsing fails, such as if the file is badly formatted or
/// does not exists.
Pubspec parsePubspecSync(Directory directory) {
  return Pubspec.parse(directory.pubspec.readAsStringSync());
}

/// Try parsing the pubspec of the given directory.
///
/// If the parsing fails for any reason, returns null.
Future<Pubspec?> tryParsePubspec(Directory directory) async {
  try {
    return await parsePubspec(directory);
  } catch (_) {
    return null;
  }
}

/// Parse the pubspec of the given directory.
///
/// Throws if the parsing fails, such as if the file is badly formatted or
/// does not exists.
Future<Pubspec> parsePubspec(Directory directory) async {
  return Pubspec.parse(await directory.pubspec.readAsString());
}

/// Try parsing the package config of the given directory.
///
/// If the parsing fails for any reason, returns null.
PackageConfig? tryParsePackageConfigSync(Directory directory) {
  try {
    return parsePackageConfigSync(directory);
  } catch (_) {
    return null;
  }
}

/// Parse the package config of the given directory.
///
/// Throws if the parsing fails, such as if the file is badly formatted or
/// does not exists.
PackageConfig parsePackageConfigSync(Directory directory) {
  final packageConfigFile = directory.packageConfig;
  return PackageConfig.parseBytes(
    packageConfigFile.readAsBytesSync(),
    packageConfigFile.uri,
  );
}

/// Try parsing the package config of the given directory.
///
/// If the parsing fails for any reason, returns null.
Future<PackageConfig?> tryParsePackageConfig(Directory directory) async {
  try {
    return await parsePackageConfig(directory);
  } catch (_) {
    return null;
  }
}

/// Parse the package config of the given directory.
///
/// Throws if the parsing fails, such as if the file is badly formatted or
/// does not exists.
Future<PackageConfig> parsePackageConfig(Directory directory) async {
  final packageConfigFile = directory.packageConfig;
  return PackageConfig.parseBytes(
    await packageConfigFile.readAsBytes(),
    packageConfigFile.uri,
  );
}

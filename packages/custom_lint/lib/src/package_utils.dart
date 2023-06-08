import 'dart:io';

import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

/// Utilities to help dealing with paths to common package files.
extension PackageIOUtils on Directory {
  /// Creates a child [File] from a list of path segments.
  File file(
    String name, [
    String? name2,
    String? name3,
    String? name4,
    String? name5,
    String? name6,
  ]) =>
      File(join(path, name, name2, name3, name4, name5, name6));

  /// Creates a child [Directory] from a list of path segments.
  Directory dir(
    String name, [
    String? name2,
    String? name3,
    String? name4,
    String? name5,
    String? name6,
  ]) =>
      Directory(join(path, name, name2, name3, name4, name5, name6));

  /// The `analysis_options.yaml` file.
  File get analysisOptions => file('analysis_options.yaml');

  /// The `pubspec.yaml` file.
  File get pubspec => file('pubspec.yaml');

  /// The `.dart_tool/package_config.json` file.
  File get packageConfig => file('.dart_tool', 'package_config.json');

  /// Returns a path relative to the given [other].
  String relativeTo(FileSystemEntity other) {
    return normalize(relative(path, from: other.path));
  }
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
  return Pubspec.parse(
      findProjectDirectory(directory).pubspec.readAsStringSync());
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
  final pubspec = findProjectDirectory(directory).pubspec;

  return Pubspec.parse(await pubspec.readAsString());
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
  final packageConfigFile = findProjectDirectory(directory).packageConfig;
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

/// Finds the project directory associated with an analysis context root
///
/// This is a folder that contains both a `pubspec.yaml` and a `.dart_tool/package_config.json` file.
/// It is either alongside the analysis_options.yaml file, or in a parent directory.
Directory findProjectDirectory(Directory directory, {Directory? original}) {
  final packageConfigFile = directory.packageConfig;
  if (!packageConfigFile.existsSync() && !directory.pubspec.existsSync()) {
    if (directory.parent.uri == directory.uri) {
      throw Exception(
          'Could not find project directory outside ${original?.path}');
    }
    return findProjectDirectory(directory.parent, original: directory);
  }
  return directory;
}

/// Parse the package config of the given directory.
///
/// Throws if the parsing fails, such as if the file is badly formatted or
/// does not exists.
Future<PackageConfig> parsePackageConfig(Directory directory) async {
  final packageConfigFile = findProjectDirectory(directory).packageConfig;

  return PackageConfig.parseBytes(
    await packageConfigFile.readAsBytes(),
    packageConfigFile.uri,
  );
}

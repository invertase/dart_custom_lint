import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

final customLintBinPath = join(
  PeerProjectMeta.current.customLintPath,
  'bin',
  'custom_lint.dart',
);

class PeerProjectMeta {
  PeerProjectMeta({
    required this.customLintPath,
    required this.customLintBuilderPath,
    required this.customLintCorePath,
    required this.exampleAppPath,
    required this.exampleLintPath,
    required this.exampleLintPackageConfigString,
    required this.exampleLintPackageConfig,
  }) {
    final dirs = [
      customLintPath,
      customLintBuilderPath,
      exampleAppPath,
      exampleLintPath,
    ];

    for (final dir in dirs) {
      if (!Directory(dir).existsSync()) {
        throw StateError('Nothing found at $dir.');
      }
    }
  }

  factory PeerProjectMeta.fromDirectory(Directory directory) {
    final exampleAppDir = Directory(
      join(
        directory.path,
        'example',
      ),
    );

    final packagesPath = normalize(join(directory.path, '..'));

    final examplePackageConfigPath = join(
      normalize(exampleAppDir.path),
      'example_lint',
      '.dart_tool',
      'package_config.json',
    );
    final exampleLintPackageConfigString =
        File(examplePackageConfigPath).readAsStringSync();

    return PeerProjectMeta(
      customLintPath: join(packagesPath, 'custom_lint'),
      customLintBuilderPath: join(packagesPath, 'custom_lint_builder'),
      customLintCorePath: join(packagesPath, 'custom_lint_core'),
      exampleAppPath: normalize(exampleAppDir.path),
      exampleLintPath:
          join(packagesPath, 'custom_lint', 'example', 'example_lint'),
      exampleLintPackageConfigString: exampleLintPackageConfigString,
      exampleLintPackageConfig:
          jsonDecode(exampleLintPackageConfigString) as Map<String, Object?>,
    );
  }

  static final current = PeerProjectMeta.fromDirectory(Directory.current);

  final String customLintPath;
  final String customLintBuilderPath;
  final String customLintCorePath;
  final String exampleAppPath;
  final String exampleLintPath;
  final String exampleLintPackageConfigString;
  final Map<String, Object?> exampleLintPackageConfig;
}

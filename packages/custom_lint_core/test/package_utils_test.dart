import 'dart:io';

import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('parsePackageConfig', () {
    test('resolves workspace root when package_config.json does not exist',
        () async {
      final tempDir =
          await Directory.systemTemp.createTemp('custom_lint_test_');
      try {
        // Create workspace structure:
        // workspace/
        //   .dart_tool/
        //     package_config.json (workspace root)
        //   package/
        //     .dart_tool/
        //       pub/
        //         workspace_ref.json (points to workspace root)
        //     pubspec.yaml

        final workspaceRoot = tempDir;
        final packageDir = Directory(p.join(tempDir.path, 'package'));

        // Create workspace root package_config.json
        final workspacePackageConfig = workspaceRoot.packageConfig;
        await workspacePackageConfig.parent.create(recursive: true);
        await workspacePackageConfig.writeAsString('''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "test_plugin",
      "rootUri": "../test_plugin",
      "packageUri": "lib"
    }
  ],
  "generated": "2024-01-01T00:00:00.000Z",
  "generator": "pub",
  "generatorVersion": "1.0.0"
}
''');

        // Create package directory structure
        await packageDir.create(recursive: true);
        await File(p.join(packageDir.path, 'pubspec.yaml')).writeAsString('''
name: test_package
version: 1.0.0
dev_dependencies:
  test_plugin:
    path: ../test_plugin
''');

        // Create workspace_ref.json pointing to workspace root
        // workspaceRoot is relative to .dart_tool/pub, so from package/.dart_tool/pub
        // we need to go up 3 levels: .. (to .dart_tool) -> .. (to package) -> .. (to workspace root)
        final workspaceRefFile = packageDir.workspaceRef;
        await workspaceRefFile.parent.create(recursive: true);
        await workspaceRefFile.writeAsString('''
{
  "workspaceRoot": "../../.."
}
''');

        // Parse package config - should resolve to workspace root
        final packageConfig = await parsePackageConfig(packageDir);

        // Verify it loaded from workspace root
        expect(packageConfig.packages, isNotEmpty);
        expect(
          packageConfig.packages.any((pkg) => pkg.name == 'test_plugin'),
          isTrue,
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('handles workspace root with relative path containing ..', () async {
      final tempDir =
          await Directory.systemTemp.createTemp('custom_lint_test_');
      try {
        // Create deeper workspace structure:
        // workspace/
        //   .dart_tool/
        //     package_config.json
        //   packages/
        //     subpackage/
        //       .dart_tool/
        //         pub/
        //           workspace_ref.json (points to ../../..)

        final workspaceRoot = tempDir;
        final subpackageDir = Directory(
          p.join(tempDir.path, 'packages', 'subpackage'),
        );

        // Create workspace root package_config.json
        final workspacePackageConfig = workspaceRoot.packageConfig;
        await workspacePackageConfig.parent.create(recursive: true);
        await workspacePackageConfig.writeAsString('''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "deep_plugin",
      "rootUri": "../deep_plugin",
      "packageUri": "lib"
    }
  ],
  "generated": "2024-01-01T00:00:00.000Z",
  "generator": "pub",
  "generatorVersion": "1.0.0"
}
''');

        // Create subpackage directory structure
        await subpackageDir.create(recursive: true);
        await File(p.join(subpackageDir.path, 'pubspec.yaml')).writeAsString('''
name: subpackage
version: 1.0.0
dev_dependencies:
  deep_plugin:
    path: ../../../deep_plugin
''');

        // Create workspace_ref.json with relative path containing ..
        // workspaceRoot is relative to .dart_tool/pub, so from packages/subpackage/.dart_tool/pub
        // we need to go up 4 levels: .. (to .dart_tool) -> .. (to subpackage) -> .. (to packages) -> .. (to workspace root)
        final workspaceRefFile = subpackageDir.workspaceRef;
        await workspaceRefFile.parent.create(recursive: true);
        await workspaceRefFile.writeAsString('''
{
  "workspaceRoot": "../../../.."
}
''');

        // Parse package config - should resolve to workspace root
        final packageConfig = await parsePackageConfig(subpackageDir);

        // Verify it loaded from workspace root
        expect(packageConfig.packages, isNotEmpty);
        expect(
          packageConfig.packages.any((pkg) => pkg.name == 'deep_plugin'),
          isTrue,
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('throws error when workspace_ref.json does not exist', () async {
      final tempDir =
          await Directory.systemTemp.createTemp('custom_lint_test_');
      try {
        final packageDir = Directory(p.join(tempDir.path, 'package'));
        await packageDir.create(recursive: true);
        await File(p.join(packageDir.path, 'pubspec.yaml')).writeAsString('''
name: test_package
version: 1.0.0
''');

        // Don't create workspace_ref.json - should throw
        expect(
          () => parsePackageConfig(packageDir),
          throwsA(isA<FileSystemException>()),
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('throws error when workspace root package_config.json does not exist',
        () async {
      final tempDir =
          await Directory.systemTemp.createTemp('custom_lint_test_');
      try {
        final packageDir = Directory(p.join(tempDir.path, 'package'));

        // Create package directory
        await packageDir.create(recursive: true);
        await File(p.join(packageDir.path, 'pubspec.yaml')).writeAsString('''
name: test_package
version: 1.0.0
''');

        // Create workspace_ref.json pointing to workspace root
        // workspaceRoot is relative to .dart_tool/pub, so from package/.dart_tool/pub
        // we need to go up 3 levels: .. (to .dart_tool) -> .. (to package) -> .. (to workspace root)
        final workspaceRefFile = packageDir.workspaceRef;
        await workspaceRefFile.parent.create(recursive: true);
        await workspaceRefFile.writeAsString('''
{
  "workspaceRoot": "../../.."
}
''');

        // Don't create workspace root package_config.json - should throw
        expect(
          () => parsePackageConfig(packageDir),
          throwsA(isA<FileSystemException>()),
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });
}

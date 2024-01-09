import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/package_utils.dart' show parsePackageConfig;
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

io.Directory createDir() {
  final tempDir = io.Directory.systemTemp.createTempSync();
  addTearDown(() => tempDir.delete(recursive: true));
  return tempDir;
}

File createAnalysisOptions(String content) {
  final dir = createDir();
  final ioFile = io.File(join(dir.path, 'analysis_options.yaml'));
  ioFile.writeAsStringSync(content);
  return PhysicalResourceProvider.INSTANCE.getFile(ioFile.path);
}

Future<String> createTempProject(String projectName, String tempDirPath) async {
  final projectPath = join(tempDirPath, projectName);

  final dir = io.Directory(projectPath);
  await dir.create();

  final libPath = join(dir.path, 'lib');
  await io.Directory(libPath).create();

  final analysisOptionsPath = join(libPath, 'analysis_options.yaml');
  await io.File(analysisOptionsPath).writeAsString('''
custom_lint:
  rules:
    - from_package
  ''');

  return dir.path;
}

PackageConfig patchPackageConfig(
  PackageConfig currentPackageConfig,
  String packageName,
  String packagePath,
) {
  final patchedPackages = currentPackageConfig.packages.toList()
    ..add(
      Package(
        packageName,
        Uri.file('$packagePath/'),
        packageUriRoot: Uri.parse('lib/'),
      ),
    );

  final patchedPackageConfig = PackageConfig(
    patchedPackages,
    extraData: currentPackageConfig.extraData,
  );

  return patchedPackageConfig;
}

void main() async {
  late File includeFile;
  late CustomLintConfigs includeConfig;

  final packageConfig = await parsePackageConfig(io.Directory.current);

  const testPackageName = 'test_package_with_config';
  setUp(() {
    includeFile = createAnalysisOptions(
      '''
custom_lint:
  rules:
  - a
  - b: false
  - c:
    foo: 42
  - d
''',
    );

    includeConfig = CustomLintConfigs.parse(includeFile, packageConfig);
  });

  test('Empty config', () {
    expect(CustomLintConfigs.empty.enableAllLintRules, null);
    expect(CustomLintConfigs.empty.rules, isEmpty);
  });

  group('parse', () {
    test('if file is null, defaults to empty', () {
      final configs = CustomLintConfigs.parse(null, packageConfig);
      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if file does not exist, defaults to empty ', () {
      final configs = CustomLintConfigs.parse(
        PhysicalResourceProvider.INSTANCE.getFile('/this-does-no-exist'),
        packageConfig,
      );
      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if custom_lint not present in the option file, clones "include"', () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false
''');
      final configs = CustomLintConfigs.parse(analysisOptions, packageConfig);

      expect(configs, includeConfig);
    });

    test('if custom_lint not present in the option file, clones "include"', () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false
''');
      final configs = CustomLintConfigs.parse(analysisOptions, packageConfig);

      expect(configs, includeConfig);
    });

    test('if custom_lint is present but empty, clones "include"', () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
''');
      final configs = CustomLintConfigs.parse(analysisOptions, packageConfig);

      expect(configs, includeConfig);
    });

    test('has an immutable list of rules', () {
      final analysisOptions = createAnalysisOptions('''
custom_lint:
  rules: 
  - a
''');
      final configs = CustomLintConfigs.parse(analysisOptions, packageConfig);

      expect(
        configs.rules,
        {'a': const LintOptions.empty(enabled: true)},
      );

      expect(
        () => configs.rules['b'] = const LintOptions.empty(enabled: true),
        throwsUnsupportedError,
      );
    });

    test(
        'if custom_lint is present and defines some properties, merges with "include"',
        () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
  enable_all_lint_rules: false
''');
      final configs = CustomLintConfigs.parse(analysisOptions, packageConfig);

      expect(configs.enableAllLintRules, false);
      expect(configs.rules, includeConfig.rules);
    });

    test(
        'if custom_lint.enable_all_lint_rules is not present, uses value from "include"',
        () {
      final included = createAnalysisOptions('''
custom_lint:
  enable_all_lint_rules: false
''');
      final analysisOptions = createAnalysisOptions('''
include: ${included.path}
custom_lint:
  rules:
  - a
''');
      final configs = CustomLintConfigs.parse(analysisOptions, packageConfig);

      expect(configs.enableAllLintRules, false);
      expect(configs.rules, {
        'a': const LintOptions.empty(enabled: true),
      });
    });

    test('include config using package: uri', () async {
      final dir = createDir();
      final file = createAnalysisOptions('''
include: package:$testPackageName/analysis_options.yaml
      ''');

      final tempProjectDir = await createTempProject(dir.path, testPackageName);

      final patchedPackageConfig = patchPackageConfig(
        packageConfig,
        testPackageName,
        tempProjectDir,
      );
      final configs = CustomLintConfigs.parse(file, patchedPackageConfig);

      expect(configs.rules.containsKey('from_package'), true);
    });

    test('if package: uri is not resolved default to empty', () async {
      const notExistingFileName = 'this-does-not-exist';

      final file = createAnalysisOptions('''
include: package:$testPackageName/$notExistingFileName
      ''');
      final dir = createDir();

      final tempProjectDir = await createTempProject(dir.path, testPackageName);
      final patchedPackageConfig = patchPackageConfig(
        packageConfig,
        testPackageName,
        tempProjectDir,
      );
      final configs = CustomLintConfigs.parse(file, patchedPackageConfig);

      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if package: uri is not valid default to empty', () async {
      const notExistingPackage = 'this-package-does-not-exists';

      final file = createAnalysisOptions('''
include: package:$notExistingPackage/analysis_options.yaml
      ''');
      final dir = createDir();
      final tempProjectDir = await createTempProject(dir.path, testPackageName);

      final patchedPackageConfig = patchPackageConfig(
        packageConfig,
        testPackageName,
        tempProjectDir,
      );
      final configs = CustomLintConfigs.parse(file, patchedPackageConfig);

      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if custom_lint.rules is present, merges with "include"', () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
  enable_all_lint_rules: true
  rules:
  - a2
  - b2: false
  - c2:
    foo: 21
  - d
''');
      final configs = CustomLintConfigs.parse(analysisOptions, packageConfig);

      expect(configs.enableAllLintRules, true);
      expect(configs.rules, {
        'a': const LintOptions.empty(enabled: true),
        'b': const LintOptions.empty(enabled: false),
        'c': const LintOptions.fromYaml({'foo': 42}, enabled: true),
        'a2': const LintOptions.empty(enabled: true),
        'b2': const LintOptions.empty(enabled: false),
        'c2': const LintOptions.fromYaml({'foo': 21}, enabled: true),
        'd': const LintOptions.empty(enabled: true),
      });
    });

    group('Handles errors', () {
      test('Defaults to empty if yaml fails to parse', () {
        final configs = CustomLintConfigs.parse(
          createAnalysisOptions(
            '''
foo:
    bar:
  baz:
''',
          ),
          packageConfig,
        );
        expect(configs, CustomLintConfigs.empty);
      });
    });
  });
}

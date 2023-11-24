import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
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

Future<void> patchPackageConfig(
  String packageName,
  String packagePath,
) async {
  final currentPackageConfig = await findPackageConfig(io.Directory.current);
  if (currentPackageConfig == null) {
    throw Exception('Could not find package config');
  }

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

  await savePackageConfig(
    patchedPackageConfig,
    io.Directory.current,
  );

  addTearDown(
    () async => savePackageConfig(currentPackageConfig, io.Directory.current),
  );
}

void main() {
  late File includeFile;
  late CustomLintConfigs includeConfig;
  setUp(() async {
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

    includeConfig = await CustomLintConfigs.parse(includeFile);
  });

  test('Empty config', () {
    expect(CustomLintConfigs.empty.enableAllLintRules, null);
    expect(CustomLintConfigs.empty.rules, isEmpty);
  });

  group('parse', () {
    test('if file is null, defaults to empty', () async {
      final configs = await CustomLintConfigs.parse(null);
      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if file does not exist, defaults to empty ', () async {
      final configs = await CustomLintConfigs.parse(
        PhysicalResourceProvider.INSTANCE.getFile('/this-does-no-exist'),
      );
      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if custom_lint not present in the option file, clones "include"',
        () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('if custom_lint not present in the option file, clones "include"',
        () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('if custom_lint is present but empty, clones "include"', () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('has an immutable list of rules', () async {
      final analysisOptions = createAnalysisOptions('''
custom_lint:
  rules: 
  - a
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

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
        () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
  enable_all_lint_rules: false
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs.enableAllLintRules, false);
      expect(configs.rules, includeConfig.rules);
    });

    test(
        'if custom_lint.enable_all_lint_rules is not present, uses value from "include"',
        () async {
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
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs.enableAllLintRules, false);
      expect(configs.rules, {
        'a': const LintOptions.empty(enabled: true),
      });
    });

    const testPackageName = 'test_package_with_config';

    test('include config using package: uri', () async {
      final dir = createDir();
      final file = createAnalysisOptions('''
include: package:$testPackageName/analysis_options.yaml
      ''');

      final tempProjectDir = await createTempProject(dir.path, testPackageName);
      await patchPackageConfig(testPackageName, tempProjectDir);
      final configs = await CustomLintConfigs.parse(file);

      expect(configs.rules.containsKey('from_package'), true);
    });

    test('if package: uri is not resolved default to empty', () async {
      const notExistedFileName = 'this-does-not-exist';

      final file = createAnalysisOptions('''
include: package:$testPackageName/$notExistedFileName
      ''');
      final dir = createDir();

      final tempProjectDir = await createTempProject(dir.path, testPackageName);
      await patchPackageConfig(testPackageName, tempProjectDir);
      final configs = await CustomLintConfigs.parse(file);

      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if custom_lint.rules is present, merges with "include"', () async {
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
      final configs = await CustomLintConfigs.parse(analysisOptions);

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
      test('Defaults to empty if yaml fails to parse', () async {
        final configs = await CustomLintConfigs.parse(
          createAnalysisOptions('''
foo:
    bar:
  baz:
'''),
        );
        expect(configs, CustomLintConfigs.empty);
      });
    });
  });
}

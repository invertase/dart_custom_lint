import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:custom_lint/custom_lint.dart';
import 'package:custom_lint/src/plugin_delegate.dart';
import 'package:custom_lint/src/runner.dart';
import 'package:custom_lint/src/server_isolate_channel.dart';
import 'package:custom_lint/src/v2/custom_lint_analyzer_plugin.dart';
import 'package:custom_lint/src/v2/server_to_client_channel.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

Future<void> entrypoint([List<String> args = const []]) async {
  await _CustomLintCommand().run(args);
}

void main([List<String> args = const []]) async {
  await entrypoint(args);
  // TODO figure out why this exit is necessary
  exit(exitCode);
}

class _CustomLintCommand extends CommandRunner<void> {
  _CustomLintCommand()
      : super(
          'custom_lint',
          'Analyzes the project and lists potential issues.',
        ) {
    addCommand(_List());
    argParser.addFlag(
      'watch',
      help: "Watches plugins' sources and perform a hot-reload on change",
      negatable: false,
    );
  }

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.command != null) {
      return super.runCommand(topLevelResults);
    }

    final help = topLevelResults['help'] as bool;
    if (help) {
      return super.runCommand(topLevelResults);
    }

    final watchMode = topLevelResults['watch'] as bool;

    await customLint(workingDirectory: Directory.current, watchMode: watchMode);
  }
}

class _List extends Command<void> {
  @override
  String get description =>
      'Obtains a machine readable list of lints for the current project.';

  @override
  String get name => 'list';

  @override
  Future<void>? run() async {
    final pubspec = _tryParsePubspec();
    if (pubspec == null) {
      exitCode = 1;
      stderr.writeln('Failed to read pubspec.yaml in directory.');
      return;
    }
    final packageConfig = _tryParsePackageConfig();
    if (packageConfig == null) {
      exitCode = 1;
      stderr.writeln(
        'Failed to read .dart_tool/package_config.json.\n'
        'Did you forget to run `pub get`?',
      );
      return;
    }

    final tempExampleDir = _writeTemporaryExampleProject(
      pubspec,
      packageConfig,
    );

    final channel = ServerIsolateChannel();
    await CustomLintServer.run(
      sendPort: channel.receivePort.sendPort,
      watchMode: false,
      // In the CLI, only show user defined lints. Errors & logs will be
      // rendered separately
      includeBuiltInLints: false,
      delegate: CommandCustomLintDelegate(),
      (customLintServer) async {
        final runner = CustomLintRunner(
          customLintServer,
          tempExampleDir,
          channel,
        );

        try {
          await runner.initialize;
          final lintRules = await runner.getLintRules();

          stdout.writeln(jsonEncode(lintRules));
        } catch (err, stack) {
          stderr.writeln('$err\n$stack');
          exitCode = 1;
        } finally {
          await Future.wait([
            tempExampleDir.delete(recursive: true),
            runner.close(),
          ]);
        }
      },
    );
  }

  Directory _writeTemporaryExampleProject(
    Pubspec pluginPubspec,
    PackageConfig packageConfig,
  ) {
    final dir = Directory.systemTemp.createTempSync();
    final pubspecFile = File(join(dir.path, 'pubspec.yaml'));

    const tmpName = '__example';

    pubspecFile.writeAsString('''
name: $tmpName
version: 0.0.1
publish_to: none
environment:
  sdk: '>=2.16.0 <3.0.0'

dev_dependencies:
  custom_lint:
  ${pluginPubspec.name}:
    path: ${Directory.current.path}
''');

    final currentPackage = packageConfig.packageOf(Directory.current.uri)!;

    writePackageConfigSync(dir, [
      ...packageConfig.packages,
      Package(
        tmpName,
        dir.uri,
        languageVersion: currentPackage.languageVersion,
      ),
    ]);

    return dir;
  }
}

Pubspec? _tryParsePubspec() {
  try {
    final pubspecFile = File('pubspec.yaml');
    final pubspecYaml = pubspecFile.readAsStringSync();
    return Pubspec.parse(pubspecYaml, sourceUrl: pubspecFile.uri);
  } catch (err) {
    return null;
  }
}

PackageConfig? _tryParsePackageConfig() {
  try {
    final packageConfigFile = File(
      join('.dart_tool', 'package_config.json'),
    ).absolute;
    final packageConfigJson = packageConfigFile.readAsStringSync();
    return PackageConfig.parseString(packageConfigJson, packageConfigFile.uri);
  } catch (err) {
    stderr.write('Err $err');
    return null;
  }
}

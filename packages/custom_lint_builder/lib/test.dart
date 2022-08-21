import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:ansi_styles/ansi_styles.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:path/path.dart';
import 'package:watcher/watcher.dart';

import 'custom_lint_builder.dart';

/// Configuration that is reloaded based on
class PluginConfiguration {
  /// Configuration for the plugin
  PluginConfiguration(
      {required List<String> paths,
      required String basePath,
      required this.plugin,
      this.verbose = false})
      : paths = paths.map(canonicalize).toSet(),
        basePath = canonicalize(basePath);

  /// The paths to the files to analyze.
  final Set<String> paths;

  /// The base path for the project to analyze.
  final String basePath;

  /// The linter plugin to run.
  final PluginBase plugin;

  /// Whether to print verbose output.
  final bool verbose;

  /// To String
  @override
  String toString() =>
      'PluginConfiguration(paths: $paths, basePath: $basePath, plugin: $plugin, verbose: $verbose)';
}

/// Runs a custom lint plugin on a set of files with hot-reload support
///
/// This allows faster iteration because we don't reanalyze the source files when only the linter has changed.
Future<void> runPlugin(PluginConfiguration Function() configuration) async {
  final resolvedUnits = <String, ResolvedUnitResult>{};
  final watchers = <String, FileWatcher>{};
  final watcherStream = <String, StreamSubscription>{};
  PluginConfiguration? currentConfiguration;
  late AnalysisContextCollection analyzerContext;
  late Completer<void> reloading;

  Future<void> lint(String path) async {
    const indent = '  ';
    try {
      stdout.writeln(AnsiStyles.blue('Rerunning lint analysis for $path'));
      final unit = resolvedUnits[path]!;
      await runZoned(
        () async {
          try {
            await for (final lint
                in currentConfiguration!.plugin.getLints(unit)) {
              stdout.writeln(AnsiStyles.blue(
                  '${indent}Lint: ${lint.code} "${lint.message}" at location ${lint.location.startLine}:${lint.location.startColumn}'));
            }
          } catch (e, st) {
            stdout.writeln(AnsiStyles.red('${indent}Exception: $e\n$st\n'));
          }
        },
        zoneSpecification: ZoneSpecification(
          print: (self, delegate, zone, line) {
            stdout.writeln(AnsiStyles.green('${indent}Print: $line'));
          },
        ),
      );
    } catch (e, st) {
      stdout.writeln(AnsiStyles.red('${indent}Exception: $e\n$st\n\n'));
    }
    stdout.writeln('\n');
  }

  Future<bool> analyzeFile(String path) async {
    try {
      stdout.write(AnsiStyles.white('Analyzing file $path... '));
      final context = analyzerContext.contextFor(path);
      final result = await context.currentSession.getResolvedUnit(path);
      if (result is ResolvedUnitResult) {
        resolvedUnits[path] = result;
        stdout.writeln(AnsiStyles.white('Done'));
        return true;
      } else {
        stdout.writeln(AnsiStyles.red('Error got: $result'));
      }
    } catch (e, st) {
      stdout.writeln(AnsiStyles.red('Error $e\n$st'));
    }
    return false;
  }

  Future<void> watchFile(String path) async {
    try {
      watchers[path] = FileWatcher(path);
      var lastModified = DateTime.now();
      watcherStream[path] = watchers[path]!.events.listen((e) async {
        final time = DateTime.now();
        if (e.type == ChangeType.MODIFY &&
            // debounce due to dartfmt
            time.difference(lastModified).abs() >
                const Duration(seconds: 1, milliseconds: 500)) {
          lastModified = time;
          analyzerContext = AnalysisContextCollection(
              includedPaths: [currentConfiguration!.basePath]);
          stdout.writeln(AnsiStyles.white('Modified test file at $path'));
          final analyzed = await analyzeFile(path);

          if (analyzed) {
            await lint(path);
          } else {
            stdout.writeln(AnsiStyles.red('Error analyzing file $path'));
          }
        }
      });
    } catch (e, st) {
      stdout.writeln(AnsiStyles.red('Error watching file $path $e\n$st'));
    }
    final analyzed = await analyzeFile(path);
    if (analyzed) {
      await lint(path);
    } else if (!analyzed) {
      stdout.writeln(AnsiStyles.red('Error analyzing file $path'));
    }
  }

  Future<void> reloadConfiguration() async {
    // Handles reanalyzing if the basePath / paths have changed
    reloading = Completer<void>();
    final newConfiguration = configuration();
    if (currentConfiguration == null ||
        currentConfiguration!.basePath != newConfiguration.basePath) {
      final dir = Directory(newConfiguration.basePath);
      if (!dir.existsSync()) {
        stdout.writeln(AnsiStyles.red(
            'Base path ${newConfiguration.basePath} does not exist.'));
      } else {
        currentConfiguration = newConfiguration;
        stdout.writeln(AnsiStyles.white(
            'Analyzing files based on new basePath ${currentConfiguration!.basePath}.\n'));
        analyzerContext = AnalysisContextCollection(
            includedPaths: [currentConfiguration!.basePath]);
        resolvedUnits.clear();
        for (final path in newConfiguration.paths) {
          await watchFile(path);
        }
        reloading.complete();
        return;
      }
    } else if (!newConfiguration.paths.matches(currentConfiguration!.paths)) {
      currentConfiguration = newConfiguration;
      final oldUnits = Map.of(resolvedUnits);
      resolvedUnits.clear();

      analyzerContext = AnalysisContextCollection(
          includedPaths: [currentConfiguration!.basePath]);
      // Only reanalyze new paths
      await Future.wait(newConfiguration.paths.map((p) async {
        if (!oldUnits.containsKey(p)) {
          await watchFile(p);
        } else {
          resolvedUnits[p] = oldUnits[p]!;
        }
      }));
    }
    currentConfiguration = newConfiguration;
    reloading.complete();
  }

  final reloader = await HotReloader.create(onBeforeReload: (info) {
    final path = info.event?.path;
    if (watchers.keys.contains(path == null ? null : canonicalize(path))) {
      // If the file is already being watched, it is a test file
      // and the file watcher will handle the reanalysis & linting, no need for reloading linter code
      return false;
    }
    if (!reloading.isCompleted) {
      stdout.writeln(AnsiStyles.red(
          'Got another reload in the middle of reanalyzing due to configuration change!'));
    }
    reloadConfiguration();
    stdout.write(AnsiStyles.white('Linter changed, reloading linter code... '));
    return true;
  }, onAfterReload: (_) async {
    stdout.writeln(AnsiStyles.white('Done'));
    if (!reloading.isCompleted) {
      await reloading.future;
    }
    for (final path in resolvedUnits.keys) {
      await lint(path);
    }
  });
  stdout.writeln(
      '\nCustom lint runner commands:\n${AnsiStyles.white.bold('r')} Hot reload\n\n');
  await reloadConfiguration();
  stdin.listen((d) {
    if (utf8.decode(d).contains('r\n')) {
      stdout.writeln('Reloading...');
      reloader.reloadCode();
    }
  });
}

extension on Set<String> {
  bool matches(Set<String> other) {
    if (length != other.length) {
      return false;
    }
    return containsAll(other);
  }
}

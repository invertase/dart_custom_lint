import 'package:analyzer/file_system/file_system.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../custom_lint_core.dart';

/// Configurations representing the custom_lint metadata in the project's `analysis_options.yaml`.
@immutable
class CustomLintConfigs {
  /// Configurations representing the custom_lint metadata in the project's `analysis_options.yaml`.
  @internal
  const CustomLintConfigs({
    required this.enableAllLintRules,
    required this.rules,
  });

  /// Decode a [CustomLintConfigs] from a file.
  @internal
  factory CustomLintConfigs.parse(
    File? analysisOptionsFile,
    PackageConfig packageConfig,
  ) {
    if (analysisOptionsFile == null || !analysisOptionsFile.exists) {
      return CustomLintConfigs.empty;
    }

    final optionsString = analysisOptionsFile.readAsStringSync();
    Object? yaml;
    try {
      yaml = loadYaml(optionsString) as Object?;
    } catch (err) {
      return CustomLintConfigs.empty;
    }
    if (yaml is! Map) return CustomLintConfigs.empty;

    final include = yaml['include'] as Object?;
    var includedOptions = CustomLintConfigs.empty;
    if (include is String) {
      final includeUri = Uri.parse(include);
      String? includeAbsolutePath;

      if (includeUri.scheme == 'package') {
        final packageUri = packageConfig.resolve(includeUri);
        includeAbsolutePath = packageUri?.toFilePath();
      } else {
        includeAbsolutePath = normalize(
          absolute(
            analysisOptionsFile.parent.path,
            includeUri.toFilePath(),
          ),
        );
      }

      if (includeAbsolutePath != null) {
        includedOptions = CustomLintConfigs.parse(
          analysisOptionsFile.provider.getFile(includeAbsolutePath),
          packageConfig,
        );
      }
    }

    final customLint = yaml['custom_lint'] as Object?;
    if (customLint is! Map) return includedOptions;

    final rules = <String, LintOptions>{...includedOptions.rules};
    final enableAllLintRulesYaml = customLint['enable_all_lint_rules'];
    final enableAllLintRules = enableAllLintRulesYaml is bool?
        ? enableAllLintRulesYaml ?? includedOptions.enableAllLintRules
        : null;

    final rulesYaml = customLint['rules'] as Object?;

    if (rulesYaml is List) {
      // Supports:
      // rules:
      // - prefer_lint
      // - map: false
      // - map2:
      //   length: 42

      for (final item in rulesYaml) {
        if (item is String) {
          rules[item] = const LintOptions.empty(enabled: true);
        } else if (item is Map) {
          final key = item.keys.first as String;
          final value = item.values.first;
          final enabled = value is bool? ? value : null;

          rules[key] = LintOptions.fromYaml(
            Map<String, Object?>.fromEntries(
              item.entries
                  .skip(1)
                  .map((e) => MapEntry(e.key as String, e.value)),
            ),
            enabled: enabled ?? true,
          );
        }
      }
    }

    return CustomLintConfigs(
      enableAllLintRules: enableAllLintRules,
      rules: UnmodifiableMapView(rules),
    );
  }

  /// An empty custom_lint configuration
  @internal
  static const empty = CustomLintConfigs(
    enableAllLintRules: null,
    rules: {},
  );

  /// A field representing whether to enable/disable lint rules that are not
  /// listed in:
  ///
  /// ```yaml
  /// custom_lint:
  ///   rules:
  ///   ...
  /// ```
  ///
  /// If `null`, the default behavior will be deferred to [LintRule.enabledByDefault].
  final bool? enableAllLintRules;

  /// A list of lints that are explicitly enabled/disabled in the config file,
  /// along with extra per-lint configuration.
  final Map<String, LintOptions> rules;

  @override
  bool operator ==(Object other) =>
      other is CustomLintConfigs &&
      other.enableAllLintRules == enableAllLintRules &&
      const MapEquality<String, LintOptions>().equals(other.rules, rules);

  @override
  int get hashCode => Object.hash(
        enableAllLintRules,
        const MapEquality<String, LintOptions>().hash(rules),
      );
}

/// Option information for a specific [LintRule].
@immutable
class LintOptions {
  /// Creates a [LintOptions] from YAML.
  @internal
  const LintOptions.fromYaml(Map<String, Object?> yaml, {required this.enabled})
      : json = yaml;

  /// Options with no [json]
  @internal
  const LintOptions.empty({required this.enabled}) : json = const {};

  /// Whether the configuration enables/disables the lint rule.
  final bool enabled;

  /// Extra configurations for a [LintRule].
  final Map<String, Object?> json;

  @override
  bool operator ==(Object other) =>
      other is LintOptions &&
      other.enabled == enabled &&
      const MapEquality<String, Object?>().equals(other.json, json);

  @override
  int get hashCode => Object.hash(
        enabled,
        const MapEquality<String, Object?>().hash(json),
      );
}

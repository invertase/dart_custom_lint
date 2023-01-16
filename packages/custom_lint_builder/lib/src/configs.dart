import 'dart:collection';

import 'package:analyzer/file_system/file_system.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import 'lint_rule.dart';

@internal
const defaultEnableAllLintRules = true;

class CustomLintConfigs {
  CustomLintConfigs._({
    required bool? enableAllLintRules,
    required Map<String, LintOptions> rules,
  })  : _enableAllLintRules = enableAllLintRules,
        _rules = rules;
  @internal
  static final empty = CustomLintConfigs._(
    enableAllLintRules: null,
    rules: {},
  );

  @internal
  // ignore: prefer_constructors_over_static_methods
  static CustomLintConfigs parse(File? analysisOptionsFile) {
    if (analysisOptionsFile == null || !analysisOptionsFile.exists) {
      return CustomLintConfigs.empty;
    }

    final optionsString = analysisOptionsFile.readAsStringSync();
    final yaml = loadYaml(optionsString) as Object?;
    if (yaml is! Map) return CustomLintConfigs.empty;

    final include = yaml['include'] as Object?;
    CustomLintConfigs? includedOptions;
    if (include is String) {
      final includeAbsolutePath = absolute(
        analysisOptionsFile.parent.path,
        include,
      );
      includedOptions = CustomLintConfigs.parse(
        analysisOptionsFile.provider.getFile(includeAbsolutePath),
      );
    }

    final customLint = yaml['custom_lint'] as Object?;
    if (customLint is! Map) return CustomLintConfigs.empty;

    final enableAllLintRulesYaml = customLint['enable_all_lint_rules'];
    final enableAllLintRules = enableAllLintRulesYaml is bool?
        ? enableAllLintRulesYaml ?? includedOptions?._enableAllLintRules
        : null;

    final areLintsEnabledByDefault =
        enableAllLintRules ?? defaultEnableAllLintRules;

    final rulesYaml = customLint['rules'] as Object?;
    final rules = <String, LintOptions>{
      ...?includedOptions?._rules,
    };

    if (rulesYaml is List) {
      // Supports:
      // rules:
      // - prefer_lint
      // - map: false
      // - map2:
      //   length: 42

      for (final item in rulesYaml) {
        if (item is String) {
          rules[item] = LintOptions.empty(enabled: areLintsEnabledByDefault);
        } else if (item is Map) {
          final key = item.keys.first as String;
          final value = item.values.first;
          final enabled = value is bool? ? value : null;

          rules[key] = LintOptions.fromYaml(
            Map<String, Object?>.fromEntries(item.entries
                .skip(1)
                .map((e) => MapEntry(e.key as String, e.value))),
            enabled: enabled ?? areLintsEnabledByDefault,
          );
        }
      }
    }

    return CustomLintConfigs._(
      enableAllLintRules: enableAllLintRules,
      rules: UnmodifiableMapView(rules),
    );
  }

  final bool? _enableAllLintRules;
  final Map<String, LintOptions> _rules;

  LintOptions optionsForFile(LintRule lintRule) {
    return _rules[lintRule.code.name] ??
        LintOptions.empty(
          enabled: _enableAllLintRules ?? defaultEnableAllLintRules,
        );
  }

  bool isLintEnabled(String name) {
    return _rules[name]?.enabled ??
        _enableAllLintRules ??
        defaultEnableAllLintRules;
  }
}

class LintOptions {
  @internal
  const LintOptions.fromYaml(
    Map<String, Object?> yaml, {
    required this.enabled,
  }) : json = yaml;

  @internal
  const LintOptions.empty({required this.enabled}) : json = const {};

  final Map<String, Object?> json;

  final bool enabled;
}

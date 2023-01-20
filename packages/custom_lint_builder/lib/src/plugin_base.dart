import 'assist.dart';
import 'configs.dart';
import 'lint_rule.dart';

/// A base class for custom analyzer plugins
///
/// If a print is emitted or an exception is uncaught,
abstract class PluginBase {
  /// Returns a list of warning/infos/errors for a Dart file.
  List<LintRule> getLintRules(CustomLintConfigs configs);

  /// Obtains the list of assists created by this plugin.
  List<Assist> getAssists() => const [];
}

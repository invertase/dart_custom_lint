import 'dart:async';

import 'package:meta/meta.dart';

import 'assist.dart';
import 'configs.dart';
import 'lint_rule.dart';

/// Runs a list of "postRun" callbacks.
///
/// Errors are caught to ensure all callbacks are executed.
@internal
void runPostRunCallbacks(List<void Function()> postRunCallbacks) {
  for (final postCallback in postRunCallbacks) {
    try {
      postCallback();
    } catch (err, stack) {
      Zone.current.handleUncaughtError(err, stack);
      // All postCallbacks should execute even if one throw
    }
  }
}

/// A base class for custom analyzer plugins
///
/// If a print is emitted or an exception is uncaught,
abstract class PluginBase {
  /// Returns a list of warning/infos/errors for a Dart file.
  List<LintRule> getLintRules(CustomLintConfigs configs);

  /// Obtains the list of assists created by this plugin.
  List<Assist> getAssists() => const [];
}

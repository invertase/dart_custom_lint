import 'package:meta/meta.dart';

import 'lint_rule.dart';
import 'resolver.dart';

/// A base-class for runnable objects.
abstract class Runnable<RunArgs> {
  /// Initializes the runnable object.
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
  );

  /// Runs the runnable object.
  @internal
  void callRun(
    CustomLintResolver resolver,
    CustomLintContext context,
    RunArgs args,
  );
}

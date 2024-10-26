import 'package:meta/meta.dart';

import 'lint_rule.dart';
import 'resolver.dart';

abstract class Runnable<RunArgs> {
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
  );

  @internal
  void callRun(
    CustomLintResolver resolver,
    CustomLintContext context,
    RunArgs args,
  );
}

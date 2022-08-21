import 'package:custom_lint_builder/test.dart';

import 'custom_lint.dart';

void main() {
  runPlugin(
    () => PluginConfiguration(
      paths: ['../lib/main.dart'],
      basePath: '../',
      plugin: RiverpodLint(),
    ),
  );
}

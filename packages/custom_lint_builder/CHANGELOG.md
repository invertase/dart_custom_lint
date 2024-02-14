## 0.6.1 - 2024-02-14

- `custom_lint_core` upgraded to `0.6.1`

## 0.6.0 - 2024-02-04

- Bumped minimum Dart SDK to 3.0.0
- Added support for `--fix`

## 0.5.14 - 2024-02-03

- `custom_lint_core` upgraded to `0.5.14`

## 0.5.13 - 2024-02-03

- `custom_lint_core` upgraded to `0.5.13`

## 0.5.12 - 2024-02-02

- `custom_lint_core` upgraded to `0.5.12`

## 0.5.11 - 2024-01-27

- Added support for `analysis_options.yaml` that are nt at the root of the project (thanks to @mrgnhnt96)

## 0.5.10 - 2024-01-26

- `custom_lint_core` upgraded to `0.5.10`

## 0.5.9 - 2024-01-26

- `custom_lint_core` upgraded to `0.5.9`

## 0.5.8 - 2024-01-09

- `// ignore` comments now correctly respect indentation when they are inserted (thanks to @PiotrRogulski)

## 0.5.7 - 2023-11-20

- `custom_lint` upgraded to `0.5.7`
- `custom_lint_core` upgraded to `0.5.7`

## 0.5.6 - 2023-10-30

- `custom_lint` upgraded to `0.5.6`
- `custom_lint_core` upgraded to `0.5.6`

## 0.5.5 - 2023-10-26

- `custom_lint` upgraded to `0.5.5`
- `custom_lint_core` upgraded to `0.5.5`

## 0.5.4 - 2023-10-20

- `custom_lint` upgraded to `0.5.4`
- `custom_lint_core` upgraded to `0.5.4`

## 0.5.3 - 2023-08-29

- `custom_lint` upgraded to `0.5.3`
- `custom_lint_core` upgraded to `0.5.3`

## 0.5.2 - 2023-08-16

- Support both analyzer 5.12.0 and 6.0.0 at the same time.
- Attempt at fixing the windows crash

## 0.5.0 - 2023-06-21

- `custom_lint` upgraded to `0.5.0`
- `custom_lint_core` upgraded to `0.5.0`

## 0.4.0 - 2023-05-12

- Report uncaught exceptions inside `context.addPostRunCallback`
- Added support for analyzer 5.12.0

## 0.3.4 - 2023-04-19

- `custom_lint` upgraded to `0.3.4`
- `custom_lint_core` upgraded to `0.3.4`

## 0.3.3 - 2023-04-06

- Upgraded `analyzer` to `>=5.7.0 <5.11.0`
- `LintRuleNodeRegistry` and other AstVisitor-like now are based off `GeneralizingAstVisitor` instead of `GeneralizingAstVisitor`
- Exposes the Pubspec in CustomLintContext

## 0.3.2 - 2023-03-09

- `custom_lint` upgraded to `0.3.2`
- `custom_lint_core` upgraded to `0.3.2`

## 0.3.1 - 2023-03-09

- `custom_lint_core` upgraded to `0.3.1`

## 0.3.0 - 2023-03-09

- Fix FileSystemException thrown when deleting a file
- Update analyzer to >=5.7.0 <5.8.0
- Upgrade dependencies

## 0.2.12

Upgrade custom_lint

## 0.2.11

- Fixes `LintCode.url` no-longer showing-up in the IDE
- Fix quick-fixes not working on the last offset of an analysis error
- Bump minimum Dart SDK to `sdk: ">=2.19.0 <3.0.0"`

## 0.2.10

Fix `filesToAnalyze` only working on the file name instead of the file path.

## 0.2.9

Fix `TypeChecker.fromPackage` not always return `true` when it should

## 0.2.8

Fix exception thrown by `TypeChecker.isExactlyType` if `DartType.element` is `null`.

## 0.2.7

Extract `LintRule` and similar other utilities to a separate package: `custom_lint_core`.  
`custom_lint_builder` re-exports `custom_lint_core`, so the utilities are still available.

## 0.2.6

Fix infinite loop on InconsistentAnalysisException

## 0.2.5

- Fix custom_lint not correctly killing sub-processes when the IDE stops custom_lint.
- Export incorrectly unexported `matcherNormalizedPrioritizedSourceChangeSnapshot`

## 0.2.4

- Added `<DartLintRule/DartFix/DartAssist>.testRun` & `testAnalyzeAndRun` methods, which
  enables programmatically running a lint/assist/fix against a Dart file.
- Added `matcherNormalizedPrioritizedSourceChangeSnapshot` test matcher, which
  allows checking that a list of file edits matches against a JSON snapshot of the changes.

## 0.2.3

Fixes InconsistentAnalysisException

## 0.2.2

Fixes an exception thrown when a project contains images.

## 0.2.1

Add `TypeChecker.every` and `TypeChecker.package`

## 0.2.0

**Large Breaking change**
This new version introduces large changes to how lints/fixes/assists are defined.  
Long story short, besides the `createPlugin` method, the entire syntax changed.

See the readme, examples, and docs around how to use the new syntax.

The new syntax has multiple benefits:

- It is now possible to enable/disable lints inside the `analysis_options.yaml`
  as followed:

  ```yaml
  # optional
  include: path/to/another/analysis_options.yaml

  custom_lint:
    rules:
      # enable a lint rule
      - my_lint_rule
      # A lint rule that is explicitly disabled
      - another_lint_rule: false
  ```

  Enabling/disabling lints is supported by default with the new syntax. Nothing to do~

- Performance improvement when using a large number of lints.
  The workload of analyzing files is now shared between lints.

- The new syntax makes the code simpler to maintain.
  Before, the `PluginBase.getLints` rapidly ended-up doing too much.
  Now, it is simple to split the implementation in multiple bits

## 0.1.2-dev

Do some internal refactoring as an attempt to fix #60

## 0.1.1

- Fix an issue where plugins were hot-reloaded when the file analyzed changed.
- Optimized analysis such that `PluginBase.getLints()` is theorically not reinvoked
  unless the file analyzed changed.

## 0.1.0

- **Breaking**: The plugin entrypoint has moved.  
  Plugins no-longer should define a `/bin/custom_lint.dart` file.
  Instead they should define a `/lib/<my_package_name>.dart`

- **Breaking**: The plugin entrypoint is modified. Plugins no-longer
  define a "main", but instead define a `createPlugin` function:

  Before:

  ```dart
  // /bin/custom_lint.dart
  void main(List<String> args, SendPort sendPort) {
    startPlugin(sendPort, MyPlugin());
  }
  ```

  After:

  ```dart
  // /lib/<my_package_name.dart
  MyPlugin createPlugin() => MyPlugin();
  ```

- Add assist support.
  Inside your plugins, you can now override `handleGetAssists`:

  ```dart
  import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;

  class MyPlugin extends PluginBase {
    // ...

    Future<analyzer_plugin.EditGetAssistsResult> handleGetAssists(
      ResolvedUnitResult resolvedUnitResult, {
      required int offset,
      required int length,
    }) async {
        // TODO return some assists for the given offset
    }
  }
  ```

## 0.0.16

Fix `expect_lint` not working if the file doesn't contain any lint.

## 0.0.15

- Custom_lint now has a built-in mechanism for testing lints.
  Simply write a file that should contain lints for your plugin.
  Then, using a syntax similar to `// ignore`, write a `// expect_lint: code`
  in the line before your lint:

  ```dart
  // expect_lint: riverpod_final_provider
  var provider = Provider(...);
  ```

  When doing this, there are two possible cases:

  - The line after the `expect_lint` correctly contains the expected lint.  
    In that case, the lint is ignored (similarly to if we used `// ignore`)
  - The next line does **not** contain the lint.
    In that case, the `expect_lint` comment will have an error.

  This allows testing your plugins by simply running `custom_lint` on your test/example folder.
  Then, if any expected lint is missing, the command will fail. But if your plugin correctly
  emits the lint, the command will succeed.

- Upgrade analyzer/analzer_plugin

## 0.0.14

- Fix custom_lint not working in the IDE

## 0.0.13

- Add debugger and hot-reload support (Thanks to @TimWhiting)
- Correctly respect `exclude` obtains from the analysis_options.yaml
- Fix `dart analyze` incorrectly failing due to showing the "plugin is starting" lint.

## 0.0.12

Upgrade dependencies

## 0.0.11

Upgrade dependencies

## 0.0.10

- Upgrade Riverpod to 2.0.0
- Fix deprecation errors with analyzer

## 0.0.9

- Lint fixes can now be used when placing the cursor on the last character of a lint
- improve pub score

## 0.0.8

Allow lints to emit fixes

## 0.0.7

Fix a bug where the custom_lint command line may not list all lints

## 0.0.6

feat!: getLints now is expected to return a `Stream<Lint>` instead of `Iterable<Lint>`

fix: a bug where the lints shown by the IDE could get out of sync with the actual content of the file

## 0.0.4

- Fixed a bug where the command line could show IDE-only meant for debugging

## 0.0.3

PluginBase.getLints now receive a `ResolvedUnitResult` instead of a `LibraryElement`.

## 0.0.2

- Compilation errors are now visible within the `pubspec.yaml` of applications
  that are using the plugin.

- Plugins that are currently loading are now highlighted inside the `pubspec.yaml`
  of applications that are using the plugin.

- If a plugin throws when trying to analyze a Dart file, the IDE will now
  show the exception at the top of the analyzed file.

- Compilation errors, exceptions and prints are now accessible within
  a log file (`custom_lint.log`) inside applications using the plugin.

## 0.0.1

Initial release

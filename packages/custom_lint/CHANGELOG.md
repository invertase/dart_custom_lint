## 0.7.6 - 2025-07-18

Fix custom_lint not working on up-to-date Dart

## 0.7.5 - 2025-02-27

Fix inconsistent version

## 0.7.4 - 2025-02-27

- Upgrade Freezed to 3.0
- Support Dart workspaces (thanks to @Rexios80)
- Suppport analyzer_plugin 0.13.0 (thanks to @Rexios80)
- Support custom hosted dependencies (thansk to @MobiliteDev)

## 0.7.3 - 2025-02-08

- Bump analyzer_plugin

## 0.7.2 - 2025-01-29

- Fix Android Studio/InteliJ (thanks to @EricSchlichting)

## 0.7.1 - 2025-01-08

- Support analyzer 7.0.0

## 0.7.0 - 2024-10-27

- `custom_lint --fix` and the generated "Fix all <code>" assists
  now correctly handle imports.
- Now supports a broad number of analyzer version.

## 0.6.10 - 2024-10-10

- Support installing custom_lint plugins in `dependencies:` instead of `dev_dependencies` (thanks to @dickermoshe).

## 0.6.9 - 2024-10-09

- `custom_lint_core` upgraded to `0.6.9`

## 0.6.8 - 2024-10-08

- Fix CI
- Fix custom_lint not warning non-Dart files when necessary.
- Custom_lint no-longer tries to analyze projects that lack a `.dart_tool/package_config.json`

## 0.6.7 - 2024-09-08

- Removed offline package resolution for the analyzer plugin.
  The logic seemed broken at times, so removing it should make custom_lint more stable.

## 0.6.6 - 2024-09-08

- Fixed an error in the CLI when Flutter generates code under `.dart_tool/` or has dependencies on iOS libraries (thanks to @Kurogoma4D)

## 0.6.5 - 2024-08-15

- Upgraded to analyzer ^6.6.0.
  This is a quick fix to unblock the stable Flutter channel.
  A more robust fix will come later.
- Fixed a bug where isSuperTypeOf throws if the element is null (thanks to @charlescyt)

## 0.6.4 - 2024-03-16

- Improve error message to attempt debugging a certain bug

## 0.6.3 - 2024-03-16

- Fixed Unimplemented error when running `pub get`.
- Hot-reload and debug mode is now disabled by default.

## 0.6.2 - 2024-02-19

- `custom_lint --format json` no-longer outputs non-JSON logs (thanks to @kzrnm)
- Upgrade analyzer to support 6.4.0
- Fix null exception when using `TypeChecker.isSuperTypeOf` (thanks to @charlescyt)

## 0.6.0 - 2024-02-04

- Added support for `--fix`

## 0.5.11 - 2024-01-27

- Added support for `analysis_options.yaml` that are nt at the root of the project (thanks to @mrgnhnt96)

## 0.5.8 - 2024-01-09

- `// ignore` comments now correctly respect indentation when they are inserted (thanks to @PiotrRogulski)

## 0.5.7 - 2023-11-20

- Support JSON output format via CLI parameter `--format json|default` (thanks to @kuhnroyal)

## 0.5.6 - 2023-10-30

Optimized logic for finding an unused VM_service port.

## 0.5.5 - 2023-10-26

- Support `hotreloader` 4.0.0

## 0.5.4 - 2023-10-20

- Sort lints by severity in the command line (thanks to @kuhnroyal)
- Fix watch mode not quitting with `q` (thanks to @kuhnroyal)
- Improve the command line's output (thanks to @kuhnroyal)
- Update uuid to 4.0.0
- Fixed a port leak
- Fix connection issues on Docker/windows (thanks to @hamsbrar)

## 0.5.3 - 2023-08-29

- The command line now supports ignoring warnings/infos with `--no-fatal-warnings`/`--no-fatal-infos` (thanks to @yamarkz)

## 0.5.2 - 2023-08-16

- Support both analyzer 5.12.0 and 6.0.0 at the same time.
- Attempt at fixing the windows crash

## 0.5.1 - 2023-08-03

Support analyzer v6

## 0.5.0 - 2023-06-21

- Now resolves packages using `pub get` if custom_lint failed to resolve packages offline.
  This should reduce the likelyness of a version conflict in mono-repositories.
  The conflict may still happen if two projects in a mono-repo use incompatible
  constraints. Like:
  ```yaml
  name: foo
  dependencies:
    package: ^1.0.0
  ```
  ```yaml
  name: bar
  dependencies:
    package: ^2.0.0
  ```
- The command line now shows the lints' severity (thanks to @praxder)
- Now requires Dart 3.0.0

## 0.4.0 - 2023-05-12

- Report uncaught exceptions inside `context.addPostRunCallback`
- Added support for analyzer 5.12.0

## 0.3.4 - 2023-04-19

- custom_lint now automatically generate quick-fixes for "ignore for line/file".
- Update the socket communication logic to avoid possible problem is the message
  contains a \n.
- fixes custom_lint on windows

## 0.3.3 - 2023-04-06

- Reduce the likelyness of a dependency version conflict.
- Fix `dart analyze` crashing on large projects in the CI due to custom_lint
  incorrectly trying to run plugins in debug mode.
- Fix the `custom_lint` command line never terminating in some cases where plugins
  fail to start (thanks to @kuhnroyal).
- Upgraded `analyzer` to `>=5.7.0 <5.11.0`
- `LintRuleNodeRegistry` and other AstVisitor-like now are based off `GeneralizingAstVisitor` instead of `GeneralizingAstVisitor`
- Upgraded `cli_util` to `^0.4.0`
- The command line no-longer throws if ran on an empty project or a project with
  no plugins enabled
- Exposes the Pubspec in CustomLintContext

## 0.3.2 - 2023-03-09

- Revert "Fixed an issue that caused a "Port already in use" error when
  trying to start custom_lint".
  This had the opposite effect of what's expected.

## 0.3.0 - 2023-03-09

- Update analyzer to >=5.7.0 <5.8.0
- Fixed an issue that caused a "Port already in use" error when trying to
  start custom_lint

## 0.2.12

Move json_serializable to dev dependencies

## 0.2.11

- Improved the error message when there is a version conflict in mono-repos (thanks to @@adsonpleal)
- Bump minimum Dart SDK to `sdk: ">=2.19.0 <3.0.0"`

## 0.2.5

Fix custom_lint not correctly killing sub-processes when the IDE stops custom_lint.

## 0.2.2

Fixes an exception thrown when a project contains images.

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

- Fix custom_lint plugins not working in release mode and when using git dependencies (thanks to @TimWhiting)
- Fix command line exit code not being set properly (thansk to @andrzejchm)

## 0.0.11

Fix custom_lint not showing in the IDE

## 0.0.10+1

Update docs

## 0.0.10

- Upgrade Riverpod to 2.0.0
- Fix deprecation errors with analyzer

## 0.0.9+1

Update description and readme

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

## 0.0.5

Fixed error reporting if a custom_lint plugin throws but the exception comes
from a package instead of the plugin itself.

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

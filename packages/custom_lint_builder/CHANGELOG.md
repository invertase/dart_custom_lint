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

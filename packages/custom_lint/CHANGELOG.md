## [Unreleased patch]

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

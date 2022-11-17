## [Unreleased]

- Add debugger and hot-reload support (Thanks to @TimWhiting)
- Correctly respect `exclude` obtains from the analysis_options.yaml

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

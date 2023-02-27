## Unreleased patch

Bump minimum Dart SDK to `sdk: ">=2.19.0 <3.0.0"`

## 0.2.10

Update `fileToAnalyze` from `*.dart` to `**.dart` to match the `fileToAnalyze` fix in `custom_lint_builder`

## 0.2.9

Fix `TypeChecker.fromPackage` not always return `true` when it should

## 0.2.8

Fix exception thrown by `TypeChecker.isExactlyType` if `DartType.element` is `null`.

## 0.2.7

Initial release
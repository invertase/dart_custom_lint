## 0.8.0 - 2025-07-25

Support analyzer 7.5.0

## 0.7.2 - 2025-02-27

Fix inconsistent version

## 0.7.1 - 2025-01-08

- Support analyzer 7.0.0

## 0.7.0 - 2024-10-27

- `custom_lint --fix` and the generated "Fix all <code>" assists
  now correctly handle imports.
- Now supports a broad number of analyzer version.

## 0.6.10 - 2024-10-10

- Added support for `dart:io` imports when using `TypeChecker.fromPackage` (thanks to @oskar-zeinomahmalat-sonarsource)

## 0.6.9 - 2024-10-09

- Support analyzer 0.6.9

## 0.6.5 - 2024-08-15

- Upgraded to analyzer ^6.6.0.
  This is a quick fix to unblock the stable Flutter channel.
  A more robust fix will come later.
- Fixed a bug where isSuperTypeOf throws if the element is null (thanks to @charlescyt)

## 0.6.3 - 2024-03-16

- Parses `debug`/`config` flags

## 0.6.2 - 2024-02-19

- Fix null exception when using `TypeChecker.isSuperTypeOf` (thanks to @charlescyt)

## 0.6.1 - 2024-02-14

- Exported `NodeLintRegistry`

## 0.6.0 - 2024-02-04

- Bumped minimum Dart SDK to 3.0.0
- goldens with diffs now include the priority, ID, selection and file path.
- **breaking**: `encodePrioritizedSourceChanges`/`matcherNormalizedPrioritizedSourceChangeSnapshot`'s `source`
  parameter now takes a `Map<String, String>? sources` instead of `String? source`.
  This enables goldens to handle fixes that emit to a different file.

## 0.5.14 - 2024-02-03

- Improved formatting when specifying `source` on `encodePrioritizedSourceChanges`/`matcherNormalizedPrioritizedSourceChangeSnapshot`

## 0.5.13 - 2024-02-03

- Improved formatting when specifying `source` on `encodePrioritizedSourceChanges`/`matcherNormalizedPrioritizedSourceChangeSnapshot`

## 0.5.12 - 2024-02-02

- Added `encodePrioritizedSourceChanges`, to enable writing a `List<PrioritizedSourceChanges>` to a file
- `matcherNormalizedPrioritizedSourceChangeSnapshot` now optionally
  takes a `String source`. This enables saving to the disk the expected
  result.

## 0.5.11 - 2024-01-27

- `custom_lint` upgraded to `0.5.11`

## 0.5.10 - 2024-01-26

- Fix a bug with `matcherNormalizedPrioritizedSourceChangeSnapshot`

## 0.5.9 - 2024-01-26

- `matcherNormalizedPrioritizedSourceChangeSnapshot` now optionally allows specifying a `JsonEncoder`.

## 0.5.8 - 2024-01-09

Added an optional `customPath` to the various `ChangeReporter` methods (thanks to @laurentschall)

## 0.5.7 - 2023-11-20

- `custom_lint` upgraded to `0.5.7`

## 0.5.6 - 2023-10-30

- `custom_lint` upgraded to `0.5.6`

## 0.5.5 - 2023-10-26

- `custom_lint` upgraded to `0.5.5`

## 0.5.4 - 2023-10-20

- `custom_lint` upgraded to `0.5.4`

## 0.5.3 - 2023-08-29

- `custom_lint` upgraded to `0.5.3`

## 0.5.2 - 2023-08-16

- Support both analyzer 5.12.0 and 6.0.0 at the same time.
- Attempt at fixing the windows crash

## 0.5.1 - 2023-08-03

Support analyzer v6

## 0.5.0 - 2023-06-21

- `custom_lint` upgraded to `0.5.0`

## 0.4.0 - 2023-05-12

- Added support for analyzer 5.12.0

## 0.3.4 - 2023-04-19

- `custom_lint` upgraded to `0.3.4`

## 0.3.3 - 2023-04-06

- Upgraded `analyzer` to `>=5.7.0 <5.11.0`
- `LintRuleNodeRegistry` and other AstVisitor-like now are based off `GeneralizingAstVisitor` instead of `GeneralizingAstVisitor`
- Exposes the Pubspec in CustomLintContext

## 0.3.2 - 2023-03-09

- `custom_lint` upgraded to `0.3.2`

## 0.3.1 - 2023-03-09

Update dependencies

## 0.3.0 - 2023-03-09

- Update analyzer to >=5.7.0 <5.8.0

## 0.2.12

Upgrade custom_lint

## 0.2.11

Bump minimum Dart SDK to `sdk: ">=2.19.0 <3.0.0"`

## 0.2.10

Update `fileToAnalyze` from `*.dart` to `**.dart` to match the `fileToAnalyze` fix in `custom_lint_builder`

## 0.2.9

Fix `TypeChecker.fromPackage` not always return `true` when it should

## 0.2.8

Fix exception thrown by `TypeChecker.isExactlyType` if `DartType.element` is `null`.

## 0.2.7

Initial release

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

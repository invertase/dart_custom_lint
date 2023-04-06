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

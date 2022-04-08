## Add built-in lints for highlighting invalid custom_lint & custom_lint_builder usage

- no `bin/custom_lint.dart` found
- highlight in the IDE on the pubspec.yaml plugins that failed to start

## Add custom_lint_test

For simplifying testing plugins

## Support disabling lint rules inside the analysis_options.yaml

Such as:

```yaml
linter:
  rules:
    require_trailing_commas: false

custom_lint:
  rules:
    riverpod_final_provider: false
```

## Add support for refactors and fixes

Instead of being limited to lints

Bonus point for a `dart run custom_lint --fix`

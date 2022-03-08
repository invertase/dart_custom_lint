potential lint errors:
- no bin found
- threw during start
- failed to connect
- unknown lint rule
- lint rule threw
- CLI executed vs local custom_lint version mismatch


features to have:
- CLI for running lints
- IDE integration
- reactive syntax for source change
- hot reload or hot-restart
- [x] support prints
- [x] built-in error reporting
- handle ignores:
  - `// ignore: lint` 
  - `// ignore_for_file: lint` 
  - `// ignore_for_file: type=lint`
- testable (expect_error?)
- support analysis_options' configs:
  - `import`
  - `exclude`
  - `include`
- custom lint packages can specify default configs (rules enabled or disabled by default)
- unknown configs
- unknown rules


How to deal with mono-repos?
Maybe:
```
packages/
  foo/
    pubspec.yaml
analysis_options.yaml
pubspec.yaml << depends on custom_lint
```
Things to consider:
- a package may not depend on a specific rule
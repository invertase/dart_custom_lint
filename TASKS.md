potential lint errors:

- [ ] no bin found
- [ ] threw during start
- [ ] failed to connect
- [ ] unknown lint rule
- [ ] lint rule threw
- [ ] CLI executed vs local custom_lint version mismatch

features to have:

- [x] IDE integration
- [x] support prints
- [x] built-in error reporting
- [x] hot-restart
- [ ] add built-in linter for providing warnings if a custom lint package is incorrectly setup
- [x] CLI for running lints
- [ ] reactive syntax for source change
- [ ] handle ignores:
  - [ ] `// ignore: lint`
  - [ ] `// ignore_for_file: lint`
  - [ ] `// ignore_for_file: type=lint`
- [ ] testing framework
- [ ] support analysis_options' configs:
  - [ ] `import`
  - [ ] `exclude`
  - [ ] `include`
- [ ] add optional configuration file for changing the entrypoint location & passing options
- [ ] custom lint packages can specify default configs (rules enabled or disabled by default)
- [ ] unknown configs
- [ ] unknown rules

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

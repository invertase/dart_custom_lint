<p align="center">
  <h1>custom_lint_core</h1>
  <span>An package exposing base classes for defining lint rules/fixes/assists.</span>
</p>

<p align="center">
  <a href="https://github.com/invertase/dart_custom_lint/blob/main/LICENSE">License</a>
</p>

## About

`custom_lint_visitor` is a dependency of `custom_lint`, for the sake of supporting
multiple Analyzer versions without causing too many breaking changes.

It exposes various ways to traverse the tree of `AstNode`s using callbacks.

## Versioning

One version of `custom_lint_visitor` is released for every `analyzer` version.

The version `1.0.0+6.7.0` means "Version 1.0.0 of custom_lint_visitor, for analyzer's 6.7.0 version".

Whenever `custom_lint_visitor` is updated, a new version may be published for the same `analyzer` version. Such as `1.0.1+6.7.0`

Depending on `custom_lint_visitor: ^1.0.0` will therefore support
any compatible Analyzer version.
To require a specific analyzer version, specify `analyzer: <your constraint>` explicitly.
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
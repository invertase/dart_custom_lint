<p align="center">
  <h1>custom_lint_core</h1>
  <span>An package exposing base classes for defining lint rules/fixes/assists.</span>
</p>

<p align="center">
  <a href="https://github.com/invertase/dart_custom_lint/blob/main/LICENSE">License</a>
</p>

## About

`custom_lint_core`, a variant of `custom_lint_builder` which exports lint-utilities without
causing custom_lint to consider the dependent as a lint plugin.

As opposed to `custom_lint_builder` , adding `custom_lint_core` as dependency will not flag
a package as a "custom_lint plugin".

See [custom_lint] for more informations

---

<p align="center">
  <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=dart_custom_lint">
    <img width="75px" src="https://static.invertase.io/assets/invertase/invertase-rounded-avatar.png">
  </a>
  <p align="center">
    Built and maintained by <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=dart_custom_lint">Invertase</a>.
  </p>
</p>

[custom_lint]: https://github.com/invertase/dart_custom_lint

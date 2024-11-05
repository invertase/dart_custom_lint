<p align="center">
  <h1>custom_lint_builder</h1>
  <span>An package for defining custom lints.</span>
</p>

<p align="center">
  <a href="https://github.com/invertase/dart_custom_lint/blob/main/LICENSE">License</a>
</p>

## About

`custom_lint_builder` is a package that should be associated with [custom_lint]
for defining custom_lint plugins.


If a package wants to access classes such as `LintRule` or `Assist` but do
not want to make a custom_lint plugin (such as for exposing new utilities
for plugin authors), then use `custom_lint_core` instead.

Using `custom_lint_builder` is reserved to plugin authors. Depending it on it
will tell custom_lint that your package is a plugin, and therefore will try to
run it.

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

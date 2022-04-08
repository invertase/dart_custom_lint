<p align="center">
  <h1>custom_lint</h1>
  <span>Tools for building custom lint rules.</span>
</p>

<p align="center">
  <a href="https://melos.invertase.dev">Documentation</a> &bull; 
  <a href="https://github.com/invertase/custom_lint/blob/main/LICENSE">License</a>
</p>

### About

Lint rules are a powerful way to improve the maintainability of a project.
The more, the merrier!  
But while Dart offers a wide variety of lint rules by default, it cannot
reasonably include every possible lint. For example, Dart does not
include lints related to third-party packages.

Custom_lint fixes that by allowing package authors to write custom lint rules.

Custom_lint is similar to [analyzer_plugin], but goes deeper by trying to
provide a better developer experience.

That includes:

- Use custom_lint's command line to obtain the list of lints in your CI –
  without having to write a command line yourself.
- A simplified project setup.  
  No need to deal with `analyzer` or error handling. Custom_lint takes care of
  that for you, so that you can focus on writing lints.
- Support for hot-restart.  
  Updating the source code of a linter plugin will dynamically restart it,
  without having to restart your IDE/analyzer server
- Support for `print(...)` and exceptions.  
  If your plugin somehow throws or print debug messages, custom_lint
  will generate a log file with the messages/errors.

## Installing

---

<p align="center">
  <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=melos">
    <img width="75px" src="https://static.invertase.io/assets/invertase/invertase-rounded-avatar.png">
  </a>
  <p align="center">
    Built and maintained by <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=melos">Invertase</a>.
  </p>
</p>

[analyzer_plugin]: https://pub.dev/packages/analyzer_plugin

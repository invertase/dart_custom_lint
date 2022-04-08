<p align="center">
  <h1>custom_lint</h1>
  <span>Tools for building custom lint rules.</span>
</p>

<p align="center">
  <a href="https://github.com/invertase/custom_lint/blob/main/LICENSE">License</a>
</p>

## About

Lint rules are a powerful way to improve the maintainability of a project.
The more, the merrier!  
But while Dart offers a wide variety of lint rules by default, it cannot
reasonably include every possible lint. For example, Dart does not
include lints related to third-party packages.

Custom_lint fixes that by allowing package authors to write custom lint rules.

Custom_lint is similar to [analyzer_plugin], but goes deeper by trying to
provide a better developer experience.

That includes:

- A command-line to obtain the list of lints in your CI
  without having to write a command line yourself.
- A simplified project setup.  
  No need to deal with the `analyzer` server or error handling. Custom_lint
  takes care of that for you, so that you can focus on writing lints.
- Support for hot-restart.  
  Updating the source code of a linter plugin will dynamically restart it,
  without having to restart your IDE/analyzer server
- Built-in support for `// ignore:` and `// ignore_for_file:`.
- Support for `print(...)` and exceptions.  
  If your plugin somehow throws or print debug messages, custom_lint
  will generate a log file with the messages/errors.

## Usage

Using custom_lint is split in two parts:

- how to define a custom_lint package
- how users can install our package in their application to see our newly defined lints

### Creating a custom lint package

To create a custom lint, you will need two things:

- updating your `pubspec.yaml` to include `custom_lint_builder` as a dependency:

  ```yaml
  # pubspec.yaml
  name: my_custom_lint_package
  environment:
    sdk: ">=2.16.0 <3.0.0"

  dependencies:
    # we will use analyzer for inspecting Dart files
    analyzer:
    # custom_lint_builder will give us tools for writing lints
    custom_lint_builder:
  ```

- create a `bin/custom_lint.dart` file in your project with the following:

  ```dart
  // This is the entrypoint of our custom linter
  void main(List<String> args, SendPort sendPort) {
    startPlugin(sendPort, _ExampleLint());
  }

  // This class is the one that will analyze Dart files and return lints
  class _ExampleLint extends PluginBase {
    @override
    Iterable<AnalysisError> getLints(LibraryElement library) sync* {
      // A basic lint that shows at the top of the file.
      yield AnalysisError(
        AnalysisErrorSeverity.WARNING,
        AnalysisErrorType.LINT,
        Location(library.source.fullName, 0, 0, 0, 0),
        'This is the description of our custom lint',
        'my_custom_lint_code',
      );
    }
  }
  ```

That's it for defining a custom lint package!

Let's use it in an application now.

### Using our custom lint package in an application

For users to run custom_lint packages, there are a few steps:

- The application must contain an `analysis_options.yaml` with the following:

  ```yaml
  analyzer:
    plugins:
      - custom_lint
  ```

- The application also needs to add `custom_lint` and our package(s) as dev
  dependency in their application:

  ```yaml
  # The pubspec.yaml of an application using our lints
  name: example_app
  environment:
    sdk: ">=2.16.0 <3.0.0"

  dev_dependencies:
    custom_lint:
    my_custom_lint_package:
  ```

That's all!  
After running `pub get` (and possibly restarting their IDE), users should now
see our custom lints in their Dart files:

![screenshot of our custom lints in the IDE](https://raw.githubusercontent.com/invertase/dart_custom_lint/main/resources/lint_showcase.png?token=GHSAT0AAAAAABKV7FKIJQP5CKCH3R74IPAYYSZFGZQ)

#### Obtaining the list of lints in the CI

Unfortunately, running `dart analyze` does not pick up our newly defined lints.  
We need a separate command for this.

To do that, users of our custom lint package can run inside the application the following:

```sh
$ dart run custom_lint
  lib/main.dart:0:0 • This is the description of our custom lint • my_custom_lint_code
```

---

<p align="center">
  <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=dart_custom_lint">
    <img width="75px" src="https://static.invertase.io/assets/invertase/invertase-rounded-avatar.png">
  </a>
  <p align="center">
    Built and maintained by <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=dart_custom_lint">Invertase</a>.
  </p>
</p>

[analyzer_plugin]: https://pub.dev/packages/analyzer_plugin

<p align="center">
  <h1>custom_lint</h1>
  <span>Tools for building custom lint rules.</span>
</p>

<p align="center">
  <a href="https://github.com/invertase/dart_custom_lint/blob/main/LICENSE">License</a>
</p>

## Index

- [Index](#index)
- [Tutorial](#tutorial)
- [About](#about)
- [Usage](#usage)
  - [Creating a custom lint package](#creating-a-custom-lint-package)
  - [Using our custom lint package in an application](#using-our-custom-lint-package-in-an-application)
  - [Obtaining the list of lints in the CI](#obtaining-the-list-of-lints-in-the-ci)
  - [Using the Dart debugger and enabling hot-restart.](#using-the-dart-debugger-and-enabling-hot-restart)
  - [Testing your plugins using expect\_lint](#testing-your-plugins-using-expect_lint)
- [FAQs](#faqs)
  - [Q. How do I get all the classes present in my source code?](#q-how-do-i-get-all-the-classes-present-in-my-source-code)
  - [Q. How do I get all the global variables present in my source code?](#q-how-do-i-get-all-the-global-variables-present-in-my-source-code)
  - [Q. How do I get the path to my currently opened dart file?](#q-how-do-i-get-the-path-to-my-currently-opened-dart-file)
  - [Q. I want to insert code at the end of the file. How can I get the required offset?](#q-i-want-to-insert-code-at-the-end-of-the-file-how-can-i-get-the-required-offset)

## Tutorial

You can read the latest [blog post](https://invertase.link/b18R) or watch the [advanced use case with custom_lint video](https://invertase.link/RNoz).

## About

Lint rules are a powerful way to improve the mainta∏inability of a project.
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
- A simplified project setup:  
  No need to deal with the `analyzer` server or error handling. Custom_lint
  takes care of that for you, so that you can focus on writing lints.
- Debugger support.  
  Inspect your lints using the Dart debugger and place breakpoints.
- Supports hot-reload/hot-restart:  
  Updating the source code of a linter plugin will dynamically restart it,
  without having to restart your IDE/analyzer server.
- Built-in support for `// ignore:` and `// ignore_for_file:`.
- Built-in testing mechanism using `// expect_lint`. See [Testing your plugins using expect_lint](#testing-your-plugins-using-expect_lint)
- Support for `print(...)` and exceptions:  
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
    analyzer_plugin:
    # custom_lint_builder will give us tools for writing lints
    custom_lint_builder:
  ```

- create a `bin/custom_lint.dart` file in your project with the following:

  ```dart
  // This is the entrypoint of our custom linter
  void main(List<String> args, SendPort sendPort) {
    startPlugin(sendPort, _ExampleLinter());
  }

  // This class is the one that will analyze Dart files and return lints
  class _ExampleLinter extends PluginBase {
    @override
    Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
      // A basic lint that shows at the top of the file.
      yield Lint(
        code: 'my_custom_lint_code',
        message: 'This is the description of our custom lint',
        // Where your lint will appear within the Dart file.
        // The following code will make appear at the top of the file (offset 0),
        // and be 10 characters long.
        location: resolvedUnitResult.lintLocationFromOffset(0, length: 10),
      );
    }
  }
  ```

That's it for defining a custom lint package!

Let's now use it in an application.

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

![screenshot of our custom lints in the IDE](https://raw.githubusercontent.com/invertase/dart_custom_lint/main/resources/lint_showcase.png)

### Obtaining the list of lints in the CI

Unfortunately, running `dart analyze` does not pick up our newly defined lints.  
We need a separate command for this.

To do that, users of our custom lint package can run the following inside their terminal:

```sh
$ dart run custom_lint
  lib/main.dart:0:0 • This is the description of our custom lint • my_custom_lint_code
```

If you are working on a Flutter project, run `flutter pub run custom_lint` instead.

### Using the Dart debugger and enabling hot-restart.

To enable hot-restart and use the Dart debugger, we'll want to start plugins in a
slightly different way.

First, create a `tools/custom_lint_debug.dart` file next to `tools/custom_lint.dart`
with the following content:

```dart
import 'dart:io';
import 'package:custom_lint/basic_runner.dart';

void main() {
  await customLint(workingDirectory: Directory.current.parent);
}

```

Now you can run/test the custom lints packages you are using via:

- Starting this main from your IDE (such as clicking on `debug` in VScode).
  This will connect your IDE to the Dart debugger, allowing the usage of breakpoints.

- From the command line with `dart --enable-vm-service path/to/custom_lint_debug.dart`  
  The Dart debugger will not be enabled, but hot-reload still will be enabled.
  Changing the source of your plugin would automatically show the update.

**I have the following error when I run the program in my IDE: `Bad state: VM service not available! You need to run dart with --enable-vm-service.`**

Chances are you didn't start your program in debug mode.  
If using VScode, when starting your program, make sure to click on `debug` not `run`:

![VScode's debug button](https://raw.githubusercontent.com/invertase/dart_custom_lint/main/resources/vscode_debug.jpg)

### Testing your plugins using expect_lint

Custom_lint comes with an official testing mechanism for asserting that your
plugins correctly work.

Testing your plugins is straightforward: Simply write a file that should contain
lints from your plugin (such as the example folder). Then, using a syntax
similar to `// ignore`, write a `// expect_lint: code` in the line before
your lint:

```dart
// expect_lint: riverpod_final_provider
var provider = Provider(...);
```

When doing this, there are two possible cases:

- The line after the `expect_lint` correctly contains the expected lint.  
  In that case, the lint is ignored (similarly to if we used `// ignore`)
- The next line does **not** contain the lint.
  In that case, the `expect_lint` comment will have an error.

This allows testing your plugins by simply running `custom_lint` on your test/example folder.
Then, if any expected lint is missing, the command will fail. But if your plugin correctly
emits the lint, the command will succeed.

---

## FAQs

### Q. How do I get all the classes present in my source code?

There are two ways of doing that. You can either use the `Element Tree` or the `Abstract Syntax Tree (AST)` to find all the classes. Here's an example with each approach.

- **Element Tree Approach**

  ```dart
  class _CustomLint extends PluginBase {
    @override
    Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
      final library = resolvedUnitResult.libraryElement;
      final classes = library.topLevelElements.whereType<ClassElement>();
      ....
      ....
    }
  }
  ```

  The variable `classes` is of type `List<ClassElement>` and will contain all the ClassElements.

- **AST Approach**

  ```dart
  class ClassDeclarationVisitor extends GeneralizingAstVisitor<void> {
    ClassDeclarationVisitor({
      required this.onClassDeclarationVisit,
    });

    void Function(ClassDeclaration node) onClassDeclarationVisit;

    @override
    void visitClassDeclaration(ClassDeclaration node) {
      onClassDeclarationVisit(node);
      super.visitClassDeclaration(node);
    }
  }

  class _CustomLint extends PluginBase {
    @override
    Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
      final classDeclarations = <ClassDeclaration>[];
      resolvedUnitResult.unit.visitChildren(
        ClassDeclarationVisitor(
          onClassDeclarationVisit: classDeclarations.add,
        ),
      );
      ....
      ....
    }
  }
  ```

  This way, the variable `classDeclarations` will contain list of `ClassDeclaration`.

---

### Q. How do I get all the global variables present in my source code?

Same as [above](#q-how-do-i-get-all-the-classes-present-in-my-source-code). Just replace `ClassElement` with `VariableElement` in the Element Tree Approach or replace `ClassDeclaration` with `VariableDeclaration` in the AST approach.

---

### Q. How do I get the path to my currently opened dart file?

You can use the instance of `ResolvedUnitResult` to call the `path` getter.

```dart
class _CustomLints extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final path = resolvedUnitResult.path; // Gives the path of the currently opened Dart file
    ...
    ...
  }
}
```

---

### Q. I want to insert code at the end of the file. How can I get the required offset?

To find the offset for the end of the file (or simply put, find the end line of a Dart file), you can use the instance of `ResolvedUnitResult` to call the `end` getter.

```dart
class _CustomLints extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final endLineOffset = resolvedUnitResult.unit.end; // Gives the offset for the last line in a Dart file
  }
}
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

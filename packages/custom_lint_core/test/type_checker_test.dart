import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'assist_test.dart';

void main() {
  test('Can call isExactlyType in DartTypes with no element', () async {
    final file = writeToTemporaryFile('''
void main() {
  void Function()? fn;
  fn?.call();
}
''');

    final unit = await resolveFile2(path: file.path);
    unit as ResolvedUnitResult;

    const checker = TypeChecker.fromName('foo');

    unit.unit.accept(
      _MethodInvocationVisitor((node) {
        expect(
          checker.isExactlyType(node.target!.staticType!),
          isFalse,
        );
      }),
    );
  });

  group('TypeChecker.fromPackage', () {
    test('matches a type from a package', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final file = File(join(tempDir.path, 'lib', 'main.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('''
class Foo {}
int a;
''');

      final pubspec = File(join(tempDir.path, 'pubspec.yaml'));
      pubspec.writeAsStringSync('''
name: some_package
version: 0.2.8
description: A package to help writing custom linters
repository: https://github.com/invertase/dart_custom_lint
environment:
  sdk: ">=3.0.0 <4.0.0"
''');

      await Process.run(
        'dart',
        ['pub', 'get', '--offline'],
        workingDirectory: tempDir.path,
      );

      final unit = await resolveFile2(path: file.path);
      unit as ResolvedUnitResult;

      const checker = TypeChecker.fromPackage('some_package');
      const checker2 = TypeChecker.fromPackage('some_package2');

      expect(
        checker.isExactlyType(
          (unit.unit.declarations.first as ClassDeclaration)
              .declaredElement!
              .thisType,
        ),
        true,
      );
      expect(
        checker2.isExactlyType(
          (unit.unit.declarations.first as ClassDeclaration)
              .declaredElement!
              .thisType,
        ),
        false,
      );

      expect(
        checker.isExactlyType(
          (unit.unit.declarations[1] as TopLevelVariableDeclaration)
              .variables
              .type!
              .type!,
        ),
        false,
      );
    });
  });
}

class _MethodInvocationVisitor extends RecursiveAstVisitor<void> {
  _MethodInvocationVisitor(this.onMethodInvocation);

  final void Function(MethodInvocation node) onMethodInvocation;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    onMethodInvocation(node);
    super.visitMethodInvocation(node);
  }
}

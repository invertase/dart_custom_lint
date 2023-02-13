import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
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

import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

/// Builds generators for `build_runner` to run
Builder lintVisitorGenerator(BuilderOptions options) {
  return SharedPartBuilder(
    [_LintVisitorGenerator()],
    'lint_visitor_generator',
  );
}

extension on Element2 {
  Annotatable? get asAnnotatable {
    if (this is Annotatable) return this as Annotatable;
    return null;
  }
}

extension on LibraryElement2 {
  Element2? findElementWithNameFromPackage(String name) {
    return library2.firstFragment.importedLibraries2
        .map(
          (e) => e.exportNamespace.get2(name),
        )
        .firstWhereOrNull((element) => element != null);
  }

  ClassElement2? _findAstVisitor() {
    return findElementWithNameFromPackage('GeneralizingAstVisitor')
        as ClassElement2?;
  }
}

class _LintVisitorGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) {
    final visitor = library.element._findAstVisitor()!;

    final buffer = StringBuffer();

    _writeLinterVisitor(buffer, visitor);
    _writeNodeLintRegistry(buffer, visitor);
    _writeLintRuleNodeRegistry(buffer, visitor);

    return buffer.toString();
  }

  void _writeNodeLintRegistry(StringBuffer buffer, ClassElement2 visitor) {
    buffer.writeln('''
/// A single subscription for a node type, by the specified "key"
class _Subscription<T> {
  _Subscription(this.listener, this.timer, this.zone);

  final void Function(T node) listener;
  final Stopwatch? timer;
  final Zone zone;
}

/// The container to register visitors for separate AST node types.
class NodeLintRegistry {
  /// The container to register visitors for separate AST node types.
  NodeLintRegistry(this._lintRegistry, {required bool enableTiming})
      : _enableTiming = enableTiming;

  final LintRegistry _lintRegistry;
  final bool _enableTiming;

  /// Get the timer associated with the given [key].
  Stopwatch? _getTimer(String key) {
    if (_enableTiming) {
      return _lintRegistry.getTimer(key);
    } else {
      return null;
    }
  }
''');

    for (final visitorMethod
        in visitor.methods2.where((e) => e.name3!.startsWith('visit'))) {
      if (visitorMethod.metadata2.hasDeprecated) continue;

      const start = 'visit'.length;

      if (visitorMethod.formalParameters.single.type.element3!.asAnnotatable!
          .metadata2.hasDeprecated) {
        buffer.write('@deprecated ');
      }

      buffer
        ..write('final List<_Subscription<')
        ..write(visitorMethod.formalParameters.single.type)
        ..write('>> _for')
        ..write(visitorMethod.formalParameters.single.type)
        ..write(' = [];');

      if (visitorMethod.formalParameters.single.type.element3!.asAnnotatable!
          .metadata2.hasDeprecated) {
        buffer.write('@deprecated ');
      }

      buffer
        ..write('void add')
        ..write(visitorMethod.name3!.substring(start))
        ..write('(String key, void Function(')
        ..write(visitorMethod.formalParameters.single.type)
        ..write(' node) listener) {_for')
        ..write(visitorMethod.formalParameters.single.type)
        ..write(
          '.add(_Subscription(listener, _getTimer(key), Zone.current));}',
        );
    }

    buffer.write('}');
  }

  void _writeLinterVisitor(StringBuffer buffer, ClassElement2 visitor) {
    buffer.writeln('''
/// The AST visitor that runs handlers for nodes from the [_registry].
class LinterVisitor extends GeneralizingAstVisitor<void> {
  /// The AST visitor that runs handlers for nodes from the [_registry].
  LinterVisitor(this._registry);

  final NodeLintRegistry _registry;


  void _runSubscriptions<T extends AstNode>(
    T node,
    List<_Subscription<T>> subscriptions,
  ) {
    for (var i = 0; i < subscriptions.length; i++) {
      final subscription = subscriptions[i];
      final timer = subscription.timer;
      timer?.start();
      try {
        subscription.zone.runUnary(subscription.listener, node);
      } catch (exception, stackTrace) {
        subscription.zone.handleUncaughtError(exception, stackTrace);
      }
      timer?.stop();
    }
  }

''');

    for (final visitorMethod in visitor.methods2) {
      if (visitorMethod.metadata2.hasDeprecated) continue;

      buffer
        ..write('@override void ')
        ..write(visitorMethod.name3)
        ..write('(')
        ..write(visitorMethod.formalParameters.single.type)
        ..write(' node) {_runSubscriptions(node, _registry._for')
        ..write(visitorMethod.formalParameters.single.type)
        ..write('); super.')
        ..write(visitorMethod.name3)
        ..write('(node);}');
    }

    buffer.writeln('}');
  }

  void _writeLintRuleNodeRegistry(StringBuffer buffer, ClassElement2 visitor) {
    buffer.writeln('''
class LintRuleNodeRegistry {
  LintRuleNodeRegistry(this.nodeLintRegistry, this.name);

  final NodeLintRegistry nodeLintRegistry;

  final String name;
''');

    for (final visitorMethod
        in visitor.methods2.where((e) => e.name3!.startsWith('visit'))) {
      if (visitorMethod.metadata2.hasDeprecated) continue;

      const start = 'visit'.length;

      if (visitorMethod.formalParameters.single.type.element3!.asAnnotatable!
          .metadata2.hasDeprecated) {
        buffer.write('@deprecated ');
      }

      buffer
        ..write('@preferInline void add')
        ..write(visitorMethod.name3!.substring(start))
        ..write('(void Function(')
        ..write(visitorMethod.formalParameters.single.type)
        ..write(' node) listener) {nodeLintRegistry.add')
        ..write(visitorMethod.name3!.substring(start))
        ..write('(name, listener);}');
    }

    buffer.writeln('}');
  }
}

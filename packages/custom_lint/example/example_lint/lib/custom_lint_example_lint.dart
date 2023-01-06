import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

bool _isProvider(DartType type) {
  // TODO refactor to use TypeChecker
  // TODO is it safe?
  final element = type.element! as ClassElement;
  final source = element.librarySource.uri;

  final isProviderBase = source.scheme == 'package' &&
      // TODO handle flutter_riverpod
      source.pathSegments.first == 'riverpod' &&
      element.name == 'ProviderBase';

  return isProviderBase || element.allSupertypes.any(_isProvider);
}

PluginBase createPlugin() => _RiverpodLint();

class _RiverpodLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final library = resolvedUnitResult.libraryElement;
    print('This is a print3');
    final providers = library.topLevelElements
        .whereType<VariableElement>()
        .where((e) => !e.isFinal)
        .where((e) => _isProvider(e.type))
        .toList();

    for (final provider in providers) {
      if (provider.name == 'fail') throw StateError('Nani?');

      yield Lint(
        code: 'riverpod_final_provider',
        message: 'Providers should always be declared as final',
        location: provider.nameLintLocation!,
        getAnalysisErrorFixes: (lint) async* {
          final changeBuilder = ChangeBuilder(
            session: resolvedUnitResult.session,
          );
          await changeBuilder.addDartFileEdit(resolvedUnitResult.path,
              (builder) {
            builder.addInsertion(lint.location.offset, (builder) {
              builder.write('final');
            });
          });
          final sourceChange = changeBuilder.sourceChange
            ..message = 'Make final';

          yield AnalysisErrorFixes(lint.asAnalysisError(), fixes: [
            PrioritizedSourceChange(1, sourceChange),
          ]);
        },
      );
    }
  }

  @override
  Future<EditGetAssistsResult> handleGetAssists(
    ResolvedUnitResult resolvedUnitResult, {
    required int offset,
    required int length,
  }) async {
    final changeBuilder = ChangeBuilder(
      session: resolvedUnitResult.session,
    );
    await changeBuilder.addDartFileEdit(resolvedUnitResult.path, (builder) {
      builder.addInsertion(offset, (builder) {
        builder.write('HelloWorld');
      });
    });

    final sourceChange = changeBuilder.sourceChange
      ..message = 'Prefix with HelloWorld';
    // print(sourceChange.toJson());

    return EditGetAssistsResult([
      PrioritizedSourceChange(1, sourceChange),
    ]);
  }
}

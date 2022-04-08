import 'dart:isolate';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
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

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _RiverpodLint());
}

class _RiverpodLint extends PluginBase {
  @override
  Iterable<AnalysisError> getLints(LibraryElement library) sync* {
    final libraryPath = library.source.fullName;

    final providers = library.topLevelElements
        .whereType<VariableElement>()
        .where((e) => !e.isFinal)
        .where((e) => _isProvider(e.type))
        .toList();

    for (final provider in providers) {
      yield AnalysisError(
        // TODO use plugin.Type
        AnalysisErrorSeverity.WARNING,
        AnalysisErrorType.LINT,
        Location(libraryPath, provider.nameOffset, provider.nameLength, 0, 0),
        'Providers should always be declared as final',
        'riverpod_final_provider',
      );
    }
  }
}

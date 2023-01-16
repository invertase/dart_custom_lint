import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_yaml.dart';
import 'package:meta/meta.dart';

import 'resolver.dart';

abstract class ChangeReporter {
  ChangeBuilder createChangeBuilder({
    required String message,
    required int priority,
  });
}

@internal
class ChangeReporterImpl implements ChangeReporter {
  ChangeReporterImpl(this._analysisSession, this._resolver);

  final CustomLintResolver _resolver;
  final AnalysisSession _analysisSession;
  final _changeBuilders = <_ChangeBuilderImpl>[];

  @override
  ChangeBuilder createChangeBuilder({
    required String message,
    required int priority,
  }) {
    final changeBuilderImpl = _ChangeBuilderImpl(
      message,
      analysisSession: _analysisSession,
      priority: priority,
      path: _resolver.path,
    );
    _changeBuilders.add(changeBuilderImpl);

    return changeBuilderImpl;
  }

  @internal
  Future<List<PrioritizedSourceChange>> waitForCompletion() async {
    return Future.wait(
      _changeBuilders.map((e) => e._waitForCompletion()),
    );
  }
}

abstract class ChangeBuilder {
  /// Use the [buildFileEdit] function to create a collection of edits to the
  /// file with the given [path]. The edits will be added to the source change
  /// that is being built.
  ///
  /// The builder passed to the [buildFileEdit] function has additional support
  /// for working with Dart source files.
  void addDartFileEdit(
    void Function(DartFileEditBuilder builder) buildFileEdit, {
    ImportPrefixGenerator importPrefixGenerator,
  });

  /// Use the [buildFileEdit] function to create a collection of edits to the
  /// file with the given [path]. The edits will be added to the source change
  /// that is being built.
  ///
  /// The builder passed to the [buildFileEdit] function has no special support
  /// for any particular kind of file.
  void addGenericFileEdit(
    void Function(analyzer_plugin.FileEditBuilder builder) buildFileEdit,
  );

  /// Use the [buildFileEdit] function to create a collection of edits to the
  /// file with the given [path]. The edits will be added to the source change
  /// that is being built.
  ///
  /// The builder passed to the [buildFileEdit] function has additional support
  /// for working with YAML source files.
  void addYamlFileEdit(
    void Function(YamlFileEditBuilder builder) buildFileEdit,
  );
}

class _ChangeBuilderImpl implements ChangeBuilder {
  _ChangeBuilderImpl(
    this._message, {
    required this.path,
    required this.priority,
    required AnalysisSession analysisSession,
  }) : _innerChangeBuilder =
            analyzer_plugin.ChangeBuilder(session: analysisSession);

  final String _message;
  final int priority;
  final String path;
  final analyzer_plugin.ChangeBuilder _innerChangeBuilder;
  final _operations = <Future<void>>[];

  @override
  void addDartFileEdit(
    void Function(DartFileEditBuilder builder) buildFileEdit, {
    ImportPrefixGenerator? importPrefixGenerator,
  }) {
    _operations.add(
      importPrefixGenerator == null
          ? _innerChangeBuilder.addDartFileEdit(path, buildFileEdit)
          : _innerChangeBuilder.addDartFileEdit(
              path,
              buildFileEdit,
              importPrefixGenerator: importPrefixGenerator,
            ),
    );
  }

  @override
  void addGenericFileEdit(
    void Function(analyzer_plugin.FileEditBuilder builder) buildFileEdit,
  ) {
    _operations.add(
      _innerChangeBuilder.addGenericFileEdit(path, buildFileEdit),
    );
  }

  @override
  void addYamlFileEdit(
    void Function(YamlFileEditBuilder builder) buildFileEdit,
  ) {
    _operations.add(
      _innerChangeBuilder.addYamlFileEdit(path, buildFileEdit),
    );
  }

  Future<PrioritizedSourceChange> _waitForCompletion() async {
    await Future.wait(_operations);

    return PrioritizedSourceChange(
      priority,
      _innerChangeBuilder.sourceChange..message = _message,
    );
  }
}

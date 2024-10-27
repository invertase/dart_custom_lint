import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_yaml.dart';
import 'package:meta/meta.dart';

import 'resolver.dart';

/// A class used for requesting a [ChangeBuilder].
abstract class ChangeReporter {
  /// Creates a [ChangeBuilder], which can then be used to modify files.
  ///
  /// [message] is the name that will show-up in the IDE when users request changes.
  ///
  /// [priority] defines how high/low in the list of proposed changes will this
  /// change be.
  ChangeBuilder createChangeBuilder({
    required String message,
    required int priority,
  });

  /// Waits for all [ChangeBuilder] to fully compute the source changes.
  Future<void> waitForCompletion();

  /// Waits for completion and obtains the changes.
  ///
  /// This life-cycle can only be called once per [ChangeReporter].
  Future<List<PrioritizedSourceChange>> complete();
}

@internal
abstract class ChangeReporterBuilder {
  ChangeReporter createChangeReporter({required String id});

  Future<List<PrioritizedSourceChange>> complete();

  Future<void> waitForCompletion();
}

@internal
class BatchChangeReporterBuilder extends ChangeReporterBuilder {
  BatchChangeReporterBuilder(ChangeBuilderImpl batchBuilder)
      : _reporter = BatchChangeReporterImpl(batchBuilder);

  final BatchChangeReporterImpl _reporter;

  @override
  ChangeReporter createChangeReporter({required String id}) => _reporter;

  @override
  Future<void> waitForCompletion() => _reporter.waitForCompletion();

  @override
  Future<List<PrioritizedSourceChange>> complete() => _reporter.complete();
}

@internal
class BatchChangeReporterImpl implements ChangeReporter {
  BatchChangeReporterImpl(this.batchBuilder);

  final ChangeBuilderImpl batchBuilder;

  @override
  ChangeBuilder createChangeBuilder({
    required String message,
    required int priority,
    String? id,
  }) {
    return batchBuilder;
  }

  @override
  Future<void> waitForCompletion() async => batchBuilder.waitForCompletion();

  @override
  Future<List<PrioritizedSourceChange>> complete() async {
    return [await batchBuilder.complete()];
  }
}

@internal
class ChangeReporterBuilderImpl extends ChangeReporterBuilder {
  ChangeReporterBuilderImpl(this._resolver, this._analysisSession);

  final CustomLintResolver _resolver;
  final AnalysisSession _analysisSession;
  final List<ChangeReporterImpl> _reporters = [];

  @override
  ChangeReporter createChangeReporter({required String id}) {
    final reporter = ChangeReporterImpl(
      _analysisSession,
      _resolver,
      id: id,
    );
    _reporters.add(reporter);

    return reporter;
  }

  @override
  Future<void> waitForCompletion() async {
    await Future.wait(
      _reporters.map((e) => e.waitForCompletion()),
    );
  }

  @override
  Future<List<PrioritizedSourceChange>> complete() async {
    final changes = Stream.fromFutures(
      _reporters.map((e) => e.complete()),
    );

    return changes.expand((e) => e).toList();
  }
}

/// The implementation of [ChangeReporter]
@internal
class ChangeReporterImpl implements ChangeReporter {
  /// The implementation of [ChangeReporter]
  ChangeReporterImpl(
    this._analysisSession,
    this._resolver, {
    this.id,
  });

  final CustomLintResolver _resolver;
  final AnalysisSession _analysisSession;
  final _changeBuilders = <ChangeBuilderImpl>[];
  final String? id;

  @override
  ChangeBuilderImpl createChangeBuilder({
    required String message,
    required int priority,
  }) {
    final changeBuilderImpl = ChangeBuilderImpl(
      message,
      analysisSession: _analysisSession,
      priority: priority,
      id: id,
      path: _resolver.path,
    );
    _changeBuilders.add(changeBuilderImpl);

    return changeBuilderImpl;
  }

  @override
  Future<void> waitForCompletion() async {
    await Future.wait(
      _changeBuilders.map((e) => e.waitForCompletion()),
    );
  }

  @override
  Future<List<PrioritizedSourceChange>> complete() async {
    return Future.wait(
      _changeBuilders.map((e) => e.complete()),
    );
  }
}

/// A class for modifying
abstract class ChangeBuilder {
  /// Use the [buildFileEdit] function to create a collection of edits to the
  /// currently analyzed file. The edits will be added to the source change
  /// that is being built.
  ///
  /// The builder passed to the [buildFileEdit] function has additional support
  /// for working with Dart source files.
  ///
  /// Use the [customPath] if the collection of edits should be written to another
  /// dart file.
  void addDartFileEdit(
    void Function(DartFileEditBuilder builder) buildFileEdit, {
    ImportPrefixGenerator importPrefixGenerator,
    String? customPath,
  });

  /// Use the [buildFileEdit] function to create a collection of edits to the
  /// currently analyzed file. The edits will be added to the source change
  /// that is being built.
  ///
  /// The builder passed to the [buildFileEdit] function has no special support
  /// for any particular kind of file.
  ///
  /// Use the [customPath] if the collection of edits should be written to another
  /// file.
  void addGenericFileEdit(
    void Function(analyzer_plugin.FileEditBuilder builder) buildFileEdit, {
    String? customPath,
  });

  /// Use the [buildFileEdit] function to create a collection of edits to the
  /// currently analyzed file. The edits will be added to the source change
  /// that is being built.
  ///
  /// The builder passed to the [buildFileEdit] function has additional support
  /// for working with YAML source files.
  ///
  /// Use the [customPath] if the collection of edits should be written to another
  /// YAML file.
  void addYamlFileEdit(
    void Function(YamlFileEditBuilder builder) buildFileEdit,
    String? customPath,
  );
}

@internal
class ChangeBuilderImpl implements ChangeBuilder {
  ChangeBuilderImpl(
    this._message, {
    required this.path,
    required this.priority,
    required this.id,
    required AnalysisSession analysisSession,
  }) : _innerChangeBuilder =
            analyzer_plugin.ChangeBuilder(session: analysisSession);

  final String _message;
  final int priority;
  final String path;
  final String? id;
  final analyzer_plugin.ChangeBuilder _innerChangeBuilder;
  var _completed = false;
  final _operations = <Future<void>>[];

  @override
  void addDartFileEdit(
    void Function(DartFileEditBuilder builder) buildFileEdit, {
    ImportPrefixGenerator? importPrefixGenerator,
    String? customPath,
  }) {
    _operations.add(
      Future(() async {
        return importPrefixGenerator == null
            ? _innerChangeBuilder.addDartFileEdit(
                customPath ?? path,
                buildFileEdit,
              )
            : _innerChangeBuilder.addDartFileEdit(
                customPath ?? path,
                buildFileEdit,
                importPrefixGenerator: importPrefixGenerator,
              );
      }),
    );
  }

  @override
  void addGenericFileEdit(
    void Function(analyzer_plugin.FileEditBuilder builder) buildFileEdit, {
    String? customPath,
  }) {
    _operations.add(
      Future(
        () async => _innerChangeBuilder.addGenericFileEdit(
          customPath ?? path,
          buildFileEdit,
        ),
      ),
    );
  }

  @override
  void addYamlFileEdit(
    void Function(YamlFileEditBuilder builder) buildFileEdit,
    String? customPath,
  ) {
    _operations.add(
      Future(
        () async => _innerChangeBuilder.addYamlFileEdit(
          customPath ?? path,
          buildFileEdit,
        ),
      ),
    );
  }

  Future<void> waitForCompletion() async {
    await Future.wait(_operations);
  }

  Future<PrioritizedSourceChange> complete() async {
    if (_completed) {
      throw StateError('Cannot call waitForCompletion more than once');
    }
    _completed = true;

    await waitForCompletion();

    return PrioritizedSourceChange(
      priority,
      _innerChangeBuilder.sourceChange
        ..id = id
        ..message = _message,
    );
  }
}

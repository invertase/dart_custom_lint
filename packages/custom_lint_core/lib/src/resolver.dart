import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/generated/source.dart' show Source;
import 'package:meta/meta.dart';

/// A class used to interact with files and possibly emit lints of out it.
///
/// The file analyzed might not be a Dart file.
abstract class CustomLintResolver {
  /// The file path that is being analyzed.
  String get path;

  /// The content of the file that is being analyzed.
  Source get source;

  /// Line/column/offset metadata about [source].
  LineInfo get lineInfo;

  /// Obtains a decoded representation of a Dart file.
  ///
  /// It is safe to invoke this method multiple times, as the future is cached.
  ///
  /// May throw an [InconsistentAnalysisException]
  Future<ResolvedUnitResult> getResolvedUnitResult();
}

/// The implementation of [CustomLintResolver]
@internal
class CustomLintResolverImpl extends CustomLintResolver {
  /// The implementation of [CustomLintResolver]
  CustomLintResolverImpl(
    this._getResolvedUnitResult, {
    required this.lineInfo,
    required this.source,
    required this.path,
  });

  @override
  final LineInfo lineInfo;

  @override
  final Source source;

  @override
  final String path;

  final Future<ResolvedUnitResult> Function() _getResolvedUnitResult;

  Future<ResolvedUnitResult>? _getResolvedUnitResultFuture;

  @override
  Future<ResolvedUnitResult> getResolvedUnitResult() {
    return _getResolvedUnitResultFuture ??= _getResolvedUnitResult();
  }
}

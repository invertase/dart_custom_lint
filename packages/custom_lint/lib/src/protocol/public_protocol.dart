import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// The severity of a [Lint]. This influences how the IDE shows the lint.
enum LintSeverity {
  ///  potential change that should be made to the code.
  info._(analyzer_plugin.AnalysisErrorSeverity.INFO),

  /// A possible problem in the code.
  warning._(analyzer_plugin.AnalysisErrorSeverity.WARNING),

  /// A problem in the code that is absolutely certain.
  error._(analyzer_plugin.AnalysisErrorSeverity.ERROR);

  const LintSeverity._(this._analysisErrorSeverity);

  final analyzer_plugin.AnalysisErrorSeverity _analysisErrorSeverity;

  /// Converts a [LintSeverity] into an [analyzer_plugin.AnalysisErrorSeverity].
  analyzer_plugin.AnalysisErrorSeverity asAnalysisErrorSeverity() {
    return _analysisErrorSeverity;
  }
}

/// Information on a possible problem/change that should be made in the user's code
@immutable
class Lint {
  /// Information on a possible problem/change that should be made in the user's code
  const Lint({
    required this.code,
    required this.message,
    required this.location,
    this.severity = LintSeverity.info,
    this.correction,
    this.url,
    Stream<analyzer_plugin.AnalysisErrorFixes> Function(Lint lint)?
        getAnalysisErrorFixes,
  }) : _getAnalysisErrorFixes = getAnalysisErrorFixes;

  /// The severity of a [Lint]. This influences how the IDE shows the lint.
  final LintSeverity severity;

  /// The message to be displayed for this error. The message should indicate
  /// what is wrong with the code and why it is wrong.
  final String message;

  /// A unique key for this error.
  ///
  /// This key will be used for `// ignore: my_code`.
  final String code;

  /// The location associated with the error.
  final LintLocation location;

  /// The correction message to be displayed for this error.
  ///
  /// The correction message should indicate how the user can fix the error.
  /// The field is omitted if there is no correction message associated with
  /// the error code.
  final String? correction;

  /// The URL of a page containing documentation associated with this error.
  final String? url;

  /// Converts a [Lint] into an [analyzer_plugin.AnalysisError]
  analyzer_plugin.AnalysisError asAnalysisError() {
    return analyzer_plugin.AnalysisError(
      severity.asAnalysisErrorSeverity(),
      analyzer_plugin.AnalysisErrorType.LINT,
      location.asLocation(),
      message,
      code,
      correction: correction,
      url: url,
      // TODO contextMessages & hasFix
    );
  }

  final Stream<analyzer_plugin.AnalysisErrorFixes> Function(Lint self)?
      _getAnalysisErrorFixes;

  /// Obtains the list of fixes for this lint.
  Stream<analyzer_plugin.AnalysisErrorFixes> handleGetAnalysisErrorFixes() {
    return _getAnalysisErrorFixes?.call(this) ?? const Stream.empty();
  }
}

/// {@template custom_lint.lint_location}
/// Indications on where a [Lint] is placed within the source code
///
/// custom_lint also comes with various utilities to easily obtain a [LintLocation].
/// This includes:
///
/// - creating a [LintLocation] from the name of an [Element]:
///   ```dart
///   Element someElement; // could be a ClassElement, VariableElement, ...
///
///   LintLocation location = someElement.nameLintLocation;
///   ```
///
/// - creating a [LintLocation] from an offset and length:
///   ```dart
///   class MyLinter extends PluginBase {
///     @override
///     Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
///       LintLocation location =
///           resolvedUnitResult.lintLocationFromOffset(42, length: 100);
///     }
///   }
///   ```
///
/// - creating a [LintLocation] from line/column informations:
///   ```dart
///   class MyLinter extends PluginBase {
///     @override
///     Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
///       LintLocation location = resolvedUnitResult.lintLocationFromLines(
///         startLine: 1,
///         endLine: 2,
///         startColumn: 5,
///       );
///     }
///   }
///   ```
///
/// Subclassing or implementing this class is not supported.
/// {@endtemplate}
@immutable
@sealed
class LintLocation {
  /// {@macro custom_lint.lint_location}
  // ignore: prefer_const_constructors_in_immutables
  LintLocation({
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
    required this.filePath,
    required this.offset,
    required this.length,
  })  : assert(startLine >= 1, 'startLine must be be >= 1'),
        assert(startColumn >= 1, 'startColumn must be be >= 1'),
        assert(endLine >= startLine, 'endLine must be after startLine'),
        assert(
          endLine > startLine || endColumn > startColumn,
          'endColumn must be after startColumn',
        ),
        assert(length >= 1, 'length must be >= 1'),
        assert(offset >= 0, 'offset must be >= 0');

  /// Converts a [analyzer_plugin.Location] into a [LintLocation].
  ///
  /// The [analyzer_plugin.Location] must have all of its properties specified,
  /// of else [LintLocation.fromLocation] will throw.
  factory LintLocation.fromLocation(analyzer_plugin.Location location) {
    return LintLocation(
      startLine: location.startLine,
      startColumn: location.startColumn,
      endLine: location.endLine!,
      endColumn: location.endColumn!,
      filePath: location.file,
      offset: location.offset,
      length: location.length,
    );
  }

  /// The line where this lint begins
  ///
  /// Starts at 1
  final int startLine;

  /// The column where this lint begins
  ///
  /// Starts at 1
  final int startColumn;

  /// The line where this lint ends
  ///
  /// Must be equal or greater than [startLine].
  final int endLine;

  /// The column where this lint ends
  ///
  /// Must be after [startColumn].
  final int endColumn;

  /// The path to the file that contains this lint.
  ///
  /// This path does not have to be the analyzed Dart file.
  final String filePath;

  /// The offset that points to the beginning of this lint.
  ///
  /// Starts at 0
  final int offset;

  /// The length of this lint
  ///
  /// Starts at 1
  final int length;

  /// Converts a [LintLocation] into a [analyzer_plugin.Location].
  analyzer_plugin.Location asLocation() {
    return analyzer_plugin.Location(
      filePath,
      offset,
      length,
      startLine,
      startColumn,
      endLine: endLine,
      endColumn: endColumn,
    );
  }
}

/// Utilities to convert an [Element] into a [LintLocation]
extension LineLocationUtils on Element {
  /// The location of the element's name.
  ///
  /// If the location cannot be determined, such as if the element doesn't
  /// have a name, will be null.
  LintLocation? get nameLintLocation {
    final nameOffset = this.nameOffset;
    final nameLength = this.nameLength;
    if (nameOffset < 0 || nameLength < 1) {
      return null;
    }

    final librarySource = this.librarySource;
    if (librarySource == null) return null;

    final parsedUnit = tryGetParsedUnit();
    if (parsedUnit == null) return null;

    return parsedUnit.lintLocationFromOffset(nameOffset, length: nameLength);
  }
}

/// Extensions for obtainining a [LintLocation] from a [FileResult].
extension LintLocationFileResultExtension on FileResult {
  /// Creates a [LintLocation] from an offset + length.
  LintLocation lintLocationFromOffset(int offset, {required int length}) {
    assert(offset >= 0, 'offset must be positive. Received $offset');
    assert(length >= 1, 'length but be greater than 0');
    final startLocation = lineInfo.getLocation(offset);
    final endLocation = lineInfo.getLocation(offset + length);

    return LintLocation(
      offset: offset,
      length: length,
      startLine: startLocation.lineNumber,
      startColumn: startLocation.columnNumber,
      endLine: endLocation.lineNumber,
      endColumn: endLocation.columnNumber,
      filePath: path,
    );
  }

  /// Creates a [LintLocation] from a line and column.
  LintLocation lintLocationFromLines({
    required int startLine,
    int? startColumn,
    required int endLine,
    int? endColumn,
  }) {
    startColumn ??= 1;
    endColumn ??= 1;
    assert(
      startLine > 0 && startColumn > 0 && endLine > 0 && endColumn > 0,
      'lines/columns start at index 1',
    );

    final startOffset =
        lineInfo.getOffsetOfLine(startLine - 1) + startColumn - 1;
    final endOffset = lineInfo.getOffsetOfLine(endLine - 1) + endColumn - 1;
    final startLocation = lineInfo.getLocation(startOffset);
    final endLocation = lineInfo.getLocation(endOffset);

    return LintLocation(
      filePath: path,
      offset: startOffset,
      length: endOffset - startOffset,
      startLine: startLocation.lineNumber,
      startColumn: startLocation.columnNumber,
      endLine: endLocation.lineNumber,
      endColumn: endLocation.columnNumber,
    );
  }
}

extension on Element {
  ParsedUnitResult? tryGetParsedUnit() {
    final library = this.library;
    if (library == null) return null;

    final session = this.session;
    if (session == null) return null;

    final parsedLibrary = session.getParsedLibraryByElement(library);
    if (parsedLibrary is! ParsedLibraryResult) return null;

    return parsedLibrary.units
        .firstWhereOrNull((element) => element.uri == library.source.uri);
  }
}

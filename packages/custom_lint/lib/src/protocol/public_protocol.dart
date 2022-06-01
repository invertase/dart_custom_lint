import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// The severify of a [Lint]. This influences how the IDE shows the lint.
enum LintSeverity {
  /// A potential change that should be made to the code.
  info,

  /// A possible problem in the code.
  warning,

  /// A problem in the code that is absolutely certain.
  error
}

/// Informations on a possible problem/change that should be made in the user's code
@immutable
class Lint {
  /// Informations on a possible problem/change that should be made in the user's code
  const Lint({
    required this.code,
    required this.message,
    required this.location,
    this.severity = LintSeverity.info,
    this.correction,
    this.url,
  });

  /// The severify of a [Lint]. This influences how the IDE shows the lint.
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
///     Iterable<Lint> getLints(ResolvedUnitResult resolvedUnitResult) sync* {
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
///     Iterable<Lint> getLints(ResolvedUnitResult resolvedUnitResult) sync* {
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

/// Extennsions for obtainining a [LintLocation] from a [FileResult].
extension LintLocationFileResultExtension on FileResult {
  /// Creates a [LintLocation] from an offset + length.
  LintLocation lintLocationFromOffset(int offset, {required int length}) {
    assert(offset >= 0, 'offset must be positive');
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

  /// Creates a [LintLocation] from an line and column informations.
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

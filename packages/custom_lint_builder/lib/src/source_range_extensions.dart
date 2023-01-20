import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';

/// Adds [sourceRange]
extension SyntacticEntitySourceRange on SyntacticEntity {
  /// A [SourceRange] based on [offset] + [length]
  SourceRange get sourceRange => SourceRange(offset, length);
}

/// Adds [sourceRange]
extension AnalysisErrorSourceRange on AnalysisError {
  /// A [SourceRange] based on [offset] + [length]
  SourceRange get sourceRange => SourceRange(offset, length);
}

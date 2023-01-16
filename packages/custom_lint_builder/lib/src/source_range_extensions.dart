import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';

extension SyntacticEntitySourceRange on SyntacticEntity {
  SourceRange get sourceRange => SourceRange(offset, length);
}

extension AnalysisErrorSourceRange on AnalysisError {
  SourceRange get sourceRange => SourceRange(offset, length);
}

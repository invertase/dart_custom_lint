// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

import 'pragrams.dart';

/// Manages lint timing.
@internal
class LintRegistry {
  /// Dictionary mapping lints (by name) to timers.
  final Map<String, Stopwatch> timers = HashMap<String, Stopwatch>();

  /// Get a timer associated with the given lint rule (or create one if none
  /// exists).
  Stopwatch getTimer(String name) {
    return timers.putIfAbsent(name, Stopwatch.new);
  }
}

/// The AST visitor that runs handlers for nodes from the [_registry].
@internal
class LinterVisitor implements AstVisitor<void> {
  LinterVisitor(this._registry);

  final NodeLintRegistry _registry;

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    _runSubscriptions(node, _registry._forAdjacentStrings);
    node.visitChildren(this);
  }

  @override
  void visitAnnotation(Annotation node) {
    _runSubscriptions(node, _registry._forAnnotation);
    node.visitChildren(this);
  }

  @override
  void visitArgumentList(ArgumentList node) {
    _runSubscriptions(node, _registry._forArgumentList);
    node.visitChildren(this);
  }

  @override
  void visitAsExpression(AsExpression node) {
    _runSubscriptions(node, _registry._forAsExpression);
    node.visitChildren(this);
  }

  @override
  void visitAssertInitializer(AssertInitializer node) {
    _runSubscriptions(node, _registry._forAssertInitializer);
    node.visitChildren(this);
  }

  @override
  void visitAssertStatement(AssertStatement node) {
    _runSubscriptions(node, _registry._forAssertStatement);
    node.visitChildren(this);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _runSubscriptions(node, _registry._forAssignmentExpression);
    node.visitChildren(this);
  }

  @override
  void visitAugmentationImportDirective(AugmentationImportDirective node) {
    _runSubscriptions(node, _registry._forAugmentationImportDirective);
    node.visitChildren(this);
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    _runSubscriptions(node, _registry._forAwaitExpression);
    node.visitChildren(this);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _runSubscriptions(node, _registry._forBinaryExpression);
    node.visitChildren(this);
  }

  @override
  void visitBinaryPattern(BinaryPattern node) {
    _runSubscriptions(node, _registry._forBinaryPattern);
    node.visitChildren(this);
  }

  @override
  void visitBlock(Block node) {
    _runSubscriptions(node, _registry._forBlock);
    node.visitChildren(this);
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    _runSubscriptions(node, _registry._forBlockFunctionBody);
    node.visitChildren(this);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    _runSubscriptions(node, _registry._forBooleanLiteral);
    node.visitChildren(this);
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    _runSubscriptions(node, _registry._forBreakStatement);
    node.visitChildren(this);
  }

  @override
  void visitCascadeExpression(CascadeExpression node) {
    _runSubscriptions(node, _registry._forCascadeExpression);
    node.visitChildren(this);
  }

  @override
  void visitCaseClause(CaseClause node) {
    _runSubscriptions(node, _registry._forCaseClause);
    node.visitChildren(this);
  }

  @override
  void visitCastPattern(CastPattern node) {
    _runSubscriptions(node, _registry._forCastPattern);
    node.visitChildren(this);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _runSubscriptions(node, _registry._forCatchClause);
    node.visitChildren(this);
  }

  @override
  void visitCatchClauseParameter(CatchClauseParameter node) {
    _runSubscriptions(node, _registry._forCatchClauseParameter);
    node.visitChildren(this);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _runSubscriptions(node, _registry._forClassDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitClassTypeAlias(ClassTypeAlias node) {
    _runSubscriptions(node, _registry._forClassTypeAlias);
    node.visitChildren(this);
  }

  @override
  void visitComment(Comment node) {
    _runSubscriptions(node, _registry._forComment);
    node.visitChildren(this);
  }

  @override
  void visitCommentReference(CommentReference node) {
    _runSubscriptions(node, _registry._forCommentReference);
    node.visitChildren(this);
  }

  @override
  void visitCompilationUnit(CompilationUnit node) {
    _runSubscriptions(node, _registry._forCompilationUnit);
    node.visitChildren(this);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _runSubscriptions(node, _registry._forConditionalExpression);
    node.visitChildren(this);
  }

  @override
  void visitConfiguration(Configuration node) {
    _runSubscriptions(node, _registry._forConfiguration);
    node.visitChildren(this);
  }

  @override
  void visitConstantPattern(ConstantPattern node) {
    _runSubscriptions(node, _registry._forConstantPattern);
    node.visitChildren(this);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _runSubscriptions(node, _registry._forConstructorDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    _runSubscriptions(node, _registry._forConstructorFieldInitializer);
    node.visitChildren(this);
  }

  @override
  void visitConstructorName(ConstructorName node) {
    _runSubscriptions(node, _registry._forConstructorName);
    node.visitChildren(this);
  }

  @override
  void visitConstructorReference(ConstructorReference node) {
    _runSubscriptions(node, _registry._forConstructorReference);
    node.visitChildren(this);
  }

  @override
  void visitConstructorSelector(ConstructorSelector node) {
    _runSubscriptions(node, _registry._forConstructorSelector);
    node.visitChildren(this);
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    _runSubscriptions(node, _registry._forContinueStatement);
    node.visitChildren(this);
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    _runSubscriptions(node, _registry._forDeclaredIdentifier);
    node.visitChildren(this);
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    _runSubscriptions(node, _registry._forDefaultFormalParameter);
    node.visitChildren(this);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _runSubscriptions(node, _registry._forDoStatement);
    node.visitChildren(this);
  }

  @override
  void visitDottedName(DottedName node) {
    _runSubscriptions(node, _registry._forDottedName);
    node.visitChildren(this);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _runSubscriptions(node, _registry._forDoubleLiteral);
    node.visitChildren(this);
  }

  @override
  void visitEmptyFunctionBody(EmptyFunctionBody node) {
    _runSubscriptions(node, _registry._forEmptyFunctionBody);
    node.visitChildren(this);
  }

  @override
  void visitEmptyStatement(EmptyStatement node) {
    _runSubscriptions(node, _registry._forEmptyStatement);
    node.visitChildren(this);
  }

  @override
  void visitEnumConstantArguments(EnumConstantArguments node) {
    _runSubscriptions(node, _registry._forEnumConstantArguments);
    node.visitChildren(this);
  }

  @override
  void visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    _runSubscriptions(node, _registry._forEnumConstantDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    _runSubscriptions(node, _registry._forEnumDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    _runSubscriptions(node, _registry._forExportDirective);
    node.visitChildren(this);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _runSubscriptions(node, _registry._forExpressionFunctionBody);
    node.visitChildren(this);
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    _runSubscriptions(node, _registry._forExpressionStatement);
    node.visitChildren(this);
  }

  @override
  void visitExtendsClause(ExtendsClause node) {
    _runSubscriptions(node, _registry._forExtendsClause);
    node.visitChildren(this);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    _runSubscriptions(node, _registry._forExtensionDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitExtensionOverride(ExtensionOverride node) {
    _runSubscriptions(node, _registry._forExtensionOverride);
    node.visitChildren(this);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    _runSubscriptions(node, _registry._forFieldDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    _runSubscriptions(node, _registry._forFieldFormalParameter);
    node.visitChildren(this);
  }

  @override
  void visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    _runSubscriptions(node, _registry._forForEachPartsWithDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) {
    _runSubscriptions(node, _registry._forForEachPartsWithIdentifier);
    node.visitChildren(this);
  }

  @override
  void visitForEachPartsWithPattern(ForEachPartsWithPattern node) {
    _runSubscriptions(node, _registry._forForEachPartsWithPattern);
    node.visitChildren(this);
  }

  @override
  void visitForElement(ForElement node) {
    _runSubscriptions(node, _registry._forForElement);
    node.visitChildren(this);
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    _runSubscriptions(node, _registry._forFormalParameterList);
    node.visitChildren(this);
  }

  @override
  void visitForPartsWithDeclarations(ForPartsWithDeclarations node) {
    _runSubscriptions(node, _registry._forForPartsWithDeclarations);
    node.visitChildren(this);
  }

  @override
  void visitForPartsWithExpression(ForPartsWithExpression node) {
    _runSubscriptions(node, _registry._forForPartsWithExpression);
    node.visitChildren(this);
  }

  @override
  void visitForPartsWithPattern(ForPartsWithPattern node) {
    _runSubscriptions(node, _registry._forForPartsWithPattern);
    node.visitChildren(this);
  }

  @override
  void visitForStatement(ForStatement node) {
    _runSubscriptions(node, _registry._forForStatement);
    node.visitChildren(this);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _runSubscriptions(node, _registry._forFunctionDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    _runSubscriptions(node, _registry._forFunctionDeclarationStatement);
    node.visitChildren(this);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    _runSubscriptions(node, _registry._forFunctionExpression);
    node.visitChildren(this);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _runSubscriptions(node, _registry._forFunctionExpressionInvocation);
    node.visitChildren(this);
  }

  @override
  void visitFunctionReference(FunctionReference node) {
    _runSubscriptions(node, _registry._forFunctionReference);
    node.visitChildren(this);
  }

  @override
  void visitFunctionTypeAlias(FunctionTypeAlias node) {
    _runSubscriptions(node, _registry._forFunctionTypeAlias);
    node.visitChildren(this);
  }

  @override
  void visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    _runSubscriptions(node, _registry._forFunctionTypedFormalParameter);
    node.visitChildren(this);
  }

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    _runSubscriptions(node, _registry._forGenericFunctionType);
    node.visitChildren(this);
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    _runSubscriptions(node, _registry._forGenericTypeAlias);
    node.visitChildren(this);
  }

  @override
  void visitGuardedPattern(GuardedPattern node) {
    _runSubscriptions(node, _registry._forCaseClause);
    node.visitChildren(this);
  }

  @override
  void visitHideCombinator(HideCombinator node) {
    _runSubscriptions(node, _registry._forHideCombinator);
    node.visitChildren(this);
  }

  @override
  void visitIfElement(IfElement node) {
    _runSubscriptions(node, _registry._forIfElement);
    node.visitChildren(this);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _runSubscriptions(node, _registry._forIfStatement);
    node.visitChildren(this);
  }

  @override
  void visitImplementsClause(ImplementsClause node) {
    _runSubscriptions(node, _registry._forImplementsClause);
    node.visitChildren(this);
  }

  @override
  void visitImplicitCallReference(ImplicitCallReference node) {
    _runSubscriptions(node, _registry._forImplicitCallReference);
    node.visitChildren(this);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    _runSubscriptions(node, _registry._forImportDirective);
    node.visitChildren(this);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    _runSubscriptions(node, _registry._forIndexExpression);
    node.visitChildren(this);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _runSubscriptions(node, _registry._forInstanceCreationExpression);
    node.visitChildren(this);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _runSubscriptions(node, _registry._forIntegerLiteral);
    node.visitChildren(this);
  }

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    _runSubscriptions(node, _registry._forInterpolationExpression);
    node.visitChildren(this);
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    _runSubscriptions(node, _registry._forInterpolationString);
    node.visitChildren(this);
  }

  @override
  void visitIsExpression(IsExpression node) {
    _runSubscriptions(node, _registry._forIsExpression);
    node.visitChildren(this);
  }

  @override
  void visitLabel(Label node) {
    _runSubscriptions(node, _registry._forLabel);
    node.visitChildren(this);
  }

  @override
  void visitLabeledStatement(LabeledStatement node) {
    _runSubscriptions(node, _registry._forLabeledStatement);
    node.visitChildren(this);
  }

  @override
  void visitLibraryAugmentationDirective(LibraryAugmentationDirective node) {
    _runSubscriptions(node, _registry._forLibraryAugmentationDirective);
    node.visitChildren(this);
  }

  @override
  void visitLibraryDirective(LibraryDirective node) {
    _runSubscriptions(node, _registry._forLibraryDirective);
    node.visitChildren(this);
  }

  @override
  void visitLibraryIdentifier(LibraryIdentifier node) {
    _runSubscriptions(node, _registry._forLibraryIdentifier);
    node.visitChildren(this);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    _runSubscriptions(node, _registry._forListLiteral);
    node.visitChildren(this);
  }

  @override
  void visitListPattern(ListPattern node) {
    _runSubscriptions(node, _registry._forListPattern);
    node.visitChildren(this);
  }

  @override
  void visitMapLiteralEntry(MapLiteralEntry node) {
    _runSubscriptions(node, _registry._forMapLiteralEntry);
    node.visitChildren(this);
  }

  @override
  void visitMapPattern(MapPattern node) {
    _runSubscriptions(node, _registry._forMapPattern);
    node.visitChildren(this);
  }

  @override
  void visitMapPatternEntry(MapPatternEntry node) {
    _runSubscriptions(node, _registry._forMapPatternEntry);
    node.visitChildren(this);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _runSubscriptions(node, _registry._forMethodDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _runSubscriptions(node, _registry._forMethodInvocation);
    node.visitChildren(this);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _runSubscriptions(node, _registry._forMixinDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    _runSubscriptions(node, _registry._forNamedExpression);
    node.visitChildren(this);
  }

  @override
  void visitNamedType(NamedType node) {
    _runSubscriptions(node, _registry._forNamedType);
    node.visitChildren(this);
  }

  @override
  void visitNativeClause(NativeClause node) {
    _runSubscriptions(node, _registry._forNativeClause);
    node.visitChildren(this);
  }

  @override
  void visitNativeFunctionBody(NativeFunctionBody node) {
    _runSubscriptions(node, _registry._forNativeFunctionBody);
    node.visitChildren(this);
  }

  @override
  void visitNullLiteral(NullLiteral node) {
    _runSubscriptions(node, _registry._forNullLiteral);
    node.visitChildren(this);
  }

  @override
  void visitObjectPattern(ObjectPattern node) {
    _runSubscriptions(node, _registry._forObjectPattern);
    node.visitChildren(this);
  }

  @override
  void visitOnClause(OnClause node) {
    _runSubscriptions(node, _registry._forOnClause);
    node.visitChildren(this);
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    _runSubscriptions(node, _registry._forParenthesizedExpression);
    node.visitChildren(this);
  }

  @override
  void visitParenthesizedPattern(ParenthesizedPattern node) {
    _runSubscriptions(node, _registry._forParenthesizedPattern);
    node.visitChildren(this);
  }

  @override
  void visitPartDirective(PartDirective node) {
    _runSubscriptions(node, _registry._forPartDirective);
    node.visitChildren(this);
  }

  @override
  void visitPartOfDirective(PartOfDirective node) {
    _runSubscriptions(node, _registry._forPartOfDirective);
    node.visitChildren(this);
  }

  @override
  void visitPatternAssignment(PatternAssignment node) {
    _runSubscriptions(node, _registry._forPatternAssignment);
    node.visitChildren(this);
  }

  @override
  void visitPatternVariableDeclaration(PatternVariableDeclaration node) {
    _runSubscriptions(node, _registry._forPatternVariableDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitPatternVariableDeclarationStatement(
      PatternVariableDeclarationStatement node) {
    _runSubscriptions(node, _registry._forPatternVariableDeclarationStatement);
    node.visitChildren(this);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _runSubscriptions(node, _registry._forPostfixExpression);
    node.visitChildren(this);
  }

  @override
  void visitPostfixPattern(PostfixPattern node) {
    _runSubscriptions(node, _registry._forPostfixPattern);
    node.visitChildren(this);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _runSubscriptions(node, _registry._forPrefixedIdentifier);
    node.visitChildren(this);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _runSubscriptions(node, _registry._forPrefixExpression);
    node.visitChildren(this);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    _runSubscriptions(node, _registry._forPropertyAccess);
    node.visitChildren(this);
  }

  @override
  void visitRecordLiteral(RecordLiteral node) {
    _runSubscriptions(node, _registry._forRecordLiterals);
    node.visitChildren(this);
  }

  @override
  void visitRecordPattern(RecordPattern node) {
    _runSubscriptions(node, _registry._forRecordPattern);
    node.visitChildren(this);
  }

  @override
  void visitRecordPatternField(RecordPatternField node) {
    _runSubscriptions(node, _registry._forRecordPatternField);
    node.visitChildren(this);
  }

  @override
  void visitRecordPatternFieldName(RecordPatternFieldName node) {
    _runSubscriptions(node, _registry._forRecordPatternFieldName);
    node.visitChildren(this);
  }

  @override
  void visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotation);
    node.visitChildren(this);
  }

  @override
  void visitRecordTypeAnnotationNamedField(
      RecordTypeAnnotationNamedField node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotationNamedField);
    node.visitChildren(this);
  }

  @override
  void visitRecordTypeAnnotationNamedFields(
      RecordTypeAnnotationNamedFields node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotationNamedFields);
    node.visitChildren(this);
  }

  @override
  void visitRecordTypeAnnotationPositionalField(
      RecordTypeAnnotationPositionalField node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotationPositionalField);
    node.visitChildren(this);
  }

  @override
  void visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    _runSubscriptions(node, _registry._forRedirectingConstructorInvocation);
    node.visitChildren(this);
  }

  @override
  void visitRelationalPattern(RelationalPattern node) {
    _runSubscriptions(node, _registry._forRelationalPattern);
    node.visitChildren(this);
  }

  @override
  void visitRestPatternElement(RestPatternElement node) {
    _runSubscriptions(node, _registry._forRestPatternElement);
    node.visitChildren(this);
  }

  @override
  void visitRethrowExpression(RethrowExpression node) {
    _runSubscriptions(node, _registry._forRethrowExpression);
    node.visitChildren(this);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    _runSubscriptions(node, _registry._forReturnStatement);
    node.visitChildren(this);
  }

  @override
  void visitScriptTag(ScriptTag node) {
    _runSubscriptions(node, _registry._forScriptTag);
    node.visitChildren(this);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _runSubscriptions(node, _registry._forSetOrMapLiteral);
    node.visitChildren(this);
  }

  @override
  void visitShowCombinator(ShowCombinator node) {
    _runSubscriptions(node, _registry._forShowCombinator);
    node.visitChildren(this);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    _runSubscriptions(node, _registry._forSimpleFormalParameter);
    node.visitChildren(this);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _runSubscriptions(node, _registry._forSimpleIdentifier);
    node.visitChildren(this);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _runSubscriptions(node, _registry._forSimpleStringLiteral);
    node.visitChildren(this);
  }

  @override
  void visitSpreadElement(SpreadElement node) {
    _runSubscriptions(node, _registry._forSpreadElement);
    node.visitChildren(this);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _runSubscriptions(node, _registry._forStringInterpolation);
    node.visitChildren(this);
  }

  @override
  void visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    _runSubscriptions(node, _registry._forSuperConstructorInvocation);
    node.visitChildren(this);
  }

  @override
  void visitSuperExpression(SuperExpression node) {
    _runSubscriptions(node, _registry._forSuperExpression);
    node.visitChildren(this);
  }

  @override
  void visitSuperFormalParameter(SuperFormalParameter node) {
    _runSubscriptions(node, _registry._forSuperFormalParameter);
    node.visitChildren(this);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _runSubscriptions(node, _registry._forSwitchCase);
    node.visitChildren(this);
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _runSubscriptions(node, _registry._forSwitchDefault);
    node.visitChildren(this);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    _runSubscriptions(node, _registry._forSwitchExpression);
    node.visitChildren(this);
  }

  @override
  void visitSwitchExpressionCase(SwitchExpressionCase node) {
    _runSubscriptions(node, _registry._forSwitchExpressionCase);
    node.visitChildren(this);
  }

  @override
  void visitSwitchPatternCase(SwitchPatternCase node) {
    _runSubscriptions(node, _registry._forSwitchPatternCase);
    node.visitChildren(this);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _runSubscriptions(node, _registry._forSwitchStatement);
    node.visitChildren(this);
  }

  @override
  void visitSymbolLiteral(SymbolLiteral node) {
    _runSubscriptions(node, _registry._forSymbolLiteral);
    node.visitChildren(this);
  }

  @override
  void visitThisExpression(ThisExpression node) {
    _runSubscriptions(node, _registry._forThisExpression);
    node.visitChildren(this);
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    _runSubscriptions(node, _registry._forThrowExpression);
    node.visitChildren(this);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    _runSubscriptions(node, _registry._forTopLevelVariableDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitTryStatement(TryStatement node) {
    _runSubscriptions(node, _registry._forTryStatement);
    node.visitChildren(this);
  }

  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    _runSubscriptions(node, _registry._forTypeArgumentList);
    node.visitChildren(this);
  }

  @override
  void visitTypeLiteral(TypeLiteral node) {
    _runSubscriptions(node, _registry._forTypeLiteral);
    node.visitChildren(this);
  }

  @override
  void visitTypeParameter(TypeParameter node) {
    _runSubscriptions(node, _registry._forTypeParameter);
    node.visitChildren(this);
  }

  @override
  void visitTypeParameterList(TypeParameterList node) {
    _runSubscriptions(node, _registry._forTypeParameterList);
    node.visitChildren(this);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _runSubscriptions(node, _registry._forVariableDeclaration);
    node.visitChildren(this);
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    _runSubscriptions(node, _registry._forVariableDeclarationList);
    node.visitChildren(this);
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    _runSubscriptions(node, _registry._forVariableDeclarationStatement);
    node.visitChildren(this);
  }

  @override
  void visitVariablePattern(VariablePattern node) {
    _runSubscriptions(node, _registry._forVariablePattern);
    node.visitChildren(this);
  }

  @override
  void visitWhenClause(WhenClause node) {
    _runSubscriptions(node, _registry._forWhenClause);
    node.visitChildren(this);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _runSubscriptions(node, _registry._forWhileStatement);
    node.visitChildren(this);
  }

  @override
  void visitWithClause(WithClause node) {
    _runSubscriptions(node, _registry._forWithClause);
    node.visitChildren(this);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _runSubscriptions(node, _registry._forYieldStatement);
    node.visitChildren(this);
  }

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
        subscription.listener(node);
      } catch (exception, stackTrace) {
        Zone.current.handleUncaughtError(exception, stackTrace);
      }
      timer?.stop();
    }
  }
}

/// The container to register visitors for separate AST node types.
@internal
class NodeLintRegistry {
  NodeLintRegistry(this._lintRegistry, {required bool enableTiming})
      : _enableTiming = enableTiming;

  final LintRegistry _lintRegistry;
  final bool _enableTiming;
  final List<_Subscription<AdjacentStrings>> _forAdjacentStrings = [];
  final List<_Subscription<Annotation>> _forAnnotation = [];
  final List<_Subscription<ArgumentList>> _forArgumentList = [];
  final List<_Subscription<AsExpression>> _forAsExpression = [];
  final List<_Subscription<AssertInitializer>> _forAssertInitializer = [];
  final List<_Subscription<AssertStatement>> _forAssertStatement = [];
  final List<_Subscription<AssignmentExpression>> _forAssignmentExpression = [];
  final List<_Subscription<AugmentationImportDirective>>
      _forAugmentationImportDirective = [];
  final List<_Subscription<AwaitExpression>> _forAwaitExpression = [];
  final List<_Subscription<BinaryExpression>> _forBinaryExpression = [];
  final List<_Subscription<BinaryPattern>> _forBinaryPattern = [];
  final List<_Subscription<Block>> _forBlock = [];
  final List<_Subscription<BlockFunctionBody>> _forBlockFunctionBody = [];
  final List<_Subscription<BooleanLiteral>> _forBooleanLiteral = [];
  final List<_Subscription<BreakStatement>> _forBreakStatement = [];
  final List<_Subscription<CascadeExpression>> _forCascadeExpression = [];
  final List<_Subscription<CaseClause>> _forCaseClause = [];
  final List<_Subscription<CastPattern>> _forCastPattern = [];
  final List<_Subscription<CatchClause>> _forCatchClause = [];
  final List<_Subscription<CatchClauseParameter>> _forCatchClauseParameter = [];
  final List<_Subscription<ClassDeclaration>> _forClassDeclaration = [];
  final List<_Subscription<ClassTypeAlias>> _forClassTypeAlias = [];
  final List<_Subscription<Comment>> _forComment = [];
  final List<_Subscription<CommentReference>> _forCommentReference = [];
  final List<_Subscription<CompilationUnit>> _forCompilationUnit = [];
  final List<_Subscription<ConditionalExpression>> _forConditionalExpression =
      [];
  final List<_Subscription<Configuration>> _forConfiguration = [];
  final List<_Subscription<ConstantPattern>> _forConstantPattern = [];
  final List<_Subscription<ConstructorDeclaration>> _forConstructorDeclaration =
      [];
  final List<_Subscription<ConstructorFieldInitializer>>
      _forConstructorFieldInitializer = [];
  final List<_Subscription<ConstructorName>> _forConstructorName = [];
  final List<_Subscription<ConstructorReference>> _forConstructorReference = [];
  final List<_Subscription<ConstructorSelector>> _forConstructorSelector = [];
  final List<_Subscription<ContinueStatement>> _forContinueStatement = [];
  final List<_Subscription<DeclaredIdentifier>> _forDeclaredIdentifier = [];
  final List<_Subscription<DefaultFormalParameter>> _forDefaultFormalParameter =
      [];
  final List<_Subscription<DoStatement>> _forDoStatement = [];
  final List<_Subscription<DottedName>> _forDottedName = [];
  final List<_Subscription<DoubleLiteral>> _forDoubleLiteral = [];
  final List<_Subscription<EmptyFunctionBody>> _forEmptyFunctionBody = [];
  final List<_Subscription<EmptyStatement>> _forEmptyStatement = [];
  final List<_Subscription<EnumConstantArguments>> _forEnumConstantArguments =
      [];
  final List<_Subscription<EnumConstantDeclaration>>
      _forEnumConstantDeclaration = [];
  final List<_Subscription<EnumDeclaration>> _forEnumDeclaration = [];
  final List<_Subscription<ExportDirective>> _forExportDirective = [];
  final List<_Subscription<ExpressionFunctionBody>> _forExpressionFunctionBody =
      [];
  final List<_Subscription<ExpressionStatement>> _forExpressionStatement = [];
  final List<_Subscription<ExtendsClause>> _forExtendsClause = [];
  final List<_Subscription<ExtensionDeclaration>> _forExtensionDeclaration = [];
  final List<_Subscription<ExtensionOverride>> _forExtensionOverride = [];
  final List<_Subscription<ObjectPattern>> _forObjectPattern = [];
  final List<_Subscription<FieldDeclaration>> _forFieldDeclaration = [];
  final List<_Subscription<FieldFormalParameter>> _forFieldFormalParameter = [];
  final List<_Subscription<ForEachPartsWithDeclaration>>
      _forForEachPartsWithDeclaration = [];
  final List<_Subscription<ForEachPartsWithIdentifier>>
      _forForEachPartsWithIdentifier = [];
  final List<_Subscription<ForEachPartsWithPattern>>
      _forForEachPartsWithPattern = [];
  final List<_Subscription<ForElement>> _forForElement = [];
  final List<_Subscription<FormalParameterList>> _forFormalParameterList = [];
  final List<_Subscription<ForPartsWithDeclarations>>
      _forForPartsWithDeclarations = [];
  final List<_Subscription<ForPartsWithExpression>> _forForPartsWithExpression =
      [];
  final List<_Subscription<ForPartsWithPattern>> _forForPartsWithPattern = [];
  final List<_Subscription<ForStatement>> _forForStatement = [];
  final List<_Subscription<FunctionDeclaration>> _forFunctionDeclaration = [];
  final List<_Subscription<FunctionDeclarationStatement>>
      _forFunctionDeclarationStatement = [];
  final List<_Subscription<FunctionExpression>> _forFunctionExpression = [];
  final List<_Subscription<FunctionExpressionInvocation>>
      _forFunctionExpressionInvocation = [];
  final List<_Subscription<FunctionReference>> _forFunctionReference = [];
  final List<_Subscription<FunctionTypeAlias>> _forFunctionTypeAlias = [];
  final List<_Subscription<FunctionTypedFormalParameter>>
      _forFunctionTypedFormalParameter = [];
  final List<_Subscription<GenericFunctionType>> _forGenericFunctionType = [];
  final List<_Subscription<GenericTypeAlias>> _forGenericTypeAlias = [];
  final List<_Subscription<GuardedPattern>> _forGuardedPattern = [];
  final List<_Subscription<HideCombinator>> _forHideCombinator = [];
  final List<_Subscription<IfElement>> _forIfElement = [];
  final List<_Subscription<IfStatement>> _forIfStatement = [];
  final List<_Subscription<ImplementsClause>> _forImplementsClause = [];
  final List<_Subscription<ImplicitCallReference>> _forImplicitCallReference =
      [];
  final List<_Subscription<ImportDirective>> _forImportDirective = [];
  final List<_Subscription<IndexExpression>> _forIndexExpression = [];
  final List<_Subscription<InstanceCreationExpression>>
      _forInstanceCreationExpression = [];
  final List<_Subscription<IntegerLiteral>> _forIntegerLiteral = [];
  final List<_Subscription<InterpolationExpression>>
      _forInterpolationExpression = [];
  final List<_Subscription<InterpolationString>> _forInterpolationString = [];
  final List<_Subscription<IsExpression>> _forIsExpression = [];
  final List<_Subscription<Label>> _forLabel = [];
  final List<_Subscription<LabeledStatement>> _forLabeledStatement = [];
  final List<_Subscription<LibraryAugmentationDirective>>
      _forLibraryAugmentationDirective = [];
  final List<_Subscription<LibraryDirective>> _forLibraryDirective = [];
  final List<_Subscription<LibraryIdentifier>> _forLibraryIdentifier = [];
  final List<_Subscription<ListLiteral>> _forListLiteral = [];
  final List<_Subscription<ListPattern>> _forListPattern = [];
  final List<_Subscription<MapLiteralEntry>> _forMapLiteralEntry = [];
  final List<_Subscription<MapPatternEntry>> _forMapPatternEntry = [];
  final List<_Subscription<MapPattern>> _forMapPattern = [];
  final List<_Subscription<MethodDeclaration>> _forMethodDeclaration = [];
  final List<_Subscription<MethodInvocation>> _forMethodInvocation = [];
  final List<_Subscription<MixinDeclaration>> _forMixinDeclaration = [];
  final List<_Subscription<NamedExpression>> _forNamedExpression = [];
  final List<_Subscription<NamedType>> _forNamedType = [];
  final List<_Subscription<NativeClause>> _forNativeClause = [];
  final List<_Subscription<NativeFunctionBody>> _forNativeFunctionBody = [];
  final List<_Subscription<NullLiteral>> _forNullLiteral = [];
  final List<_Subscription<OnClause>> _forOnClause = [];
  final List<_Subscription<ParenthesizedExpression>>
      _forParenthesizedExpression = [];
  final List<_Subscription<ParenthesizedPattern>> _forParenthesizedPattern = [];
  final List<_Subscription<PartDirective>> _forPartDirective = [];
  final List<_Subscription<PartOfDirective>> _forPartOfDirective = [];
  final List<_Subscription<PatternAssignment>> _forPatternAssignment = [];
  final List<_Subscription<PatternVariableDeclaration>>
      _forPatternVariableDeclaration = [];
  final List<_Subscription<PatternVariableDeclarationStatement>>
      _forPatternVariableDeclarationStatement = [];
  final List<_Subscription<PostfixExpression>> _forPostfixExpression = [];
  final List<_Subscription<PostfixPattern>> _forPostfixPattern = [];
  final List<_Subscription<PrefixedIdentifier>> _forPrefixedIdentifier = [];
  final List<_Subscription<PrefixExpression>> _forPrefixExpression = [];
  final List<_Subscription<PropertyAccess>> _forPropertyAccess = [];
  final List<_Subscription<RecordLiteral>> _forRecordLiterals = [];
  final List<_Subscription<RecordPatternField>> _forRecordPatternField = [];
  final List<_Subscription<RecordPatternFieldName>> _forRecordPatternFieldName =
      [];
  final List<_Subscription<RecordPattern>> _forRecordPattern = [];
  final List<_Subscription<RecordTypeAnnotation>> _forRecordTypeAnnotation = [];
  final List<_Subscription<RecordTypeAnnotationNamedField>>
      _forRecordTypeAnnotationNamedField = [];
  final List<_Subscription<RecordTypeAnnotationNamedFields>>
      _forRecordTypeAnnotationNamedFields = [];
  final List<_Subscription<RecordTypeAnnotationPositionalField>>
      _forRecordTypeAnnotationPositionalField = [];
  final List<_Subscription<RedirectingConstructorInvocation>>
      _forRedirectingConstructorInvocation = [];
  final List<_Subscription<RelationalPattern>> _forRelationalPattern = [];
  final List<_Subscription<RestPatternElement>> _forRestPatternElement = [];
  final List<_Subscription<RethrowExpression>> _forRethrowExpression = [];
  final List<_Subscription<ReturnStatement>> _forReturnStatement = [];
  final List<_Subscription<ScriptTag>> _forScriptTag = [];
  final List<_Subscription<SetOrMapLiteral>> _forSetOrMapLiteral = [];
  final List<_Subscription<ShowCombinator>> _forShowCombinator = [];
  final List<_Subscription<SimpleFormalParameter>> _forSimpleFormalParameter =
      [];
  final List<_Subscription<SimpleIdentifier>> _forSimpleIdentifier = [];
  final List<_Subscription<SimpleStringLiteral>> _forSimpleStringLiteral = [];
  final List<_Subscription<SpreadElement>> _forSpreadElement = [];
  final List<_Subscription<StringInterpolation>> _forStringInterpolation = [];
  final List<_Subscription<SuperConstructorInvocation>>
      _forSuperConstructorInvocation = [];
  final List<_Subscription<SuperExpression>> _forSuperExpression = [];
  final List<_Subscription<SuperFormalParameter>> _forSuperFormalParameter = [];
  final List<_Subscription<SwitchCase>> _forSwitchCase = [];
  final List<_Subscription<SwitchDefault>> _forSwitchDefault = [];
  final List<_Subscription<SwitchExpressionCase>> _forSwitchExpressionCase = [];
  final List<_Subscription<SwitchExpression>> _forSwitchExpression = [];
  final List<_Subscription<SwitchPatternCase>> _forSwitchPatternCase = [];
  final List<_Subscription<SwitchStatement>> _forSwitchStatement = [];
  final List<_Subscription<SymbolLiteral>> _forSymbolLiteral = [];
  final List<_Subscription<ThisExpression>> _forThisExpression = [];
  final List<_Subscription<ThrowExpression>> _forThrowExpression = [];
  final List<_Subscription<TopLevelVariableDeclaration>>
      _forTopLevelVariableDeclaration = [];
  final List<_Subscription<TryStatement>> _forTryStatement = [];
  final List<_Subscription<TypeArgumentList>> _forTypeArgumentList = [];
  final List<_Subscription<TypeLiteral>> _forTypeLiteral = [];
  final List<_Subscription<TypeParameter>> _forTypeParameter = [];
  final List<_Subscription<TypeParameterList>> _forTypeParameterList = [];
  final List<_Subscription<VariableDeclaration>> _forVariableDeclaration = [];
  final List<_Subscription<VariableDeclarationList>>
      _forVariableDeclarationList = [];
  final List<_Subscription<VariableDeclarationStatement>>
      _forVariableDeclarationStatement = [];
  final List<_Subscription<VariablePattern>> _forVariablePattern = [];
  final List<_Subscription<WhenClause>> _forWhenClause = [];
  final List<_Subscription<WhileStatement>> _forWhileStatement = [];
  final List<_Subscription<WithClause>> _forWithClause = [];
  final List<_Subscription<YieldStatement>> _forYieldStatement = [];

  void addAdjacentStrings(
    String key,
    void Function(AdjacentStrings node) listener,
  ) {
    _forAdjacentStrings
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addAnnotation(
    String key,
    void Function(Annotation node) listener,
  ) {
    _forAnnotation.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addArgumentList(
    String key,
    void Function(ArgumentList node) listener,
  ) {
    _forArgumentList.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addAsExpression(
    String key,
    void Function(AsExpression node) listener,
  ) {
    _forAsExpression.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addAssertInitializer(
    String key,
    void Function(AssertInitializer node) listener,
  ) {
    _forAssertInitializer
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addAssertStatement(
    String key,
    void Function(AssertStatement node) listener,
  ) {
    _forAssertStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addAssignmentExpression(
    String key,
    void Function(AssignmentExpression node) listener,
  ) {
    _forAssignmentExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addAugmentationImportDirective(
    String key,
    void Function(AugmentationImportDirective node) listener,
  ) {
    _forAugmentationImportDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addAwaitExpression(
    String key,
    void Function(AwaitExpression node) listener,
  ) {
    _forAwaitExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addBinaryExpression(
    String key,
    void Function(BinaryExpression node) listener,
  ) {
    _forBinaryExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addBinaryPattern(
    String key,
    void Function(BinaryPattern node) listener,
  ) {
    _forBinaryPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addBlock(
    String key,
    void Function(Block node) listener,
  ) {
    _forBlock.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addBlockFunctionBody(
    String key,
    void Function(BlockFunctionBody node) listener,
  ) {
    _forBlockFunctionBody
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addBooleanLiteral(
    String key,
    void Function(BooleanLiteral node) listener,
  ) {
    _forBooleanLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addBreakStatement(
    String key,
    void Function(BreakStatement node) listener,
  ) {
    _forBreakStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addCascadeExpression(
    String key,
    void Function(CascadeExpression node) listener,
  ) {
    _forCascadeExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addCaseClause(
    String key,
    void Function(CaseClause node) listener,
  ) {
    _forCaseClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addCastPattern(
    String key,
    void Function(CastPattern node) listener,
  ) {
    _forCastPattern.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addCatchClause(
    String key,
    void Function(CatchClause node) listener,
  ) {
    _forCatchClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addCatchClauseParameter(
    String key,
    void Function(CatchClauseParameter node) listener,
  ) {
    _forCatchClauseParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addClassDeclaration(
    String key,
    void Function(ClassDeclaration node) listener,
  ) {
    _forClassDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addClassTypeAlias(
    String key,
    void Function(ClassTypeAlias node) listener,
  ) {
    _forClassTypeAlias
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addComment(
    String key,
    void Function(Comment node) listener,
  ) {
    _forComment.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addCommentReference(
    String key,
    void Function(CommentReference node) listener,
  ) {
    _forCommentReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addCompilationUnit(
    String key,
    void Function(CompilationUnit node) listener,
  ) {
    _forCompilationUnit
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addConditionalExpression(
    String key,
    void Function(ConditionalExpression node) listener,
  ) {
    _forConditionalExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addConfiguration(
    String key,
    void Function(Configuration node) listener,
  ) {
    _forConfiguration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addConstantPattern(
    String key,
    void Function(ConstantPattern node) listener,
  ) {
    _forConstantPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addConstructorDeclaration(
    String key,
    void Function(ConstructorDeclaration node) listener,
  ) {
    _forConstructorDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addConstructorFieldInitializer(
    String key,
    void Function(ConstructorFieldInitializer node) listener,
  ) {
    _forConstructorFieldInitializer
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addConstructorName(
    String key,
    void Function(ConstructorName node) listener,
  ) {
    _forConstructorName
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addConstructorReference(
    String key,
    void Function(ConstructorReference node) listener,
  ) {
    _forConstructorReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addConstructorSelector(
    String key,
    void Function(ConstructorSelector node) listener,
  ) {
    _forConstructorSelector
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addContinueStatement(
    String key,
    void Function(ContinueStatement node) listener,
  ) {
    _forContinueStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addDeclaredIdentifier(
    String key,
    void Function(DeclaredIdentifier node) listener,
  ) {
    _forDeclaredIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addDefaultFormalParameter(
    String key,
    void Function(DefaultFormalParameter node) listener,
  ) {
    _forDefaultFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addDoStatement(
    String key,
    void Function(DoStatement node) listener,
  ) {
    _forDoStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addDottedName(
    String key,
    void Function(DottedName node) listener,
  ) {
    _forDottedName.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addDoubleLiteral(
    String key,
    void Function(DoubleLiteral node) listener,
  ) {
    _forDoubleLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addEmptyFunctionBody(
    String key,
    void Function(EmptyFunctionBody node) listener,
  ) {
    _forEmptyFunctionBody
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addEmptyStatement(
    String key,
    void Function(EmptyStatement node) listener,
  ) {
    _forEmptyStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addEnumConstantArguments(
    String key,
    void Function(EnumConstantArguments node) listener,
  ) {
    _forEnumConstantArguments
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addEnumConstantDeclaration(
    String key,
    void Function(EnumConstantDeclaration node) listener,
  ) {
    _forEnumConstantDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addEnumDeclaration(
    String key,
    void Function(EnumDeclaration node) listener,
  ) {
    _forEnumDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addExportDirective(
    String key,
    void Function(ExportDirective node) listener,
  ) {
    _forExportDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addExpressionFunctionBody(
    String key,
    void Function(ExpressionFunctionBody node) listener,
  ) {
    _forExpressionFunctionBody
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addExpressionStatement(
    String key,
    void Function(ExpressionStatement node) listener,
  ) {
    _forExpressionStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addExtendsClause(
    String key,
    void Function(ExtendsClause node) listener,
  ) {
    _forExtendsClause
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addExtensionDeclaration(
    String key,
    void Function(ExtensionDeclaration node) listener,
  ) {
    _forExtensionDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addExtensionOverride(
    String key,
    void Function(ExtensionOverride node) listener,
  ) {
    _forExtensionOverride
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFieldDeclaration(
    String key,
    void Function(FieldDeclaration node) listener,
  ) {
    _forFieldDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFieldFormalParameter(
    String key,
    void Function(FieldFormalParameter node) listener,
  ) {
    _forFieldFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addForEachPartsWithDeclaration(
    String key,
    void Function(ForEachPartsWithDeclaration node) listener,
  ) {
    _forForEachPartsWithDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addForEachPartsWithIdentifier(
    String key,
    void Function(ForEachPartsWithIdentifier node) listener,
  ) {
    _forForEachPartsWithIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addForEachPartsWithPattern(
    String key,
    void Function(ForEachPartsWithPattern node) listener,
  ) {
    _forForEachPartsWithPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addForElement(
    String key,
    void Function(ForElement node) listener,
  ) {
    _forForElement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFormalParameterList(
    String key,
    void Function(FormalParameterList node) listener,
  ) {
    _forFormalParameterList
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addForPartsWithDeclarations(
    String key,
    void Function(ForPartsWithDeclarations node) listener,
  ) {
    _forForPartsWithDeclarations
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addForPartsWithExpression(
    String key,
    void Function(ForPartsWithExpression node) listener,
  ) {
    _forForPartsWithExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addForPartsWithPattern(
    String key,
    void Function(ForPartsWithPattern node) listener,
  ) {
    _forForPartsWithPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addForStatement(
    String key,
    void Function(ForStatement node) listener,
  ) {
    _forForStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFunctionDeclaration(
    String key,
    void Function(FunctionDeclaration node) listener,
  ) {
    _forFunctionDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFunctionDeclarationStatement(
    String key,
    void Function(FunctionDeclarationStatement node) listener,
  ) {
    _forFunctionDeclarationStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFunctionExpression(
    String key,
    void Function(FunctionExpression node) listener,
  ) {
    _forFunctionExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFunctionExpressionInvocation(
    String key,
    void Function(FunctionExpressionInvocation node) listener,
  ) {
    _forFunctionExpressionInvocation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFunctionReference(
    String key,
    void Function(FunctionReference node) listener,
  ) {
    _forFunctionReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFunctionTypeAlias(
    String key,
    void Function(FunctionTypeAlias node) listener,
  ) {
    _forFunctionTypeAlias
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addFunctionTypedFormalParameter(
    String key,
    void Function(FunctionTypedFormalParameter node) listener,
  ) {
    _forFunctionTypedFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addGenericFunctionType(
    String key,
    void Function(GenericFunctionType node) listener,
  ) {
    _forGenericFunctionType
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addGenericTypeAlias(
    String key,
    void Function(GenericTypeAlias node) listener,
  ) {
    _forGenericTypeAlias
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addGuardedPattern(
    String key,
    void Function(GuardedPattern node) listener,
  ) {
    _forGuardedPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addHideCombinator(
    String key,
    void Function(HideCombinator node) listener,
  ) {
    _forHideCombinator
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addIfElement(
    String key,
    void Function(IfElement node) listener,
  ) {
    _forIfElement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addIfStatement(
    String key,
    void Function(IfStatement node) listener,
  ) {
    _forIfStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addImplementsClause(
    String key,
    void Function(ImplementsClause node) listener,
  ) {
    _forImplementsClause
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addImplicitCallReference(
    String key,
    void Function(ImplicitCallReference node) listener,
  ) {
    _forImplicitCallReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addImportDirective(
    String key,
    void Function(ImportDirective node) listener,
  ) {
    _forImportDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addIndexExpression(
    String key,
    void Function(IndexExpression node) listener,
  ) {
    _forIndexExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addInstanceCreationExpression(
    String key,
    void Function(InstanceCreationExpression node) listener,
  ) {
    _forInstanceCreationExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addIntegerLiteral(
    String key,
    void Function(IntegerLiteral node) listener,
  ) {
    _forIntegerLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addInterpolationExpression(
    String key,
    void Function(InterpolationExpression node) listener,
  ) {
    _forInterpolationExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addInterpolationString(
    String key,
    void Function(InterpolationString node) listener,
  ) {
    _forInterpolationString
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addIsExpression(
    String key,
    void Function(IsExpression node) listener,
  ) {
    _forIsExpression.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addLabel(
    String key,
    void Function(Label node) listener,
  ) {
    _forLabel.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addLabeledStatement(
    String key,
    void Function(LabeledStatement node) listener,
  ) {
    _forLabeledStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addLibraryAugmentationDirective(
    String key,
    void Function(LibraryAugmentationDirective node) listener,
  ) {
    _forLibraryAugmentationDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addLibraryDirective(
    String key,
    void Function(LibraryDirective node) listener,
  ) {
    _forLibraryDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addLibraryIdentifier(
    String key,
    void Function(LibraryIdentifier node) listener,
  ) {
    _forLibraryIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addListLiteral(
    String key,
    void Function(ListLiteral node) listener,
  ) {
    _forListLiteral.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addListPattern(
    String key,
    void Function(ListPattern node) listener,
  ) {
    _forListPattern.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addMapLiteralEntry(
    String key,
    void Function(MapLiteralEntry node) listener,
  ) {
    _forMapLiteralEntry
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addMapPattern(
    String key,
    void Function(MapPattern node) listener,
  ) {
    _forMapPattern.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addMapPatternEntry(
    String key,
    void Function(MapPatternEntry node) listener,
  ) {
    _forMapPatternEntry
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addMethodDeclaration(
    String key,
    void Function(MethodDeclaration node) listener,
  ) {
    _forMethodDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addMethodInvocation(
    String key,
    void Function(MethodInvocation node) listener,
  ) {
    _forMethodInvocation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addMixinDeclaration(
    String key,
    void Function(MixinDeclaration node) listener,
  ) {
    _forMixinDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addNamedExpression(
    String key,
    void Function(NamedExpression node) listener,
  ) {
    _forNamedExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addNamedType(
    String key,
    void Function(NamedType node) listener,
  ) {
    _forNamedType.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addNativeClause(
    String key,
    void Function(NativeClause node) listener,
  ) {
    _forNativeClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addNativeFunctionBody(
    String key,
    void Function(NativeFunctionBody node) listener,
  ) {
    _forNativeFunctionBody
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addNullLiteral(
    String key,
    void Function(NullLiteral node) listener,
  ) {
    _forNullLiteral.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addObjectPattern(
    String key,
    void Function(ObjectPattern node) listener,
  ) {
    _forObjectPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addOnClause(
    String key,
    void Function(OnClause node) listener,
  ) {
    _forOnClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addParenthesizedExpression(
    String key,
    void Function(ParenthesizedExpression node) listener,
  ) {
    _forParenthesizedExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addParenthesizedPattern(
    String key,
    void Function(ParenthesizedPattern node) listener,
  ) {
    _forParenthesizedPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPartDirective(
    String key,
    void Function(PartDirective node) listener,
  ) {
    _forPartDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPartOfDirective(
    String key,
    void Function(PartOfDirective node) listener,
  ) {
    _forPartOfDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPatternAssignment(
    String key,
    void Function(PatternAssignment node) listener,
  ) {
    _forPatternAssignment
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPatternVariableDeclaration(
    String key,
    void Function(PatternVariableDeclaration node) listener,
  ) {
    _forPatternVariableDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPatternVariableDeclarationStatement(
    String key,
    void Function(PatternVariableDeclarationStatement node) listener,
  ) {
    _forPatternVariableDeclarationStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPostfixExpression(
    String key,
    void Function(PostfixExpression node) listener,
  ) {
    _forPostfixExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPostfixPattern(
    String key,
    void Function(PostfixPattern node) listener,
  ) {
    _forPostfixPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPrefixedIdentifier(
    String key,
    void Function(PrefixedIdentifier node) listener,
  ) {
    _forPrefixedIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPrefixExpression(
    String key,
    void Function(PrefixExpression node) listener,
  ) {
    _forPrefixExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addPropertyAccess(
    String key,
    void Function(PropertyAccess node) listener,
  ) {
    _forPropertyAccess
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRecordLiteral(
    String key,
    void Function(RecordLiteral node) listener,
  ) {
    _forRecordLiterals
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRecordPattern(
    String key,
    void Function(RecordPattern node) listener,
  ) {
    _forRecordPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRecordPatternField(
    String key,
    void Function(RecordPatternField node) listener,
  ) {
    _forRecordPatternField
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRecordPatternFieldName(
    String key,
    void Function(RecordPatternFieldName node) listener,
  ) {
    _forRecordPatternFieldName
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRecordTypeAnnotation(
    String key,
    void Function(RecordTypeAnnotation node) listener,
  ) {
    _forRecordTypeAnnotation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRedirectingConstructorInvocation(
    String key,
    void Function(RedirectingConstructorInvocation node) listener,
  ) {
    _forRedirectingConstructorInvocation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRelationalPattern(
    String key,
    void Function(RelationalPattern node) listener,
  ) {
    _forRelationalPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRestPatternElement(
    String key,
    void Function(RestPatternElement node) listener,
  ) {
    _forRestPatternElement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addRethrowExpression(
    String key,
    void Function(RethrowExpression node) listener,
  ) {
    _forRethrowExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addReturnStatement(
    String key,
    void Function(ReturnStatement node) listener,
  ) {
    _forReturnStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addScriptTag(
    String key,
    void Function(ScriptTag node) listener,
  ) {
    _forScriptTag.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSetOrMapLiteral(
    String key,
    void Function(SetOrMapLiteral node) listener,
  ) {
    _forSetOrMapLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addShowCombinator(
    String key,
    void Function(ShowCombinator node) listener,
  ) {
    _forShowCombinator
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSimpleFormalParameter(
    String key,
    void Function(SimpleFormalParameter node) listener,
  ) {
    _forSimpleFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSimpleIdentifier(
    String key,
    void Function(SimpleIdentifier node) listener,
  ) {
    _forSimpleIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSimpleStringLiteral(
    String key,
    void Function(SimpleStringLiteral node) listener,
  ) {
    _forSimpleStringLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSpreadElement(
    String key,
    void Function(SpreadElement node) listener,
  ) {
    _forSpreadElement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addStringInterpolation(
    String key,
    void Function(StringInterpolation node) listener,
  ) {
    _forStringInterpolation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSuperConstructorInvocation(
    String key,
    void Function(SuperConstructorInvocation node) listener,
  ) {
    _forSuperConstructorInvocation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSuperExpression(
    String key,
    void Function(SuperExpression node) listener,
  ) {
    _forSuperExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSuperFormalParameter(
    String key,
    void Function(SuperFormalParameter node) listener,
  ) {
    _forSuperFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSwitchCase(
    String key,
    void Function(SwitchCase node) listener,
  ) {
    _forSwitchCase.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSwitchDefault(
    String key,
    void Function(SwitchDefault node) listener,
  ) {
    _forSwitchDefault
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSwitchExpression(
    String key,
    void Function(SwitchExpression node) listener,
  ) {
    _forSwitchExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSwitchExpressionCase(
    String key,
    void Function(SwitchExpressionCase node) listener,
  ) {
    _forSwitchExpressionCase
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSwitchPatternCase(
    String key,
    void Function(SwitchPatternCase node) listener,
  ) {
    _forSwitchPatternCase
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSwitchStatement(
    String key,
    void Function(SwitchStatement node) listener,
  ) {
    _forSwitchStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addSymbolLiteral(
    String key,
    void Function(SymbolLiteral node) listener,
  ) {
    _forSymbolLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addThisExpression(
    String key,
    void Function(ThisExpression node) listener,
  ) {
    _forThisExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addThrowExpression(
    String key,
    void Function(ThrowExpression node) listener,
  ) {
    _forThrowExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addTopLevelVariableDeclaration(
    String key,
    void Function(TopLevelVariableDeclaration node) listener,
  ) {
    _forTopLevelVariableDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addTryStatement(
    String key,
    void Function(TryStatement node) listener,
  ) {
    _forTryStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addTypeArgumentList(
    String key,
    void Function(TypeArgumentList node) listener,
  ) {
    _forTypeArgumentList
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addTypeLiteral(
    String key,
    void Function(TypeLiteral node) listener,
  ) {
    _forTypeLiteral.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addTypeParameter(
    String key,
    void Function(TypeParameter node) listener,
  ) {
    _forTypeParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addTypeParameterList(
    String key,
    void Function(TypeParameterList node) listener,
  ) {
    _forTypeParameterList
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addVariableDeclaration(
    String key,
    void Function(VariableDeclaration node) listener,
  ) {
    _forVariableDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addVariableDeclarationList(
    String key,
    void Function(VariableDeclarationList node) listener,
  ) {
    _forVariableDeclarationList
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addVariableDeclarationStatement(
    String key,
    void Function(VariableDeclarationStatement node) listener,
  ) {
    _forVariableDeclarationStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addVariablePattern(
    String key,
    void Function(VariablePattern node) listener,
  ) {
    _forVariablePattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addWhenClause(
    String key,
    void Function(WhenClause node) listener,
  ) {
    _forWhenClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addWhileStatement(
    String key,
    void Function(WhileStatement node) listener,
  ) {
    _forWhileStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addWithClause(
    String key,
    void Function(WithClause node) listener,
  ) {
    _forWithClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  void addYieldStatement(
    String key,
    void Function(YieldStatement node) listener,
  ) {
    _forYieldStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  /// Get the timer associated with the given [key].
  Stopwatch? _getTimer(String key) {
    if (_enableTiming) {
      return _lintRegistry.getTimer(key);
    } else {
      return null;
    }
  }
}

/// A single subscription for a node type, by the specified "key"
class _Subscription<T> {
  _Subscription(this.listener, this.timer, this.zone);

  final void Function(T node) listener;
  final Stopwatch? timer;
  final Zone zone;
}

class LintRuleNodeRegistry {
  LintRuleNodeRegistry(this.nodeLintRegistry, this.name);

  @internal
  final NodeLintRegistry nodeLintRegistry;
  @internal
  final String name;

  @preferInline
  void addAdjacentStrings(
    void Function(AdjacentStrings node) listener,
  ) {
    nodeLintRegistry.addAdjacentStrings(name, listener);
  }

  @preferInline
  void addAnnotation(
    void Function(Annotation node) listener,
  ) {
    nodeLintRegistry.addAnnotation(name, listener);
  }

  @preferInline
  void addArgumentList(
    void Function(ArgumentList node) listener,
  ) {
    nodeLintRegistry.addArgumentList(name, listener);
  }

  @preferInline
  void addAsExpression(
    void Function(AsExpression node) listener,
  ) {
    nodeLintRegistry.addAsExpression(name, listener);
  }

  @preferInline
  void addAssertInitializer(
    void Function(AssertInitializer node) listener,
  ) {
    nodeLintRegistry.addAssertInitializer(name, listener);
  }

  @preferInline
  void addAssertStatement(
    void Function(AssertStatement node) listener,
  ) {
    nodeLintRegistry.addAssertStatement(name, listener);
  }

  @preferInline
  void addAssignmentExpression(
    void Function(AssignmentExpression node) listener,
  ) {
    nodeLintRegistry.addAssignmentExpression(name, listener);
  }

  @preferInline
  void addAugmentationImportDirective(
    void Function(AugmentationImportDirective node) listener,
  ) {
    nodeLintRegistry.addAugmentationImportDirective(name, listener);
  }

  @preferInline
  void addAwaitExpression(
    void Function(AwaitExpression node) listener,
  ) {
    nodeLintRegistry.addAwaitExpression(name, listener);
  }

  @preferInline
  void addBinaryExpression(
    void Function(BinaryExpression node) listener,
  ) {
    nodeLintRegistry.addBinaryExpression(name, listener);
  }

  @preferInline
  void addBinaryPattern(
    void Function(BinaryPattern node) listener,
  ) {
    nodeLintRegistry.addBinaryPattern(name, listener);
  }

  @preferInline
  void addBlock(
    void Function(Block node) listener,
  ) {
    nodeLintRegistry.addBlock(name, listener);
  }

  @preferInline
  void addBlockFunctionBody(
    void Function(BlockFunctionBody node) listener,
  ) {
    nodeLintRegistry.addBlockFunctionBody(name, listener);
  }

  @preferInline
  void addBooleanLiteral(
    void Function(BooleanLiteral node) listener,
  ) {
    nodeLintRegistry.addBooleanLiteral(name, listener);
  }

  @preferInline
  void addBreakStatement(
    void Function(BreakStatement node) listener,
  ) {
    nodeLintRegistry.addBreakStatement(name, listener);
  }

  @preferInline
  void addCascadeExpression(
    void Function(CascadeExpression node) listener,
  ) {
    nodeLintRegistry.addCascadeExpression(name, listener);
  }

  @preferInline
  void addCaseClause(
    void Function(CaseClause node) listener,
  ) {
    nodeLintRegistry.addCaseClause(name, listener);
  }

  @preferInline
  void addCastPattern(
    void Function(CastPattern node) listener,
  ) {
    nodeLintRegistry.addCastPattern(name, listener);
  }

  @preferInline
  void addCatchClause(
    void Function(CatchClause node) listener,
  ) {
    nodeLintRegistry.addCatchClause(name, listener);
  }

  @preferInline
  void addCatchClauseParameter(
    void Function(CatchClauseParameter node) listener,
  ) {
    nodeLintRegistry.addCatchClauseParameter(name, listener);
  }

  @preferInline
  void addClassDeclaration(
    void Function(ClassDeclaration node) listener,
  ) {
    nodeLintRegistry.addClassDeclaration(name, listener);
  }

  @preferInline
  void addClassTypeAlias(
    void Function(ClassTypeAlias node) listener,
  ) {
    nodeLintRegistry.addClassTypeAlias(name, listener);
  }

  @preferInline
  void addComment(
    void Function(Comment node) listener,
  ) {
    nodeLintRegistry.addComment(name, listener);
  }

  @preferInline
  void addCommentReference(
    void Function(CommentReference node) listener,
  ) {
    nodeLintRegistry.addCommentReference(name, listener);
  }

  @preferInline
  void addCompilationUnit(
    void Function(CompilationUnit node) listener,
  ) {
    nodeLintRegistry.addCompilationUnit(name, listener);
  }

  @preferInline
  void addConditionalExpression(
    void Function(ConditionalExpression node) listener,
  ) {
    nodeLintRegistry.addConditionalExpression(name, listener);
  }

  @preferInline
  void addConfiguration(
    void Function(Configuration node) listener,
  ) {
    nodeLintRegistry.addConfiguration(name, listener);
  }

  @preferInline
  void addConstantPattern(
    void Function(ConstantPattern node) listener,
  ) {
    nodeLintRegistry.addConstantPattern(name, listener);
  }

  @preferInline
  void addConstructorDeclaration(
    void Function(ConstructorDeclaration node) listener,
  ) {
    nodeLintRegistry.addConstructorDeclaration(name, listener);
  }

  @preferInline
  void addConstructorFieldInitializer(
    void Function(ConstructorFieldInitializer node) listener,
  ) {
    nodeLintRegistry.addConstructorFieldInitializer(name, listener);
  }

  @preferInline
  void addConstructorName(
    void Function(ConstructorName node) listener,
  ) {
    nodeLintRegistry.addConstructorName(name, listener);
  }

  @preferInline
  void addConstructorReference(
    void Function(ConstructorReference node) listener,
  ) {
    nodeLintRegistry.addConstructorReference(name, listener);
  }

  @preferInline
  void addConstructorSelector(
    void Function(ConstructorSelector node) listener,
  ) {
    nodeLintRegistry.addConstructorSelector(name, listener);
  }

  @preferInline
  void addContinueStatement(
    void Function(ContinueStatement node) listener,
  ) {
    nodeLintRegistry.addContinueStatement(name, listener);
  }

  @preferInline
  void addDeclaredIdentifier(
    void Function(DeclaredIdentifier node) listener,
  ) {
    nodeLintRegistry.addDeclaredIdentifier(name, listener);
  }

  @preferInline
  void addDefaultFormalParameter(
    void Function(DefaultFormalParameter node) listener,
  ) {
    nodeLintRegistry.addDefaultFormalParameter(name, listener);
  }

  @preferInline
  void addDoStatement(
    void Function(DoStatement node) listener,
  ) {
    nodeLintRegistry.addDoStatement(name, listener);
  }

  @preferInline
  void addDottedName(
    void Function(DottedName node) listener,
  ) {
    nodeLintRegistry.addDottedName(name, listener);
  }

  @preferInline
  void addDoubleLiteral(
    void Function(DoubleLiteral node) listener,
  ) {
    nodeLintRegistry.addDoubleLiteral(name, listener);
  }

  @preferInline
  void addEmptyFunctionBody(
    void Function(EmptyFunctionBody node) listener,
  ) {
    nodeLintRegistry.addEmptyFunctionBody(name, listener);
  }

  @preferInline
  void addEmptyStatement(
    void Function(EmptyStatement node) listener,
  ) {
    nodeLintRegistry.addEmptyStatement(name, listener);
  }

  @preferInline
  void addEnumConstantArguments(
    void Function(EnumConstantArguments node) listener,
  ) {
    nodeLintRegistry.addEnumConstantArguments(name, listener);
  }

  @preferInline
  void addEnumConstantDeclaration(
    void Function(EnumConstantDeclaration node) listener,
  ) {
    nodeLintRegistry.addEnumConstantDeclaration(name, listener);
  }

  @preferInline
  void addEnumDeclaration(
    void Function(EnumDeclaration node) listener,
  ) {
    nodeLintRegistry.addEnumDeclaration(name, listener);
  }

  @preferInline
  void addExportDirective(
    void Function(ExportDirective node) listener,
  ) {
    nodeLintRegistry.addExportDirective(name, listener);
  }

  @preferInline
  void addExpressionFunctionBody(
    void Function(ExpressionFunctionBody node) listener,
  ) {
    nodeLintRegistry.addExpressionFunctionBody(name, listener);
  }

  @preferInline
  void addExpressionStatement(
    void Function(ExpressionStatement node) listener,
  ) {
    nodeLintRegistry.addExpressionStatement(name, listener);
  }

  @preferInline
  void addExtendsClause(
    void Function(ExtendsClause node) listener,
  ) {
    nodeLintRegistry.addExtendsClause(name, listener);
  }

  @preferInline
  void addExtensionDeclaration(
    void Function(ExtensionDeclaration node) listener,
  ) {
    nodeLintRegistry.addExtensionDeclaration(name, listener);
  }

  @preferInline
  void addExtensionOverride(
    void Function(ExtensionOverride node) listener,
  ) {
    nodeLintRegistry.addExtensionOverride(name, listener);
  }

  @preferInline
  void addFieldDeclaration(
    void Function(FieldDeclaration node) listener,
  ) {
    nodeLintRegistry.addFieldDeclaration(name, listener);
  }

  @preferInline
  void addFieldFormalParameter(
    void Function(FieldFormalParameter node) listener,
  ) {
    nodeLintRegistry.addFieldFormalParameter(name, listener);
  }

  @preferInline
  void addForEachPartsWithDeclaration(
    void Function(ForEachPartsWithDeclaration node) listener,
  ) {
    nodeLintRegistry.addForEachPartsWithDeclaration(name, listener);
  }

  @preferInline
  void addForEachPartsWithIdentifier(
    void Function(ForEachPartsWithIdentifier node) listener,
  ) {
    nodeLintRegistry.addForEachPartsWithIdentifier(name, listener);
  }

  @preferInline
  void addForEachPartsWithPattern(
    void Function(ForEachPartsWithPattern node) listener,
  ) {
    nodeLintRegistry.addForEachPartsWithPattern(name, listener);
  }

  @preferInline
  void addForElement(
    void Function(ForElement node) listener,
  ) {
    nodeLintRegistry.addForElement(name, listener);
  }

  @preferInline
  void addFormalParameterList(
    void Function(FormalParameterList node) listener,
  ) {
    nodeLintRegistry.addFormalParameterList(name, listener);
  }

  @preferInline
  void addForPartsWithDeclarations(
    void Function(ForPartsWithDeclarations node) listener,
  ) {
    nodeLintRegistry.addForPartsWithDeclarations(name, listener);
  }

  @preferInline
  void addForPartsWithExpression(
    void Function(ForPartsWithExpression node) listener,
  ) {
    nodeLintRegistry.addForPartsWithExpression(name, listener);
  }

  @preferInline
  void addForPartsWithPattern(
    void Function(ForPartsWithPattern node) listener,
  ) {
    nodeLintRegistry.addForPartsWithPattern(name, listener);
  }

  @preferInline
  void addForStatement(
    void Function(ForStatement node) listener,
  ) {
    nodeLintRegistry.addForStatement(name, listener);
  }

  @preferInline
  void addFunctionDeclaration(
    void Function(FunctionDeclaration node) listener,
  ) {
    nodeLintRegistry.addFunctionDeclaration(name, listener);
  }

  @preferInline
  void addFunctionDeclarationStatement(
    void Function(FunctionDeclarationStatement node) listener,
  ) {
    nodeLintRegistry.addFunctionDeclarationStatement(name, listener);
  }

  @preferInline
  void addFunctionExpression(
    void Function(FunctionExpression node) listener,
  ) {
    nodeLintRegistry.addFunctionExpression(name, listener);
  }

  @preferInline
  void addFunctionExpressionInvocation(
    void Function(FunctionExpressionInvocation node) listener,
  ) {
    nodeLintRegistry.addFunctionExpressionInvocation(name, listener);
  }

  @preferInline
  void addFunctionReference(
    void Function(FunctionReference node) listener,
  ) {
    nodeLintRegistry.addFunctionReference(name, listener);
  }

  @preferInline
  void addFunctionTypeAlias(
    void Function(FunctionTypeAlias node) listener,
  ) {
    nodeLintRegistry.addFunctionTypeAlias(name, listener);
  }

  @preferInline
  void addFunctionTypedFormalParameter(
    void Function(FunctionTypedFormalParameter node) listener,
  ) {
    nodeLintRegistry.addFunctionTypedFormalParameter(name, listener);
  }

  @preferInline
  void addGenericFunctionType(
    void Function(GenericFunctionType node) listener,
  ) {
    nodeLintRegistry.addGenericFunctionType(name, listener);
  }

  @preferInline
  void addGenericTypeAlias(
    void Function(GenericTypeAlias node) listener,
  ) {
    nodeLintRegistry.addGenericTypeAlias(name, listener);
  }

  @preferInline
  void addGuardedPattern(
    void Function(GuardedPattern node) listener,
  ) {
    nodeLintRegistry.addGuardedPattern(name, listener);
  }

  @preferInline
  void addHideCombinator(
    void Function(HideCombinator node) listener,
  ) {
    nodeLintRegistry.addHideCombinator(name, listener);
  }

  @preferInline
  void addIfElement(
    void Function(IfElement node) listener,
  ) {
    nodeLintRegistry.addIfElement(name, listener);
  }

  @preferInline
  void addIfStatement(
    void Function(IfStatement node) listener,
  ) {
    nodeLintRegistry.addIfStatement(name, listener);
  }

  @preferInline
  void addImplementsClause(
    void Function(ImplementsClause node) listener,
  ) {
    nodeLintRegistry.addImplementsClause(name, listener);
  }

  @preferInline
  void addImplicitCallReference(
    void Function(ImplicitCallReference node) listener,
  ) {
    nodeLintRegistry.addImplicitCallReference(name, listener);
  }

  @preferInline
  void addImportDirective(
    void Function(ImportDirective node) listener,
  ) {
    nodeLintRegistry.addImportDirective(name, listener);
  }

  @preferInline
  void addIndexExpression(
    void Function(IndexExpression node) listener,
  ) {
    nodeLintRegistry.addIndexExpression(name, listener);
  }

  @preferInline
  void addInstanceCreationExpression(
    void Function(InstanceCreationExpression node) listener,
  ) {
    nodeLintRegistry.addInstanceCreationExpression(name, listener);
  }

  @preferInline
  void addIntegerLiteral(
    void Function(IntegerLiteral node) listener,
  ) {
    nodeLintRegistry.addIntegerLiteral(name, listener);
  }

  @preferInline
  void addInterpolationExpression(
    void Function(InterpolationExpression node) listener,
  ) {
    nodeLintRegistry.addInterpolationExpression(name, listener);
  }

  @preferInline
  void addInterpolationString(
    void Function(InterpolationString node) listener,
  ) {
    nodeLintRegistry.addInterpolationString(name, listener);
  }

  @preferInline
  void addIsExpression(
    void Function(IsExpression node) listener,
  ) {
    nodeLintRegistry.addIsExpression(name, listener);
  }

  @preferInline
  void addLabel(
    void Function(Label node) listener,
  ) {
    nodeLintRegistry.addLabel(name, listener);
  }

  @preferInline
  void addLabeledStatement(
    void Function(LabeledStatement node) listener,
  ) {
    nodeLintRegistry.addLabeledStatement(name, listener);
  }

  @preferInline
  void addLibraryAugmentationDirective(
    void Function(LibraryAugmentationDirective node) listener,
  ) {
    nodeLintRegistry.addLibraryAugmentationDirective(name, listener);
  }

  @preferInline
  void addLibraryDirective(
    void Function(LibraryDirective node) listener,
  ) {
    nodeLintRegistry.addLibraryDirective(name, listener);
  }

  @preferInline
  void addLibraryIdentifier(
    void Function(LibraryIdentifier node) listener,
  ) {
    nodeLintRegistry.addLibraryIdentifier(name, listener);
  }

  @preferInline
  void addListLiteral(
    void Function(ListLiteral node) listener,
  ) {
    nodeLintRegistry.addListLiteral(name, listener);
  }

  @preferInline
  void addListPattern(
    void Function(ListPattern node) listener,
  ) {
    nodeLintRegistry.addListPattern(name, listener);
  }

  @preferInline
  void addMapLiteralEntry(
    void Function(MapLiteralEntry node) listener,
  ) {
    nodeLintRegistry.addMapLiteralEntry(name, listener);
  }

  @preferInline
  void addMapPattern(
    void Function(MapPattern node) listener,
  ) {
    nodeLintRegistry.addMapPattern(name, listener);
  }

  @preferInline
  void addMapPatternEntry(
    void Function(MapPatternEntry node) listener,
  ) {
    nodeLintRegistry.addMapPatternEntry(name, listener);
  }

  @preferInline
  void addMethodDeclaration(
    void Function(MethodDeclaration node) listener,
  ) {
    nodeLintRegistry.addMethodDeclaration(name, listener);
  }

  @preferInline
  void addMethodInvocation(
    void Function(MethodInvocation node) listener,
  ) {
    nodeLintRegistry.addMethodInvocation(name, listener);
  }

  @preferInline
  void addMixinDeclaration(
    void Function(MixinDeclaration node) listener,
  ) {
    nodeLintRegistry.addMixinDeclaration(name, listener);
  }

  @preferInline
  void addNamedExpression(
    void Function(NamedExpression node) listener,
  ) {
    nodeLintRegistry.addNamedExpression(name, listener);
  }

  @preferInline
  void addNamedType(
    void Function(NamedType node) listener,
  ) {
    nodeLintRegistry.addNamedType(name, listener);
  }

  @preferInline
  void addNativeClause(
    void Function(NativeClause node) listener,
  ) {
    nodeLintRegistry.addNativeClause(name, listener);
  }

  @preferInline
  void addNativeFunctionBody(
    void Function(NativeFunctionBody node) listener,
  ) {
    nodeLintRegistry.addNativeFunctionBody(name, listener);
  }

  @preferInline
  void addNullLiteral(
    void Function(NullLiteral node) listener,
  ) {
    nodeLintRegistry.addNullLiteral(name, listener);
  }

  @preferInline
  void addObjectPattern(
    void Function(ObjectPattern node) listener,
  ) {
    nodeLintRegistry.addObjectPattern(name, listener);
  }

  @preferInline
  void addOnClause(
    void Function(OnClause node) listener,
  ) {
    nodeLintRegistry.addOnClause(name, listener);
  }

  @preferInline
  void addParenthesizedExpression(
    void Function(ParenthesizedExpression node) listener,
  ) {
    nodeLintRegistry.addParenthesizedExpression(name, listener);
  }

  @preferInline
  void addParenthesizedPattern(
    void Function(ParenthesizedPattern node) listener,
  ) {
    nodeLintRegistry.addParenthesizedPattern(name, listener);
  }

  @preferInline
  void addPartDirective(
    void Function(PartDirective node) listener,
  ) {
    nodeLintRegistry.addPartDirective(name, listener);
  }

  @preferInline
  void addPartOfDirective(
    void Function(PartOfDirective node) listener,
  ) {
    nodeLintRegistry.addPartOfDirective(name, listener);
  }

  @preferInline
  void addPatternAssignment(
    void Function(PatternAssignment node) listener,
  ) {
    nodeLintRegistry.addPatternAssignment(name, listener);
  }

  @preferInline
  void addPatternVariableDeclaration(
    void Function(PatternVariableDeclaration node) listener,
  ) {
    nodeLintRegistry.addPatternVariableDeclaration(
      name,
      listener,
    );
  }

  @preferInline
  void addPatternVariableDeclarationStatement(
    void Function(PatternVariableDeclarationStatement node) listener,
  ) {
    nodeLintRegistry.addPatternVariableDeclarationStatement(
      name,
      listener,
    );
  }

  @preferInline
  void addPostfixExpression(
    void Function(PostfixExpression node) listener,
  ) {
    nodeLintRegistry.addPostfixExpression(name, listener);
  }

  @preferInline
  void addPostfixPattern(
    void Function(PostfixPattern node) listener,
  ) {
    nodeLintRegistry.addPostfixPattern(name, listener);
  }

  @preferInline
  void addPrefixedIdentifier(
    void Function(PrefixedIdentifier node) listener,
  ) {
    nodeLintRegistry.addPrefixedIdentifier(name, listener);
  }

  @preferInline
  void addPrefixExpression(
    void Function(PrefixExpression node) listener,
  ) {
    nodeLintRegistry.addPrefixExpression(name, listener);
  }

  @preferInline
  void addPropertyAccess(
    void Function(PropertyAccess node) listener,
  ) {
    nodeLintRegistry.addPropertyAccess(name, listener);
  }

  @preferInline
  void addRecordLiteral(
    void Function(RecordLiteral node) listener,
  ) {
    nodeLintRegistry.addRecordLiteral(name, listener);
  }

  @preferInline
  void addRecordPattern(
    void Function(RecordPattern node) listener,
  ) {
    nodeLintRegistry.addRecordPattern(name, listener);
  }

  @preferInline
  void addRecordPatternField(
    void Function(RecordPatternField node) listener,
  ) {
    nodeLintRegistry.addRecordPatternField(name, listener);
  }

  @preferInline
  void addRecordPatternFieldName(
    void Function(RecordPatternFieldName node) listener,
  ) {
    nodeLintRegistry.addRecordPatternFieldName(name, listener);
  }

  @preferInline
  void addRecordTypeAnnotation(
    void Function(RecordTypeAnnotation node) listener,
  ) {
    nodeLintRegistry.addRecordTypeAnnotation(name, listener);
  }

  @preferInline
  void addRedirectingConstructorInvocation(
    void Function(RedirectingConstructorInvocation node) listener,
  ) {
    nodeLintRegistry.addRedirectingConstructorInvocation(name, listener);
  }

  @preferInline
  void addRelationalPattern(
    void Function(RelationalPattern node) listener,
  ) {
    nodeLintRegistry.addRelationalPattern(name, listener);
  }

  @preferInline
  void addRestPatternElement(
    void Function(RestPatternElement node) listener,
  ) {
    nodeLintRegistry.addRestPatternElement(name, listener);
  }

  @preferInline
  void addRethrowExpression(
    void Function(RethrowExpression node) listener,
  ) {
    nodeLintRegistry.addRethrowExpression(name, listener);
  }

  @preferInline
  void addReturnStatement(
    void Function(ReturnStatement node) listener,
  ) {
    nodeLintRegistry.addReturnStatement(name, listener);
  }

  @preferInline
  void addScriptTag(
    void Function(ScriptTag node) listener,
  ) {
    nodeLintRegistry.addScriptTag(name, listener);
  }

  @preferInline
  void addSetOrMapLiteral(
    void Function(SetOrMapLiteral node) listener,
  ) {
    nodeLintRegistry.addSetOrMapLiteral(name, listener);
  }

  @preferInline
  void addShowCombinator(
    void Function(ShowCombinator node) listener,
  ) {
    nodeLintRegistry.addShowCombinator(name, listener);
  }

  @preferInline
  void addSimpleFormalParameter(
    void Function(SimpleFormalParameter node) listener,
  ) {
    nodeLintRegistry.addSimpleFormalParameter(name, listener);
  }

  @preferInline
  void addSimpleIdentifier(
    void Function(SimpleIdentifier node) listener,
  ) {
    nodeLintRegistry.addSimpleIdentifier(name, listener);
  }

  @preferInline
  void addSimpleStringLiteral(
    void Function(SimpleStringLiteral node) listener,
  ) {
    nodeLintRegistry.addSimpleStringLiteral(name, listener);
  }

  @preferInline
  void addSpreadElement(
    void Function(SpreadElement node) listener,
  ) {
    nodeLintRegistry.addSpreadElement(name, listener);
  }

  @preferInline
  void addStringInterpolation(
    void Function(StringInterpolation node) listener,
  ) {
    nodeLintRegistry.addStringInterpolation(name, listener);
  }

  @preferInline
  void addSuperConstructorInvocation(
    void Function(SuperConstructorInvocation node) listener,
  ) {
    nodeLintRegistry.addSuperConstructorInvocation(name, listener);
  }

  @preferInline
  void addSuperExpression(
    void Function(SuperExpression node) listener,
  ) {
    nodeLintRegistry.addSuperExpression(name, listener);
  }

  @preferInline
  void addSuperFormalParameter(
    void Function(SuperFormalParameter node) listener,
  ) {
    nodeLintRegistry.addSuperFormalParameter(name, listener);
  }

  @preferInline
  void addSwitchCase(
    void Function(SwitchCase node) listener,
  ) {
    nodeLintRegistry.addSwitchCase(name, listener);
  }

  @preferInline
  void addSwitchDefault(
    void Function(SwitchDefault node) listener,
  ) {
    nodeLintRegistry.addSwitchDefault(name, listener);
  }

  @preferInline
  void addSwitchExpression(
    void Function(SwitchExpression node) listener,
  ) {
    nodeLintRegistry.addSwitchExpression(name, listener);
  }

  @preferInline
  void addSwitchExpressionCase(
    void Function(SwitchExpressionCase node) listener,
  ) {
    nodeLintRegistry.addSwitchExpressionCase(name, listener);
  }

  @preferInline
  void addSwitchPatternCase(
    void Function(SwitchPatternCase node) listener,
  ) {
    nodeLintRegistry.addSwitchPatternCase(name, listener);
  }

  @preferInline
  void addSwitchStatement(
    void Function(SwitchStatement node) listener,
  ) {
    nodeLintRegistry.addSwitchStatement(name, listener);
  }

  @preferInline
  void addSymbolLiteral(
    void Function(SymbolLiteral node) listener,
  ) {
    nodeLintRegistry.addSymbolLiteral(name, listener);
  }

  @preferInline
  void addThisExpression(
    void Function(ThisExpression node) listener,
  ) {
    nodeLintRegistry.addThisExpression(name, listener);
  }

  @preferInline
  void addThrowExpression(
    void Function(ThrowExpression node) listener,
  ) {
    nodeLintRegistry.addThrowExpression(name, listener);
  }

  @preferInline
  void addTopLevelVariableDeclaration(
    void Function(TopLevelVariableDeclaration node) listener,
  ) {
    nodeLintRegistry.addTopLevelVariableDeclaration(name, listener);
  }

  @preferInline
  void addTryStatement(
    void Function(TryStatement node) listener,
  ) {
    nodeLintRegistry.addTryStatement(name, listener);
  }

  @preferInline
  void addTypeArgumentList(
    void Function(TypeArgumentList node) listener,
  ) {
    nodeLintRegistry.addTypeArgumentList(name, listener);
  }

  @preferInline
  void addTypeLiteral(
    void Function(TypeLiteral node) listener,
  ) {
    nodeLintRegistry.addTypeLiteral(name, listener);
  }

  @preferInline
  void addTypeParameter(
    void Function(TypeParameter node) listener,
  ) {
    nodeLintRegistry.addTypeParameter(name, listener);
  }

  @preferInline
  void addTypeParameterList(
    void Function(TypeParameterList node) listener,
  ) {
    nodeLintRegistry.addTypeParameterList(name, listener);
  }

  @preferInline
  void addVariableDeclaration(
    void Function(VariableDeclaration node) listener,
  ) {
    nodeLintRegistry.addVariableDeclaration(name, listener);
  }

  @preferInline
  void addVariableDeclarationList(
    void Function(VariableDeclarationList node) listener,
  ) {
    nodeLintRegistry.addVariableDeclarationList(name, listener);
  }

  @preferInline
  void addVariableDeclarationStatement(
    void Function(VariableDeclarationStatement node) listener,
  ) {
    nodeLintRegistry.addVariableDeclarationStatement(name, listener);
  }

  @preferInline
  void addVariablePattern(
    void Function(VariablePattern node) listener,
  ) {
    nodeLintRegistry.addVariablePattern(name, listener);
  }

  @preferInline
  void addWhenClause(
    void Function(WhenClause node) listener,
  ) {
    nodeLintRegistry.addWhenClause(name, listener);
  }

  @preferInline
  void addWhileStatement(
    void Function(WhileStatement node) listener,
  ) {
    nodeLintRegistry.addWhileStatement(name, listener);
  }

  @preferInline
  void addWithClause(
    void Function(WithClause node) listener,
  ) {
    nodeLintRegistry.addWithClause(name, listener);
  }

  @preferInline
  void addYieldStatement(
    void Function(YieldStatement node) listener,
  ) {
    nodeLintRegistry.addYieldStatement(name, listener);
  }
}

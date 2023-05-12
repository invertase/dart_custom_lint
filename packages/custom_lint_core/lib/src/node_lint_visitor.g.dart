// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'node_lint_visitor.dart';

// **************************************************************************
// _LintVisitorGenerator
// **************************************************************************

/// The AST visitor that runs handlers for nodes from the [_registry].
@internal
class LinterVisitor extends GeneralizingAstVisitor<void> {
  /// The AST visitor that runs handlers for nodes from the [_registry].
  @internal
  LinterVisitor(this._registry);

  final NodeLintRegistry _registry;

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
      } catch (exception, stackTrace) {
        subscription.zone.handleUncaughtError(exception, stackTrace);
      }
      timer?.stop();
    }
  }

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    _runSubscriptions(node, _registry._forAdjacentStrings);
    super.visitAdjacentStrings(node);
  }

  @override
  void visitAnnotatedNode(AnnotatedNode node) {
    _runSubscriptions(node, _registry._forAnnotatedNode);
    super.visitAnnotatedNode(node);
  }

  @override
  void visitAnnotation(Annotation node) {
    _runSubscriptions(node, _registry._forAnnotation);
    super.visitAnnotation(node);
  }

  @override
  void visitArgumentList(ArgumentList node) {
    _runSubscriptions(node, _registry._forArgumentList);
    super.visitArgumentList(node);
  }

  @override
  void visitAsExpression(AsExpression node) {
    _runSubscriptions(node, _registry._forAsExpression);
    super.visitAsExpression(node);
  }

  @override
  void visitAssertInitializer(AssertInitializer node) {
    _runSubscriptions(node, _registry._forAssertInitializer);
    super.visitAssertInitializer(node);
  }

  @override
  void visitAssertStatement(AssertStatement node) {
    _runSubscriptions(node, _registry._forAssertStatement);
    super.visitAssertStatement(node);
  }

  @override
  void visitAssignedVariablePattern(AssignedVariablePattern node) {
    _runSubscriptions(node, _registry._forAssignedVariablePattern);
    super.visitAssignedVariablePattern(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _runSubscriptions(node, _registry._forAssignmentExpression);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitAugmentationImportDirective(AugmentationImportDirective node) {
    _runSubscriptions(node, _registry._forAugmentationImportDirective);
    super.visitAugmentationImportDirective(node);
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    _runSubscriptions(node, _registry._forAwaitExpression);
    super.visitAwaitExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _runSubscriptions(node, _registry._forBinaryExpression);
    super.visitBinaryExpression(node);
  }

  @override
  void visitBlock(Block node) {
    _runSubscriptions(node, _registry._forBlock);
    super.visitBlock(node);
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    _runSubscriptions(node, _registry._forBlockFunctionBody);
    super.visitBlockFunctionBody(node);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    _runSubscriptions(node, _registry._forBooleanLiteral);
    super.visitBooleanLiteral(node);
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    _runSubscriptions(node, _registry._forBreakStatement);
    super.visitBreakStatement(node);
  }

  @override
  void visitCascadeExpression(CascadeExpression node) {
    _runSubscriptions(node, _registry._forCascadeExpression);
    super.visitCascadeExpression(node);
  }

  @override
  void visitCaseClause(CaseClause node) {
    _runSubscriptions(node, _registry._forCaseClause);
    super.visitCaseClause(node);
  }

  @override
  void visitCastPattern(CastPattern node) {
    _runSubscriptions(node, _registry._forCastPattern);
    super.visitCastPattern(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _runSubscriptions(node, _registry._forCatchClause);
    super.visitCatchClause(node);
  }

  @override
  void visitCatchClauseParameter(CatchClauseParameter node) {
    _runSubscriptions(node, _registry._forCatchClauseParameter);
    super.visitCatchClauseParameter(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _runSubscriptions(node, _registry._forClassDeclaration);
    super.visitClassDeclaration(node);
  }

  @override
  void visitClassMember(ClassMember node) {
    _runSubscriptions(node, _registry._forClassMember);
    super.visitClassMember(node);
  }

  @override
  void visitClassTypeAlias(ClassTypeAlias node) {
    _runSubscriptions(node, _registry._forClassTypeAlias);
    super.visitClassTypeAlias(node);
  }

  @override
  void visitCollectionElement(CollectionElement node) {
    _runSubscriptions(node, _registry._forCollectionElement);
    super.visitCollectionElement(node);
  }

  @override
  void visitCombinator(Combinator node) {
    _runSubscriptions(node, _registry._forCombinator);
    super.visitCombinator(node);
  }

  @override
  void visitComment(Comment node) {
    _runSubscriptions(node, _registry._forComment);
    super.visitComment(node);
  }

  @override
  void visitCommentReference(CommentReference node) {
    _runSubscriptions(node, _registry._forCommentReference);
    super.visitCommentReference(node);
  }

  @override
  void visitCompilationUnit(CompilationUnit node) {
    _runSubscriptions(node, _registry._forCompilationUnit);
    super.visitCompilationUnit(node);
  }

  @override
  void visitCompilationUnitMember(CompilationUnitMember node) {
    _runSubscriptions(node, _registry._forCompilationUnitMember);
    super.visitCompilationUnitMember(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _runSubscriptions(node, _registry._forConditionalExpression);
    super.visitConditionalExpression(node);
  }

  @override
  void visitConfiguration(Configuration node) {
    _runSubscriptions(node, _registry._forConfiguration);
    super.visitConfiguration(node);
  }

  @override
  void visitConstantPattern(ConstantPattern node) {
    _runSubscriptions(node, _registry._forConstantPattern);
    super.visitConstantPattern(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _runSubscriptions(node, _registry._forConstructorDeclaration);
    super.visitConstructorDeclaration(node);
  }

  @override
  void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    _runSubscriptions(node, _registry._forConstructorFieldInitializer);
    super.visitConstructorFieldInitializer(node);
  }

  @override
  void visitConstructorInitializer(ConstructorInitializer node) {
    _runSubscriptions(node, _registry._forConstructorInitializer);
    super.visitConstructorInitializer(node);
  }

  @override
  void visitConstructorName(ConstructorName node) {
    _runSubscriptions(node, _registry._forConstructorName);
    super.visitConstructorName(node);
  }

  @override
  void visitConstructorReference(ConstructorReference node) {
    _runSubscriptions(node, _registry._forConstructorReference);
    super.visitConstructorReference(node);
  }

  @override
  void visitConstructorSelector(ConstructorSelector node) {
    _runSubscriptions(node, _registry._forConstructorSelector);
    super.visitConstructorSelector(node);
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    _runSubscriptions(node, _registry._forContinueStatement);
    super.visitContinueStatement(node);
  }

  @override
  void visitDartPattern(DartPattern node) {
    _runSubscriptions(node, _registry._forDartPattern);
    super.visitDartPattern(node);
  }

  @override
  void visitDeclaration(Declaration node) {
    _runSubscriptions(node, _registry._forDeclaration);
    super.visitDeclaration(node);
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    _runSubscriptions(node, _registry._forDeclaredIdentifier);
    super.visitDeclaredIdentifier(node);
  }

  @override
  void visitDeclaredVariablePattern(DeclaredVariablePattern node) {
    _runSubscriptions(node, _registry._forDeclaredVariablePattern);
    super.visitDeclaredVariablePattern(node);
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    _runSubscriptions(node, _registry._forDefaultFormalParameter);
    super.visitDefaultFormalParameter(node);
  }

  @override
  void visitDirective(Directive node) {
    _runSubscriptions(node, _registry._forDirective);
    super.visitDirective(node);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _runSubscriptions(node, _registry._forDoStatement);
    super.visitDoStatement(node);
  }

  @override
  void visitDottedName(DottedName node) {
    _runSubscriptions(node, _registry._forDottedName);
    super.visitDottedName(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _runSubscriptions(node, _registry._forDoubleLiteral);
    super.visitDoubleLiteral(node);
  }

  @override
  void visitEmptyFunctionBody(EmptyFunctionBody node) {
    _runSubscriptions(node, _registry._forEmptyFunctionBody);
    super.visitEmptyFunctionBody(node);
  }

  @override
  void visitEmptyStatement(EmptyStatement node) {
    _runSubscriptions(node, _registry._forEmptyStatement);
    super.visitEmptyStatement(node);
  }

  @override
  void visitEnumConstantArguments(EnumConstantArguments node) {
    _runSubscriptions(node, _registry._forEnumConstantArguments);
    super.visitEnumConstantArguments(node);
  }

  @override
  void visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    _runSubscriptions(node, _registry._forEnumConstantDeclaration);
    super.visitEnumConstantDeclaration(node);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    _runSubscriptions(node, _registry._forEnumDeclaration);
    super.visitEnumDeclaration(node);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    _runSubscriptions(node, _registry._forExportDirective);
    super.visitExportDirective(node);
  }

  @override
  void visitExpression(Expression node) {
    _runSubscriptions(node, _registry._forExpression);
    super.visitExpression(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _runSubscriptions(node, _registry._forExpressionFunctionBody);
    super.visitExpressionFunctionBody(node);
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    _runSubscriptions(node, _registry._forExpressionStatement);
    super.visitExpressionStatement(node);
  }

  @override
  void visitExtendsClause(ExtendsClause node) {
    _runSubscriptions(node, _registry._forExtendsClause);
    super.visitExtendsClause(node);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    _runSubscriptions(node, _registry._forExtensionDeclaration);
    super.visitExtensionDeclaration(node);
  }

  @override
  void visitExtensionOverride(ExtensionOverride node) {
    _runSubscriptions(node, _registry._forExtensionOverride);
    super.visitExtensionOverride(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    _runSubscriptions(node, _registry._forFieldDeclaration);
    super.visitFieldDeclaration(node);
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    _runSubscriptions(node, _registry._forFieldFormalParameter);
    super.visitFieldFormalParameter(node);
  }

  @override
  void visitForEachParts(ForEachParts node) {
    _runSubscriptions(node, _registry._forForEachParts);
    super.visitForEachParts(node);
  }

  @override
  void visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    _runSubscriptions(node, _registry._forForEachPartsWithDeclaration);
    super.visitForEachPartsWithDeclaration(node);
  }

  @override
  void visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) {
    _runSubscriptions(node, _registry._forForEachPartsWithIdentifier);
    super.visitForEachPartsWithIdentifier(node);
  }

  @override
  void visitForEachPartsWithPattern(ForEachPartsWithPattern node) {
    _runSubscriptions(node, _registry._forForEachPartsWithPattern);
    super.visitForEachPartsWithPattern(node);
  }

  @override
  void visitForElement(ForElement node) {
    _runSubscriptions(node, _registry._forForElement);
    super.visitForElement(node);
  }

  @override
  void visitFormalParameter(FormalParameter node) {
    _runSubscriptions(node, _registry._forFormalParameter);
    super.visitFormalParameter(node);
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    _runSubscriptions(node, _registry._forFormalParameterList);
    super.visitFormalParameterList(node);
  }

  @override
  void visitForParts(ForParts node) {
    _runSubscriptions(node, _registry._forForParts);
    super.visitForParts(node);
  }

  @override
  void visitForPartsWithDeclarations(ForPartsWithDeclarations node) {
    _runSubscriptions(node, _registry._forForPartsWithDeclarations);
    super.visitForPartsWithDeclarations(node);
  }

  @override
  void visitForPartsWithExpression(ForPartsWithExpression node) {
    _runSubscriptions(node, _registry._forForPartsWithExpression);
    super.visitForPartsWithExpression(node);
  }

  @override
  void visitForPartsWithPattern(ForPartsWithPattern node) {
    _runSubscriptions(node, _registry._forForPartsWithPattern);
    super.visitForPartsWithPattern(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    _runSubscriptions(node, _registry._forForStatement);
    super.visitForStatement(node);
  }

  @override
  void visitFunctionBody(FunctionBody node) {
    _runSubscriptions(node, _registry._forFunctionBody);
    super.visitFunctionBody(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _runSubscriptions(node, _registry._forFunctionDeclaration);
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    _runSubscriptions(node, _registry._forFunctionDeclarationStatement);
    super.visitFunctionDeclarationStatement(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    _runSubscriptions(node, _registry._forFunctionExpression);
    super.visitFunctionExpression(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _runSubscriptions(node, _registry._forFunctionExpressionInvocation);
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitFunctionReference(FunctionReference node) {
    _runSubscriptions(node, _registry._forFunctionReference);
    super.visitFunctionReference(node);
  }

  @override
  void visitFunctionTypeAlias(FunctionTypeAlias node) {
    _runSubscriptions(node, _registry._forFunctionTypeAlias);
    super.visitFunctionTypeAlias(node);
  }

  @override
  void visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    _runSubscriptions(node, _registry._forFunctionTypedFormalParameter);
    super.visitFunctionTypedFormalParameter(node);
  }

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    _runSubscriptions(node, _registry._forGenericFunctionType);
    super.visitGenericFunctionType(node);
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    _runSubscriptions(node, _registry._forGenericTypeAlias);
    super.visitGenericTypeAlias(node);
  }

  @override
  void visitGuardedPattern(GuardedPattern node) {
    _runSubscriptions(node, _registry._forGuardedPattern);
    super.visitGuardedPattern(node);
  }

  @override
  void visitHideCombinator(HideCombinator node) {
    _runSubscriptions(node, _registry._forHideCombinator);
    super.visitHideCombinator(node);
  }

  @override
  void visitIdentifier(Identifier node) {
    _runSubscriptions(node, _registry._forIdentifier);
    super.visitIdentifier(node);
  }

  @override
  void visitIfElement(IfElement node) {
    _runSubscriptions(node, _registry._forIfElement);
    super.visitIfElement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _runSubscriptions(node, _registry._forIfStatement);
    super.visitIfStatement(node);
  }

  @override
  void visitImplementsClause(ImplementsClause node) {
    _runSubscriptions(node, _registry._forImplementsClause);
    super.visitImplementsClause(node);
  }

  @override
  void visitImplicitCallReference(ImplicitCallReference node) {
    _runSubscriptions(node, _registry._forImplicitCallReference);
    super.visitImplicitCallReference(node);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    _runSubscriptions(node, _registry._forImportDirective);
    super.visitImportDirective(node);
  }

  @override
  void visitImportPrefixReference(ImportPrefixReference node) {
    _runSubscriptions(node, _registry._forImportPrefixReference);
    super.visitImportPrefixReference(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    _runSubscriptions(node, _registry._forIndexExpression);
    super.visitIndexExpression(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _runSubscriptions(node, _registry._forInstanceCreationExpression);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _runSubscriptions(node, _registry._forIntegerLiteral);
    super.visitIntegerLiteral(node);
  }

  @override
  void visitInterpolationElement(InterpolationElement node) {
    _runSubscriptions(node, _registry._forInterpolationElement);
    super.visitInterpolationElement(node);
  }

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    _runSubscriptions(node, _registry._forInterpolationExpression);
    super.visitInterpolationExpression(node);
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    _runSubscriptions(node, _registry._forInterpolationString);
    super.visitInterpolationString(node);
  }

  @override
  void visitInvocationExpression(InvocationExpression node) {
    _runSubscriptions(node, _registry._forInvocationExpression);
    super.visitInvocationExpression(node);
  }

  @override
  void visitIsExpression(IsExpression node) {
    _runSubscriptions(node, _registry._forIsExpression);
    super.visitIsExpression(node);
  }

  @override
  void visitLabel(Label node) {
    _runSubscriptions(node, _registry._forLabel);
    super.visitLabel(node);
  }

  @override
  void visitLabeledStatement(LabeledStatement node) {
    _runSubscriptions(node, _registry._forLabeledStatement);
    super.visitLabeledStatement(node);
  }

  @override
  void visitLibraryAugmentationDirective(LibraryAugmentationDirective node) {
    _runSubscriptions(node, _registry._forLibraryAugmentationDirective);
    super.visitLibraryAugmentationDirective(node);
  }

  @override
  void visitLibraryDirective(LibraryDirective node) {
    _runSubscriptions(node, _registry._forLibraryDirective);
    super.visitLibraryDirective(node);
  }

  @override
  void visitLibraryIdentifier(LibraryIdentifier node) {
    _runSubscriptions(node, _registry._forLibraryIdentifier);
    super.visitLibraryIdentifier(node);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    _runSubscriptions(node, _registry._forListLiteral);
    super.visitListLiteral(node);
  }

  @override
  void visitListPattern(ListPattern node) {
    _runSubscriptions(node, _registry._forListPattern);
    super.visitListPattern(node);
  }

  @override
  void visitLiteral(Literal node) {
    _runSubscriptions(node, _registry._forLiteral);
    super.visitLiteral(node);
  }

  @override
  void visitLogicalAndPattern(LogicalAndPattern node) {
    _runSubscriptions(node, _registry._forLogicalAndPattern);
    super.visitLogicalAndPattern(node);
  }

  @override
  void visitLogicalOrPattern(LogicalOrPattern node) {
    _runSubscriptions(node, _registry._forLogicalOrPattern);
    super.visitLogicalOrPattern(node);
  }

  @override
  void visitMapLiteralEntry(MapLiteralEntry node) {
    _runSubscriptions(node, _registry._forMapLiteralEntry);
    super.visitMapLiteralEntry(node);
  }

  @override
  void visitMapPattern(MapPattern node) {
    _runSubscriptions(node, _registry._forMapPattern);
    super.visitMapPattern(node);
  }

  @override
  void visitMapPatternEntry(MapPatternEntry node) {
    _runSubscriptions(node, _registry._forMapPatternEntry);
    super.visitMapPatternEntry(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _runSubscriptions(node, _registry._forMethodDeclaration);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _runSubscriptions(node, _registry._forMethodInvocation);
    super.visitMethodInvocation(node);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _runSubscriptions(node, _registry._forMixinDeclaration);
    super.visitMixinDeclaration(node);
  }

  @override
  void visitNamedCompilationUnitMember(NamedCompilationUnitMember node) {
    _runSubscriptions(node, _registry._forNamedCompilationUnitMember);
    super.visitNamedCompilationUnitMember(node);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    _runSubscriptions(node, _registry._forNamedExpression);
    super.visitNamedExpression(node);
  }

  @override
  void visitNamedType(NamedType node) {
    _runSubscriptions(node, _registry._forNamedType);
    super.visitNamedType(node);
  }

  @override
  void visitNamespaceDirective(NamespaceDirective node) {
    _runSubscriptions(node, _registry._forNamespaceDirective);
    super.visitNamespaceDirective(node);
  }

  @override
  void visitNativeClause(NativeClause node) {
    _runSubscriptions(node, _registry._forNativeClause);
    super.visitNativeClause(node);
  }

  @override
  void visitNativeFunctionBody(NativeFunctionBody node) {
    _runSubscriptions(node, _registry._forNativeFunctionBody);
    super.visitNativeFunctionBody(node);
  }

  @override
  void visitNode(AstNode node) {
    _runSubscriptions(node, _registry._forAstNode);
    super.visitNode(node);
  }

  @override
  void visitNormalFormalParameter(NormalFormalParameter node) {
    _runSubscriptions(node, _registry._forNormalFormalParameter);
    super.visitNormalFormalParameter(node);
  }

  @override
  void visitNullAssertPattern(NullAssertPattern node) {
    _runSubscriptions(node, _registry._forNullAssertPattern);
    super.visitNullAssertPattern(node);
  }

  @override
  void visitNullCheckPattern(NullCheckPattern node) {
    _runSubscriptions(node, _registry._forNullCheckPattern);
    super.visitNullCheckPattern(node);
  }

  @override
  void visitNullLiteral(NullLiteral node) {
    _runSubscriptions(node, _registry._forNullLiteral);
    super.visitNullLiteral(node);
  }

  @override
  void visitObjectPattern(ObjectPattern node) {
    _runSubscriptions(node, _registry._forObjectPattern);
    super.visitObjectPattern(node);
  }

  @override
  void visitOnClause(OnClause node) {
    _runSubscriptions(node, _registry._forOnClause);
    super.visitOnClause(node);
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    _runSubscriptions(node, _registry._forParenthesizedExpression);
    super.visitParenthesizedExpression(node);
  }

  @override
  void visitParenthesizedPattern(ParenthesizedPattern node) {
    _runSubscriptions(node, _registry._forParenthesizedPattern);
    super.visitParenthesizedPattern(node);
  }

  @override
  void visitPartDirective(PartDirective node) {
    _runSubscriptions(node, _registry._forPartDirective);
    super.visitPartDirective(node);
  }

  @override
  void visitPartOfDirective(PartOfDirective node) {
    _runSubscriptions(node, _registry._forPartOfDirective);
    super.visitPartOfDirective(node);
  }

  @override
  void visitPatternAssignment(PatternAssignment node) {
    _runSubscriptions(node, _registry._forPatternAssignment);
    super.visitPatternAssignment(node);
  }

  @override
  void visitPatternField(PatternField node) {
    _runSubscriptions(node, _registry._forPatternField);
    super.visitPatternField(node);
  }

  @override
  void visitPatternFieldName(PatternFieldName node) {
    _runSubscriptions(node, _registry._forPatternFieldName);
    super.visitPatternFieldName(node);
  }

  @override
  void visitPatternVariableDeclaration(PatternVariableDeclaration node) {
    _runSubscriptions(node, _registry._forPatternVariableDeclaration);
    super.visitPatternVariableDeclaration(node);
  }

  @override
  void visitPatternVariableDeclarationStatement(
      PatternVariableDeclarationStatement node) {
    _runSubscriptions(node, _registry._forPatternVariableDeclarationStatement);
    super.visitPatternVariableDeclarationStatement(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _runSubscriptions(node, _registry._forPostfixExpression);
    super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _runSubscriptions(node, _registry._forPrefixedIdentifier);
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _runSubscriptions(node, _registry._forPrefixExpression);
    super.visitPrefixExpression(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    _runSubscriptions(node, _registry._forPropertyAccess);
    super.visitPropertyAccess(node);
  }

  @override
  void visitRecordLiteral(RecordLiteral node) {
    _runSubscriptions(node, _registry._forRecordLiteral);
    super.visitRecordLiteral(node);
  }

  @override
  void visitRecordPattern(RecordPattern node) {
    _runSubscriptions(node, _registry._forRecordPattern);
    super.visitRecordPattern(node);
  }

  @override
  void visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotation);
    super.visitRecordTypeAnnotation(node);
  }

  @override
  void visitRecordTypeAnnotationField(RecordTypeAnnotationField node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotationField);
    super.visitRecordTypeAnnotationField(node);
  }

  @override
  void visitRecordTypeAnnotationNamedField(
      RecordTypeAnnotationNamedField node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotationNamedField);
    super.visitRecordTypeAnnotationNamedField(node);
  }

  @override
  void visitRecordTypeAnnotationNamedFields(
      RecordTypeAnnotationNamedFields node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotationNamedFields);
    super.visitRecordTypeAnnotationNamedFields(node);
  }

  @override
  void visitRecordTypeAnnotationPositionalField(
      RecordTypeAnnotationPositionalField node) {
    _runSubscriptions(node, _registry._forRecordTypeAnnotationPositionalField);
    super.visitRecordTypeAnnotationPositionalField(node);
  }

  @override
  void visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    _runSubscriptions(node, _registry._forRedirectingConstructorInvocation);
    super.visitRedirectingConstructorInvocation(node);
  }

  @override
  void visitRelationalPattern(RelationalPattern node) {
    _runSubscriptions(node, _registry._forRelationalPattern);
    super.visitRelationalPattern(node);
  }

  @override
  void visitRestPatternElement(RestPatternElement node) {
    _runSubscriptions(node, _registry._forRestPatternElement);
    super.visitRestPatternElement(node);
  }

  @override
  void visitRethrowExpression(RethrowExpression node) {
    _runSubscriptions(node, _registry._forRethrowExpression);
    super.visitRethrowExpression(node);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    _runSubscriptions(node, _registry._forReturnStatement);
    super.visitReturnStatement(node);
  }

  @override
  void visitScriptTag(ScriptTag node) {
    _runSubscriptions(node, _registry._forScriptTag);
    super.visitScriptTag(node);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _runSubscriptions(node, _registry._forSetOrMapLiteral);
    super.visitSetOrMapLiteral(node);
  }

  @override
  void visitShowCombinator(ShowCombinator node) {
    _runSubscriptions(node, _registry._forShowCombinator);
    super.visitShowCombinator(node);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    _runSubscriptions(node, _registry._forSimpleFormalParameter);
    super.visitSimpleFormalParameter(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _runSubscriptions(node, _registry._forSimpleIdentifier);
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _runSubscriptions(node, _registry._forSimpleStringLiteral);
    super.visitSimpleStringLiteral(node);
  }

  @override
  void visitSingleStringLiteral(SingleStringLiteral node) {
    _runSubscriptions(node, _registry._forSingleStringLiteral);
    super.visitSingleStringLiteral(node);
  }

  @override
  void visitSpreadElement(SpreadElement node) {
    _runSubscriptions(node, _registry._forSpreadElement);
    super.visitSpreadElement(node);
  }

  @override
  void visitStatement(Statement node) {
    _runSubscriptions(node, _registry._forStatement);
    super.visitStatement(node);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _runSubscriptions(node, _registry._forStringInterpolation);
    super.visitStringInterpolation(node);
  }

  @override
  void visitStringLiteral(StringLiteral node) {
    _runSubscriptions(node, _registry._forStringLiteral);
    super.visitStringLiteral(node);
  }

  @override
  void visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    _runSubscriptions(node, _registry._forSuperConstructorInvocation);
    super.visitSuperConstructorInvocation(node);
  }

  @override
  void visitSuperExpression(SuperExpression node) {
    _runSubscriptions(node, _registry._forSuperExpression);
    super.visitSuperExpression(node);
  }

  @override
  void visitSuperFormalParameter(SuperFormalParameter node) {
    _runSubscriptions(node, _registry._forSuperFormalParameter);
    super.visitSuperFormalParameter(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _runSubscriptions(node, _registry._forSwitchCase);
    super.visitSwitchCase(node);
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _runSubscriptions(node, _registry._forSwitchDefault);
    super.visitSwitchDefault(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    _runSubscriptions(node, _registry._forSwitchExpression);
    super.visitSwitchExpression(node);
  }

  @override
  void visitSwitchExpressionCase(SwitchExpressionCase node) {
    _runSubscriptions(node, _registry._forSwitchExpressionCase);
    super.visitSwitchExpressionCase(node);
  }

  @override
  void visitSwitchMember(SwitchMember node) {
    _runSubscriptions(node, _registry._forSwitchMember);
    super.visitSwitchMember(node);
  }

  @override
  void visitSwitchPatternCase(SwitchPatternCase node) {
    _runSubscriptions(node, _registry._forSwitchPatternCase);
    super.visitSwitchPatternCase(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _runSubscriptions(node, _registry._forSwitchStatement);
    super.visitSwitchStatement(node);
  }

  @override
  void visitSymbolLiteral(SymbolLiteral node) {
    _runSubscriptions(node, _registry._forSymbolLiteral);
    super.visitSymbolLiteral(node);
  }

  @override
  void visitThisExpression(ThisExpression node) {
    _runSubscriptions(node, _registry._forThisExpression);
    super.visitThisExpression(node);
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    _runSubscriptions(node, _registry._forThrowExpression);
    super.visitThrowExpression(node);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    _runSubscriptions(node, _registry._forTopLevelVariableDeclaration);
    super.visitTopLevelVariableDeclaration(node);
  }

  @override
  void visitTryStatement(TryStatement node) {
    _runSubscriptions(node, _registry._forTryStatement);
    super.visitTryStatement(node);
  }

  @override
  void visitTypeAlias(TypeAlias node) {
    _runSubscriptions(node, _registry._forTypeAlias);
    super.visitTypeAlias(node);
  }

  @override
  void visitTypeAnnotation(TypeAnnotation node) {
    _runSubscriptions(node, _registry._forTypeAnnotation);
    super.visitTypeAnnotation(node);
  }

  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    _runSubscriptions(node, _registry._forTypeArgumentList);
    super.visitTypeArgumentList(node);
  }

  @override
  void visitTypedLiteral(TypedLiteral node) {
    _runSubscriptions(node, _registry._forTypedLiteral);
    super.visitTypedLiteral(node);
  }

  @override
  void visitTypeLiteral(TypeLiteral node) {
    _runSubscriptions(node, _registry._forTypeLiteral);
    super.visitTypeLiteral(node);
  }

  @override
  void visitTypeParameter(TypeParameter node) {
    _runSubscriptions(node, _registry._forTypeParameter);
    super.visitTypeParameter(node);
  }

  @override
  void visitTypeParameterList(TypeParameterList node) {
    _runSubscriptions(node, _registry._forTypeParameterList);
    super.visitTypeParameterList(node);
  }

  @override
  void visitUriBasedDirective(UriBasedDirective node) {
    _runSubscriptions(node, _registry._forUriBasedDirective);
    super.visitUriBasedDirective(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _runSubscriptions(node, _registry._forVariableDeclaration);
    super.visitVariableDeclaration(node);
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    _runSubscriptions(node, _registry._forVariableDeclarationList);
    super.visitVariableDeclarationList(node);
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    _runSubscriptions(node, _registry._forVariableDeclarationStatement);
    super.visitVariableDeclarationStatement(node);
  }

  @override
  void visitWhenClause(WhenClause node) {
    _runSubscriptions(node, _registry._forWhenClause);
    super.visitWhenClause(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _runSubscriptions(node, _registry._forWhileStatement);
    super.visitWhileStatement(node);
  }

  @override
  void visitWildcardPattern(WildcardPattern node) {
    _runSubscriptions(node, _registry._forWildcardPattern);
    super.visitWildcardPattern(node);
  }

  @override
  void visitWithClause(WithClause node) {
    _runSubscriptions(node, _registry._forWithClause);
    super.visitWithClause(node);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _runSubscriptions(node, _registry._forYieldStatement);
    super.visitYieldStatement(node);
  }
}

/// A single subscription for a node type, by the specified "key"
class _Subscription<T> {
  _Subscription(this.listener, this.timer, this.zone);

  final void Function(T node) listener;
  final Stopwatch? timer;
  final Zone zone;
}

/// The container to register visitors for separate AST node types.
@internal
class NodeLintRegistry {
  /// The container to register visitors for separate AST node types.
  @internal
  NodeLintRegistry(this._lintRegistry, {required bool enableTiming})
      : _enableTiming = enableTiming;

  final LintRegistry _lintRegistry;
  final bool _enableTiming;

  /// Get the timer associated with the given [key].
  Stopwatch? _getTimer(String key) {
    if (_enableTiming) {
      return _lintRegistry.getTimer(key);
    } else {
      return null;
    }
  }

  final List<_Subscription<AdjacentStrings>> _forAdjacentStrings = [];
  void addAdjacentStrings(
      String key, void Function(AdjacentStrings node) listener) {
    _forAdjacentStrings
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AnnotatedNode>> _forAnnotatedNode = [];
  void addAnnotatedNode(
      String key, void Function(AnnotatedNode node) listener) {
    _forAnnotatedNode
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Annotation>> _forAnnotation = [];
  void addAnnotation(String key, void Function(Annotation node) listener) {
    _forAnnotation.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ArgumentList>> _forArgumentList = [];
  void addArgumentList(String key, void Function(ArgumentList node) listener) {
    _forArgumentList.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AsExpression>> _forAsExpression = [];
  void addAsExpression(String key, void Function(AsExpression node) listener) {
    _forAsExpression.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AssertInitializer>> _forAssertInitializer = [];
  void addAssertInitializer(
      String key, void Function(AssertInitializer node) listener) {
    _forAssertInitializer
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AssertStatement>> _forAssertStatement = [];
  void addAssertStatement(
      String key, void Function(AssertStatement node) listener) {
    _forAssertStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AssignedVariablePattern>>
      _forAssignedVariablePattern = [];
  void addAssignedVariablePattern(
      String key, void Function(AssignedVariablePattern node) listener) {
    _forAssignedVariablePattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AssignmentExpression>> _forAssignmentExpression = [];
  void addAssignmentExpression(
      String key, void Function(AssignmentExpression node) listener) {
    _forAssignmentExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AugmentationImportDirective>>
      _forAugmentationImportDirective = [];
  void addAugmentationImportDirective(
      String key, void Function(AugmentationImportDirective node) listener) {
    _forAugmentationImportDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AwaitExpression>> _forAwaitExpression = [];
  void addAwaitExpression(
      String key, void Function(AwaitExpression node) listener) {
    _forAwaitExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<BinaryExpression>> _forBinaryExpression = [];
  void addBinaryExpression(
      String key, void Function(BinaryExpression node) listener) {
    _forBinaryExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Block>> _forBlock = [];
  void addBlock(String key, void Function(Block node) listener) {
    _forBlock.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<BlockFunctionBody>> _forBlockFunctionBody = [];
  void addBlockFunctionBody(
      String key, void Function(BlockFunctionBody node) listener) {
    _forBlockFunctionBody
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<BooleanLiteral>> _forBooleanLiteral = [];
  void addBooleanLiteral(
      String key, void Function(BooleanLiteral node) listener) {
    _forBooleanLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<BreakStatement>> _forBreakStatement = [];
  void addBreakStatement(
      String key, void Function(BreakStatement node) listener) {
    _forBreakStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CascadeExpression>> _forCascadeExpression = [];
  void addCascadeExpression(
      String key, void Function(CascadeExpression node) listener) {
    _forCascadeExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CaseClause>> _forCaseClause = [];
  void addCaseClause(String key, void Function(CaseClause node) listener) {
    _forCaseClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CastPattern>> _forCastPattern = [];
  void addCastPattern(String key, void Function(CastPattern node) listener) {
    _forCastPattern.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CatchClause>> _forCatchClause = [];
  void addCatchClause(String key, void Function(CatchClause node) listener) {
    _forCatchClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CatchClauseParameter>> _forCatchClauseParameter = [];
  void addCatchClauseParameter(
      String key, void Function(CatchClauseParameter node) listener) {
    _forCatchClauseParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ClassDeclaration>> _forClassDeclaration = [];
  void addClassDeclaration(
      String key, void Function(ClassDeclaration node) listener) {
    _forClassDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ClassMember>> _forClassMember = [];
  void addClassMember(String key, void Function(ClassMember node) listener) {
    _forClassMember.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ClassTypeAlias>> _forClassTypeAlias = [];
  void addClassTypeAlias(
      String key, void Function(ClassTypeAlias node) listener) {
    _forClassTypeAlias
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CollectionElement>> _forCollectionElement = [];
  void addCollectionElement(
      String key, void Function(CollectionElement node) listener) {
    _forCollectionElement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Combinator>> _forCombinator = [];
  void addCombinator(String key, void Function(Combinator node) listener) {
    _forCombinator.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Comment>> _forComment = [];
  void addComment(String key, void Function(Comment node) listener) {
    _forComment.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CommentReference>> _forCommentReference = [];
  void addCommentReference(
      String key, void Function(CommentReference node) listener) {
    _forCommentReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CompilationUnit>> _forCompilationUnit = [];
  void addCompilationUnit(
      String key, void Function(CompilationUnit node) listener) {
    _forCompilationUnit
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<CompilationUnitMember>> _forCompilationUnitMember =
      [];
  void addCompilationUnitMember(
      String key, void Function(CompilationUnitMember node) listener) {
    _forCompilationUnitMember
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ConditionalExpression>> _forConditionalExpression =
      [];
  void addConditionalExpression(
      String key, void Function(ConditionalExpression node) listener) {
    _forConditionalExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Configuration>> _forConfiguration = [];
  void addConfiguration(
      String key, void Function(Configuration node) listener) {
    _forConfiguration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ConstantPattern>> _forConstantPattern = [];
  void addConstantPattern(
      String key, void Function(ConstantPattern node) listener) {
    _forConstantPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ConstructorDeclaration>> _forConstructorDeclaration =
      [];
  void addConstructorDeclaration(
      String key, void Function(ConstructorDeclaration node) listener) {
    _forConstructorDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ConstructorFieldInitializer>>
      _forConstructorFieldInitializer = [];
  void addConstructorFieldInitializer(
      String key, void Function(ConstructorFieldInitializer node) listener) {
    _forConstructorFieldInitializer
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ConstructorInitializer>> _forConstructorInitializer =
      [];
  void addConstructorInitializer(
      String key, void Function(ConstructorInitializer node) listener) {
    _forConstructorInitializer
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ConstructorName>> _forConstructorName = [];
  void addConstructorName(
      String key, void Function(ConstructorName node) listener) {
    _forConstructorName
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ConstructorReference>> _forConstructorReference = [];
  void addConstructorReference(
      String key, void Function(ConstructorReference node) listener) {
    _forConstructorReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ConstructorSelector>> _forConstructorSelector = [];
  void addConstructorSelector(
      String key, void Function(ConstructorSelector node) listener) {
    _forConstructorSelector
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ContinueStatement>> _forContinueStatement = [];
  void addContinueStatement(
      String key, void Function(ContinueStatement node) listener) {
    _forContinueStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<DartPattern>> _forDartPattern = [];
  void addDartPattern(String key, void Function(DartPattern node) listener) {
    _forDartPattern.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Declaration>> _forDeclaration = [];
  void addDeclaration(String key, void Function(Declaration node) listener) {
    _forDeclaration.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<DeclaredIdentifier>> _forDeclaredIdentifier = [];
  void addDeclaredIdentifier(
      String key, void Function(DeclaredIdentifier node) listener) {
    _forDeclaredIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<DeclaredVariablePattern>>
      _forDeclaredVariablePattern = [];
  void addDeclaredVariablePattern(
      String key, void Function(DeclaredVariablePattern node) listener) {
    _forDeclaredVariablePattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<DefaultFormalParameter>> _forDefaultFormalParameter =
      [];
  void addDefaultFormalParameter(
      String key, void Function(DefaultFormalParameter node) listener) {
    _forDefaultFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Directive>> _forDirective = [];
  void addDirective(String key, void Function(Directive node) listener) {
    _forDirective.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<DoStatement>> _forDoStatement = [];
  void addDoStatement(String key, void Function(DoStatement node) listener) {
    _forDoStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<DottedName>> _forDottedName = [];
  void addDottedName(String key, void Function(DottedName node) listener) {
    _forDottedName.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<DoubleLiteral>> _forDoubleLiteral = [];
  void addDoubleLiteral(
      String key, void Function(DoubleLiteral node) listener) {
    _forDoubleLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<EmptyFunctionBody>> _forEmptyFunctionBody = [];
  void addEmptyFunctionBody(
      String key, void Function(EmptyFunctionBody node) listener) {
    _forEmptyFunctionBody
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<EmptyStatement>> _forEmptyStatement = [];
  void addEmptyStatement(
      String key, void Function(EmptyStatement node) listener) {
    _forEmptyStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<EnumConstantArguments>> _forEnumConstantArguments =
      [];
  void addEnumConstantArguments(
      String key, void Function(EnumConstantArguments node) listener) {
    _forEnumConstantArguments
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<EnumConstantDeclaration>>
      _forEnumConstantDeclaration = [];
  void addEnumConstantDeclaration(
      String key, void Function(EnumConstantDeclaration node) listener) {
    _forEnumConstantDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<EnumDeclaration>> _forEnumDeclaration = [];
  void addEnumDeclaration(
      String key, void Function(EnumDeclaration node) listener) {
    _forEnumDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ExportDirective>> _forExportDirective = [];
  void addExportDirective(
      String key, void Function(ExportDirective node) listener) {
    _forExportDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Expression>> _forExpression = [];
  void addExpression(String key, void Function(Expression node) listener) {
    _forExpression.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ExpressionFunctionBody>> _forExpressionFunctionBody =
      [];
  void addExpressionFunctionBody(
      String key, void Function(ExpressionFunctionBody node) listener) {
    _forExpressionFunctionBody
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ExpressionStatement>> _forExpressionStatement = [];
  void addExpressionStatement(
      String key, void Function(ExpressionStatement node) listener) {
    _forExpressionStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ExtendsClause>> _forExtendsClause = [];
  void addExtendsClause(
      String key, void Function(ExtendsClause node) listener) {
    _forExtendsClause
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ExtensionDeclaration>> _forExtensionDeclaration = [];
  void addExtensionDeclaration(
      String key, void Function(ExtensionDeclaration node) listener) {
    _forExtensionDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ExtensionOverride>> _forExtensionOverride = [];
  void addExtensionOverride(
      String key, void Function(ExtensionOverride node) listener) {
    _forExtensionOverride
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FieldDeclaration>> _forFieldDeclaration = [];
  void addFieldDeclaration(
      String key, void Function(FieldDeclaration node) listener) {
    _forFieldDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FieldFormalParameter>> _forFieldFormalParameter = [];
  void addFieldFormalParameter(
      String key, void Function(FieldFormalParameter node) listener) {
    _forFieldFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForEachParts>> _forForEachParts = [];
  void addForEachParts(String key, void Function(ForEachParts node) listener) {
    _forForEachParts.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForEachPartsWithDeclaration>>
      _forForEachPartsWithDeclaration = [];
  void addForEachPartsWithDeclaration(
      String key, void Function(ForEachPartsWithDeclaration node) listener) {
    _forForEachPartsWithDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForEachPartsWithIdentifier>>
      _forForEachPartsWithIdentifier = [];
  void addForEachPartsWithIdentifier(
      String key, void Function(ForEachPartsWithIdentifier node) listener) {
    _forForEachPartsWithIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForEachPartsWithPattern>>
      _forForEachPartsWithPattern = [];
  void addForEachPartsWithPattern(
      String key, void Function(ForEachPartsWithPattern node) listener) {
    _forForEachPartsWithPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForElement>> _forForElement = [];
  void addForElement(String key, void Function(ForElement node) listener) {
    _forForElement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FormalParameter>> _forFormalParameter = [];
  void addFormalParameter(
      String key, void Function(FormalParameter node) listener) {
    _forFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FormalParameterList>> _forFormalParameterList = [];
  void addFormalParameterList(
      String key, void Function(FormalParameterList node) listener) {
    _forFormalParameterList
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForParts>> _forForParts = [];
  void addForParts(String key, void Function(ForParts node) listener) {
    _forForParts.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForPartsWithDeclarations>>
      _forForPartsWithDeclarations = [];
  void addForPartsWithDeclarations(
      String key, void Function(ForPartsWithDeclarations node) listener) {
    _forForPartsWithDeclarations
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForPartsWithExpression>> _forForPartsWithExpression =
      [];
  void addForPartsWithExpression(
      String key, void Function(ForPartsWithExpression node) listener) {
    _forForPartsWithExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForPartsWithPattern>> _forForPartsWithPattern = [];
  void addForPartsWithPattern(
      String key, void Function(ForPartsWithPattern node) listener) {
    _forForPartsWithPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ForStatement>> _forForStatement = [];
  void addForStatement(String key, void Function(ForStatement node) listener) {
    _forForStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FunctionBody>> _forFunctionBody = [];
  void addFunctionBody(String key, void Function(FunctionBody node) listener) {
    _forFunctionBody.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FunctionDeclaration>> _forFunctionDeclaration = [];
  void addFunctionDeclaration(
      String key, void Function(FunctionDeclaration node) listener) {
    _forFunctionDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FunctionDeclarationStatement>>
      _forFunctionDeclarationStatement = [];
  void addFunctionDeclarationStatement(
      String key, void Function(FunctionDeclarationStatement node) listener) {
    _forFunctionDeclarationStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FunctionExpression>> _forFunctionExpression = [];
  void addFunctionExpression(
      String key, void Function(FunctionExpression node) listener) {
    _forFunctionExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FunctionExpressionInvocation>>
      _forFunctionExpressionInvocation = [];
  void addFunctionExpressionInvocation(
      String key, void Function(FunctionExpressionInvocation node) listener) {
    _forFunctionExpressionInvocation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FunctionReference>> _forFunctionReference = [];
  void addFunctionReference(
      String key, void Function(FunctionReference node) listener) {
    _forFunctionReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FunctionTypeAlias>> _forFunctionTypeAlias = [];
  void addFunctionTypeAlias(
      String key, void Function(FunctionTypeAlias node) listener) {
    _forFunctionTypeAlias
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<FunctionTypedFormalParameter>>
      _forFunctionTypedFormalParameter = [];
  void addFunctionTypedFormalParameter(
      String key, void Function(FunctionTypedFormalParameter node) listener) {
    _forFunctionTypedFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<GenericFunctionType>> _forGenericFunctionType = [];
  void addGenericFunctionType(
      String key, void Function(GenericFunctionType node) listener) {
    _forGenericFunctionType
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<GenericTypeAlias>> _forGenericTypeAlias = [];
  void addGenericTypeAlias(
      String key, void Function(GenericTypeAlias node) listener) {
    _forGenericTypeAlias
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<GuardedPattern>> _forGuardedPattern = [];
  void addGuardedPattern(
      String key, void Function(GuardedPattern node) listener) {
    _forGuardedPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<HideCombinator>> _forHideCombinator = [];
  void addHideCombinator(
      String key, void Function(HideCombinator node) listener) {
    _forHideCombinator
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Identifier>> _forIdentifier = [];
  void addIdentifier(String key, void Function(Identifier node) listener) {
    _forIdentifier.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<IfElement>> _forIfElement = [];
  void addIfElement(String key, void Function(IfElement node) listener) {
    _forIfElement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<IfStatement>> _forIfStatement = [];
  void addIfStatement(String key, void Function(IfStatement node) listener) {
    _forIfStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ImplementsClause>> _forImplementsClause = [];
  void addImplementsClause(
      String key, void Function(ImplementsClause node) listener) {
    _forImplementsClause
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ImplicitCallReference>> _forImplicitCallReference =
      [];
  void addImplicitCallReference(
      String key, void Function(ImplicitCallReference node) listener) {
    _forImplicitCallReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ImportDirective>> _forImportDirective = [];
  void addImportDirective(
      String key, void Function(ImportDirective node) listener) {
    _forImportDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ImportPrefixReference>> _forImportPrefixReference =
      [];
  void addImportPrefixReference(
      String key, void Function(ImportPrefixReference node) listener) {
    _forImportPrefixReference
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<IndexExpression>> _forIndexExpression = [];
  void addIndexExpression(
      String key, void Function(IndexExpression node) listener) {
    _forIndexExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<InstanceCreationExpression>>
      _forInstanceCreationExpression = [];
  void addInstanceCreationExpression(
      String key, void Function(InstanceCreationExpression node) listener) {
    _forInstanceCreationExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<IntegerLiteral>> _forIntegerLiteral = [];
  void addIntegerLiteral(
      String key, void Function(IntegerLiteral node) listener) {
    _forIntegerLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<InterpolationElement>> _forInterpolationElement = [];
  void addInterpolationElement(
      String key, void Function(InterpolationElement node) listener) {
    _forInterpolationElement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<InterpolationExpression>>
      _forInterpolationExpression = [];
  void addInterpolationExpression(
      String key, void Function(InterpolationExpression node) listener) {
    _forInterpolationExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<InterpolationString>> _forInterpolationString = [];
  void addInterpolationString(
      String key, void Function(InterpolationString node) listener) {
    _forInterpolationString
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<InvocationExpression>> _forInvocationExpression = [];
  void addInvocationExpression(
      String key, void Function(InvocationExpression node) listener) {
    _forInvocationExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<IsExpression>> _forIsExpression = [];
  void addIsExpression(String key, void Function(IsExpression node) listener) {
    _forIsExpression.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Label>> _forLabel = [];
  void addLabel(String key, void Function(Label node) listener) {
    _forLabel.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<LabeledStatement>> _forLabeledStatement = [];
  void addLabeledStatement(
      String key, void Function(LabeledStatement node) listener) {
    _forLabeledStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<LibraryAugmentationDirective>>
      _forLibraryAugmentationDirective = [];
  void addLibraryAugmentationDirective(
      String key, void Function(LibraryAugmentationDirective node) listener) {
    _forLibraryAugmentationDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<LibraryDirective>> _forLibraryDirective = [];
  void addLibraryDirective(
      String key, void Function(LibraryDirective node) listener) {
    _forLibraryDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<LibraryIdentifier>> _forLibraryIdentifier = [];
  void addLibraryIdentifier(
      String key, void Function(LibraryIdentifier node) listener) {
    _forLibraryIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ListLiteral>> _forListLiteral = [];
  void addListLiteral(String key, void Function(ListLiteral node) listener) {
    _forListLiteral.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ListPattern>> _forListPattern = [];
  void addListPattern(String key, void Function(ListPattern node) listener) {
    _forListPattern.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Literal>> _forLiteral = [];
  void addLiteral(String key, void Function(Literal node) listener) {
    _forLiteral.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<LogicalAndPattern>> _forLogicalAndPattern = [];
  void addLogicalAndPattern(
      String key, void Function(LogicalAndPattern node) listener) {
    _forLogicalAndPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<LogicalOrPattern>> _forLogicalOrPattern = [];
  void addLogicalOrPattern(
      String key, void Function(LogicalOrPattern node) listener) {
    _forLogicalOrPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<MapLiteralEntry>> _forMapLiteralEntry = [];
  void addMapLiteralEntry(
      String key, void Function(MapLiteralEntry node) listener) {
    _forMapLiteralEntry
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<MapPattern>> _forMapPattern = [];
  void addMapPattern(String key, void Function(MapPattern node) listener) {
    _forMapPattern.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<MapPatternEntry>> _forMapPatternEntry = [];
  void addMapPatternEntry(
      String key, void Function(MapPatternEntry node) listener) {
    _forMapPatternEntry
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<MethodDeclaration>> _forMethodDeclaration = [];
  void addMethodDeclaration(
      String key, void Function(MethodDeclaration node) listener) {
    _forMethodDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<MethodInvocation>> _forMethodInvocation = [];
  void addMethodInvocation(
      String key, void Function(MethodInvocation node) listener) {
    _forMethodInvocation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<MixinDeclaration>> _forMixinDeclaration = [];
  void addMixinDeclaration(
      String key, void Function(MixinDeclaration node) listener) {
    _forMixinDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NamedCompilationUnitMember>>
      _forNamedCompilationUnitMember = [];
  void addNamedCompilationUnitMember(
      String key, void Function(NamedCompilationUnitMember node) listener) {
    _forNamedCompilationUnitMember
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NamedExpression>> _forNamedExpression = [];
  void addNamedExpression(
      String key, void Function(NamedExpression node) listener) {
    _forNamedExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NamedType>> _forNamedType = [];
  void addNamedType(String key, void Function(NamedType node) listener) {
    _forNamedType.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NamespaceDirective>> _forNamespaceDirective = [];
  void addNamespaceDirective(
      String key, void Function(NamespaceDirective node) listener) {
    _forNamespaceDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NativeClause>> _forNativeClause = [];
  void addNativeClause(String key, void Function(NativeClause node) listener) {
    _forNativeClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NativeFunctionBody>> _forNativeFunctionBody = [];
  void addNativeFunctionBody(
      String key, void Function(NativeFunctionBody node) listener) {
    _forNativeFunctionBody
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<AstNode>> _forAstNode = [];
  void addNode(String key, void Function(AstNode node) listener) {
    _forAstNode.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NormalFormalParameter>> _forNormalFormalParameter =
      [];
  void addNormalFormalParameter(
      String key, void Function(NormalFormalParameter node) listener) {
    _forNormalFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NullAssertPattern>> _forNullAssertPattern = [];
  void addNullAssertPattern(
      String key, void Function(NullAssertPattern node) listener) {
    _forNullAssertPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NullCheckPattern>> _forNullCheckPattern = [];
  void addNullCheckPattern(
      String key, void Function(NullCheckPattern node) listener) {
    _forNullCheckPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<NullLiteral>> _forNullLiteral = [];
  void addNullLiteral(String key, void Function(NullLiteral node) listener) {
    _forNullLiteral.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ObjectPattern>> _forObjectPattern = [];
  void addObjectPattern(
      String key, void Function(ObjectPattern node) listener) {
    _forObjectPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<OnClause>> _forOnClause = [];
  void addOnClause(String key, void Function(OnClause node) listener) {
    _forOnClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ParenthesizedExpression>>
      _forParenthesizedExpression = [];
  void addParenthesizedExpression(
      String key, void Function(ParenthesizedExpression node) listener) {
    _forParenthesizedExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ParenthesizedPattern>> _forParenthesizedPattern = [];
  void addParenthesizedPattern(
      String key, void Function(ParenthesizedPattern node) listener) {
    _forParenthesizedPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PartDirective>> _forPartDirective = [];
  void addPartDirective(
      String key, void Function(PartDirective node) listener) {
    _forPartDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PartOfDirective>> _forPartOfDirective = [];
  void addPartOfDirective(
      String key, void Function(PartOfDirective node) listener) {
    _forPartOfDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PatternAssignment>> _forPatternAssignment = [];
  void addPatternAssignment(
      String key, void Function(PatternAssignment node) listener) {
    _forPatternAssignment
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PatternField>> _forPatternField = [];
  void addPatternField(String key, void Function(PatternField node) listener) {
    _forPatternField.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PatternFieldName>> _forPatternFieldName = [];
  void addPatternFieldName(
      String key, void Function(PatternFieldName node) listener) {
    _forPatternFieldName
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PatternVariableDeclaration>>
      _forPatternVariableDeclaration = [];
  void addPatternVariableDeclaration(
      String key, void Function(PatternVariableDeclaration node) listener) {
    _forPatternVariableDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PatternVariableDeclarationStatement>>
      _forPatternVariableDeclarationStatement = [];
  void addPatternVariableDeclarationStatement(String key,
      void Function(PatternVariableDeclarationStatement node) listener) {
    _forPatternVariableDeclarationStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PostfixExpression>> _forPostfixExpression = [];
  void addPostfixExpression(
      String key, void Function(PostfixExpression node) listener) {
    _forPostfixExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PrefixedIdentifier>> _forPrefixedIdentifier = [];
  void addPrefixedIdentifier(
      String key, void Function(PrefixedIdentifier node) listener) {
    _forPrefixedIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PrefixExpression>> _forPrefixExpression = [];
  void addPrefixExpression(
      String key, void Function(PrefixExpression node) listener) {
    _forPrefixExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<PropertyAccess>> _forPropertyAccess = [];
  void addPropertyAccess(
      String key, void Function(PropertyAccess node) listener) {
    _forPropertyAccess
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RecordLiteral>> _forRecordLiteral = [];
  void addRecordLiteral(
      String key, void Function(RecordLiteral node) listener) {
    _forRecordLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RecordPattern>> _forRecordPattern = [];
  void addRecordPattern(
      String key, void Function(RecordPattern node) listener) {
    _forRecordPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RecordTypeAnnotation>> _forRecordTypeAnnotation = [];
  void addRecordTypeAnnotation(
      String key, void Function(RecordTypeAnnotation node) listener) {
    _forRecordTypeAnnotation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RecordTypeAnnotationField>>
      _forRecordTypeAnnotationField = [];
  void addRecordTypeAnnotationField(
      String key, void Function(RecordTypeAnnotationField node) listener) {
    _forRecordTypeAnnotationField
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RecordTypeAnnotationNamedField>>
      _forRecordTypeAnnotationNamedField = [];
  void addRecordTypeAnnotationNamedField(
      String key, void Function(RecordTypeAnnotationNamedField node) listener) {
    _forRecordTypeAnnotationNamedField
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RecordTypeAnnotationNamedFields>>
      _forRecordTypeAnnotationNamedFields = [];
  void addRecordTypeAnnotationNamedFields(String key,
      void Function(RecordTypeAnnotationNamedFields node) listener) {
    _forRecordTypeAnnotationNamedFields
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RecordTypeAnnotationPositionalField>>
      _forRecordTypeAnnotationPositionalField = [];
  void addRecordTypeAnnotationPositionalField(String key,
      void Function(RecordTypeAnnotationPositionalField node) listener) {
    _forRecordTypeAnnotationPositionalField
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RedirectingConstructorInvocation>>
      _forRedirectingConstructorInvocation = [];
  void addRedirectingConstructorInvocation(String key,
      void Function(RedirectingConstructorInvocation node) listener) {
    _forRedirectingConstructorInvocation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RelationalPattern>> _forRelationalPattern = [];
  void addRelationalPattern(
      String key, void Function(RelationalPattern node) listener) {
    _forRelationalPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RestPatternElement>> _forRestPatternElement = [];
  void addRestPatternElement(
      String key, void Function(RestPatternElement node) listener) {
    _forRestPatternElement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<RethrowExpression>> _forRethrowExpression = [];
  void addRethrowExpression(
      String key, void Function(RethrowExpression node) listener) {
    _forRethrowExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ReturnStatement>> _forReturnStatement = [];
  void addReturnStatement(
      String key, void Function(ReturnStatement node) listener) {
    _forReturnStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ScriptTag>> _forScriptTag = [];
  void addScriptTag(String key, void Function(ScriptTag node) listener) {
    _forScriptTag.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SetOrMapLiteral>> _forSetOrMapLiteral = [];
  void addSetOrMapLiteral(
      String key, void Function(SetOrMapLiteral node) listener) {
    _forSetOrMapLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ShowCombinator>> _forShowCombinator = [];
  void addShowCombinator(
      String key, void Function(ShowCombinator node) listener) {
    _forShowCombinator
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SimpleFormalParameter>> _forSimpleFormalParameter =
      [];
  void addSimpleFormalParameter(
      String key, void Function(SimpleFormalParameter node) listener) {
    _forSimpleFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SimpleIdentifier>> _forSimpleIdentifier = [];
  void addSimpleIdentifier(
      String key, void Function(SimpleIdentifier node) listener) {
    _forSimpleIdentifier
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SimpleStringLiteral>> _forSimpleStringLiteral = [];
  void addSimpleStringLiteral(
      String key, void Function(SimpleStringLiteral node) listener) {
    _forSimpleStringLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SingleStringLiteral>> _forSingleStringLiteral = [];
  void addSingleStringLiteral(
      String key, void Function(SingleStringLiteral node) listener) {
    _forSingleStringLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SpreadElement>> _forSpreadElement = [];
  void addSpreadElement(
      String key, void Function(SpreadElement node) listener) {
    _forSpreadElement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<Statement>> _forStatement = [];
  void addStatement(String key, void Function(Statement node) listener) {
    _forStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<StringInterpolation>> _forStringInterpolation = [];
  void addStringInterpolation(
      String key, void Function(StringInterpolation node) listener) {
    _forStringInterpolation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<StringLiteral>> _forStringLiteral = [];
  void addStringLiteral(
      String key, void Function(StringLiteral node) listener) {
    _forStringLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SuperConstructorInvocation>>
      _forSuperConstructorInvocation = [];
  void addSuperConstructorInvocation(
      String key, void Function(SuperConstructorInvocation node) listener) {
    _forSuperConstructorInvocation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SuperExpression>> _forSuperExpression = [];
  void addSuperExpression(
      String key, void Function(SuperExpression node) listener) {
    _forSuperExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SuperFormalParameter>> _forSuperFormalParameter = [];
  void addSuperFormalParameter(
      String key, void Function(SuperFormalParameter node) listener) {
    _forSuperFormalParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SwitchCase>> _forSwitchCase = [];
  void addSwitchCase(String key, void Function(SwitchCase node) listener) {
    _forSwitchCase.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SwitchDefault>> _forSwitchDefault = [];
  void addSwitchDefault(
      String key, void Function(SwitchDefault node) listener) {
    _forSwitchDefault
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SwitchExpression>> _forSwitchExpression = [];
  void addSwitchExpression(
      String key, void Function(SwitchExpression node) listener) {
    _forSwitchExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SwitchExpressionCase>> _forSwitchExpressionCase = [];
  void addSwitchExpressionCase(
      String key, void Function(SwitchExpressionCase node) listener) {
    _forSwitchExpressionCase
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SwitchMember>> _forSwitchMember = [];
  void addSwitchMember(String key, void Function(SwitchMember node) listener) {
    _forSwitchMember.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SwitchPatternCase>> _forSwitchPatternCase = [];
  void addSwitchPatternCase(
      String key, void Function(SwitchPatternCase node) listener) {
    _forSwitchPatternCase
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SwitchStatement>> _forSwitchStatement = [];
  void addSwitchStatement(
      String key, void Function(SwitchStatement node) listener) {
    _forSwitchStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<SymbolLiteral>> _forSymbolLiteral = [];
  void addSymbolLiteral(
      String key, void Function(SymbolLiteral node) listener) {
    _forSymbolLiteral
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ThisExpression>> _forThisExpression = [];
  void addThisExpression(
      String key, void Function(ThisExpression node) listener) {
    _forThisExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<ThrowExpression>> _forThrowExpression = [];
  void addThrowExpression(
      String key, void Function(ThrowExpression node) listener) {
    _forThrowExpression
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TopLevelVariableDeclaration>>
      _forTopLevelVariableDeclaration = [];
  void addTopLevelVariableDeclaration(
      String key, void Function(TopLevelVariableDeclaration node) listener) {
    _forTopLevelVariableDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TryStatement>> _forTryStatement = [];
  void addTryStatement(String key, void Function(TryStatement node) listener) {
    _forTryStatement.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TypeAlias>> _forTypeAlias = [];
  void addTypeAlias(String key, void Function(TypeAlias node) listener) {
    _forTypeAlias.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TypeAnnotation>> _forTypeAnnotation = [];
  void addTypeAnnotation(
      String key, void Function(TypeAnnotation node) listener) {
    _forTypeAnnotation
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TypeArgumentList>> _forTypeArgumentList = [];
  void addTypeArgumentList(
      String key, void Function(TypeArgumentList node) listener) {
    _forTypeArgumentList
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TypedLiteral>> _forTypedLiteral = [];
  void addTypedLiteral(String key, void Function(TypedLiteral node) listener) {
    _forTypedLiteral.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TypeLiteral>> _forTypeLiteral = [];
  void addTypeLiteral(String key, void Function(TypeLiteral node) listener) {
    _forTypeLiteral.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TypeParameter>> _forTypeParameter = [];
  void addTypeParameter(
      String key, void Function(TypeParameter node) listener) {
    _forTypeParameter
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<TypeParameterList>> _forTypeParameterList = [];
  void addTypeParameterList(
      String key, void Function(TypeParameterList node) listener) {
    _forTypeParameterList
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<UriBasedDirective>> _forUriBasedDirective = [];
  void addUriBasedDirective(
      String key, void Function(UriBasedDirective node) listener) {
    _forUriBasedDirective
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<VariableDeclaration>> _forVariableDeclaration = [];
  void addVariableDeclaration(
      String key, void Function(VariableDeclaration node) listener) {
    _forVariableDeclaration
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<VariableDeclarationList>>
      _forVariableDeclarationList = [];
  void addVariableDeclarationList(
      String key, void Function(VariableDeclarationList node) listener) {
    _forVariableDeclarationList
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<VariableDeclarationStatement>>
      _forVariableDeclarationStatement = [];
  void addVariableDeclarationStatement(
      String key, void Function(VariableDeclarationStatement node) listener) {
    _forVariableDeclarationStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<WhenClause>> _forWhenClause = [];
  void addWhenClause(String key, void Function(WhenClause node) listener) {
    _forWhenClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<WhileStatement>> _forWhileStatement = [];
  void addWhileStatement(
      String key, void Function(WhileStatement node) listener) {
    _forWhileStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<WildcardPattern>> _forWildcardPattern = [];
  void addWildcardPattern(
      String key, void Function(WildcardPattern node) listener) {
    _forWildcardPattern
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<WithClause>> _forWithClause = [];
  void addWithClause(String key, void Function(WithClause node) listener) {
    _forWithClause.add(_Subscription(listener, _getTimer(key), Zone.current));
  }

  final List<_Subscription<YieldStatement>> _forYieldStatement = [];
  void addYieldStatement(
      String key, void Function(YieldStatement node) listener) {
    _forYieldStatement
        .add(_Subscription(listener, _getTimer(key), Zone.current));
  }
}

class LintRuleNodeRegistry {
  LintRuleNodeRegistry(this.nodeLintRegistry, this.name);

  @internal
  final NodeLintRegistry nodeLintRegistry;

  @internal
  final String name;

  @preferInline
  void addAdjacentStrings(void Function(AdjacentStrings node) listener) {
    nodeLintRegistry.addAdjacentStrings(name, listener);
  }

  @preferInline
  void addAnnotatedNode(void Function(AnnotatedNode node) listener) {
    nodeLintRegistry.addAnnotatedNode(name, listener);
  }

  @preferInline
  void addAnnotation(void Function(Annotation node) listener) {
    nodeLintRegistry.addAnnotation(name, listener);
  }

  @preferInline
  void addArgumentList(void Function(ArgumentList node) listener) {
    nodeLintRegistry.addArgumentList(name, listener);
  }

  @preferInline
  void addAsExpression(void Function(AsExpression node) listener) {
    nodeLintRegistry.addAsExpression(name, listener);
  }

  @preferInline
  void addAssertInitializer(void Function(AssertInitializer node) listener) {
    nodeLintRegistry.addAssertInitializer(name, listener);
  }

  @preferInline
  void addAssertStatement(void Function(AssertStatement node) listener) {
    nodeLintRegistry.addAssertStatement(name, listener);
  }

  @preferInline
  void addAssignedVariablePattern(
      void Function(AssignedVariablePattern node) listener) {
    nodeLintRegistry.addAssignedVariablePattern(name, listener);
  }

  @preferInline
  void addAssignmentExpression(
      void Function(AssignmentExpression node) listener) {
    nodeLintRegistry.addAssignmentExpression(name, listener);
  }

  @preferInline
  void addAugmentationImportDirective(
      void Function(AugmentationImportDirective node) listener) {
    nodeLintRegistry.addAugmentationImportDirective(name, listener);
  }

  @preferInline
  void addAwaitExpression(void Function(AwaitExpression node) listener) {
    nodeLintRegistry.addAwaitExpression(name, listener);
  }

  @preferInline
  void addBinaryExpression(void Function(BinaryExpression node) listener) {
    nodeLintRegistry.addBinaryExpression(name, listener);
  }

  @preferInline
  void addBlock(void Function(Block node) listener) {
    nodeLintRegistry.addBlock(name, listener);
  }

  @preferInline
  void addBlockFunctionBody(void Function(BlockFunctionBody node) listener) {
    nodeLintRegistry.addBlockFunctionBody(name, listener);
  }

  @preferInline
  void addBooleanLiteral(void Function(BooleanLiteral node) listener) {
    nodeLintRegistry.addBooleanLiteral(name, listener);
  }

  @preferInline
  void addBreakStatement(void Function(BreakStatement node) listener) {
    nodeLintRegistry.addBreakStatement(name, listener);
  }

  @preferInline
  void addCascadeExpression(void Function(CascadeExpression node) listener) {
    nodeLintRegistry.addCascadeExpression(name, listener);
  }

  @preferInline
  void addCaseClause(void Function(CaseClause node) listener) {
    nodeLintRegistry.addCaseClause(name, listener);
  }

  @preferInline
  void addCastPattern(void Function(CastPattern node) listener) {
    nodeLintRegistry.addCastPattern(name, listener);
  }

  @preferInline
  void addCatchClause(void Function(CatchClause node) listener) {
    nodeLintRegistry.addCatchClause(name, listener);
  }

  @preferInline
  void addCatchClauseParameter(
      void Function(CatchClauseParameter node) listener) {
    nodeLintRegistry.addCatchClauseParameter(name, listener);
  }

  @preferInline
  void addClassDeclaration(void Function(ClassDeclaration node) listener) {
    nodeLintRegistry.addClassDeclaration(name, listener);
  }

  @preferInline
  void addClassMember(void Function(ClassMember node) listener) {
    nodeLintRegistry.addClassMember(name, listener);
  }

  @preferInline
  void addClassTypeAlias(void Function(ClassTypeAlias node) listener) {
    nodeLintRegistry.addClassTypeAlias(name, listener);
  }

  @preferInline
  void addCollectionElement(void Function(CollectionElement node) listener) {
    nodeLintRegistry.addCollectionElement(name, listener);
  }

  @preferInline
  void addCombinator(void Function(Combinator node) listener) {
    nodeLintRegistry.addCombinator(name, listener);
  }

  @preferInline
  void addComment(void Function(Comment node) listener) {
    nodeLintRegistry.addComment(name, listener);
  }

  @preferInline
  void addCommentReference(void Function(CommentReference node) listener) {
    nodeLintRegistry.addCommentReference(name, listener);
  }

  @preferInline
  void addCompilationUnit(void Function(CompilationUnit node) listener) {
    nodeLintRegistry.addCompilationUnit(name, listener);
  }

  @preferInline
  void addCompilationUnitMember(
      void Function(CompilationUnitMember node) listener) {
    nodeLintRegistry.addCompilationUnitMember(name, listener);
  }

  @preferInline
  void addConditionalExpression(
      void Function(ConditionalExpression node) listener) {
    nodeLintRegistry.addConditionalExpression(name, listener);
  }

  @preferInline
  void addConfiguration(void Function(Configuration node) listener) {
    nodeLintRegistry.addConfiguration(name, listener);
  }

  @preferInline
  void addConstantPattern(void Function(ConstantPattern node) listener) {
    nodeLintRegistry.addConstantPattern(name, listener);
  }

  @preferInline
  void addConstructorDeclaration(
      void Function(ConstructorDeclaration node) listener) {
    nodeLintRegistry.addConstructorDeclaration(name, listener);
  }

  @preferInline
  void addConstructorFieldInitializer(
      void Function(ConstructorFieldInitializer node) listener) {
    nodeLintRegistry.addConstructorFieldInitializer(name, listener);
  }

  @preferInline
  void addConstructorInitializer(
      void Function(ConstructorInitializer node) listener) {
    nodeLintRegistry.addConstructorInitializer(name, listener);
  }

  @preferInline
  void addConstructorName(void Function(ConstructorName node) listener) {
    nodeLintRegistry.addConstructorName(name, listener);
  }

  @preferInline
  void addConstructorReference(
      void Function(ConstructorReference node) listener) {
    nodeLintRegistry.addConstructorReference(name, listener);
  }

  @preferInline
  void addConstructorSelector(
      void Function(ConstructorSelector node) listener) {
    nodeLintRegistry.addConstructorSelector(name, listener);
  }

  @preferInline
  void addContinueStatement(void Function(ContinueStatement node) listener) {
    nodeLintRegistry.addContinueStatement(name, listener);
  }

  @preferInline
  void addDartPattern(void Function(DartPattern node) listener) {
    nodeLintRegistry.addDartPattern(name, listener);
  }

  @preferInline
  void addDeclaration(void Function(Declaration node) listener) {
    nodeLintRegistry.addDeclaration(name, listener);
  }

  @preferInline
  void addDeclaredIdentifier(void Function(DeclaredIdentifier node) listener) {
    nodeLintRegistry.addDeclaredIdentifier(name, listener);
  }

  @preferInline
  void addDeclaredVariablePattern(
      void Function(DeclaredVariablePattern node) listener) {
    nodeLintRegistry.addDeclaredVariablePattern(name, listener);
  }

  @preferInline
  void addDefaultFormalParameter(
      void Function(DefaultFormalParameter node) listener) {
    nodeLintRegistry.addDefaultFormalParameter(name, listener);
  }

  @preferInline
  void addDirective(void Function(Directive node) listener) {
    nodeLintRegistry.addDirective(name, listener);
  }

  @preferInline
  void addDoStatement(void Function(DoStatement node) listener) {
    nodeLintRegistry.addDoStatement(name, listener);
  }

  @preferInline
  void addDottedName(void Function(DottedName node) listener) {
    nodeLintRegistry.addDottedName(name, listener);
  }

  @preferInline
  void addDoubleLiteral(void Function(DoubleLiteral node) listener) {
    nodeLintRegistry.addDoubleLiteral(name, listener);
  }

  @preferInline
  void addEmptyFunctionBody(void Function(EmptyFunctionBody node) listener) {
    nodeLintRegistry.addEmptyFunctionBody(name, listener);
  }

  @preferInline
  void addEmptyStatement(void Function(EmptyStatement node) listener) {
    nodeLintRegistry.addEmptyStatement(name, listener);
  }

  @preferInline
  void addEnumConstantArguments(
      void Function(EnumConstantArguments node) listener) {
    nodeLintRegistry.addEnumConstantArguments(name, listener);
  }

  @preferInline
  void addEnumConstantDeclaration(
      void Function(EnumConstantDeclaration node) listener) {
    nodeLintRegistry.addEnumConstantDeclaration(name, listener);
  }

  @preferInline
  void addEnumDeclaration(void Function(EnumDeclaration node) listener) {
    nodeLintRegistry.addEnumDeclaration(name, listener);
  }

  @preferInline
  void addExportDirective(void Function(ExportDirective node) listener) {
    nodeLintRegistry.addExportDirective(name, listener);
  }

  @preferInline
  void addExpression(void Function(Expression node) listener) {
    nodeLintRegistry.addExpression(name, listener);
  }

  @preferInline
  void addExpressionFunctionBody(
      void Function(ExpressionFunctionBody node) listener) {
    nodeLintRegistry.addExpressionFunctionBody(name, listener);
  }

  @preferInline
  void addExpressionStatement(
      void Function(ExpressionStatement node) listener) {
    nodeLintRegistry.addExpressionStatement(name, listener);
  }

  @preferInline
  void addExtendsClause(void Function(ExtendsClause node) listener) {
    nodeLintRegistry.addExtendsClause(name, listener);
  }

  @preferInline
  void addExtensionDeclaration(
      void Function(ExtensionDeclaration node) listener) {
    nodeLintRegistry.addExtensionDeclaration(name, listener);
  }

  @preferInline
  void addExtensionOverride(void Function(ExtensionOverride node) listener) {
    nodeLintRegistry.addExtensionOverride(name, listener);
  }

  @preferInline
  void addFieldDeclaration(void Function(FieldDeclaration node) listener) {
    nodeLintRegistry.addFieldDeclaration(name, listener);
  }

  @preferInline
  void addFieldFormalParameter(
      void Function(FieldFormalParameter node) listener) {
    nodeLintRegistry.addFieldFormalParameter(name, listener);
  }

  @preferInline
  void addForEachParts(void Function(ForEachParts node) listener) {
    nodeLintRegistry.addForEachParts(name, listener);
  }

  @preferInline
  void addForEachPartsWithDeclaration(
      void Function(ForEachPartsWithDeclaration node) listener) {
    nodeLintRegistry.addForEachPartsWithDeclaration(name, listener);
  }

  @preferInline
  void addForEachPartsWithIdentifier(
      void Function(ForEachPartsWithIdentifier node) listener) {
    nodeLintRegistry.addForEachPartsWithIdentifier(name, listener);
  }

  @preferInline
  void addForEachPartsWithPattern(
      void Function(ForEachPartsWithPattern node) listener) {
    nodeLintRegistry.addForEachPartsWithPattern(name, listener);
  }

  @preferInline
  void addForElement(void Function(ForElement node) listener) {
    nodeLintRegistry.addForElement(name, listener);
  }

  @preferInline
  void addFormalParameter(void Function(FormalParameter node) listener) {
    nodeLintRegistry.addFormalParameter(name, listener);
  }

  @preferInline
  void addFormalParameterList(
      void Function(FormalParameterList node) listener) {
    nodeLintRegistry.addFormalParameterList(name, listener);
  }

  @preferInline
  void addForParts(void Function(ForParts node) listener) {
    nodeLintRegistry.addForParts(name, listener);
  }

  @preferInline
  void addForPartsWithDeclarations(
      void Function(ForPartsWithDeclarations node) listener) {
    nodeLintRegistry.addForPartsWithDeclarations(name, listener);
  }

  @preferInline
  void addForPartsWithExpression(
      void Function(ForPartsWithExpression node) listener) {
    nodeLintRegistry.addForPartsWithExpression(name, listener);
  }

  @preferInline
  void addForPartsWithPattern(
      void Function(ForPartsWithPattern node) listener) {
    nodeLintRegistry.addForPartsWithPattern(name, listener);
  }

  @preferInline
  void addForStatement(void Function(ForStatement node) listener) {
    nodeLintRegistry.addForStatement(name, listener);
  }

  @preferInline
  void addFunctionBody(void Function(FunctionBody node) listener) {
    nodeLintRegistry.addFunctionBody(name, listener);
  }

  @preferInline
  void addFunctionDeclaration(
      void Function(FunctionDeclaration node) listener) {
    nodeLintRegistry.addFunctionDeclaration(name, listener);
  }

  @preferInline
  void addFunctionDeclarationStatement(
      void Function(FunctionDeclarationStatement node) listener) {
    nodeLintRegistry.addFunctionDeclarationStatement(name, listener);
  }

  @preferInline
  void addFunctionExpression(void Function(FunctionExpression node) listener) {
    nodeLintRegistry.addFunctionExpression(name, listener);
  }

  @preferInline
  void addFunctionExpressionInvocation(
      void Function(FunctionExpressionInvocation node) listener) {
    nodeLintRegistry.addFunctionExpressionInvocation(name, listener);
  }

  @preferInline
  void addFunctionReference(void Function(FunctionReference node) listener) {
    nodeLintRegistry.addFunctionReference(name, listener);
  }

  @preferInline
  void addFunctionTypeAlias(void Function(FunctionTypeAlias node) listener) {
    nodeLintRegistry.addFunctionTypeAlias(name, listener);
  }

  @preferInline
  void addFunctionTypedFormalParameter(
      void Function(FunctionTypedFormalParameter node) listener) {
    nodeLintRegistry.addFunctionTypedFormalParameter(name, listener);
  }

  @preferInline
  void addGenericFunctionType(
      void Function(GenericFunctionType node) listener) {
    nodeLintRegistry.addGenericFunctionType(name, listener);
  }

  @preferInline
  void addGenericTypeAlias(void Function(GenericTypeAlias node) listener) {
    nodeLintRegistry.addGenericTypeAlias(name, listener);
  }

  @preferInline
  void addGuardedPattern(void Function(GuardedPattern node) listener) {
    nodeLintRegistry.addGuardedPattern(name, listener);
  }

  @preferInline
  void addHideCombinator(void Function(HideCombinator node) listener) {
    nodeLintRegistry.addHideCombinator(name, listener);
  }

  @preferInline
  void addIdentifier(void Function(Identifier node) listener) {
    nodeLintRegistry.addIdentifier(name, listener);
  }

  @preferInline
  void addIfElement(void Function(IfElement node) listener) {
    nodeLintRegistry.addIfElement(name, listener);
  }

  @preferInline
  void addIfStatement(void Function(IfStatement node) listener) {
    nodeLintRegistry.addIfStatement(name, listener);
  }

  @preferInline
  void addImplementsClause(void Function(ImplementsClause node) listener) {
    nodeLintRegistry.addImplementsClause(name, listener);
  }

  @preferInline
  void addImplicitCallReference(
      void Function(ImplicitCallReference node) listener) {
    nodeLintRegistry.addImplicitCallReference(name, listener);
  }

  @preferInline
  void addImportDirective(void Function(ImportDirective node) listener) {
    nodeLintRegistry.addImportDirective(name, listener);
  }

  @preferInline
  void addImportPrefixReference(
      void Function(ImportPrefixReference node) listener) {
    nodeLintRegistry.addImportPrefixReference(name, listener);
  }

  @preferInline
  void addIndexExpression(void Function(IndexExpression node) listener) {
    nodeLintRegistry.addIndexExpression(name, listener);
  }

  @preferInline
  void addInstanceCreationExpression(
      void Function(InstanceCreationExpression node) listener) {
    nodeLintRegistry.addInstanceCreationExpression(name, listener);
  }

  @preferInline
  void addIntegerLiteral(void Function(IntegerLiteral node) listener) {
    nodeLintRegistry.addIntegerLiteral(name, listener);
  }

  @preferInline
  void addInterpolationElement(
      void Function(InterpolationElement node) listener) {
    nodeLintRegistry.addInterpolationElement(name, listener);
  }

  @preferInline
  void addInterpolationExpression(
      void Function(InterpolationExpression node) listener) {
    nodeLintRegistry.addInterpolationExpression(name, listener);
  }

  @preferInline
  void addInterpolationString(
      void Function(InterpolationString node) listener) {
    nodeLintRegistry.addInterpolationString(name, listener);
  }

  @preferInline
  void addInvocationExpression(
      void Function(InvocationExpression node) listener) {
    nodeLintRegistry.addInvocationExpression(name, listener);
  }

  @preferInline
  void addIsExpression(void Function(IsExpression node) listener) {
    nodeLintRegistry.addIsExpression(name, listener);
  }

  @preferInline
  void addLabel(void Function(Label node) listener) {
    nodeLintRegistry.addLabel(name, listener);
  }

  @preferInline
  void addLabeledStatement(void Function(LabeledStatement node) listener) {
    nodeLintRegistry.addLabeledStatement(name, listener);
  }

  @preferInline
  void addLibraryAugmentationDirective(
      void Function(LibraryAugmentationDirective node) listener) {
    nodeLintRegistry.addLibraryAugmentationDirective(name, listener);
  }

  @preferInline
  void addLibraryDirective(void Function(LibraryDirective node) listener) {
    nodeLintRegistry.addLibraryDirective(name, listener);
  }

  @preferInline
  void addLibraryIdentifier(void Function(LibraryIdentifier node) listener) {
    nodeLintRegistry.addLibraryIdentifier(name, listener);
  }

  @preferInline
  void addListLiteral(void Function(ListLiteral node) listener) {
    nodeLintRegistry.addListLiteral(name, listener);
  }

  @preferInline
  void addListPattern(void Function(ListPattern node) listener) {
    nodeLintRegistry.addListPattern(name, listener);
  }

  @preferInline
  void addLiteral(void Function(Literal node) listener) {
    nodeLintRegistry.addLiteral(name, listener);
  }

  @preferInline
  void addLogicalAndPattern(void Function(LogicalAndPattern node) listener) {
    nodeLintRegistry.addLogicalAndPattern(name, listener);
  }

  @preferInline
  void addLogicalOrPattern(void Function(LogicalOrPattern node) listener) {
    nodeLintRegistry.addLogicalOrPattern(name, listener);
  }

  @preferInline
  void addMapLiteralEntry(void Function(MapLiteralEntry node) listener) {
    nodeLintRegistry.addMapLiteralEntry(name, listener);
  }

  @preferInline
  void addMapPattern(void Function(MapPattern node) listener) {
    nodeLintRegistry.addMapPattern(name, listener);
  }

  @preferInline
  void addMapPatternEntry(void Function(MapPatternEntry node) listener) {
    nodeLintRegistry.addMapPatternEntry(name, listener);
  }

  @preferInline
  void addMethodDeclaration(void Function(MethodDeclaration node) listener) {
    nodeLintRegistry.addMethodDeclaration(name, listener);
  }

  @preferInline
  void addMethodInvocation(void Function(MethodInvocation node) listener) {
    nodeLintRegistry.addMethodInvocation(name, listener);
  }

  @preferInline
  void addMixinDeclaration(void Function(MixinDeclaration node) listener) {
    nodeLintRegistry.addMixinDeclaration(name, listener);
  }

  @preferInline
  void addNamedCompilationUnitMember(
      void Function(NamedCompilationUnitMember node) listener) {
    nodeLintRegistry.addNamedCompilationUnitMember(name, listener);
  }

  @preferInline
  void addNamedExpression(void Function(NamedExpression node) listener) {
    nodeLintRegistry.addNamedExpression(name, listener);
  }

  @preferInline
  void addNamedType(void Function(NamedType node) listener) {
    nodeLintRegistry.addNamedType(name, listener);
  }

  @preferInline
  void addNamespaceDirective(void Function(NamespaceDirective node) listener) {
    nodeLintRegistry.addNamespaceDirective(name, listener);
  }

  @preferInline
  void addNativeClause(void Function(NativeClause node) listener) {
    nodeLintRegistry.addNativeClause(name, listener);
  }

  @preferInline
  void addNativeFunctionBody(void Function(NativeFunctionBody node) listener) {
    nodeLintRegistry.addNativeFunctionBody(name, listener);
  }

  @preferInline
  void addNode(void Function(AstNode node) listener) {
    nodeLintRegistry.addNode(name, listener);
  }

  @preferInline
  void addNormalFormalParameter(
      void Function(NormalFormalParameter node) listener) {
    nodeLintRegistry.addNormalFormalParameter(name, listener);
  }

  @preferInline
  void addNullAssertPattern(void Function(NullAssertPattern node) listener) {
    nodeLintRegistry.addNullAssertPattern(name, listener);
  }

  @preferInline
  void addNullCheckPattern(void Function(NullCheckPattern node) listener) {
    nodeLintRegistry.addNullCheckPattern(name, listener);
  }

  @preferInline
  void addNullLiteral(void Function(NullLiteral node) listener) {
    nodeLintRegistry.addNullLiteral(name, listener);
  }

  @preferInline
  void addObjectPattern(void Function(ObjectPattern node) listener) {
    nodeLintRegistry.addObjectPattern(name, listener);
  }

  @preferInline
  void addOnClause(void Function(OnClause node) listener) {
    nodeLintRegistry.addOnClause(name, listener);
  }

  @preferInline
  void addParenthesizedExpression(
      void Function(ParenthesizedExpression node) listener) {
    nodeLintRegistry.addParenthesizedExpression(name, listener);
  }

  @preferInline
  void addParenthesizedPattern(
      void Function(ParenthesizedPattern node) listener) {
    nodeLintRegistry.addParenthesizedPattern(name, listener);
  }

  @preferInline
  void addPartDirective(void Function(PartDirective node) listener) {
    nodeLintRegistry.addPartDirective(name, listener);
  }

  @preferInline
  void addPartOfDirective(void Function(PartOfDirective node) listener) {
    nodeLintRegistry.addPartOfDirective(name, listener);
  }

  @preferInline
  void addPatternAssignment(void Function(PatternAssignment node) listener) {
    nodeLintRegistry.addPatternAssignment(name, listener);
  }

  @preferInline
  void addPatternField(void Function(PatternField node) listener) {
    nodeLintRegistry.addPatternField(name, listener);
  }

  @preferInline
  void addPatternFieldName(void Function(PatternFieldName node) listener) {
    nodeLintRegistry.addPatternFieldName(name, listener);
  }

  @preferInline
  void addPatternVariableDeclaration(
      void Function(PatternVariableDeclaration node) listener) {
    nodeLintRegistry.addPatternVariableDeclaration(name, listener);
  }

  @preferInline
  void addPatternVariableDeclarationStatement(
      void Function(PatternVariableDeclarationStatement node) listener) {
    nodeLintRegistry.addPatternVariableDeclarationStatement(name, listener);
  }

  @preferInline
  void addPostfixExpression(void Function(PostfixExpression node) listener) {
    nodeLintRegistry.addPostfixExpression(name, listener);
  }

  @preferInline
  void addPrefixedIdentifier(void Function(PrefixedIdentifier node) listener) {
    nodeLintRegistry.addPrefixedIdentifier(name, listener);
  }

  @preferInline
  void addPrefixExpression(void Function(PrefixExpression node) listener) {
    nodeLintRegistry.addPrefixExpression(name, listener);
  }

  @preferInline
  void addPropertyAccess(void Function(PropertyAccess node) listener) {
    nodeLintRegistry.addPropertyAccess(name, listener);
  }

  @preferInline
  void addRecordLiteral(void Function(RecordLiteral node) listener) {
    nodeLintRegistry.addRecordLiteral(name, listener);
  }

  @preferInline
  void addRecordPattern(void Function(RecordPattern node) listener) {
    nodeLintRegistry.addRecordPattern(name, listener);
  }

  @preferInline
  void addRecordTypeAnnotation(
      void Function(RecordTypeAnnotation node) listener) {
    nodeLintRegistry.addRecordTypeAnnotation(name, listener);
  }

  @preferInline
  void addRecordTypeAnnotationField(
      void Function(RecordTypeAnnotationField node) listener) {
    nodeLintRegistry.addRecordTypeAnnotationField(name, listener);
  }

  @preferInline
  void addRecordTypeAnnotationNamedField(
      void Function(RecordTypeAnnotationNamedField node) listener) {
    nodeLintRegistry.addRecordTypeAnnotationNamedField(name, listener);
  }

  @preferInline
  void addRecordTypeAnnotationNamedFields(
      void Function(RecordTypeAnnotationNamedFields node) listener) {
    nodeLintRegistry.addRecordTypeAnnotationNamedFields(name, listener);
  }

  @preferInline
  void addRecordTypeAnnotationPositionalField(
      void Function(RecordTypeAnnotationPositionalField node) listener) {
    nodeLintRegistry.addRecordTypeAnnotationPositionalField(name, listener);
  }

  @preferInline
  void addRedirectingConstructorInvocation(
      void Function(RedirectingConstructorInvocation node) listener) {
    nodeLintRegistry.addRedirectingConstructorInvocation(name, listener);
  }

  @preferInline
  void addRelationalPattern(void Function(RelationalPattern node) listener) {
    nodeLintRegistry.addRelationalPattern(name, listener);
  }

  @preferInline
  void addRestPatternElement(void Function(RestPatternElement node) listener) {
    nodeLintRegistry.addRestPatternElement(name, listener);
  }

  @preferInline
  void addRethrowExpression(void Function(RethrowExpression node) listener) {
    nodeLintRegistry.addRethrowExpression(name, listener);
  }

  @preferInline
  void addReturnStatement(void Function(ReturnStatement node) listener) {
    nodeLintRegistry.addReturnStatement(name, listener);
  }

  @preferInline
  void addScriptTag(void Function(ScriptTag node) listener) {
    nodeLintRegistry.addScriptTag(name, listener);
  }

  @preferInline
  void addSetOrMapLiteral(void Function(SetOrMapLiteral node) listener) {
    nodeLintRegistry.addSetOrMapLiteral(name, listener);
  }

  @preferInline
  void addShowCombinator(void Function(ShowCombinator node) listener) {
    nodeLintRegistry.addShowCombinator(name, listener);
  }

  @preferInline
  void addSimpleFormalParameter(
      void Function(SimpleFormalParameter node) listener) {
    nodeLintRegistry.addSimpleFormalParameter(name, listener);
  }

  @preferInline
  void addSimpleIdentifier(void Function(SimpleIdentifier node) listener) {
    nodeLintRegistry.addSimpleIdentifier(name, listener);
  }

  @preferInline
  void addSimpleStringLiteral(
      void Function(SimpleStringLiteral node) listener) {
    nodeLintRegistry.addSimpleStringLiteral(name, listener);
  }

  @preferInline
  void addSingleStringLiteral(
      void Function(SingleStringLiteral node) listener) {
    nodeLintRegistry.addSingleStringLiteral(name, listener);
  }

  @preferInline
  void addSpreadElement(void Function(SpreadElement node) listener) {
    nodeLintRegistry.addSpreadElement(name, listener);
  }

  @preferInline
  void addStatement(void Function(Statement node) listener) {
    nodeLintRegistry.addStatement(name, listener);
  }

  @preferInline
  void addStringInterpolation(
      void Function(StringInterpolation node) listener) {
    nodeLintRegistry.addStringInterpolation(name, listener);
  }

  @preferInline
  void addStringLiteral(void Function(StringLiteral node) listener) {
    nodeLintRegistry.addStringLiteral(name, listener);
  }

  @preferInline
  void addSuperConstructorInvocation(
      void Function(SuperConstructorInvocation node) listener) {
    nodeLintRegistry.addSuperConstructorInvocation(name, listener);
  }

  @preferInline
  void addSuperExpression(void Function(SuperExpression node) listener) {
    nodeLintRegistry.addSuperExpression(name, listener);
  }

  @preferInline
  void addSuperFormalParameter(
      void Function(SuperFormalParameter node) listener) {
    nodeLintRegistry.addSuperFormalParameter(name, listener);
  }

  @preferInline
  void addSwitchCase(void Function(SwitchCase node) listener) {
    nodeLintRegistry.addSwitchCase(name, listener);
  }

  @preferInline
  void addSwitchDefault(void Function(SwitchDefault node) listener) {
    nodeLintRegistry.addSwitchDefault(name, listener);
  }

  @preferInline
  void addSwitchExpression(void Function(SwitchExpression node) listener) {
    nodeLintRegistry.addSwitchExpression(name, listener);
  }

  @preferInline
  void addSwitchExpressionCase(
      void Function(SwitchExpressionCase node) listener) {
    nodeLintRegistry.addSwitchExpressionCase(name, listener);
  }

  @preferInline
  void addSwitchMember(void Function(SwitchMember node) listener) {
    nodeLintRegistry.addSwitchMember(name, listener);
  }

  @preferInline
  void addSwitchPatternCase(void Function(SwitchPatternCase node) listener) {
    nodeLintRegistry.addSwitchPatternCase(name, listener);
  }

  @preferInline
  void addSwitchStatement(void Function(SwitchStatement node) listener) {
    nodeLintRegistry.addSwitchStatement(name, listener);
  }

  @preferInline
  void addSymbolLiteral(void Function(SymbolLiteral node) listener) {
    nodeLintRegistry.addSymbolLiteral(name, listener);
  }

  @preferInline
  void addThisExpression(void Function(ThisExpression node) listener) {
    nodeLintRegistry.addThisExpression(name, listener);
  }

  @preferInline
  void addThrowExpression(void Function(ThrowExpression node) listener) {
    nodeLintRegistry.addThrowExpression(name, listener);
  }

  @preferInline
  void addTopLevelVariableDeclaration(
      void Function(TopLevelVariableDeclaration node) listener) {
    nodeLintRegistry.addTopLevelVariableDeclaration(name, listener);
  }

  @preferInline
  void addTryStatement(void Function(TryStatement node) listener) {
    nodeLintRegistry.addTryStatement(name, listener);
  }

  @preferInline
  void addTypeAlias(void Function(TypeAlias node) listener) {
    nodeLintRegistry.addTypeAlias(name, listener);
  }

  @preferInline
  void addTypeAnnotation(void Function(TypeAnnotation node) listener) {
    nodeLintRegistry.addTypeAnnotation(name, listener);
  }

  @preferInline
  void addTypeArgumentList(void Function(TypeArgumentList node) listener) {
    nodeLintRegistry.addTypeArgumentList(name, listener);
  }

  @preferInline
  void addTypedLiteral(void Function(TypedLiteral node) listener) {
    nodeLintRegistry.addTypedLiteral(name, listener);
  }

  @preferInline
  void addTypeLiteral(void Function(TypeLiteral node) listener) {
    nodeLintRegistry.addTypeLiteral(name, listener);
  }

  @preferInline
  void addTypeParameter(void Function(TypeParameter node) listener) {
    nodeLintRegistry.addTypeParameter(name, listener);
  }

  @preferInline
  void addTypeParameterList(void Function(TypeParameterList node) listener) {
    nodeLintRegistry.addTypeParameterList(name, listener);
  }

  @preferInline
  void addUriBasedDirective(void Function(UriBasedDirective node) listener) {
    nodeLintRegistry.addUriBasedDirective(name, listener);
  }

  @preferInline
  void addVariableDeclaration(
      void Function(VariableDeclaration node) listener) {
    nodeLintRegistry.addVariableDeclaration(name, listener);
  }

  @preferInline
  void addVariableDeclarationList(
      void Function(VariableDeclarationList node) listener) {
    nodeLintRegistry.addVariableDeclarationList(name, listener);
  }

  @preferInline
  void addVariableDeclarationStatement(
      void Function(VariableDeclarationStatement node) listener) {
    nodeLintRegistry.addVariableDeclarationStatement(name, listener);
  }

  @preferInline
  void addWhenClause(void Function(WhenClause node) listener) {
    nodeLintRegistry.addWhenClause(name, listener);
  }

  @preferInline
  void addWhileStatement(void Function(WhileStatement node) listener) {
    nodeLintRegistry.addWhileStatement(name, listener);
  }

  @preferInline
  void addWildcardPattern(void Function(WildcardPattern node) listener) {
    nodeLintRegistry.addWildcardPattern(name, listener);
  }

  @preferInline
  void addWithClause(void Function(WithClause node) listener) {
    nodeLintRegistry.addWithClause(name, listener);
  }

  @preferInline
  void addYieldStatement(void Function(YieldStatement node) listener) {
    nodeLintRegistry.addYieldStatement(name, listener);
  }
}

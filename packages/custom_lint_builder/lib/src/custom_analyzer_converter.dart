// ignore_for_file: type=lint
// Forked from analyzer_plugin to fix https://github.com/invertase/dart_custom_lint/issues/87

// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart' as analyzer;
import 'package:analyzer/source/line_info.dart' as analyzer;
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart' as analyzer;
import 'package:analyzer/diagnostic/diagnostic.dart' as analyzer;
import 'package:analyzer/error/error.dart' as analyzer;
import 'package:analyzer/source/error_processor.dart' as analyzer;
import 'package:analyzer/src/generated/engine.dart' as analyzer;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;

/// An object used to convert between objects defined by the 'analyzer' package
/// and those defined by the plugin protocol.
///
/// Clients may not extend, implement or mix-in this class.
class CustomAnalyzerConverter {
  /// Convert the analysis [error] from the 'analyzer' package to an analysis
  /// error defined by the plugin API. If a [lineInfo] is provided then the
  /// error's location will have a start line and start column. If a [severity]
  /// is provided, then it will override the severity defined by the error.
  plugin.AnalysisError convertAnalysisError(
    analyzer.AnalysisError error, {
    analyzer.LineInfo? lineInfo,
    analyzer.ErrorSeverity? severity,
  }) {
    var errorCode = error.errorCode;
    severity ??= errorCode.errorSeverity;
    var offset = error.offset;
    var startLine = -1;
    var startColumn = -1;
    var endLine = -1;
    var endColumn = -1;
    if (lineInfo != null) {
      var startLocation = lineInfo.getLocation(offset);
      startLine = startLocation.lineNumber;
      startColumn = startLocation.columnNumber;
      var endLocation = lineInfo.getLocation(offset + error.length);
      endLine = endLocation.lineNumber;
      endColumn = endLocation.columnNumber;
    }
    List<plugin.DiagnosticMessage>? contextMessages;
    if (error.contextMessages.isNotEmpty) {
      contextMessages = error.contextMessages
          .map((message) =>
              convertDiagnosticMessage(message, lineInfo: lineInfo))
          .toList();
    }
    return plugin.AnalysisError(
      convertErrorSeverity(severity),
      convertErrorType(errorCode.type),
      plugin.Location(
          error.source.fullName, offset, error.length, startLine, startColumn,
          endLine: endLine, endColumn: endColumn),
      error.message,
      errorCode.name.toLowerCase(),
      contextMessages: contextMessages,
      correction: error.correction,
      hasFix: null,
      url: errorCode.url,
    );
  }

  /// Convert the list of analysis [errors] from the 'analyzer' package to a
  /// list of analysis errors defined by the plugin API. If a [lineInfo] is
  /// provided then the resulting errors locations will have a start line and
  /// start column. If an analysis [options] is provided then the severities of
  /// the errors will be altered based on those options.
  List<plugin.AnalysisError> convertAnalysisErrors(
      List<analyzer.AnalysisError> errors,
      {analyzer.LineInfo? lineInfo,
      analyzer.AnalysisOptions? options}) {
    var serverErrors = <plugin.AnalysisError>[];
    for (var error in errors) {
      var processor = analyzer.ErrorProcessor.getProcessor(options, error);
      if (processor != null) {
        var severity = processor.severity;
        // Errors with null severity are filtered out.
        if (severity != null) {
          // Specified severities override.
          serverErrors.add(convertAnalysisError(error,
              lineInfo: lineInfo, severity: severity));
        }
      } else {
        serverErrors.add(convertAnalysisError(error, lineInfo: lineInfo));
      }
    }
    return serverErrors;
  }

  /// Convert the diagnostic [message] from the 'analyzer' package to an
  /// analysis error defined by the plugin API. If a [lineInfo] is provided then
  /// the error's location will have a start line and start column.
  plugin.DiagnosticMessage convertDiagnosticMessage(
      analyzer.DiagnosticMessage message,
      {analyzer.LineInfo? lineInfo}) {
    var file = message.filePath;
    var offset = message.offset;
    var length = message.length;
    var startLine = -1;
    var startColumn = -1;
    var endLine = -1;
    var endColumn = -1;
    if (lineInfo != null) {
      var lineLocation = lineInfo.getLocation(offset);
      startLine = lineLocation.lineNumber;
      startColumn = lineLocation.columnNumber;
      var endLocation = lineInfo.getLocation(offset + length);
      endLine = endLocation.lineNumber;
      endColumn = endLocation.columnNumber;
    }
    return plugin.DiagnosticMessage(
        message.messageText(includeUrl: true),
        plugin.Location(file, offset, length, startLine, startColumn,
            endLine: endLine, endColumn: endColumn));
  }

  /// Convert the given [element] from the 'analyzer' package to an element
  /// defined by the plugin API.
  plugin.Element convertElement(analyzer.Element element) {
    var kind = _convertElementToElementKind(element);
    return plugin.Element(
      kind,
      element.displayName,
      plugin.Element.makeFlags(
        isPrivate: element.isPrivate,
        isDeprecated: element.hasDeprecated,
        isAbstract: _isAbstract(element),
        isConst: _isConst(element),
        isFinal: _isFinal(element),
        isStatic: _isStatic(element),
      ),
      location: locationFromElement(element),
      typeParameters: _getTypeParametersString(element),
      aliasedType: _getAliasedTypeString(element),
      parameters: _getParametersString(element),
      returnType: _getReturnTypeString(element),
    );
  }

  /// Convert the element [kind] from the 'analyzer' package to an element kind
  /// defined by the plugin API.
  ///
  /// This method does not take into account that an instance of [ClassElement]
  /// can be an enum and an instance of [FieldElement] can be an enum constant.
  /// Use [_convertElementToElementKind] where possible.
  plugin.ElementKind convertElementKind(analyzer.ElementKind kind) {
    if (kind == analyzer.ElementKind.CLASS) {
      return plugin.ElementKind.CLASS;
    } else if (kind == analyzer.ElementKind.COMPILATION_UNIT) {
      return plugin.ElementKind.COMPILATION_UNIT;
    } else if (kind == analyzer.ElementKind.CONSTRUCTOR) {
      return plugin.ElementKind.CONSTRUCTOR;
    } else if (kind == analyzer.ElementKind.FIELD) {
      return plugin.ElementKind.FIELD;
    } else if (kind == analyzer.ElementKind.FUNCTION) {
      return plugin.ElementKind.FUNCTION;
    } else if (kind == analyzer.ElementKind.FUNCTION_TYPE_ALIAS) {
      return plugin.ElementKind.FUNCTION_TYPE_ALIAS;
    } else if (kind == analyzer.ElementKind.GENERIC_FUNCTION_TYPE) {
      return plugin.ElementKind.FUNCTION_TYPE_ALIAS;
    } else if (kind == analyzer.ElementKind.GETTER) {
      return plugin.ElementKind.GETTER;
    } else if (kind == analyzer.ElementKind.LABEL) {
      return plugin.ElementKind.LABEL;
    } else if (kind == analyzer.ElementKind.LIBRARY) {
      return plugin.ElementKind.LIBRARY;
    } else if (kind == analyzer.ElementKind.LOCAL_VARIABLE) {
      return plugin.ElementKind.LOCAL_VARIABLE;
    } else if (kind == analyzer.ElementKind.METHOD) {
      return plugin.ElementKind.METHOD;
    } else if (kind == analyzer.ElementKind.PARAMETER) {
      return plugin.ElementKind.PARAMETER;
    } else if (kind == analyzer.ElementKind.PREFIX) {
      return plugin.ElementKind.PREFIX;
    } else if (kind == analyzer.ElementKind.SETTER) {
      return plugin.ElementKind.SETTER;
    } else if (kind == analyzer.ElementKind.TOP_LEVEL_VARIABLE) {
      return plugin.ElementKind.TOP_LEVEL_VARIABLE;
    } else if (kind == analyzer.ElementKind.TYPE_ALIAS) {
      return plugin.ElementKind.TYPE_ALIAS;
    } else if (kind == analyzer.ElementKind.TYPE_PARAMETER) {
      return plugin.ElementKind.TYPE_PARAMETER;
    }
    return plugin.ElementKind.UNKNOWN;
  }

  /// Convert the error [severity] from the 'analyzer' package to an analysis
  /// error severity defined by the plugin API.
  plugin.AnalysisErrorSeverity convertErrorSeverity(
          analyzer.ErrorSeverity severity) =>
      plugin.AnalysisErrorSeverity.values.byName(severity.name);

  /// Convert the error [type] from the 'analyzer' package to an analysis error
  /// type defined by the plugin API.
  plugin.AnalysisErrorType convertErrorType(analyzer.ErrorType type) =>
      plugin.AnalysisErrorType.values.byName(type.name);

  /// Create a location based on an the given [element].
  plugin.Location? locationFromElement(analyzer.Element? element,
      {int? offset, int? length}) {
    if (element == null || element.source == null) {
      return null;
    }
    offset ??= element.nameOffset;
    length ??= element.nameLength;
    if (element is analyzer.CompilationUnitElement ||
        (element is analyzer.LibraryElement && offset < 0)) {
      offset = 0;
      length = 0;
    }
    var unitElement = _getUnitElement(element);
    var range = analyzer.SourceRange(offset, length);
    return _locationForArgs(unitElement, range);
  }

  /// Convert the element kind of the [element] from the 'analyzer' package to
  /// an element kind defined by the plugin API.
  plugin.ElementKind _convertElementToElementKind(analyzer.Element element) {
    if (element is analyzer.EnumElement) {
      return plugin.ElementKind.ENUM;
    } else if (element is analyzer.FieldElement && element.isEnumConstant
        // MyEnum.values and MyEnum.one.index return isEnumConstant = true
        // so these additional checks are necessary.
        // so should it return isEnumConstant = true?
        // MyEnum.one.index is final but *not* constant
        // so should it return isEnumConstant = true?
        // Or should we return ElementKind.ENUM_CONSTANT here
        // in either or both of these cases?
        ) {
      final type = element.type;
      if (type is InterfaceType && type.element3 == element.enclosingElement3) {
        return plugin.ElementKind.ENUM_CONSTANT;
      }
    }
    return convertElementKind(element.kind);
  }

  String? _getAliasedTypeString(analyzer.Element element) {
    if (element is analyzer.TypeAliasElement) {
      var aliasedType = element.aliasedType;
      return aliasedType.getDisplayString();
    }
    return null;
  }

  /// Return a textual representation of the parameters of the given [element],
  /// or `null` if the element does not have any parameters.
  String? _getParametersString(analyzer.Element element) {
    List<analyzer.ParameterElement> parameters;
    if (element is analyzer.ExecutableElement) {
      // valid getters don't have parameters
      if (element.kind == analyzer.ElementKind.GETTER &&
          element.parameters.isEmpty) {
        return null;
      }
      parameters = element.parameters;
    } else if (element is analyzer.TypeAliasElement) {
      var aliasedElement = element.aliasedElement;
      if (aliasedElement is analyzer.GenericFunctionTypeElement) {
        parameters = aliasedElement.parameters;
      } else {
        return null;
      }
    } else {
      return null;
    }
    var buffer = StringBuffer();
    var closeOptionalString = '';
    buffer.write('(');
    for (var i = 0; i < parameters.length; i++) {
      var parameter = parameters[i];
      if (i > 0) {
        buffer.write(', ');
      }
      if (closeOptionalString.isEmpty) {
        if (parameter.isNamed) {
          buffer.write('{');
          closeOptionalString = '}';
        } else if (parameter.isOptionalPositional) {
          buffer.write('[');
          closeOptionalString = ']';
        }
      }
      parameter.appendToWithoutDelimiters(buffer);
    }
    buffer.write(closeOptionalString);
    buffer.write(')');
    return buffer.toString();
  }

  /// Return a textual representation of the return type of the given [element],
  /// or `null` if the element does not have a return type.
  String? _getReturnTypeString(analyzer.Element element) {
    if (element is analyzer.ExecutableElement) {
      if (element.kind == analyzer.ElementKind.SETTER) {
        return null;
      }
      return element.returnType.getDisplayString();
    } else if (element is analyzer.VariableElement) {
      return element.type.getDisplayString();
    } else if (element is analyzer.TypeAliasElement) {
      var aliasedType = element.aliasedType;
      if (aliasedType is FunctionType) {
        var returnType = aliasedType.returnType;
        return returnType.getDisplayString();
      }
    }
    return null;
  }

  /// Return a textual representation of the type parameters of the given
  /// [element], or `null` if the element does not have type parameters.
  String? _getTypeParametersString(analyzer.Element element) {
    if (element is analyzer.TypeParameterizedElement) {
      var typeParameters = element.typeParameters;
      if (typeParameters.isEmpty) {
        return null;
      }
      return '<${typeParameters.join(', ')}>';
    }
    return null;
  }

  /// Return the compilation unit containing the given [element].
  analyzer.CompilationUnitElement? _getUnitElement(analyzer.Element element) {
    analyzer.Element? currentElement = element;
    if (currentElement is analyzer.CompilationUnitElement) {
      return currentElement;
    }
    if (currentElement.enclosingElement3 is analyzer.LibraryElement) {
      currentElement = currentElement.enclosingElement3;
    }
    if (currentElement is analyzer.LibraryElement) {
      return currentElement.definingCompilationUnit;
    }
    for (;
        currentElement != null;
        currentElement = currentElement.enclosingElement3) {
      if (currentElement is analyzer.CompilationUnitElement) {
        return currentElement;
      }
    }
    return null;
  }

  bool _isAbstract(analyzer.Element element) {
    if (element is analyzer.ClassElement) {
      return element.isAbstract;
    } else if (element is analyzer.MethodElement) {
      return element.isAbstract;
    } else if (element is analyzer.PropertyAccessorElement) {
      return element.isAbstract;
    }
    return false;
  }

  bool _isConst(analyzer.Element element) {
    if (element is analyzer.ConstructorElement) {
      return element.isConst;
    } else if (element is analyzer.VariableElement) {
      return element.isConst;
    }
    return false;
  }

  bool _isFinal(analyzer.Element element) {
    if (element is analyzer.VariableElement) {
      return element.isFinal;
    }
    return false;
  }

  bool _isStatic(analyzer.Element element) {
    if (element is analyzer.ExecutableElement) {
      return element.isStatic;
    } else if (element is analyzer.PropertyInducingElement) {
      return element.isStatic;
    }
    return false;
  }

  /// Create and return a location within the given [unitElement] at the given
  /// [range].
  plugin.Location? _locationForArgs(
      analyzer.CompilationUnitElement? unitElement,
      analyzer.SourceRange range) {
    if (unitElement == null) {
      return null;
    }

    var lineInfo = unitElement.lineInfo;
    var offsetLocation = lineInfo.getLocation(range.offset);
    var endLocation = lineInfo.getLocation(range.offset + range.length);
    var startLine = offsetLocation.lineNumber;
    var startColumn = offsetLocation.columnNumber;
    var endLine = endLocation.lineNumber;
    var endColumn = endLocation.columnNumber;

    return plugin.Location(unitElement.source.fullName, range.offset,
        range.length, startLine, startColumn,
        endLine: endLine, endColumn: endColumn);
  }
}

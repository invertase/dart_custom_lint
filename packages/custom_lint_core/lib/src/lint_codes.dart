// Forked from package:analyzer/src/dart/error/lint_codes.dart

// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:meta/meta.dart';

import '../custom_lint_core.dart';

/// A class representing an [DiagnosticCode] for [LintRule]s.
@immutable
class LintCode extends DiagnosticCode {
  /// A class representing an [DiagnosticCode] for [LintRule]s.
  const LintCode({
    required super.name,
    required super.problemMessage,
    super.correctionMessage,
    String? uniqueName,
    this.url,
    this.severity = DiagnosticSeverity.INFO,
  }) : super(
          uniqueName: uniqueName ?? name,
        );

  @override
  DiagnosticType get type => DiagnosticType.LINT;

  @override
  final String? url;

  @override
  final DiagnosticSeverity severity;

  @override
  int get hashCode => uniqueName.hashCode;

  @override
  bool operator ==(Object other) {
    return other is LintCode && uniqueName == other.uniqueName;
  }
}

// ignore_for_file: type=lint
// Forked from package:analyzer/src/dart/error/lint_codes.dart

// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart';

/// Defines style and best practice recommendations.
///
/// Unlike [HintCode]s, which are akin to traditional static warnings from a
/// compiler, lint recommendations focus on matters of style and practices that
/// might aggregated to define a project's style guide.
class LintCode extends ErrorCode {
  const LintCode({
    required String name,
    required String problemMessage,
    super.correctionMessage,
    String? uniqueName,
    this.url,
    this.errorSeverity = ErrorSeverity.INFO,
  }) : super(
          problemMessage: problemMessage,
          name: name,
          uniqueName: uniqueName ?? name,
        );

  @override
  ErrorType get type => ErrorType.LINT;

  @override
  final String? url;

  @override
  final ErrorSeverity errorSeverity;

  @override
  int get hashCode => uniqueName.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LintCode && uniqueName == other.uniqueName;
}

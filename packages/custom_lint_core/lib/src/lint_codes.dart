// Forked from package:analyzer/src/dart/error/lint_codes.dart

// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart';
import 'package:meta/meta.dart';

import '../custom_lint_core.dart';

/// A class representing an [ErrorCode] for [LintRule]s.
@immutable
class LintCode extends ErrorCode {
  /// A class representing an [ErrorCode] for [LintRule]s.
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
  bool operator ==(Object other) {
    return other is LintCode && uniqueName == other.uniqueName;
  }
}

// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:meta/meta.dart';

import 'pragrams.dart';

part 'node_lint_visitor.g.dart';

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

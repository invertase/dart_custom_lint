import 'dart:io';
import 'package:custom_lint/basic_runner.dart';

Future<int> main() {
  return runCustomLintOnDirectory(Directory.current.parent);
}

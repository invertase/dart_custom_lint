import 'dart:io';
import 'package:custom_lint/basic_runner.dart';

Future<void> main() async {
  await runCustomLintOnDirectory(Directory.current.parent);
}

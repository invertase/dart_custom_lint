import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/package_utils.dart';
import 'package:test/test.dart';

final _fixesGoldenFile =
    Directory.current.file('test', 'goldens', 'ignore_quick_fix.json');

Object? _encodePrioritizedSourceChange(PrioritizedSourceChange change) {
  final json = change.toJson();

  final jsonChange = json['change']! as Map;
  final jsonEdits = jsonChange['edits']! as List;

  for (final jsonEdit in jsonEdits) {
    jsonEdit as Map;
    jsonEdit.remove('file');
  }

  return json;
}

Object? _encodeAnalysisErrorFixes(AnalysisErrorFixes fixes) {
  final json = fixes.toJson();

  final editedPrioritizedSourceChanges =
      fixes.fixes.map(_encodePrioritizedSourceChange).toList();

  final jsonError = json['error']! as Map;
  final jsonLocation = jsonError['location']! as Map;
  jsonLocation.remove('file');

  json['fixes'] = editedPrioritizedSourceChanges;

  return json;
}

void saveGoldensFixes(List<AnalysisErrorFixes> fixes) {
  _fixesGoldenFile.writeAsStringSync(
    jsonEncode(fixes.map(_encodeAnalysisErrorFixes).toList()),
  );
}

void expectMatchesGoldenFixes(List<AnalysisErrorFixes> fixes) {
  expect(
    jsonEncode(fixes.map(_encodeAnalysisErrorFixes).toList()),
    _fixesGoldenFile.readAsStringSync(),
  );
}

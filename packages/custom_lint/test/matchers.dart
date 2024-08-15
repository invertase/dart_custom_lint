import 'dart:io';

import 'package:test/test.dart';

final throwsAssertionError = throwsA(isAssertionError);

final isAssertionError = isA<AssertionError>();

Matcher matchesLogGolden(
  String goldenPath, {
  Map<Uri, String>? paths,
}) {
  return isA<String>().having(
    (e) => _normalizeLog(e, paths: paths),
    'normalized log matches golden file $goldenPath',
    _normalizeLog(File(goldenPath).readAsStringSync(), paths: paths),
  );
}

void saveLogGoldens(
  File goldenPath,
  String content, {
  Map<Uri, String>? paths,
}) {
  goldenPath.createSync(recursive: true);
  goldenPath.writeAsStringSync(_normalizeLog(content, paths: paths));
}

final _logDateRegex = RegExp(r'^\[(.+?)\] \S+', multiLine: true);

String _normalizeLog(String log, {Map<Uri, String>? paths}) {
  var result = log.replaceAllMapped(
    _logDateRegex,
    (match) => '[${match.group(1)}] ${DateTime(1990).toIso8601String()}',
  );

  if (paths != null) {
    for (final entry in paths.entries) {
      result = result.replaceAll(entry.key.toString(), '${entry.value}/');
      result = result.replaceAll(entry.key.toFilePath(), '${entry.value}/');
    }
  }

  return result;
}

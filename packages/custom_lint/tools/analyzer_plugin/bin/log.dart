import 'dart:io';

@deprecated
final file = File(
  '/Users/remirousselet/dev/invertase/custom_lint/packages/custom_lint/log.txt',
);

void log(Object obj) {
  file.writeAsStringSync(
    '\n${DateTime.now()} $obj',
    mode: FileMode.append,
  );
}

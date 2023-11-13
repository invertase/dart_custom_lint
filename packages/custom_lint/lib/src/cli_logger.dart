import 'dart:io' as io;

import 'package:cli_util/cli_logging.dart';

/// Temporary copy of [StandardLogger] from `cli_util` package with a fix
/// for https://github.com/dart-lang/cli_util/pull/87
/// which replaces print with stdout.writeln.
class CliLogger implements Logger {
  /// Creates a cli logger with ANSI support
  /// that writes messages and progress [io.stdout].
  CliLogger({Ansi? ansi}) : ansi = ansi ?? Ansi(io.stdout.supportsAnsiEscapes);

  @override
  Ansi ansi;

  @override
  bool get isVerbose => false;

  Progress? _currentProgress;

  @override
  void stderr(String message) {
    _cancelProgress();

    io.stderr.writeln(message);
  }

  @override
  void stdout(String message) {
    _cancelProgress();

    io.stdout.writeln(message);
  }

  @override
  void trace(String message) {}

  @override
  void write(String message) {
    _cancelProgress();

    io.stdout.write(message);
  }

  @override
  void writeCharCode(int charCode) {
    _cancelProgress();

    io.stdout.writeCharCode(charCode);
  }

  void _cancelProgress() {
    final progress = _currentProgress;
    if (progress != null) {
      _currentProgress = null;
      progress.cancel();
    }
  }

  @override
  Progress progress(String message) {
    _cancelProgress();

    final progress = ansi.useAnsi
        ? AnsiProgress(ansi, message)
        : SimpleProgress(this, message);
    _currentProgress = progress;
    return progress;
  }

  @override
  @Deprecated('This method will be removed in the future')
  void flush() {}
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Overrides the body of a test so that I/O is run against an in-memory
/// file system, not the host's disk.
///
/// The I/O override is applied only to the code running within [testBody].
Future<T> runWithIOOverride<T>(
  FutureOr<T> Function(Stream<String> out, Stream<String> err) testBody, {
  Directory? currentDirectory,
  bool supportsAnsiEscapes = false,
}) async {
  final fs = _MockFs(
    stdout,
    currentDirectory ?? Directory.current,
    supportsAnsiEscapes: supportsAnsiEscapes,
  );

  try {
    return await IOOverrides.runWithIOOverrides(
      () => testBody(fs.stdout.stream, fs.stderr.stream),
      fs,
    );
  } finally {
    // TODO figure out why awaiting the close causes tests to time-out if they fail
    // ignore: unawaited_futures
    fs.stderr.close();
    // ignore: unawaited_futures
    fs.stdout.close();
  }
}

class _StdoutOverride implements Stdout {
  _StdoutOverride(
    this._stdout, {
    required this.supportsAnsiEscapes,
  });

  final Stdout _stdout;

  final _controller = StreamController<String>();

  Stream<String> get stream => _controller.stream;

  @override
  Encoding get encoding => _stdout.encoding;

  @override
  set encoding(Encoding e) => throw UnimplementedError();

  @override
  void add(List<int> data) => throw UnimplementedError();

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    throw UnimplementedError();
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) =>
      throw UnimplementedError();

  @override
  Future<void> close() => _controller.close();

  @override
  Future<void> get done => throw UnimplementedError();

  @override
  Future<void> flush() => throw UnimplementedError();

  @override
  bool get hasTerminal => _stdout.hasTerminal;

  @override
  IOSink get nonBlocking => _stdout.nonBlocking;

  @override
  final bool supportsAnsiEscapes;

  @override
  int get terminalColumns => _stdout.terminalColumns;

  @override
  int get terminalLines => _stdout.terminalLines;

  @override
  void write(Object? object) {
    _controller.add(object.toString());
  }

  @override
  void writeAll(Iterable<Object?> objects, [String sep = '']) {
    _controller.add(objects.join(sep));
  }

  @override
  void writeCharCode(int charCode) => throw UnimplementedError();

  @override
  void writeln([Object? object = '']) {
    _controller.add('$object\n');
  }
}

/// Used to override file I/O with an in-memory file system for testing.
///
/// Usage:
///
/// ```dart
/// test('My FS test', withMockFs(() {
///   File('foo').createSync(); // File created in memory
/// }));
/// ```
///
/// Alternatively, set [IOOverrides.global] to a [_MockFs] instance in your
/// test's `setUp`, and to `null` in the `tearDown`.
class _MockFs extends IOOverrides {
  _MockFs(
    Stdout out,
    this._directory, {
    required bool supportsAnsiEscapes,
  })  : stdout = _StdoutOverride(out, supportsAnsiEscapes: supportsAnsiEscapes),
        stderr = _StdoutOverride(out, supportsAnsiEscapes: supportsAnsiEscapes);

  @override
  final _StdoutOverride stdout;

  @override
  final _StdoutOverride stderr;

  Directory _directory;

  @override
  Directory getCurrentDirectory() => _directory;

  @override
  void setCurrentDirectory(String path) {
    _directory = Directory(path);
  }
}

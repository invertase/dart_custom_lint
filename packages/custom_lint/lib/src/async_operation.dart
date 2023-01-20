import 'dart:async';

/// A class for awaiting multiple async operations at once.
///
/// See [wait].
class PendingOperation {
  final _pendingOperations = <Future<void>>[];

  /// Register an async operation to be awaited.
  Future<T> run<T>(Future<T> Function() cb) async {
    final future = Future(cb);
    _pendingOperations.add(future);
    try {
      return await future;
    } finally {
      _pendingOperations.remove(future);
    }
  }

  /// Waits for all operations registered in [run].
  ///
  /// If during the wait new async operations are registered, they will be
  /// awaited too.
  Future<void> wait() async {
    while (_pendingOperations.isNotEmpty) {
      await Future.wait(_pendingOperations.toList());
    }
  }
}

import 'dart:async';

class PendingOperation {
  final _pendingOperations = <MapEntry<String, Future<void>>>[];

  Future<T> run<T>(String key, Future<T> Function() cb) async {
    final future = Future(cb);
    final entry = MapEntry(key, future);
    _pendingOperations.add(entry);
    try {
      return await future;
    } finally {
      _pendingOperations.remove(entry);
    }
  }

  Future<void> wait() async {
    while (_pendingOperations.isNotEmpty) {
      await Future.wait([
        for (final entry in _pendingOperations) entry.value,
      ]);
    }
  }
}

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

/// Workaround to a limitation in [runZonedGuarded] that states the following:
///
/// > The zone will always be an error-zone ([Zone.errorZone]), so returning a
/// > future created inside the zone, and waiting for it outside of the zone,
/// > will risk the future not being seen to complete.
///
/// This function solves the issue by creating a [Completer] outside of
/// [runZonedGuarded] and completing it inside the zone. This way, the future
/// is created outside of the zone and can safely be awaited.
Future<R> asyncRunZonedGuarded<R>(
  Future<R> Function() body,
  void Function(Object error, StackTrace stack) onError, {
  Map<Object?, Object?>? zoneValues,
  ZoneSpecification? zoneSpecification,
}) async {
  final completer = Completer<R>();

  unawaited(
    runZonedGuarded(
      () => body().then(completer.complete, onError: completer.completeError),
      onError,
      zoneSpecification: zoneSpecification,
    ),
  );

  return completer.future;
}

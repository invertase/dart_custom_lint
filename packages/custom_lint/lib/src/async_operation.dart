import 'dart:async';

/// An extension on [Stream] that adds a [safeFirst] method.
extension StreamFirst<T> on Stream<T> {
  /// A fork of [first] meant to be used instead of [first], to possibly override
  /// it during debugging to provide more information.
  Future<T> get safeFirst => first;
}

/// A class for awaiting multiple async operations at once.
///
/// See [wait].
class PendingOperation {
  final _pendingOperations = <Future<void>>[];

  /// Register an async operation to be awaited.
  Future<T> run<T>(Future<T> Function() cb) async {
    final future = cb();

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
    /// Wait for all pending operations to complete and check that no new
    /// operations are queued for a few consecutive frames.
    while (_pendingOperations.isNotEmpty) {
      await Future.wait(_pendingOperations.toList())
          // Catches errors to make sure that errors inside operations don't
          // abort the "wait" early
          .then<void>((value) => null, onError: (_) {});
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
  FutureOr<R> Function() body,
  void Function(Object error, StackTrace stack) onError, {
  Map<Object?, Object?>? zoneValues,
  ZoneSpecification? zoneSpecification,
}) async {
  final completer = Completer<R>();

  unawaited(
    runZonedGuarded(
      () => Future(body).then(
        completer.complete,
        // ignore: avoid_types_on_closure_parameters, false positive
        onError: (Object error, StackTrace stack) {
          // Make sure the initial error is also reported.
          onError(error, stack);

          completer.completeError(error, stack);
        },
      ),
      onError,
      zoneSpecification: zoneSpecification,
    ),
  );

  return completer.future;
}

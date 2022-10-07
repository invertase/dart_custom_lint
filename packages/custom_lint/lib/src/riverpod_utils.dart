import 'dart:async';

import 'package:riverpod/riverpod.dart';

/// Utils specific to Riverpod for manipulated the Ref
extension RiverpodUtils<T> on AutoDisposeRef<T> {
  /// Maintains the state of a provider for [duration]
  void cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }

  /// [cacheFor] with a fixed 5minutes.
  void cache5() {
    cacheFor(const Duration(minutes: 5));
  }
}

import 'package:meta/meta.dart';

/// An object that represents either a value or an error
@immutable
class Result<T> {
  /// A valid value for a [Result]
  Result.data(T value)
      : map = <R>({required data, required error}) => data(value);

  /// A [Result] in error state
  Result.error(Object err, StackTrace stack)
      : map = <R>({required data, required error}) => error(err, stack);

  /// A function to perform a switch-case over whether the [Result] is
  /// in data or error state.
  final R Function<R>({
    required R Function(T value) data,
    required R Function(Object err, StackTrace stackTrace) error,
  }) map;

  /// Whether there is an error or not.
  late final bool hasError = map(
    data: (value) => false,
    error: (err, stack) => true,
  );

  /// Whether there is a data or not
  late final bool hasValue = map(
    data: (value) => true,
    error: (err, stack) => false,
  );

  /// The data passed to [Result.data].
  ///
  /// If [Result] is a [Result.error] instead, will rethrow the exception.
  late final T value = map(
    data: (value) => value,
    error: Error.throwWithStackTrace,
  );

  /// The data passed to [Result.data].
  ///
  /// If [Result] is a [Result.error] instead, will return null.
  late final T? valueOrNull = map(
    data: (value) => value,
    error: (err, stack) => null,
  );

  /// The error passed to [Result.error] or null.
  late final Object? error = map(
    data: (value) => null,
    error: (err, _) => err,
  );

  /// The stack trace passed to [Result.error] or null.
  late final StackTrace? stackTrace = map(
    data: (value) => null,
    error: (_, stackTrace) => stackTrace,
  );

  @override
  bool operator ==(Object? other) {
    return other is Result<T> &&
        other.error == error &&
        other.stackTrace == stackTrace &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(T, value, error, stackTrace);
}

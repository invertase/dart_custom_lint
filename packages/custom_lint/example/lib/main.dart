import 'package:riverpod/riverpod.dart';

void main() {
  print('hello world');
}

class Main {}

// expect_lint: riverpod_final_provider
ProviderBase<int> provider = Provider((ref) => 0);

// expect_lints: riverpod_final_provider
Provider<int> provider2 = Provider((ref) => 0);

Object? foo = 42;

Provider<int> fail = Provider((ref) => 0);

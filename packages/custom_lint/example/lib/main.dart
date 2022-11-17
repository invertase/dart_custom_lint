import 'package:riverpod/riverpod.dart';

void main() {
  print('hello world');
}

class Main {}

ProviderBase<int> provider = Provider((ref) => 0);

Provider<int> provider2 = Provider((ref) => 0);

Object? foo = 42;

Provider<int> fail = Provider((ref) => 0);

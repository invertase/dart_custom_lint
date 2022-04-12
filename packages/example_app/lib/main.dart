import 'package:riverpod/riverpod.dart';

void main() {
  print('hello wolrd');
}

class Main {}

ProviderBase<int> provider = Provider((ref) => 0);

Provider<int> provider2 = Provider((ref) => 0);

Object? foo = 42;

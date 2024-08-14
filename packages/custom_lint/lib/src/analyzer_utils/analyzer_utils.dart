import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports, not exported
import 'package:analyzer/src/dart/analysis/byte_store.dart';
// ignore: implementation_imports, not exported
import 'package:analyzer/src/dart/analysis/file_byte_store.dart';

/// Adds [createByteStore].
extension CreateByteStore on ResourceProvider {
  /// Obtains the location of a [ByteStore].
  String getByteStorePath(String pluginID) {
    final stateLocation = getStateLocation(pluginID);

    if (stateLocation == null) {
      throw StateError('Failed to obtain the byte store path');
    }

    return stateLocation.path;
  }

  /// If the state location can be accessed, return the file byte store,
  /// otherwise return the memory byte store.
  ByteStore createByteStore(String pluginID) {
    const M = 1024 * 1024;

    return MemoryCachingByteStore(
      FileByteStore(
        getByteStorePath(pluginID),
        tempNameSuffix: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
      64 * M,
    );
  }
}

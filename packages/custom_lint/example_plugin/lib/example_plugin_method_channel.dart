import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'example_plugin_platform_interface.dart';

/// An implementation of [ExamplePluginPlatform] that uses method channels.
class MethodChannelExamplePlugin extends ExamplePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('example_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

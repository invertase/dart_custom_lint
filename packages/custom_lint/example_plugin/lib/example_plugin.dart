
import 'example_plugin_platform_interface.dart';

class ExamplePlugin {
  Future<String?> getPlatformVersion() {
    return ExamplePluginPlatform.instance.getPlatformVersion();
  }
}


import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';

import 'example_plugin_platform_interface.dart';

class ExamplePlugin {
  Future<String?> getPlatformVersion() {
    return ExamplePluginPlatform.instance.getPlatformVersion();
  }

  Future<Widget?> getWidget() {
    return ExamplePluginPlatform.instance.getWidget();
  }
}

// expect_lint: riverpod_final_provider
ProviderBase<int> provider = Provider((ref) => 0);

// expect_lint: riverpod_final_provider
Provider<int> provider2 = Provider((ref) => 0);

import 'package:custom_lint_example_plugin/example_plugin.dart';
import 'package:custom_lint_example_plugin/example_plugin_method_channel.dart';
import 'package:custom_lint_example_plugin/example_plugin_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockExamplePluginPlatform
    with MockPlatformInterfaceMixin
    implements ExamplePluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Widget?> getWidget() => Future.value(const SizedBox.shrink());
}

void main() {
  final initialPlatform = ExamplePluginPlatform.instance;

  test('$MethodChannelExamplePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelExamplePlugin>());
  });

  test('getPlatformVersion', () async {
    final examplePlugin = ExamplePlugin();
    final fakePlatform = MockExamplePluginPlatform();
    ExamplePluginPlatform.instance = fakePlatform;

    expect(await examplePlugin.getPlatformVersion(), '42');
  });
}

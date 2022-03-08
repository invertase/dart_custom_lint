// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:isolate';

import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/starter.dart';

import 'my_isolate_channel.dart';
import 'my_server_plugin.dart';

/// The [Driver] class represents a single running instance of an analysis
/// server plugin. It is responsible for handling the communications with the
/// server and forwarding requests on to the plugin.
class MyServerPluginStarter implements ServerPluginStarter {
  /// The plugin that will be started.
  final MyServerPlugin plugin;

  /// Initialize a newly created driver that can be used to start the given
  /// plugin.
  MyServerPluginStarter(this.plugin);

  @override
  void start(SendPort sendPort) {
    var channel = PluginIsolateChannel(sendPort);
    plugin.start(channel);
  }
}

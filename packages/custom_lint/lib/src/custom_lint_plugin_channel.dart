// import 'dart:isolate';

// import 'package:analyzer_plugin/protocol/protocol.dart';
// import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// // ignore: implementation_imports
// import 'package:analyzer_plugin/src/protocol/protocol_internal.dart';
// import 'package:uuid/uuid.dart';

// import 'analyzer_plugin/server_isolate_channel.dart';

// const _uuid = Uuid();

// /// Interact with the custom_lint plugins.
// abstract class CustomLintPluginChannel {
//   CustomLintPluginChannel({
//     required AnalysisSetContextRootsParams contextRoots,
//     required this.versionCheckParams,
//   }) : _contextRoots = contextRoots;

//   final PluginVersionCheckParams versionCheckParams;
//   AnalysisSetContextRootsParams _contextRoots;

//   /// The notifications emitted by the
//   Stream<Notification> get notifications;

//   /// Initializes the plugin
//   Future<void> start() async {
//     await sendRequest(versionCheckParams);
//     await sendRequest(_contextRoots);
//   }

//   /// The server was notified of context root changes.
//   ///
//   /// The change will be transmitted to the plugin.
//   Future<void> setContextRoots(
//     AnalysisSetContextRootsParams parameters,
//   ) async {
//     _contextRoots = parameters;
//     await sendRequest(_contextRoots);
//   }

//   /// Sends a request and returns the response for that request.
//   ///
//   /// Throws [RequestFailure] if a request failed.
//   Future<Response> sendRequest(RequestParams request);
// }

// /// An interface for communicating with custom_lint plugins if the plugin
// /// was spawed using Isolates.
// class CustomLintPluginIsolateChannel extends CustomLintPluginChannel
//     with IsolateChannelBase {
//   CustomLintPluginIsolateChannel({
//     required super.contextRoots,
//     required super.versionCheckParams,
//     required this.receivePort,
//   });

//   @override
//   final ReceivePort receivePort;
// }

// /// An interface for communicating with custom_lint plugins if the plugin
// /// was spawed using Isolates.
// class CustomLintPluginSocketChannel extends CustomLintPluginChannel
//     with IsolateChannelBase {
//   CustomLintPluginSocketChannel({
//     required super.contextRoots,
//     required super.versionCheckParams,
//     required this.receivePort,
//   });

//   @override
//   final Socket receivePort;
// }

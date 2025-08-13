// import 'dart:async';

// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
// import 'package:salesforce/core/utils/logger.dart';

// class PusherService {
//   static PusherService? _instance;
//   static PusherService get instance => _instance ??= PusherService._();
//   PusherService._();

//   PusherChannelsFlutter? _pusher;
//   final _eventController = StreamController<Map<String, dynamic>>.broadcast();

//   Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

//   Future<void> initialize({
//     required String apiKey,
//     required String cluster,
//   }) async {
//     try {
//       _pusher = PusherChannelsFlutter.getInstance();
//       await _pusher!.init(
//         apiKey: apiKey,
//         cluster: cluster,
//         onConnectionStateChange: _onConnectionStateChange,
//         onError: _onError,
//         onEvent: _onEvent,
//       );
//       await _pusher!.connect();
//     } catch (e) {
//       throw PusherException('Failed to initialize Pusher: $e');
//     }
//   }

//   Future<void> subscribeToChannel(String channelName) async {
//     await _pusher!.subscribe(channelName: channelName);
//   }

//   Future<void> unsubscribeFromChannel(String channelName) async {
//     await _pusher!.unsubscribe(channelName: channelName);
//   }

//   void _onEvent(PusherEvent event) {
//     _eventController.add({
//       'channel': event.channelName,
//       'event': event.eventName,
//       'data': event.data,
//     });
//   }

//   void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
//     Logger.log('Connection: $currentState');
//   }

//   void _onError(String message, int? code, dynamic e) {
//     Logger.log('Pusher error: $message');
//   }

//   Future<void> disconnect() async {
//     await _pusher?.disconnect();
//     await _eventController.close();
//   }
// }

// class PusherException implements Exception {
//   final String message;
//   PusherException(this.message);
// }

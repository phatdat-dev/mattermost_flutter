import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mattermost_flutter/src/config/config.dart';
import 'package:mattermost_flutter/src/mattermost_client.dart';

/// WebSocket client for Mattermost
class MattermostWebSocketClient {
  final MattermostConfig config;
  final MattermostClient client;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _eventController = StreamController<Map<String, dynamic>>.broadcast();
  int _seq = 1;
  bool _connected = false;
  Timer? _pingTimer;

  /// Stream of WebSocket events
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  /// Whether the WebSocket is connected
  bool get isConnected => _connected;

  MattermostWebSocketClient({
    required this.config,
    required this.client,
  });

  /// Connect to the WebSocket
  Future<void> connect() async {
    if (_connected) return;

    try {
      final serverUrl = config.baseUrl.replaceFirst('http', 'ws');
      final wsUrl = '$serverUrl/api/v4/websocket';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _subscription = _channel!.stream.listen(
        (dynamic message) {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          _handleMessage(data);
        },
        onError: (error) {
          _eventController.add({
            'event': 'error',
            'data': {'message': error.toString()},
          });
          disconnect();
        },
        onDone: () {
          _connected = false;
          _eventController.add({
            'event': 'close',
            'data': {'message': 'WebSocket connection closed'},
          });
        },
      );

      // Authenticate after connection
      if (config.token != null && config.token!.isNotEmpty) {
        _authenticate();
      }

      _connected = true;
      _startPingTimer();

      _eventController.add({
        'event': 'open',
        'data': {'message': 'WebSocket connection established'},
      });
    } catch (e) {
      _eventController.add({
        'event': 'error',
        'data': {'message': 'Failed to connect to WebSocket: $e'},
      });
      rethrow;
    }
  }

  /// Disconnect from the WebSocket
  void disconnect() {
    _stopPingTimer();
    _subscription?.cancel();
    _channel?.sink.close();
    _connected = false;
  }

  /// Send a message to the WebSocket
  void send(Map<String, dynamic> message) {
    if (!_connected) {
      throw Exception('WebSocket is not connected');
    }

    message['seq'] = _seq++;
    _channel!.sink.add(jsonEncode(message));
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(Map<String, dynamic> message) {
    if (message.containsKey('event')) {
      _eventController.add(message);
    }

    if (message.containsKey('seq_reply')) {
      // Handle response to a previous request
      _eventController.add({
        'event': 'response',
        'seq': message['seq_reply'],
        'data': message,
      });
    }
  }

  /// Authenticate with the WebSocket
  void _authenticate() {
    send({
      'action': 'authentication_challenge',
      'data': {
        'token': config.token,
      },
    });
  }

  /// Start the ping timer to keep the connection alive
  void _startPingTimer() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_connected) {
        send({
          'action': 'ping',
          'data': {},
        });
      }
    });
  }

  /// Stop the ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Dispose the WebSocket client
  void dispose() {
    disconnect();
    _eventController.close();
  }
}

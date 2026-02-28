/// vox core: WebSocket engine — real-time bidirectional messaging.
library;

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

// ---------------------------------------------------------------------------
// VoxSocket — the WebSocket connection handle
// ---------------------------------------------------------------------------

/// A real-time WebSocket connection.
///
/// Created via `ws("wss://...")`. Handles connect, send, listen, and close.
///
/// ```dart
/// final socket = ws("wss://chat.example.com/room/1");
///
/// socket.on("message", (data) => messages << data['text']);
/// socket.on("user_joined", (data) => log.info("${data['name']} joined"));
///
/// socket.send({"type": "message", "text": "Hello!"});
///
/// // When done:
/// socket.close();
/// ```
class VoxSocket {
  final String _url;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  final Map<String, List<void Function(dynamic)>> _listeners = {};

  bool _connected = false;

  VoxSocket._(this._url) {
    _connect();
  }

  // -- Connection -----------------------------------------------------------

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _connected = true;
      _sub = _channel!.stream.listen(
        _onData,
        onError: (_) => _connected = false,
        onDone: () => _connected = false,
        cancelOnError: false,
      );
    } catch (_) {
      _connected = false;
    }
  }

  /// Whether the socket is currently connected.
  bool get isConnected => _connected;

  // -- Events ---------------------------------------------------------------

  void _onData(dynamic raw) {
    try {
      if (raw is String) {
        final data = jsonDecode(raw);
        if (data is Map) {
          final type = (data['type'] ?? data['event'])?.toString();
          if (type != null) {
            _dispatch(type, Map<String, dynamic>.from(data));
          }
        }
        _dispatch('_message', raw);
      } else {
        _dispatch('_bytes', raw);
      }
    } catch (_) {
      _dispatch('_raw', raw);
    }
  }

  void _dispatch(String event, dynamic data) {
    final handlers = _listeners[event];
    if (handlers != null) {
      for (final fn in List.of(handlers)) {
        fn(data);
      }
    }
  }

  // -- Listen ---------------------------------------------------------------

  /// Register a [callback] for [event] messages.
  ///
  /// [event] matches the `"type"` or `"event"` field in incoming JSON.
  /// Use `"_message"` to receive every raw message.
  /// Use `"_bytes"` to receive binary frames.
  ///
  /// ```dart
  /// socket.on("chat", (data) => messages << data['text']);
  /// ```
  void on(String event, void Function(dynamic data) callback) {
    _listeners.putIfAbsent(event, () => []).add(callback);
  }

  /// Remove a specific [callback] for [event], or all callbacks if omitted.
  void off(String event, [void Function(dynamic data)? callback]) {
    if (callback == null) {
      _listeners.remove(event);
    } else {
      _listeners[event]?.remove(callback);
    }
  }

  // -- Send -----------------------------------------------------------------

  /// Send a JSON [data] map to the server.
  ///
  /// ```dart
  /// socket.send({"type": "chat", "text": "Hello!"});
  /// ```
  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  /// Send a raw [text] string to the server.
  void sendText(String text) {
    _channel?.sink.add(text);
  }

  /// Send raw [bytes] to the server.
  void sendBytes(List<int> bytes) {
    _channel?.sink.add(bytes);
  }

  // -- Close ----------------------------------------------------------------

  /// Close the connection and remove all listeners.
  void close([int? code, String? reason]) {
    _sub?.cancel();
    _channel?.sink.close(code, reason);
    _connected = false;
    _listeners.clear();
  }
}

// ---------------------------------------------------------------------------
// ws() — top-level factory
// ---------------------------------------------------------------------------

/// Open a WebSocket connection to [url].
///
/// Returns a [VoxSocket] that is already connected and ready to use.
///
/// ```dart
/// final socket = ws("wss://chat.example.com/room/1");
///
/// socket.on("message", (data) {
///   messages << data['text'];
/// });
///
/// socket.send({"type": "join", "name": "Alice"});
/// ```
VoxSocket ws(String url) => VoxSocket._(url);

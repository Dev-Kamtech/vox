/// vox api: realtime — WebSocket real-time messaging.
///
/// ```dart
/// // Connect to a WebSocket server:
/// final socket = ws("wss://chat.example.com/room/1");
///
/// // Listen to typed events (matches "type" field in JSON):
/// socket.on("message",     (data) => messages << data['text']);
/// socket.on("user_joined", (data) => log.info("${data['name']} joined"));
///
/// // Listen to every incoming message:
/// socket.on("_message", (raw) => print(raw));
///
/// // Send a JSON message:
/// socket.send({"type": "chat", "text": "Hello!"});
///
/// // Send raw text:
/// socket.sendText("ping");
///
/// // Disconnect:
/// socket.close();
///
/// // Check connection:
/// if (socket.isConnected) { ... }
/// ```
library;

export '../core/realtime/websocket.dart' show VoxSocket, ws;

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    // Replace with your machine IP if testing on device
    socket = IO.io(
        'http://10.0.2.2:3000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build()
    );

    socket.onConnect((_) {
      print('Connected to Socket.IO server: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    socket.on('receive_message', (data) {
      print('Message received: $data');
    });
  }

  void sendMessage(String text, String sender) {
    socket.emit('send_message', {
      'text': text,
      'sender': sender,
      'sentAt': DateTime.now().toIso8601String()
    });
  }

  void disconnect() {
    socket.dispose();
  }
}

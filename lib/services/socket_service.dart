import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class SocketService {
  IO.Socket? socket; // Nullable now

  // Get proper base URL depending on platform
  String getBaseUrl() {
    if (kIsWeb) return "http://localhost:3000";
    if (Platform.isAndroid) return "http://10.0.2.2:3000";
    return "http://192.168.1.8:3000"; // Replace with your PC IP for real device
  }

  Future<void> connect() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ No user logged in. Cannot connect to Socket.IO");
      return;
    }

    final idToken = await user.getIdToken();

    socket = IO.io(
      getBaseUrl(),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .enableReconnection()
          .setAuth({"token": idToken})
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("🔥 Connected to Socket.IO with Firebase ID token");
    });

    socket!.onConnectError((err) {
      print("❌ Socket Connect Error: $err");
    });

    socket!.onDisconnect((_) {
      print("🔻 Socket Disconnected");
    });

    socket!.on('auth_ok', (data) {
      print("✅ Auth OK from server: $data");
    });

    socket!.on('receive_message', (data) {
      print("📩 Incoming message: $data");
    });
  }

  void joinRoom(String room) {
    if (socket?.connected ?? false) {
      socket!.emit("join", room);
    } else {
      print("⚠️ Socket not connected. Cannot join room $room");
    }
  }

  void leaveRoom(String room) {
    if (socket?.connected ?? false) {
      socket!.emit("leave", room);
    } else {
      print("⚠️ Socket not connected. Cannot leave room $room");
    }
  }

  void sendMessage(Map<String, dynamic> message, String room, String sender) {
    if (socket?.connected ?? false) {
      socket!.emit("send_message", {
        "sender": sender,
        "text": message["text"],
        "room": room,
        "sentAt": message["sentAt"],
      });
    } else {
      print("⚠️ Socket not connected. Cannot send message");
    }
  }

  void disconnect() {
    socket?.disconnect();
    print("🔻 Socket manually disconnected");
  }
}

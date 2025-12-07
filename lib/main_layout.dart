import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_screen.dart';
import 'services/socket_service.dart';
import 'phone_login_screen.dart';
import 'main_layout.dart';

/// ============================
/// MAIN LAYOUT (Home + Chat List)
/// ============================
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late String currentUserUid;
  late SocketService socketService;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserUid = user.uid;
      socketService = SocketService();
      socketService.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    // Fetch all users except current user
    final usersStream = FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: currentUserUid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text(
          'Chit Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs;
          if (users.isEmpty) return const Center(child: Text("No users found"));

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(indent: 72),
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: const CircleAvatar(radius: 25, child: Icon(Icons.person)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        u['name'] ?? "Unknown",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                subtitle: const Text("Tap to chat"),
                onTap: () {
                  final room = generateRoomId(currentUserUid, u['uid']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        name: u['name'] ?? "Unknown",
                        room: room,
                        socketService: socketService,
                        currentUserUid: currentUserUid,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  String generateRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return "${ids[0]}_${ids[1]}";
  }
}

/// ============================
/// CHAT PAGE
/// ============================
class ChatPage extends StatefulWidget {
  final String name;
  final String room;
  final SocketService socketService;
  final String currentUserUid;

  const ChatPage({
    super.key,
    required this.name,
    required this.room,
    required this.socketService,
    required this.currentUserUid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();

    // Join room
    widget.socketService.joinRoom(widget.room);

    // Listen to socket messages
    widget.socketService.socket?.on('receive_message', (data) {
      if (data['room'] == widget.room) {
        setState(() {
          messages.add({
            "sender": data['sender'],
            "text": data['text'],
            "sentAt": data['sentAt'],
          });
        });
        _scroll.jumpTo(_scroll.position.maxScrollExtent + 60);
      }
    });
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final msg = {
      "sender": widget.currentUserUid,
      "text": text,
      "room": widget.room,
      "sentAt": DateTime.now().toIso8601String(),
    };

    // Send via Socket
    widget.socketService.sendMessage(msg, widget.room, widget.currentUserUid);

    // Save to Firestore
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.room)
        .collection('messages')
        .add(msg);

    _controller.clear();
  }

  @override
  void dispose() {
    widget.socketService.leaveRoom(widget.room);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msgStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.room)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 10),
            Text(widget.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: msgStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final docs = snapshot.data!.docs;
                messages.clear();
                messages.addAll(docs.map((doc) => {
                  "sender": doc['sender'],
                  "text": doc['text'],
                  "sentAt": doc['sentAt'],
                }));
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    final isMe = m['sender'] == widget.currentUserUid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m['text'] ?? ""),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.green[800],
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

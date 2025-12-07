import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_screen.dart';
import 'find_friends_screen.dart';
import 'services/socket_service.dart';
import 'phone_login_screen.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late String currentUserUid;
  late SocketService socketService;
  List<String> friends = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      currentUserUid = user.uid;

      socketService = SocketService();
      socketService.connect(); // optional: keep socket if you want real-time
      _loadFriends();
    }
  }

  void _loadFriends() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .get();

    friends = List<String>.from(doc['friends'] ?? []);
    setState(() {});
  }

  Stream<QuerySnapshot> getFriendsStream() {
    if (friends.isEmpty) {
      // Return a query that will never match any documents
      return FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: 'null')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: friends)
          .snapshots();
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text(
          'Chit Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FindFriendsScreen()),
              );
            },
          ),
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
        stream: getFriendsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("No friends yet"));
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(indent: 72),
            itemBuilder: (context, index) {
              final u = users[index];

              return ListTile(
                leading: const CircleAvatar(radius: 25, child: Icon(Icons.person)),
                title: Text(
                  u['name'] ?? "Unknown",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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


// CHAT PAGE

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

  @override
  void initState() {
    super.initState();

    widget.socketService.joinRoom(widget.room);

    widget.socketService.socket?.on('receive_message', (data) {
      if (data['room'] == widget.room) {
        setState(() {});
        _scroll.jumpTo(_scroll.position.maxScrollExtent + 80);
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

    widget.socketService.sendMessage(msg, widget.room, widget.currentUserUid);

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
        .orderBy('sentAt')
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

                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final m = docs[i];
                    final isMe = m['sender'] == widget.currentUserUid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m['text']),
                      ),
                    );
                  },
                );
              },
            ),
          ),

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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

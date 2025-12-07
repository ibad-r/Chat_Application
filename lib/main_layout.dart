// main_layout.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_screen.dart';
import 'find_friends_screen.dart';
import 'phone_login_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String? currentUserUid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUserUid = user?.uid;
  }

  String generateRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Widget build(BuildContext context) {
    // If not logged in, redirect to login screen
    if (currentUserUid == null) {
      // use microtask to avoid calling navigator during build sync
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
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

      // Body: stream current user doc to get friends list in real-time
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocStream,
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnap.hasData || userSnap.data == null) {
            return const Center(child: Text("User data not found."));
          }

          final data = userSnap.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("User data unavailable."));
          }

          final List<dynamic> friendsDynamic = data['friends'] ?? [];
          final List<String> friends = friendsDynamic.map((e) => e.toString()).toList();

          // If there are no friends, show message and button to Find Friends
          if (friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("No friends yet. Find and add friends to start chatting."),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text("Find Friends"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FindFriendsScreen()),
                      );
                    },
                  ),
                ],
              ),
            );
          }


          final friendsStream = FirebaseFirestore.instance
              .collection('users')
              .where('uid', whereIn: friends)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: friendsStream,
            builder: (context, friendsSnap) {
              if (friendsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!friendsSnap.hasData) {
                return const Center(child: Text("No friends found."));
              }

              final docs = friendsSnap.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text("No friends found."));
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(indent: 72),
                itemBuilder: (context, index) {
                  final u = docs[index].data() as Map<String, dynamic>;
                  final friendName = (u['name'] ?? 'Unknown') as String;
                  final friendUid = (u['uid'] ?? docs[index].id) as String;

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: u['photo'] != null ? NetworkImage(u['photo']) : null,
                      child: u['photo'] == null ? Text(friendName.isNotEmpty ? friendName[0] : '?') : null,
                    ),
                    title: Text(friendName, overflow: TextOverflow.ellipsis),
                    subtitle: const Text("Tap to chat"),
                    onTap: () {
                      final roomId = generateRoomId(currentUserUid!, friendUid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            name: friendName,
                            friendUid: friendUid,
                            room: roomId,
                            currentUserUid: currentUserUid!,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


/// ChatPage

class ChatPage extends StatefulWidget {
  final String name;
  final String friendUid;
  final String room;
  final String currentUserUid;

  const ChatPage({
    super.key,
    required this.name,
    required this.friendUid,
    required this.room,
    required this.currentUserUid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // message payload
    final msg = {
      "sender": widget.currentUserUid,
      "text": text,
      "sentAt": FieldValue.serverTimestamp(),
    };

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.room);

    try {
      // Add the message (this will create the chats/{room} doc + messages subcollection automatically)
      await chatRef.collection('messages').add(msg);

      // Update room metadata (members should be UIDs)
      await chatRef.set({
        "members": [widget.currentUserUid, widget.friendUid],
        "lastMessage": text,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // show minimal error to user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Send failed: $e")));
      return;
    }

    _controller.clear();

    // scroll to bottom after small delay so new message appears
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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
        title: Row(
          children: [
            CircleAvatar(
              child: Text(widget.name.isNotEmpty ? widget.name[0] : '?'),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.name)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: msgStream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data == null) {
                  return const SizedBox();
                }
                final docs = snap.data!.docs;

                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final m = docs[i].data() as Map<String, dynamic>;
                    final sender = m['sender'] ?? '';
                    final text = m['text'] ?? '';
                    final isMe = sender == widget.currentUserUid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(text),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // input area
          SafeArea(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green[800],
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

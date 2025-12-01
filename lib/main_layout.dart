import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// MAIN SCREEN
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  final List<Map<String, String>> chats = const [
    {'name': 'Ali Ahmed', 'message': 'What kind of strategy is better?', 'date': '11/16/19', 'image': ''},
    {'name': 'Ayesha Malik', 'message': 'Voice Message • 0:14', 'date': '11/15/19', 'image': ''},
    {'name': 'Hassan Raza', 'message': 'Bro, I have a good idea!', 'date': '10/30/19', 'image': ''},
    {'name': 'Fatima Noor', 'message': 'Photo ', 'date': '10/28/19', 'image': ''},
    {'name': 'Sara Ahmed', 'message': 'Actually I wanted to check with you...', 'date': '8/25/19', 'image': ''},
    {'name': 'Muneeba Tariq', 'message': 'Welcome, let’s make design process faster!', 'date': '8/20/19', 'image': ''},
    {'name': 'Bilal Shah', 'message': 'Ok, have a good trip!', 'date': '7/29/19', 'image': ''},
    {'name': 'Zainab Rehman', 'message': 'See you at the meeting tomorrow!', 'date': '11/18/19', 'image': ''},
    {'name': 'Hamza Qureshi', 'message': 'Let’s play cricket this weekend!', 'date': '11/12/19', 'image': ''},
    {'name': 'Maryam Siddiqui', 'message': 'Got your message, thanks!', 'date': '10/05/19', 'image': ''},
    {'name': 'Umar Farooq', 'message': 'Photo ', 'date': '9/21/19', 'image': ''},
    {'name': 'Hira Khan', 'message': 'Let’s meet at Café Lahore.', 'date': '8/10/19', 'image': ''},
    {'name': 'Ahmed Saeed', 'message': 'Done! I’ve sent the files.', 'date': '8/04/19', 'image': ''},
    {'name': 'Laiba Nawaz', 'message': 'Good night ', 'date': '7/20/19', 'image': ''},
  ];

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(indent: 72),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: const CircleAvatar(radius: 25, child: Icon(Icons.person)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    chat['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  chat['date']!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(chat['message']!, overflow: TextOverflow.ellipsis),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(name: chat['name']!, image: chat['image']!),
                ),
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
}

// CHAT PAGE WITH ROOM MANAGEMENT
class ChatPage extends StatefulWidget {
  final String name;
  final String image;
  const ChatPage({super.key, required this.name, required this.image});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = [];

  late IO.Socket socket;
  late String username;
  String? currentRoom;

  @override
  void initState() {
    super.initState();
    username = widget.name;

    // Connect socket (if not already connected globally, create here)
    socket = IO.io(
      'http://localhost:3000', // replace with LAN IP if using physical device
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    socket.onConnect((_) {
      print('Connected: ${socket.id}');
      joinRoom(widget.name); // join initial room
    });

    // Listen to messages
    socket.on('receive_message', (data) {
      setState(() {
        messages.add({
          "sender": data['sender'] ?? "Anon",
          "text": data['text'] ?? "",
        });
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    socket.onDisconnect((_) => print('Disconnected'));
  }

  void joinRoom(String room) {
    if (currentRoom != null) {
      socket.emit('leave', currentRoom); // leave previous room
      print('Left room $currentRoom');
    }
    socket.emit('join', room);
    currentRoom = room;
    print('Joined room $room');
    messages.clear(); // clear old messages for new chat
  }

  @override
  void dispose() {
    socket.emit('leave', currentRoom);
    socket.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final message = {
        "sender": username,
        "text": text,
        "sentAt": DateTime.now().toIso8601String()
      };
      socket.emit('send_message', message);
      setState(() {
        messages.add(message);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: const [
          Icon(Icons.videocam),
          SizedBox(width: 16),
          Icon(Icons.call),
          SizedBox(width: 16),
          Icon(Icons.more_vert),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['sender'] == username;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['sender']!,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(message['text']!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  color: Colors.grey[700],
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.grey[700],
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  color: Colors.grey[700],
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    radius: 22,
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

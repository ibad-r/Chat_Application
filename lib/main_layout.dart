import 'package:flutter/material.dart';

// MAIN SCREEN (with updated, clickable profile icon)
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  // Dummy chat list (you can add as many as you want)
  final List<Map<String, String>> chats = const [
    {
      'name': 'Ali Khan',
      'message': 'What kind of strategy is better?',
      'date': '11/16/19',
      'image': 'https://randomuser.me/api/portraits/men/31.jpg',
    },
    {
      'name': 'Ayesha Malik',
      'message': 'Voice Message • 0:14',
      'date': '11/15/19',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
    },
    // ... other chat data remains the same
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
        // THIS 'actions' SECTION IS THE ONLY PART THAT HAS CHANGED
        actions: [
          // Wrapped the CircleAvatar in an IconButton to make it clickable
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {
              // Navigate to the new ProfileScreen when tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      // CHAT LIST (This part is unchanged)
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(indent: 72),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(chat['image']!),
            ),
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
              child: Text(
                chat['message']!,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    name: chat['name']!,
                    image: chat['image']!,
                  ),
                ),
              );
            },
          );
        },
      ),

      // BOTTOM NAV (This part is unchanged)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// NEW PROFILE SCREEN WIDGET
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Large profile picture
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'), // Placeholder image
            ),
            const SizedBox(height: 20),
            // User Name
            const Text(
              'IBAD', // Placeholder Name
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // User Info using ListTiles for a clean look
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('uibad0642@gmail.com'), // Placeholder Email
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('+92 123 4567890'), // Placeholder Phone
            ),
          ],
        ),
      ),
    );
  }
}


// CHAT PAGE (This part is unchanged)
class ChatPage extends StatefulWidget {
  final String name;
  final String image;

  const ChatPage({super.key, required this.name, required this.image});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [
    "Hey there!",
    "How are you doing today?",
    "Let's catch up later!"
  ];

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add(text);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CHAT HEADER
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.image),
            ),
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

      // CHAT MESSAGES
      body: Column(
        children: [
          // Scrollable messages area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = index % 2 == 0; // alternate for demo

                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.green[100]
                          : Colors.grey[200], // light color bubbles
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(message),
                  ),
                );
              },
            ),
          ),

          //  TEXT INPUT AREA
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
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
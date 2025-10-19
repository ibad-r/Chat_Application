import 'package:flutter/material.dart';

// MAIN SCREEN (Images Removed)
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  final List<Map<String, String>> chats = const [
    {
      'name': 'Ali Ahmed',
      'message': 'What kind of strategy is better?',
      'date': '11/16/19',
      'image': '',
    },
    {
      'name': 'Ayesha Malik',
      'message': 'Voice Message • 0:14',
      'date': '11/15/19',
      'image': '',
    },
    {
      'name': 'Hassan Raza',
      'message': 'Bro, I have a good idea!',
      'date': '10/30/19',
      'image': '',
    },
    {
      'name': 'Fatima Noor',
      'message': 'Photo ',
      'date': '10/28/19',
      'image': '',
    },
    {
      'name': 'Sara Ahmed',
      'message': 'Actually I wanted to check with you...',
      'date': '8/25/19',
      'image': '',
    },
    {
      'name': 'Muneeba Tariq',
      'message': 'Welcome, let’s make design process faster!',
      'date': '8/20/19',
      'image': '',
    },
    {
      'name': 'Bilal Shah',
      'message': 'Ok, have a good trip!',
      'date': '7/29/19',
      'image': '',
    },
    {
      'name': 'Zainab Rehman',
      'message': 'See you at the meeting tomorrow!',
      'date': '11/18/19',
      'image': '',
    },
    {
      'name': 'Hamza Qureshi',
      'message': 'Let’s play cricket this weekend!',
      'date': '11/12/19',
      'image': '',
    },
    {
      'name': 'Maryam Siddiqui',
      'message': 'Got your message, thanks!',
      'date': '10/05/19',
      'image': '',
    },
    {
      'name': 'Umar Farooq',
      'message': 'Photo ',
      'date': '9/21/19',
      'image': '',
    },
    {
      'name': 'Hira Khan',
      'message': 'Let’s meet at Café Lahore.',
      'date': '8/10/19',
      'image': '',
    },
    {
      'name': 'Ahmed Saeed',
      'message': 'Done! I’ve sent the files.',
      'date': '8/04/19',
      'image': '',
    },
    {
      'name': 'Laiba Nawaz',
      'message': 'Good night ',
      'date': '7/20/19',
      'image': '',
    },
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
            // **IMAGE REMOVED HERE**
            leading: const CircleAvatar(
              radius: 25,
              child: Icon(Icons.person),
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

// PROFILE SCREEN WIDGET (Image Removed)
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
            // **IMAGE REMOVED HERE**
            const CircleAvatar(
              radius: 60,
              child: Icon(Icons.person, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              'IBAD',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('uibad0642@gmail.com'),
            ),
            const ListTile(
              leading: Icon(Icons.phone_outlined),
              title: Text('+92 123 4567890'),
            ),
          ],
        ),
      ),
    );
  }
}

// CHAT PAGE (Image Removed)
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
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
        title: Row(
          children: [
            // **IMAGE REMOVED HERE**
            const CircleAvatar(
              child: Icon(Icons.person),
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
      body: Column(
        children: [
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
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(message),
                  ),
                );
              },
            ),
          ),
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
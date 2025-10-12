import 'package:flutter/material.dart';

//  MAIN SCREEN
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
    {
      'name': 'Hassan Raza',
      'message': 'Bro, I have a good idea!',
      'date': '10/30/19',
      'image': 'https://randomuser.me/api/portraits/men/46.jpg',
    },
    {
      'name': 'Fatima Noor',
      'message': 'Photo ',
      'date': '10/28/19',
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
    },
    {
      'name': 'Sara Ahmed',
      'message': 'Actually I wanted to check with you...',
      'date': '8/25/19',
      'image': 'https://randomuser.me/api/portraits/women/21.jpg',
    },
    {
      'name': 'Muneeba Tariq',
      'message': 'Welcome, let’s make design process faster!',
      'date': '8/20/19',
      'image': 'https://randomuser.me/api/portraits/women/9.jpg',
    },
    {
      'name': 'Bilal Shah',
      'message': 'Ok, have a good trip!',
      'date': '7/29/19',
      'image': 'https://randomuser.me/api/portraits/men/22.jpg',
    },
    {
      'name': 'Zainab Rehman',
      'message': 'See you at the meeting tomorrow!',
      'date': '11/18/19',
      'image': 'https://randomuser.me/api/portraits/women/37.jpg',
    },
    {
      'name': 'Hamza Qureshi',
      'message': 'Let’s play cricket this weekend!',
      'date': '11/12/19',
      'image': 'https://randomuser.me/api/portraits/men/24.jpg',
    },
    {
      'name': 'Maryam Siddiqui',
      'message': 'Got your message, thanks!',
      'date': '10/05/19',
      'image': 'https://randomuser.me/api/portraits/women/36.jpg',
    },
    {
      'name': 'Umar Farooq',
      'message': 'Photo ',
      'date': '9/21/19',
      'image': 'https://randomuser.me/api/portraits/men/41.jpg',
    },
    {
      'name': 'Hira Khan',
      'message': 'Let’s meet at Café Lahore.',
      'date': '8/10/19',
      'image': 'https://randomuser.me/api/portraits/women/60.jpg',
    },
    {
      'name': 'Ahmed Saeed',
      'message': 'Done! I’ve sent the files.',
      'date': '8/04/19',
      'image': 'https://randomuser.me/api/portraits/men/49.jpg',
    },
    {
      'name': 'Laiba Nawaz',
      'message': 'Good night ',
      'date': '7/20/19',
      'image': 'https://randomuser.me/api/portraits/women/55.jpg',
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      // CHAT LIST
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

      // BOTTOM NAV
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

//CHAT PAGE
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

import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  // This const constructor is the key to fixing the error!
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text(
          'Chit Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),

      body: const Center(
        child: Text('SUDAIS MALIK will build the chat list here tomorrow!'),
      ),

      // We are adding the BottomNavigationBar here
      bottomNavigationBar: BottomNavigationBar(
        // This makes the first item ("Chats") appear selected
        currentIndex: 0,

        // This makes the icons and text blue when selected
        selectedItemColor: Colors.blue[800],

        // This makes the icons and text grey when not selected
        unselectedItemColor: Colors.grey[600],

        // This ensures the background color is always white and items don't shift
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
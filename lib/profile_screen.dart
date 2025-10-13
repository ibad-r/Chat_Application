// lib/profile_screen.dart
import 'package:flutter/material.dart';

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
              child: Icon(Icons.person, size: 60),
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
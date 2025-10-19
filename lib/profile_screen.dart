// lib/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              leading: const CircleAvatar(
                radius: 35,
                child: Icon(Icons.person, size: 35),
              ),
              title: const Text(
                'IBAD',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Busy',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: Icon(Icons.qr_code, color: Colors.green[800]),
                onPressed: () {  },
              ),
              onTap: () {  },
            ),

            const Divider(thickness: 1),

            _buildSettingsTile(
              icon: Icons.key,
              title: 'Account',
              subtitle: 'Security notifications, change number',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.lock,
              title: 'Privacy',
              subtitle: 'Block contacts, disappearing messages',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.emoji_emotions,
              title: 'Avatar',
              subtitle: 'Create, edit, profile photo',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Message, group & call tones',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.data_usage,
              title: 'Storage and data',
              subtitle: 'Network usage, auto-download',
              onTap: () {},
            ),

            const Divider(thickness: 1, height: 20),

            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help',
              subtitle: 'Help center, contact us, privacy policy',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.group,
              title: 'Invite a friend',
              subtitle: '',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: onTap,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return const Center(child: Text("User data not found!"));
          }

          String name = userData["name"] ?? "Unknown User";
          String phone = userData["phone"] ?? "No Phone";
          String? photo = userData["photo"];
          String status = userData["status"] ?? "Busy";

          return SingleChildScrollView(
            child: Column(
              children: [
                /// TOP PROFILE TILE
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  leading: CircleAvatar(
                    radius: 35,
                    backgroundImage: photo != null ? NetworkImage(photo) : null,
                    child: photo == null ? const Icon(Icons.person, size: 35) : null,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    status,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.qr_code, color: Colors.green[800]),
                    onPressed: () {},
                  ),
                  onTap: () {},
                ),

                Divider(thickness: 1),

                /// ADD MORE SETTINGS
                _buildSettingsTile(
                  icon: Icons.phone,
                  title: 'Phone',
                  subtitle: phone,
                  onTap: () {},
                ),
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

                Divider(thickness: 1, height: 20),

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
          );
        },
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

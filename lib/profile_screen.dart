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
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("User data not found!"));
          }

          final String name = data["name"] ?? "Unknown User";
          final String phone = data["phone"] ?? "No Phone";
          final String? photo = data["photo"];
          final String status = data["status"] ?? "Busy";

          return SingleChildScrollView(
            child: Column(
              children: [
                // USER PROFILE HEADER
                ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),

                  leading: CircleAvatar(
                    radius: 38,
                    backgroundImage:
                    photo != null ? NetworkImage(photo) : null,
                    child: photo == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),

                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Text(
                    status,
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  trailing: Icon(Icons.qr_code, color: Colors.green[800]),
                  onTap: () {},
                ),

                const Divider(),

                // PHONE
                _buildSettingsTile(
                  icon: Icons.phone,
                  title: "Phone",
                  subtitle: phone,
                  onTap: () {},
                ),

                // ACCOUNT
                _buildSettingsTile(
                  icon: Icons.key,
                  title: "Account",
                  subtitle: "Security notifications, change number",
                  onTap: () {},
                ),

                // PRIVACY
                _buildSettingsTile(
                  icon: Icons.lock,
                  title: "Privacy",
                  subtitle: "Block contacts, disappearing messages",
                  onTap: () {},
                ),

                // NOTIFICATIONS
                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: "Notifications",
                  subtitle: "Message, group & call tones",
                  onTap: () {},
                ),

                // STORAGE
                _buildSettingsTile(
                  icon: Icons.data_usage,
                  title: "Storage and data",
                  subtitle: "Network usage, auto-download",
                  onTap: () {},
                ),

                const Divider(height: 24),

                // HELP
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: "Help",
                  subtitle: "Help center, contact us, privacy policy",
                  onTap: () {},
                ),

                //INVITE
                _buildSettingsTile(
                  icon: Icons.group,
                  title: "Invite a friend",
                  subtitle: "",
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //REUSABLE SETTING TILE
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

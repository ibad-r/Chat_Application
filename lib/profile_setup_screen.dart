import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_layout.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phone;

  const ProfileSetupScreen({super.key, required this.phone});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  bool _saving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () async {
                final picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => _image = File(picked.path));
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () async {
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _image = File(picked.path));
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String? imageUrl;

      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child("profile_pics/$uid.jpg");
        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "name": _nameController.text.trim(),
        "phone": widget.phone,
        "photo": imageUrl,
        "created_at": FieldValue.serverTimestamp(),
      });

      // ✅ Fixed: Navigate to MainLayout (imported already)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Setup"),
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 65,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.camera_alt, size: 45) : null,
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save & Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

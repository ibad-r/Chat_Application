import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'phone_login_screen.dart';
import 'main_layout.dart';
import 'profile_setup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _checkLoginFlow() async {
    final user = FirebaseAuth.instance.currentUser;

    // User NOT logged in → Go to phone login
    if (user == null) {
      return const PhoneLoginScreen();
    }

    // User logged in → Check Firestore profile
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      // Profile exists → Go to Main Home Layout
      return MainLayout();
    } else {
      // First login → Go to Profile Setup Page
      return ProfileSetupScreen(phone: user.phoneNumber ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _checkLoginFlow(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}

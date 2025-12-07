import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'phone_login_screen.dart';
import 'main_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final user = FirebaseAuth.instance.currentUser;

  // Connect SocketService only if user is logged in
  if (user != null) {
    await SocketService().connect();
  }

  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;
  const MyApp({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? const PhoneLoginScreen() : MainLayout(), // removed const
    );
  }
}

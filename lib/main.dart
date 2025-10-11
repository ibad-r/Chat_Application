// main.dart
import 'package:flutter/material.dart';
import 'phone_login_screen.dart'; // Import your new screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        // Define your color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF075E54), // Dark Blue/Green (Primary)
          primary: const Color(0xFF075E54),   // Primary color
          secondary: const Color(0xFF25D366), // Teal/Green (Accent)
        ),
        useMaterial3: true,
      ),
      // Start the app on the login screen
      home: const PhoneLoginScreen(),
    );
  }
}
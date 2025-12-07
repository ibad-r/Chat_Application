import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_setup_screen.dart';
import 'main_layout.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  Future<void> _verifyOtp() async {
    final String otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter 6-digit OTP")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final auth = FirebaseAuth.instance;

      // Create Firebase credential
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign in the user
      final userCred = await auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user == null) {
        throw Exception("User not found after OTP verification.");
      }

      // Check Firestore profile
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        // Profile already created → Go to main layout
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainLayout()),
              (route) => false,
        );
      } else {
        // First time login → Go to profile setup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupScreen(phone: widget.phone),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the OTP sent to ${widget.phone}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // OTP input
            TextField(
              controller: _otpController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("6 Digit OTP"),
              ),
            ),

            const SizedBox(height: 20),

            // Verify Button
            ElevatedButton(
              onPressed: _loading ? null : _verifyOtp,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}

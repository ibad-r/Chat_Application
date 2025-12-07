import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  Future<void> _sendOtp() async {
    String phone = _phoneController.text.trim();

    // Normalize phone number
    if (phone.startsWith("0")) {
      phone = phone.substring(1);
    }

    // Final full phone with +92
    final fullPhone = "+92$phone";

    // Validate phone
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid Pakistani phone number.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential cred) async {
          // (Optional) auto verification
        },
        verificationFailed: (FirebaseAuthException error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${error.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                verificationId: verificationId,
                phone: fullPhone,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending OTP: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your phone number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // Phone number input
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                label: Text("Phone (e.g. 3001234567)"),
                prefixText: "+92 ",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            // Send OTP Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child:
                  CircularProgressIndicator(color: Colors.white),
                )
                    : const Text("Send OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

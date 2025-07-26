import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  String message = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password', style: GoogleFonts.lato())),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined,
                  size: 64, color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text(
                'Enter your email address and we’ll send you a link to reset your password.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: loading
                    ? null
                    : () async {
                        setState(() {
                          loading = true;
                          message = '';
                        });
                        try {
                          await AuthService.sendPasswordResetEmail(
                              emailController.text.trim());
                          setState(() {
                            message = 'Password reset email sent!';
                          });
                        } catch (e) {
                          setState(() {
                            message = 'Failed to send reset email.';
                          });
                        }
                        setState(() {
                          loading = false;
                        });
                      },
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Send Reset Link'),
              ),
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    message,
                    style: TextStyle(
                        color: message.contains('sent')
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

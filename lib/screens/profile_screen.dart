// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color violet = const Color(0xFF8F5CFF);
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  void _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  void _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = value;
    });
    await prefs.setBool('notificationsEnabled', value);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeNotifier = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.lato(color: violet)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: violet),
            tooltip: "Log out",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: violet.withAlpha((0.2 * 255).toInt()),
              backgroundImage: const AssetImage('assets/profile.png'),
            ),
            const SizedBox(height: 16),
            if (user?.displayName != null && user!.displayName!.isNotEmpty)
              Text(
                user.displayName!,
                style: GoogleFonts.lato(
                  color: violet,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              user?.email ?? 'No email',
              style: GoogleFonts.lato(color: violet, fontSize: 16),
            ),
            if (user?.uid != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "UID: ${user!.uid.substring(0, 8)}...",
                  style: GoogleFonts.lato(
                    color: violet.withAlpha((0.5 * 255).toInt()),
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: violet,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.lock_reset),
              label: const Text('Change Password'),
              onPressed: () => _showChangePasswordDialog(context),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode',
                    style: GoogleFonts.lato(color: violet, fontSize: 18)),
                Switch(
                  value: themeNotifier.isDark,
                  activeColor: violet,
                  onChanged: (val) {
                    themeNotifier.toggleTheme(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Enable Notifications',
                    style: GoogleFonts.lato(color: violet, fontSize: 18)),
                Switch(
                  value: notificationsEnabled,
                  activeColor: violet,
                  onChanged: _toggleNotification,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1333),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Change Password',
                  style: GoogleFonts.lato(
                      color: violet,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              const SizedBox(height: 16),
              Text(
                'A password reset link will be sent to:',
                style: GoogleFonts.lato(color: violet),
              ),
              const SizedBox(height: 8),
              Text(email,
                  style: GoogleFonts.lato(
                      color: violet, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: violet,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (email.isNotEmpty) {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password reset email sent!')),
                    );
                  }
                },
                child: const Text('Send Reset Link'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: violet)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

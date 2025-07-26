// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myfirstproject/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning ☀️";
    if (hour < 18) return "Good Afternoon 🌤️";
    return "Good Evening 🌙";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout,
                color: isDarkMode ? Colors.white70 : Colors.black54),
            onPressed: () async {
              await AuthService.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dashboard',
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      backgroundColor:
                          isDarkMode ? Colors.white12 : Colors.black12,
                      child: Icon(Icons.person,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Greeting Card
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF5A189A), Color(0xFF240046)],
                            ),
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: GoogleFonts.poppins(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user?.email ?? '',
                                style: GoogleFonts.poppins(
                                  color: isDarkMode
                                      ? Colors.white60
                                      : Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Quick Access Title
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Quick Access",
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grid Access
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _DashboardCard(
                      icon: Icons.wb_sunny_rounded,
                      title: 'Weather',
                      subtitle: 'Live forecast',
                      color: Colors.tealAccent,
                      onTap: () => Navigator.pushNamed(context, '/weather')),
                  _DashboardCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Diary',
                      subtitle: 'Personal journal',
                      color: Colors.deepPurpleAccent,
                      onTap: () => Navigator.pushNamed(context, '/diary')),
                  _DashboardCard(
                      icon: Icons.check_box_rounded,
                      title: 'Tasks',
                      subtitle: 'Manage to-dos',
                      color: Colors.amberAccent,
                      onTap: () => Navigator.pushNamed(context, '/todo')),
                  _DashboardCard(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      color: Colors.lightBlueAccent,
                      onTap: () => Navigator.pushNamed(context, '/profile')),
                  _DashboardCard(
                      icon: Icons.bolt,
                      title: 'Reaction Test',
                      subtitle: 'Test your reflexes',
                      color: Colors.lightGreenAccent,
                      onTap: () => Navigator.pushNamed(context, '/reaction')),
                  _DashboardCard(
                      icon: Icons.touch_app,
                      title: 'Tapping Frenzy',
                      subtitle: 'Tap fast for 10 sec',
                      color: Colors.pinkAccent,
                      onTap: () => Navigator.pushNamed(context, '/tapping')),
                ],
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  "All your essentials, one tap away",
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

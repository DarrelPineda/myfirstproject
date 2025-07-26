import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReactionTestScreen extends StatefulWidget {
  const ReactionTestScreen({super.key});

  @override
  State<ReactionTestScreen> createState() => _ReactionTestScreenState();
}

class _ReactionTestScreenState extends State<ReactionTestScreen> {
  bool waiting = false;
  bool canTap = false;
  String message = "Tap to Start";
  Color backgroundColor = Colors.deepPurple.shade900;
  late DateTime startTime;
  Timer? delayTimer;

  void startTest() {
    setState(() {
      waiting = true;
      canTap = false;
      message = "Wait for green...";
      backgroundColor = Colors.red.shade900;
    });

    final randomDelay = Random().nextInt(3000) + 2000; // 2s - 5s

    delayTimer = Timer(Duration(milliseconds: randomDelay), () {
      setState(() {
        canTap = true;
        backgroundColor = Colors.green.shade700;
        message = "TAP NOW!";
        startTime = DateTime.now();
      });
    });
  }

  void handleTap() {
    if (!waiting) {
      startTest();
    } else if (!canTap) {
      // Too early!
      delayTimer?.cancel();
      setState(() {
        message = "Too soon! Try again.";
        backgroundColor = Colors.deepPurple.shade900;
        waiting = false;
      });
    } else {
      final reactionTime = DateTime.now().difference(startTime).inMilliseconds;
      setState(() {
        message = "Your reaction time: ${reactionTime}ms";
        backgroundColor = Colors.deepPurple.shade900;
        waiting = false;
      });
    }
  }

  @override
  void dispose() {
    delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: "Exit",
          ),
        ),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: backgroundColor,
          child: Center(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

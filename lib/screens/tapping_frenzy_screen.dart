import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

class TappingFrenzyScreen extends StatefulWidget {
  const TappingFrenzyScreen({super.key});

  @override
  State<TappingFrenzyScreen> createState() => _TappingFrenzyScreenState();
}

class _TappingFrenzyScreenState extends State<TappingFrenzyScreen> {
  int _tapCount = 0;
  bool _gameStarted = false;
  bool _gameOver = false;
  late DateTime _startTime;
  late Timer _timer;
  int _secondsLeft = 10;
  final Color velvetIndigo = const Color(0xFF4B0082);

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _tapCount = 1; // first tap
      _secondsLeft = 10;
      _startTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsed = DateTime.now().difference(_startTime).inSeconds;
      setState(() {
        _secondsLeft = 10 - elapsed;
      });
      if (elapsed >= 10) {
        _endGame();
      }
    });
  }

  void _incrementTap() {
    if (!_gameStarted) {
      _startGame();
    } else if (!_gameOver) {
      setState(() {
        _tapCount++;
      });
    }
  }

  void _endGame() {
    _timer.cancel();
    setState(() {
      _gameOver = true;
      _gameStarted = false;
    });
  }

  void _restartGame() {
    setState(() {
      _tapCount = 0;
      _gameStarted = false;
      _gameOver = false;
      _secondsLeft = 10;
    });
  }

  @override
  void dispose() {
    if (_gameStarted) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tapping Frenzy'),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _gameOver ? null : _incrementTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _gameOver
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Time\'s up!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your score: $_tapCount',
                        style: TextStyle(
                          fontSize: 28,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: velvetIndigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _restartGame,
                        child: const Text('Play Again'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Time left: $_secondsLeft s',
                        style: TextStyle(
                          fontSize: 24,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Taps: $_tapCount',
                        style: TextStyle(
                          fontSize: 48,
                          color: velvetIndigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_gameStarted)
                        Text(
                          'Tap anywhere to start!',
                          style: TextStyle(
                            fontSize: 20,
                            color: textColor,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

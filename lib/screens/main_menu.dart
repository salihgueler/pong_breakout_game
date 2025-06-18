import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/simple_pong_game.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PONG',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            _buildMenuButton(
              context,
              'Single Player',
              () => _startGame(context, GameMode.singlePlayer),
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              'Two Player (Local)',
              () => _startGame(context, GameMode.multiPlayer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(text),
      ),
    );
  }

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameMode: mode),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final GameMode gameMode;

  const GameScreen({super.key, required this.gameMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<SimplePongGame>.controlled(
        gameFactory: () => SimplePongGame(gameMode: gameMode),
      ),
    );
  }
}

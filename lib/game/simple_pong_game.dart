import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum GameMode { singlePlayer, multiPlayer }

class SimplePongGame extends FlameGame {
  late RectangleComponent player1Paddle;
  late RectangleComponent player2Paddle;
  late CircleComponent ball;
  late TextComponent scoreText;
  late TextComponent instructionText;
  
  Vector2 ballVelocity = Vector2.zero();
  int player1Score = 0;
  int player2Score = 0;
  
  // Input states
  bool player1Up = false;
  bool player1Down = false;
  bool player2Up = false;
  bool player2Down = false;
  
  final GameMode gameMode;
  
  SimplePongGame({required this.gameMode});

  @override
  Future<void> onLoad() async {
    // Create paddles
    player1Paddle = RectangleComponent(
      position: Vector2(50, size.y / 2 - 50),
      size: Vector2(20, 100),
      paint: Paint()..color = Colors.white,
    );
    
    player2Paddle = RectangleComponent(
      position: Vector2(size.x - 70, size.y / 2 - 50),
      size: Vector2(20, 100),
      paint: Paint()..color = Colors.white,
    );
    
    // Create ball
    ball = CircleComponent(
      position: Vector2(size.x / 2, size.y / 2),
      radius: 10,
      paint: Paint()..color = Colors.white,
    );
    
    // Create score text
    scoreText = TextComponent(
      text: '0 - 0',
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    // Create instruction text
    String controls = gameMode == GameMode.singlePlayer 
        ? 'Player: W/S or ↑/↓ keys'
        : 'Player 1: W/S | Player 2: I/K';
    
    instructionText = TextComponent(
      text: '$controls | Press R to restart',
      position: Vector2(size.x / 2, size.y - 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );
    
    // Add components
    add(player1Paddle);
    add(player2Paddle);
    add(ball);
    add(scoreText);
    add(instructionText);
    
    // Start the game
    Future.delayed(const Duration(milliseconds: 500), () {
      _launchBall();
    });
  }

  void _launchBall() {
    // Reset ball to center
    ball.position = Vector2(size.x / 2, size.y / 2);
    
    // Random direction for the ball
    final random = Random();
    final xDirection = random.nextBool() ? 1 : -1;
    final yDirection = random.nextBool() ? 1 : -1;
    
    ballVelocity = Vector2(300.0 * xDirection, 200.0 * yDirection);
  }

  void _resetBall() {
    ball.position = Vector2(size.x / 2, size.y / 2);
    ballVelocity = Vector2.zero();
    
    // Launch ball after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      _launchBall();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _handleInput();
    _movePaddles(dt);
    _moveBall(dt);
    _checkCollisions();
    _checkScoring();
  }

  void _handleInput() {
    // Player 1 controls (W/S and Arrow keys)
    player1Up = HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.keyW) ||
                HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.arrowUp);
    player1Down = HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.keyS) ||
                  HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.arrowDown);
    
    // Player 2 controls (I/K) - only in local multiplayer
    if (gameMode == GameMode.multiPlayer) {
      player2Up = HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.keyI);
      player2Down = HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.keyK);
    }
    
    // Restart game (with simple debouncing)
    if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.keyR)) {
      _restartGame();
    }
  }

  void _moveBall(double dt) {
    ball.position += ballVelocity * dt;
    
    // Ball collision with top and bottom walls
    if (ball.position.y <= ball.radius || ball.position.y >= size.y - ball.radius) {
      ballVelocity.y = -ballVelocity.y;
      ball.position.y = ball.position.y <= ball.radius ? ball.radius : size.y - ball.radius;
    }
  }

  void _checkCollisions() {
    // Ball collision with paddles
    if (_ballCollidesWithPaddle(player1Paddle) || _ballCollidesWithPaddle(player2Paddle)) {
      ballVelocity.x = -ballVelocity.x;
      
      // Add some randomness to the bounce
      final random = Random();
      ballVelocity.y += (random.nextDouble() - 0.5) * 100;
    }
  }

  void _checkScoring() {
    // Scoring
    if (ball.position.x < 0) {
      player2Score++;
      scoreText.text = '$player1Score - $player2Score';
      _resetBall();
    } else if (ball.position.x > size.x) {
      player1Score++;
      scoreText.text = '$player1Score - $player2Score';
      _resetBall();
    }
  }

  bool _ballCollidesWithPaddle(RectangleComponent paddle) {
    final ballRect = Rect.fromCenter(
      center: Offset(ball.position.x, ball.position.y),
      width: ball.radius * 2,
      height: ball.radius * 2,
    );
    
    final paddleRect = Rect.fromLTWH(
      paddle.position.x,
      paddle.position.y,
      paddle.size.x,
      paddle.size.y,
    );
    
    return ballRect.overlaps(paddleRect);
  }

  void _movePaddles(double dt) {
    const speed = 300.0;
    
    if (gameMode == GameMode.singlePlayer) {
      // Single player: Player controls paddle 1, AI controls paddle 2
      if (player1Up && player1Paddle.position.y > 0) {
        player1Paddle.position.y -= speed * dt;
      }
      if (player1Down && player1Paddle.position.y < size.y - player1Paddle.size.y) {
        player1Paddle.position.y += speed * dt;
      }
      
      // AI for player 2
      const aiSpeed = speed * 0.7;
      if (ball.position.y < player2Paddle.position.y + player2Paddle.size.y / 2) {
        if (player2Paddle.position.y > 0) {
          player2Paddle.position.y -= aiSpeed * dt;
        }
      } else {
        if (player2Paddle.position.y < size.y - player2Paddle.size.y) {
          player2Paddle.position.y += aiSpeed * dt;
        }
      }
    } else {
      // Local multiplayer: Player 1 uses W/S, Player 2 uses I/K
      if (player1Up && player1Paddle.position.y > 0) {
        player1Paddle.position.y -= speed * dt;
      }
      if (player1Down && player1Paddle.position.y < size.y - player1Paddle.size.y) {
        player1Paddle.position.y += speed * dt;
      }
      
      if (player2Up && player2Paddle.position.y > 0) {
        player2Paddle.position.y -= speed * dt;
      }
      if (player2Down && player2Paddle.position.y < size.y - player2Paddle.size.y) {
        player2Paddle.position.y += speed * dt;
      }
    }
  }

  void _restartGame() {
    player1Score = 0;
    player2Score = 0;
    scoreText.text = '0 - 0';
    _resetBall();
  }
}

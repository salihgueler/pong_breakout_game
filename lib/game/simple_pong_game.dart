import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum GameMode { singlePlayer, multiPlayer }

class SimplePongGame extends FlameGame with HasKeyboardHandlerComponents {
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
    // Create paddles with neon glow effect
    player1Paddle = RectangleComponent(
      position: Vector2(50, size.y / 2 - 50),
      size: Vector2(20, 100),
      paint: Paint()
        ..color = const Color(0xFF00ff00)
        ..style = PaintingStyle.fill,
    );
    
    player2Paddle = RectangleComponent(
      position: Vector2(size.x - 70, size.y / 2 - 50),
      size: Vector2(20, 100),
      paint: Paint()
        ..color = const Color(0xFFff6600)
        ..style = PaintingStyle.fill,
    );
    
    // Create ball with neon effect
    ball = CircleComponent(
      position: Vector2(size.x / 2, size.y / 2),
      radius: 12,
      paint: Paint()
        ..color = const Color(0xFF00ffff)
        ..style = PaintingStyle.fill,
    );
    
    // Create score text with arcade styling
    scoreText = TextComponent(
      text: '0 - 0',
      position: Vector2(size.x / 2, 60),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00ffff),
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
          shadows: [
            Shadow(
              color: Color(0xFF00ffff),
              blurRadius: 10,
            ),
            Shadow(
              color: Color(0xFFff00ff),
              offset: Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
      ),
    );
    
    // Create instruction text with retro styling
    String controls = gameMode == GameMode.singlePlayer 
        ? 'PLAYER: W/S OR ↑/↓ KEYS'
        : 'P1: W/S | P2: I/K';
    
    instructionText = TextComponent(
      text: '$controls | PRESS R TO RESTART',
      position: Vector2(size.x / 2, size.y - 40),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Color(0xFF444444),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
    
    // Add center line
    final centerLine = _createCenterLine();
    add(centerLine);
    
    // Add components with subtle effects
    add(player1Paddle);
    add(player2Paddle);
    add(ball);
    add(scoreText);
    add(instructionText);
    
    // Add subtle pulsing effect to ball
    ball.add(
      ScaleEffect.to(
        Vector2.all(1.1),
        EffectController(
          duration: 1.0,
          reverseDuration: 1.0,
          infinite: true,
        ),
      ),
    );
    
    // Start the game
    Future.delayed(const Duration(milliseconds: 500), () {
      _launchBall();
    });
  }

  Component _createCenterLine() {
    final centerLine = Component();
    
    // Create dashed center line
    for (double y = 0; y < size.y; y += 30) {
      final dash = RectangleComponent(
        position: Vector2(size.x / 2 - 2, y),
        size: Vector2(4, 15),
        paint: Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.fill,
      );
      centerLine.add(dash);
    }
    
    return centerLine;
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Call super to maintain proper mixin behavior
    super.onKeyEvent(event, keysPressed);
    
    // Player 1 controls (W/S and Arrow keys)
    player1Up = keysPressed.contains(LogicalKeyboardKey.keyW) ||
                keysPressed.contains(LogicalKeyboardKey.arrowUp);
    player1Down = keysPressed.contains(LogicalKeyboardKey.keyS) ||
                  keysPressed.contains(LogicalKeyboardKey.arrowDown);
    
    // Player 2 controls (I/K) - only in local multiplayer
    if (gameMode == GameMode.multiPlayer) {
      player2Up = keysPressed.contains(LogicalKeyboardKey.keyI);
      player2Down = keysPressed.contains(LogicalKeyboardKey.keyK);
    }
    
    // Restart game - only on key down to prevent multiple triggers
    if (keysPressed.contains(LogicalKeyboardKey.keyR) && event is KeyDownEvent) {
      _restartGame();
    }
    
    // Return KeyEventResult.handled to indicate we processed the event
    return KeyEventResult.handled;
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
    
    _movePaddles(dt);
    _moveBall(dt);
    _checkCollisions();
    _checkScoring();
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
    if (_ballCollidesWithPaddle(player1Paddle)) {
      ballVelocity.x = ballVelocity.x.abs(); // Ensure ball goes right
      _createCollisionEffect(player1Paddle.position + Vector2(20, 50), const Color(0xFF00ff00));
      
      // Add some randomness to the bounce
      final random = Random();
      ballVelocity.y += (random.nextDouble() - 0.5) * 100;
    } else if (_ballCollidesWithPaddle(player2Paddle)) {
      ballVelocity.x = -ballVelocity.x.abs(); // Ensure ball goes left
      _createCollisionEffect(player2Paddle.position + Vector2(0, 50), const Color(0xFFff6600));
      
      // Add some randomness to the bounce
      final random = Random();
      ballVelocity.y += (random.nextDouble() - 0.5) * 100;
    }
  }

  void _createCollisionEffect(Vector2 position, Color color) {
    // Use Flame's built-in particle system
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 8,
        lifespan: 0.5,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 200), // Gravity effect
          speed: Vector2.random(Random()) * 200,
          position: position.clone(),
          child: CircleParticle(
            radius: 3.0,
            paint: Paint()..color = color,
          ),
        ),
      ),
    );
    add(particleComponent);
  }

  void _checkScoring() {
    // Scoring
    if (ball.position.x < 0) {
      player2Score++;
      scoreText.text = '$player1Score - $player2Score';
      _createScoreEffect(false); // Player 2 scored
      _resetBall();
    } else if (ball.position.x > size.x) {
      player1Score++;
      scoreText.text = '$player1Score - $player2Score';
      _createScoreEffect(true); // Player 1 scored
      _resetBall();
    }
  }

  void _createScoreEffect(bool player1Scored) {
    // Use Flame's built-in particle system for score explosion
    final center = Vector2(size.x / 2, size.y / 2);
    final color = player1Scored ? const Color(0xFF00ff00) : const Color(0xFFff6600);
    
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 15,
        lifespan: 1.0,
        generator: (i) {
          final angle = (i / 15) * 2 * pi;
          return AcceleratedParticle(
            acceleration: Vector2(0, 50), // Slight gravity
            speed: Vector2(
              cos(angle) * (100 + Random().nextDouble() * 100),
              sin(angle) * (100 + Random().nextDouble() * 100),
            ),
            position: center.clone(),
            child: CircleParticle(
              radius: 4.0,
              paint: Paint()..color = color,
            ),
          );
        },
      ),
    );
    add(particleComponent);
    
    // Add scale effect to score text
    scoreText.add(
      ScaleEffect.to(
        Vector2.all(1.2),
        EffectController(duration: 0.2, reverseDuration: 0.2),
      ),
    );
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

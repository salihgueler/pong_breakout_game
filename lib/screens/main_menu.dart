import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/simple_pong_game.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF1a0033), // Deep purple
              Color(0xFF000011), // Almost black
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),
            
            // Scanlines effect
            _buildScanlines(),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated PONG title
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00ffff).withValues(alpha: _glowAnimation.value),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: const Color(0xFFff00ff).withValues(alpha: _glowAnimation.value * 0.7),
                              blurRadius: 50,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: const Text(
                                'PONG',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF00ffff),
                                  letterSpacing: 8,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFFff00ff),
                                      offset: Offset(3, 3),
                                      blurRadius: 5,
                                    ),
                                    Shadow(
                                      color: Color(0xFF00ffff),
                                      offset: Offset(-2, -2),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Subtitle
                  const Text(
                    'RETRO ARCADE EDITION',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF888888),
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Menu buttons
                  _buildArcadeButton(
                    'SINGLE PLAYER',
                    const Color(0xFF00ff00),
                    () => _startGame(context, GameMode.singlePlayer),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  _buildArcadeButton(
                    'TWO PLAYER',
                    const Color(0xFFff6600),
                    () => _startGame(context, GameMode.multiPlayer),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Controls info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF333333), width: 1),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF111111).withValues(alpha: 0.8),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'CONTROLS',
                          style: TextStyle(
                            color: Color(0xFF00ffff),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Player 1: W/S or ↑/↓\nPlayer 2: I/K\nRestart: R',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArcadeButton(String text, Color color, VoidCallback onPressed) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _glowAnimation.value * 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onPressed,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: color.withValues(alpha: 0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final offset = (index * 0.1 + _pulseController.value) % 1.0;
        final size = MediaQuery.of(context).size;
        
        return Positioned(
          left: (index * 37) % size.width,
          top: offset * size.height,
          child: Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFF00ffff).withValues(alpha: 0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00ffff).withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanlines() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ScanlinesPainter(),
      ),
    );
  }

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GameScreen(gameMode: mode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00ffff).withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GameScreen extends StatelessWidget {
  final GameMode gameMode;

  const GameScreen({super.key, required this.gameMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF001122),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Game widget
            GameWidget<SimplePongGame>.controlled(
              gameFactory: () => SimplePongGame(gameMode: gameMode),
            ),
            
            // Back button
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF000000).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00ffff), width: 1),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF00ffff),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

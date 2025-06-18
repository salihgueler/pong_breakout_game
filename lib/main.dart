import 'package:flutter/material.dart';
import 'screens/main_menu.dart';

void main() {
  runApp(const PongBreakoutApp());
}

class PongBreakoutApp extends StatelessWidget {
  const PongBreakoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pong Game',
      theme: ThemeData.dark(),
      home: const MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

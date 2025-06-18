# Pong Breakout Championship

A competitive two-player Pong/Breakout game built with Flutter and Flame engine, featuring real-time multiplayer capabilities.

## Features

### Game Modes
- **Single Player**: Classic Pong against AI with breakout elements (destructible bricks)
- **Multiplayer**: Real-time competitive PvP with game ID system
- **Create Game**: Host a multiplayer game and share Game ID
- **Join Game**: Join an existing game using Game ID

### Gameplay Features
- Smooth paddle controls with keyboard input
- Physics-based ball movement with realistic collisions
- Dynamic ball speed that increases during rallies
- Colorful destructible bricks in single-player mode
- Real-time score tracking
- Game end detection with restart capability

### Controls
- **Player 1**: W/S keys or Arrow Up/Down
- **Player 2** (Multiplayer): I/K keys
- **Space**: Pause/Resume game
- **R**: Restart game

## Installation

1. Ensure you have Flutter installed (3.10.0 or higher)
2. Clone or download this project
3. Navigate to the project directory
4. Run the following commands:

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── screens/
│   ├── main_menu_screen.dart         # Main menu with game mode selection
│   ├── game_screen.dart              # Game wrapper screen
│   └── join_game_screen.dart         # Join game interface
└── game/
    ├── pong_breakout_game.dart       # Main game logic
    └── components/
        ├── paddle.dart               # Paddle component with controls
        ├── ball.dart                 # Ball physics and collision
        ├── brick.dart                # Destructible brick component
        ├── game_hud.dart             # UI overlay and scoring
        └── multiplayer_sync.dart     # Real-time sync (mocked)
```

## Technical Details

### Built With
- **Flutter**: Cross-platform UI framework
- **Flame**: 2D game engine for Flutter
- **Flame Forge2D**: Physics engine integration
- **UUID**: Game ID generation
- **Shared Preferences**: Local data storage

### Game Architecture
- Component-based architecture using Flame's ECS system
- Real-time multiplayer sync (currently mocked for demonstration)
- Collision detection system for paddles, walls, and bricks
- State management for scores and game flow

### Multiplayer Implementation
The multiplayer system is currently implemented with mocked behavior to demonstrate the architecture. In a production environment, you would:

1. Replace `MultiplayerSync` with real WebSocket or HTTP connections
2. Implement a backend server for game state synchronization
3. Add player authentication and matchmaking
4. Implement lag compensation and prediction algorithms

## Game Rules

### Single Player (Pong + Breakout)
- Destroy all colored bricks to win
- Don't let the ball pass your paddle
- Different colored bricks are worth different points

### Multiplayer (Competitive Pong)
- First player to reach 11 points wins
- Ball speed increases during rallies for exciting gameplay
- Real-time synchronization ensures fair competition

## Future Enhancements

- [ ] Real multiplayer backend integration
- [ ] Sound effects and background music
- [ ] Power-ups and special abilities
- [ ] Tournament mode with brackets
- [ ] Player profiles and statistics
- [ ] Mobile touch controls
- [ ] Spectator mode
- [ ] Replay system

## Contributing

Feel free to contribute to this project by:
1. Reporting bugs or issues
2. Suggesting new features
3. Submitting pull requests
4. Improving documentation

## License

This project is open source and available under the MIT License.

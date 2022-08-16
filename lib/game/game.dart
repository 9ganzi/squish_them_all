import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'level/level.dart';

class SquishThemAll extends FlameGame {
  // ? makes the type nullable.
  Level? _currentLevel;
  late List<Image> spriteSheet;

  @override
  Future<void>? onLoad() async {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    // This will make sure to load and keep a reference to the spritesheet before starting the game.
    spriteSheet = await images.loadAll(
      [
        'Angry Pig - Idle (36x30).png',
        'Angry Pig - Walk (36x30).png',
        'Angry Pig - Hit 1 (36x30).png',
        'Angry Pig - Run (36x30).png',
        'Angry Pig - Hit 2 (36x30).png',
        'Checkpoints - End (Idle).png',
        'Checkpoints - End (Pressed) (64x64).png',
        'Fruits - Apple.png',
        'Fruits - Bananas.png',
        'Fruits - Melon.png',
        'Pink Man - Idle (32x32).png',
        'Pink Man - Run (32x32).png',
        'Pink Man - Jump (32x32).png',
        'Pink Man - Double Jump (32x32).png',
        'Pink Man - Wall Jump (32x32).png',
        'Pink Man - Fall (32x32).png',
        'Pink Man - Hit (32x32).png',
      ],
    );

    // Basically this viewport makes sure the ratio between width and height is always the same in your game, no matter the platform.
    camera.viewport = FixedResolutionViewport(
      Vector2(288, 208),
    );

    loadLevel('Level1.tmx');

    return super.onLoad();
  }

  void loadLevel(String levelName) {
    // This will remove the current level from game if there is any.
    // See what happens without it(~)
    _currentLevel?.removeFromParent();
    _currentLevel = Level(levelName);
    // ! does the null check. Like,
    // if (currentLevel == null) return;
    add(_currentLevel!);
  }
}
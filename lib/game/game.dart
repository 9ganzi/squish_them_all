import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'level/level.dart';

class SquishThemAll extends FlameGame {
  // ? makes the type nullable.
  Level? _currentLevel;

  @override
  Future<void>? onLoad() async {
    Flame.device.fullScreen();
    Flame.device.setLandscape();

    camera.viewport = FixedResolutionViewport(
      Vector2(288, 208),
    );

    loadLevel('Level1.tmx');

    return super.onLoad();
  }

  void loadLevel(String levelName) {
    // This will remove the current level from game if there is any.
    _currentLevel?.removeFromParent();
    _currentLevel = Level(levelName);
    add(_currentLevel!);
  }
}

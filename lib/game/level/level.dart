import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:squish_them_all/game/actors/angry_pig.dart';
import 'package:squish_them_all/game/actors/apple.dart';
import 'package:squish_them_all/game/actors/end.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:tiled/tiled.dart';

import '../actors/player(testing).dart';

enum AnimationStates {
  idle,
  run,
  jump,
  doubleJump,
  wallJump,
  fall,
  hit,
}

// The mixin ensures that level can access the parent game class instance using gameRef.
class Level extends Component with HasGameRef<SquishThemAll> {
  final String levelName;

  // Use late to declare variables that will be initialized later. This will ensure the variable is not null at runtime.
  late Player _player;

  Level(this.levelName) : super();

  @override
  Future<void>? onLoad() async {
    final level = await TiledComponent.load(
      levelName,
      Vector2.all(16),
    );
    add(level);

    // The method returns the object layer from the map.
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      // Iterate through all the objects from the layer.
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.type) {
          case 'Player':
            _player = Player(
              animations: {
                AnimationStates.idle: await gameRef.loadSpriteAnimation(
                  'Pink Man - Idle (32x32).png',
                  SpriteAnimationData.sequenced(
                    amount: 11,
                    stepTime: .05,
                    textureSize: Vector2.all(32),
                  ),
                ),
              },
              current: AnimationStates.idle,
            );
            add(_player);
            break;
          case 'Apple':
            final apple = Apple(
              gameRef.spriteSheet[1],
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(apple);
            break;
          case 'Angry Pig':
            final angryPig = AngryPig(
              gameRef.spriteSheet[2],
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(angryPig);
            break;
          case 'End':
            final end = End(
              gameRef.spriteSheet[3],
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(end);
            break;
        }
      }
    }

    return super.onLoad();
  }
}

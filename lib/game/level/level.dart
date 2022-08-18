import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:squish_them_all/game/actors/angry_pig.dart';
import 'package:squish_them_all/game/actors/apple.dart';
import 'package:squish_them_all/game/actors/end.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:tiled/tiled.dart';

import '../actors/player.dart';
import '../actors/apple.dart';
import '../actors/angry_pig.dart';
import '../actors/end.dart';
import '../actors/bananas.dart';
import '../actors/melon.dart';

// The mixin ensures that level can access the parent game class instance using gameRef.
class Level extends Component with HasGameRef<SquishThemAll> {
  final String levelName;

  // Use late to declare variables that will be initialized later. This will ensure the variable is not null at runtime.
  // late Player _player;

  Level(this.levelName) : super();

  @override
  Future<void>? onLoad() async {
    final level = await TiledComponent.load(
      levelName,
      Vector2.all(16),
    );
    add(level);

    final playerAnimations = {
      PlayerStates.idle: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Idle (32x32).png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerStates.run: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Run (32x32).png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerStates.jump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Jump (32x32).png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerStates.doubleJump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Double Jump (32x32).png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerStates.wallJump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Wall Jump (32x32).png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerStates.fall: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Fall (32x32).png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerStates.hit: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Hit (32x32).png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
    };

    final appleAnimations = {
      AppleStates.idle: SpriteSheet(
        image: gameRef.images.fromCache('Fruits - Apple.png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
    };

    final bananasAnimations = {
      BananasStates.idle: SpriteSheet(
        image: gameRef.images.fromCache('Fruits - Bananas.png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
    };

    final melonAnimations = {
      MelonStates.idle: SpriteSheet(
        image: gameRef.images.fromCache('Fruits - Melon.png'),
        srcSize: Vector2.all(32),
      ).createAnimation(row: 0, stepTime: 0.05),
    };

    final angryPigAnimations = {
      AngryPigStates.idle: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Idle (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigStates.walk: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Walk (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigStates.hit1: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Hit 1 (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigStates.run: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Run (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigStates.hit2: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Hit 2 (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
    };

    final endAnimations = {
      EndStates.idle: SpriteSheet(
        image: gameRef.images.fromCache('Checkpoints - End (Idle).png'),
        srcSize: Vector2.all(64),
      ).createAnimation(row: 0, stepTime: 0.05),
      EndStates.pressed: SpriteSheet(
        image:
            gameRef.images.fromCache('Checkpoints - End (Pressed) (64x64).png'),
        srcSize: Vector2.all(64),
      ).createAnimation(row: 0, stepTime: 0.05),
    };

    // The method returns the object layer from the map.
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      // Iterate through all the objects from the layer.
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.type) {
          case 'Player':
            final _player = Player(
              Vector2(spawnPoint.x, spawnPoint.y),
              SpriteAnimationComponent(
                animation: SpriteAnimation.fromFrameData(
                  await gameRef.images.load('Pink Man - Idle (32x32).png'),
                  SpriteAnimationData.sequenced(
                    amount: 11,
                    textureSize: Vector2.all(32),
                    stepTime: .05,
                  ),
                ),
                size: Vector2.all(32),
                anchor: Anchor.center,
              ),
            );
            add(_player);
            break;
          case 'Apple':
            final _apple = Apple(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: appleAnimations,
              size: Vector2.all(32),
              current: AppleStates.idle,
            );
            add(_apple);
            break;
          case 'Angry Pig':
            final _angryPig = AngryPig(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: angryPigAnimations,
              size: Vector2(36, 30),
              current: AngryPigStates.idle,
            );
            add(_angryPig);
            break;
          case 'End':
            final _end = End(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: endAnimations,
              size: Vector2.all(64),
              current: EndStates.idle,
            );
            add(_end);
            break;
          case 'Melon':
            final _melon = Melon(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: melonAnimations,
              size: Vector2.all(32),
              current: MelonStates.idle,
            );
            add(_melon);
            break;
          case 'Bananas':
            final _bananas = Bananas(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: bananasAnimations,
              size: Vector2.all(32),
              current: BananasStates.idle,
            );
            add(_bananas);
            break;
        }
      }
    }

    return super.onLoad();
  }
}

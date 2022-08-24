import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';

import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:tiled/tiled.dart';

import 'package:squish_them_all/game/actors/angry_pig.dart';
import 'package:squish_them_all/game/actors/apple.dart';
import 'package:squish_them_all/game/actors/end.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:squish_them_all/game/actors/player.dart';
import 'package:squish_them_all/game/actors/bananas.dart';
import 'package:squish_them_all/game/actors/melon.dart';
import 'package:squish_them_all/game/actors/ground.dart';

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

    await spawnActors(level.tileMap, appleAnimations, angryPigAnimations,
        endAnimations, melonAnimations, bananasAnimations);

    return super.onLoad();
  }

  Future<void> spawnActors(
      RenderableTiledMap tileMap,
      Map<AppleStates, SpriteAnimation> appleAnimations,
      Map<AngryPigStates, SpriteAnimation> angryPigAnimations,
      Map<EndStates, SpriteAnimation> endAnimations,
      Map<MelonStates, SpriteAnimation> melonAnimations,
      Map<BananasStates, SpriteAnimation> bananasAnimations) async {
    final groundLayer = tileMap.getLayer<ObjectGroup>('Ground');

    final List<Rect> rects = List<Rect>.empty(growable: true);

    if (groundLayer != null) {
      for (final ground in groundLayer.objects) {
        final rect =
            Rect.fromLTWH(ground.x, ground.y, ground.width, ground.height);
        rects.add(rect);
      }
    }
    add(Ground.fromRects(rects));

    // The method returns the object layer from the map.
    final spawnPointsLayer = tileMap.getLayer<ObjectGroup>('SpawnPoints');

    final worldBounds = Rect.fromLTRB(
      0,
      0,
      tileMap.map.width.toDouble() * tileMap.map.tileWidth,
      tileMap.map.height.toDouble() * tileMap.map.tileWidth,
    );

    if (spawnPointsLayer != null) {
      // Iterate through all the objects from the layer.
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.type) {
          case 'Player':
            gameRef.player = Player(
              Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
            );
            await add(gameRef.player);
            gameRef.camera.followBodyComponent(
              gameRef.player,
              worldBounds: worldBounds,
            );
            break;
          case 'Apple':
            final apple = Apple(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: appleAnimations,
              size: Vector2.all(32),
              current: AppleStates.idle,
            );
            add(apple);
            break;
          case 'Angry Pig':
            final angryPig = AngryPig(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: angryPigAnimations,
              size: Vector2(36, 30),
              current: AngryPigStates.idle,
            );
            add(angryPig);
            break;
          case 'End':
            final end = End(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: endAnimations,
              size: Vector2.all(64),
              current: EndStates.idle,
            );
            add(end);
            break;
          case 'Melon':
            final melon = Melon(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: melonAnimations,
              size: Vector2.all(32),
              current: MelonStates.idle,
            );
            add(melon);
            break;
          case 'Bananas':
            final bananas = Bananas(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              animations: bananasAnimations,
              size: Vector2.all(32),
              current: BananasStates.idle,
            );
            add(bananas);
            break;
        }
      }
    }
  }
}

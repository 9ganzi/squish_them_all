import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
// import 'package:flame/sprite.dart';

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
import 'package:squish_them_all/game/actors/wall.dart';

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
      Vector2.all(16) / 100,
    );
    add(level);

    await spawnActors(level.tileMap);

    return super.onLoad();
  }

  Future<void> spawnActors(RenderableTiledMap tileMap) async {
    final groundLayer = tileMap.getLayer<ObjectGroup>('Background');

    final List<Rect> groundRects = List<Rect>.empty(growable: true);

    final List<Rect> wallRects = List<Rect>.empty(growable: true);

    if (groundLayer != null) {
      for (final ground in groundLayer.objects) {
        switch (ground.type) {
          case "Ground":
            final rect = Rect.fromLTWH(ground.x / 100, ground.y / 100,
                ground.width / 100, ground.height / 100);
            groundRects.add(rect);
            break;
          case "Walls":
            final rect = Rect.fromLTWH(ground.x / 100, ground.y / 100,
                ground.width / 100, ground.height / 100);
            wallRects.add(rect);
            break;
        }
      }
    }
    add(Ground.fromRects(groundRects));
    add(Wall.fromRects(wallRects));

    // The method returns the object layer from the map.
    final spawnPointsLayer = tileMap.getLayer<ObjectGroup>('SpawnPoints');

    worldSize = Vector2(
      tileMap.map.width.toDouble() * tileMap.map.tileWidth / 100,
      tileMap.map.height.toDouble() * tileMap.map.tileWidth / 100,
    );

    final worldBounds = Rect.fromLTRB(
      0,
      0,
      tileMap.map.width.toDouble() * tileMap.map.tileWidth / 100,
      tileMap.map.height.toDouble() * tileMap.map.tileHeight / 100,
    );

    if (spawnPointsLayer != null) {
      // Iterate through all the objects from the layer.
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.type) {
          case 'Player':
            gameRef.player = Player(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / 100,
                (spawnPoint.y + spawnPoint.width / 2) / 100,
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
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / 100,
                (spawnPoint.y + spawnPoint.width / 2) / 100,
              ),
            );
            add(apple);
            break;
          case 'Bananas':
            final bananas = Bananas(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / 100,
                (spawnPoint.y + spawnPoint.width / 2) / 100,
              ),
            );
            add(bananas);
            break;
          case 'Angry Pig':
            final angryPig = AngryPig(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / 100,
                (spawnPoint.y + spawnPoint.width / 2) / 100,
              ),
            );
            add(angryPig);
            break;
          case 'End':
            final end = End(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / 100,
                (spawnPoint.y + spawnPoint.width / 2) / 100,
              ),
            );
            add(end);
            break;
          case 'Melon':
            final melon = Melon(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / 100,
                (spawnPoint.y + spawnPoint.width / 2) / 100,
              ),
            );
            add(melon);
            break;
        }
      }
    }
  }
}

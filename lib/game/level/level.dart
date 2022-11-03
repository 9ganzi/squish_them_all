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
      Vector2.all(16) / zoomLevel,
    );
    add(level);

    await spawnActors(level.tileMap);

    return super.onLoad();
  }

  Future<void> spawnActors(RenderableTiledMap tileMap) async {
    final groundLayer = tileMap.getLayer<ObjectGroup>('Background');

    final List<Rect> groundRects = List<Rect>.empty(growable: true);

    if (groundLayer != null) {
      for (final ground in groundLayer.objects) {
        switch (ground.type) {
          case "Ground":
            final rect = Rect.fromLTWH(
                ground.x / zoomLevel,
                ground.y / zoomLevel,
                ground.width / zoomLevel,
                ground.height / zoomLevel);
            groundRects.add(rect);
            break;
          // case "Walls":
          //   final rect = Rect.fromLTWH(ground.x / zoomLevel, ground.y / zoomLevel,
          //       ground.width / zoomLevel, ground.height / zoomLevel);
          //   wallRects.add(rect);
          //   break;
        }
      }
    }
    add(Ground.fromRects(groundRects));

    // The method returns the object layer from the map.
    final spawnPointsLayer = tileMap.getLayer<ObjectGroup>('SpawnPoints');

    worldSize = Vector2(
      tileMap.map.width.toDouble() * tileMap.map.tileWidth / zoomLevel,
      tileMap.map.height.toDouble() * tileMap.map.tileWidth / zoomLevel,
    );

    final List<EdgeShape> wallEdges = List<EdgeShape>.empty(growable: true);

    add(Wall(wallEdges, worldSize));

    // print(
    //     '\ntileMap.map.width.toDouble() = ${tileMap.map.width.toDouble()}\ntileMap.map.tileWidth = ${tileMap.map.tileWidth}');
    // print(worldSize);
    final worldBounds = Rect.fromLTRB(
      0,
      0,
      tileMap.map.width.toDouble() * tileMap.map.tileWidth / zoomLevel,
      tileMap.map.height.toDouble() * tileMap.map.tileHeight / zoomLevel,
    );

    if (spawnPointsLayer != null) {
      // Iterate through all the objects from the layer.
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.type) {
          case 'Player':
            gameRef.player = Player(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / zoomLevel,
                (spawnPoint.y + spawnPoint.width / 2) / zoomLevel,
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
                (spawnPoint.x + spawnPoint.height / 2) / zoomLevel,
                (spawnPoint.y + spawnPoint.width / 2) / zoomLevel,
              ),
            );
            add(apple);
            break;
          case 'Bananas':
            final bananas = Bananas(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / zoomLevel,
                (spawnPoint.y + spawnPoint.width / 2) / zoomLevel,
              ),
            );
            add(bananas);
            break;
          case 'Angry Pig':
            final angryPig = AngryPig(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / zoomLevel,
                (spawnPoint.y + spawnPoint.width / 2) / zoomLevel,
              ),
            );
            add(angryPig);
            break;
          case 'End':
            final end = End(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / zoomLevel,
                (spawnPoint.y + spawnPoint.width / 2) / zoomLevel,
              ),
            );
            add(end);
            break;
          case 'Melon':
            final melon = Melon(
              Vector2(
                (spawnPoint.x + spawnPoint.height / 2) / zoomLevel,
                (spawnPoint.y + spawnPoint.width / 2) / zoomLevel,
              ),
            );
            add(melon);
            break;
        }
      }
    }
  }
}

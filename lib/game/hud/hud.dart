import 'package:flame/components.dart';
import 'package:flame/input.dart';

import 'package:squish_them_all/game/game.dart';
import 'package:squish_them_all/game/overlays/game_over.dart';
import 'package:squish_them_all/game/overlays/pause_menu.dart';

class Hud extends Component with HasGameRef<SquishThemAll> {
  late final TextComponent scoreTextComponent;
  late final TextComponent healthTextComponent;

  Hud({super.children, super.priority}) {
    positionType = PositionType.viewport;
  }

  @override
  Future<void>? onLoad() async {
    // load image
    await gameRef.images.load('Pink Man - Idle (32x32).png');
    gameRef.images.load('Spritesheet.png');

    // Score text
    scoreTextComponent = TextComponent(
      text: 'Score: 0',
      position: Vector2.all(10),
    );
    add(scoreTextComponent);

    // Health text
    healthTextComponent = TextComponent(
      text: 'x5',
      anchor: Anchor.topRight,
      position: Vector2(gameRef.size.x + 270, 10),
    );
    add(healthTextComponent);

    final playerSprite = SpriteComponent.fromImage(
      // gameRef.images.load('Pink Man - Idle (32x32).png'),
      gameRef.images.fromCache('Pink Man - Idle (32x32).png'),
      srcPosition: Vector2.zero(),
      srcSize: Vector2.all(32),
      anchor: Anchor.topRight,
      position: Vector2(
          healthTextComponent.position.x - healthTextComponent.size.x - 5, 5),
    );
    add(playerSprite);

    gameRef.playerData.score.addListener(() {
      scoreTextComponent.text = 'Score: ${gameRef.playerData.score.value}';
    });

    gameRef.playerData.health.addListener(() {
      healthTextComponent.text = 'x${gameRef.playerData.health.value}';
    });

    final pauseButton = SpriteButtonComponent(
      onPressed: () {
        gameRef.pauseEngine();
        gameRef.overlays.add(PauseMenu.id);
      },
      button: Sprite(
        gameRef.images.fromCache('Spritesheet.png'),
        srcSize: Vector2.all(32),
        srcPosition: Vector2(32 * 4, 0),
      ),
      size: Vector2.all(32),
      anchor: Anchor.topCenter,
      position: Vector2(gameRef.size.x + 150, 10),
    )..positionType = PositionType.viewport;
    add(pauseButton);

    return super.onLoad();
  }

  @override
  void onRemove() {
    gameRef.playerData.score.removeListener(onScoreChange);
    gameRef.playerData.health.removeListener(onHealthChange);
    super.onRemove();
  }

  // Updates score text on hud.
  void onScoreChange() {
    scoreTextComponent.text = 'Score: ${gameRef.playerData.score.value}';
  }

  // Updates health text on hud.
  void onHealthChange() {
    healthTextComponent.text = 'x${gameRef.playerData.health.value}';

    // Load game over overlay if health is zero.
    if (gameRef.playerData.health.value == 0) {
      gameRef.pauseEngine();
      gameRef.overlays.add(GameOver.id);
    }
  }
}

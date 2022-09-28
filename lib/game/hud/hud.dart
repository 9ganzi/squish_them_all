import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:squish_them_all/game/game.dart';

class Hud extends Component with HasGameRef<SquishThemAll> {
  Hud({super.children, super.priority}) {
    positionType = PositionType.viewport;
  }

  @override
  Future<void>? onLoad() {
    // Score text
    final scoreTextComponent =
        TextComponent(text: 'Score: 0', position: Vector2.all(10));
    add(scoreTextComponent);

    // Health text
    final healthTextComponent = TextComponent(
      text: 'Life: 5',
      anchor: Anchor.topRight,
      position: Vector2(gameRef.size.x + 270, 10),
    );
    add(healthTextComponent);

    // final playerSprite = SpriteComponent.fromImage(
    //   gameRef.spriteSheet[0],
    //   srcPosition: Vector2.zero(),
    //   srcSize: Vector2.all(32),
    //   anchor: Anchor.topRight,
    //   position: Vector2(
    //       healthTextComponent.position.x - healthTextComponent.size.x - 5, 5),
    // );
    // add(playerSprite);

    return super.onLoad();
  }
}
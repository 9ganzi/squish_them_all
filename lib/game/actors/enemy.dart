import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/game.dart';

class Enemy extends BodyComponent<SquishThemAll> with ContactCallbacks {
  final Vector2 position;
  int direction = 0;

  Enemy(this.position, {super.renderBody = false});

  @override
  Body createBody() {
    throw UnimplementedError();
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:squish_them_all/game/game.dart';

enum BananasStates {
  idle,
}

class Bananas extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameRef<SquishThemAll> {
  Bananas({
    super.animations,
    super.current,
    super.removeOnFinish,
    super.paint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  });
}

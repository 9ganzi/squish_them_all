import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:squish_them_all/game/game.dart';

enum AppleStates {
  idle,
}

class Apple extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameRef<SquishThemAll> {
  Apple({
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

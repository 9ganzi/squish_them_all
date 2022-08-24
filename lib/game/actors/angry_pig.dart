import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:squish_them_all/game/game.dart';

enum AngryPigStates {
  idle,
  walk,
  hit1,
  run,
  hit2,
}

class AngryPig extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameRef<SquishThemAll> {
  AngryPig({
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

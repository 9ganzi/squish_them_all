import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/game.dart';

enum PlayerStates {
  idle,
  run,
  jump,
  doubleJump,
  wallJump,
  fall,
  hit,
}

class Player extends BodyComponent with CollisionCallbacks {
  final Vector2 position;
  final Vector2 size;

  Player(
    this.position,
    PositionComponent component,
  ) : size = component.size {
    renderBody = false;
    add(component);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = size.x / 4;
    final fixtureDef = FixtureDef(
      shape,
      // To be able to determine object in collision
      userData: this,
      restitution: 0.8,
      density: 1.0,
      friction: 0.2,
    );

    final velocity = (Vector2.random() - Vector2.random()) * 200;
    final bodyDef = BodyDef(
      position: position,
      angle: velocity.angleTo(Vector2(1, 0)),
      linearVelocity: velocity,
      type: BodyType.dynamic,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

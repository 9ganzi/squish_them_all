import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/game.dart';
// import 'package:flame/sprite.dart';
// import 'package:flame/components.dart';
// import 'package:flame_forge2d/flame_forge2d.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';

enum AngryPigState {
  idle,
  walk,
  hit1,
  run,
  hit2,
}

class AngryPig extends BodyComponent<SquishThemAll> {
  final _size = Vector2(36, 30);
  final Vector2 _position;
  int accelerationX = 0;

  late SpriteAnimationGroupComponent _angryPigComponent;

  AngryPig(this._position, {super.renderBody = false});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await gameRef.images.loadAll(
      [
        'Angry Pig - Idle (36x30).png',
        'Angry Pig - Walk (36x30).png',
        'Angry Pig - Hit 1 (36x30).png',
        'Angry Pig - Run (36x30).png',
        'Angry Pig - Hit 2 (36x30).png',
      ],
    );

    final animations = {
      AngryPigState.idle: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Idle (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigState.walk: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Walk (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigState.hit1: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Hit 1 (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigState.run: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Run (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigState.hit2: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Hit 2 (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
    };

    _angryPigComponent = SpriteAnimationGroupComponent<AngryPigState>(
      anchor: Anchor.center,
      size: _size / zoomLevel,
      animations: animations,
      current: AngryPigState.run,
    );

    add(_angryPigComponent);
  }

  void idle() {
    accelerationX = 0;
  }

  void walkLeft() {
    accelerationX = -1;
  }

  void walkRight() {
    accelerationX = 1;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final velocity = body.linearVelocity;
    final position = body.position;

    if (accelerationX != 0) {
      _angryPigComponent.current = AngryPigState.run;
    } else {
      _angryPigComponent.current = AngryPigState.idle;
    }

    velocity.x = accelerationX * 1;
    body.linearVelocity = velocity;

    if (position.x > worldSize.x) {
      position.x = 0;
      body.setTransform(position, 0);
    } else if (position.x < 0) {
      position.x = worldSize.x;
      body.setTransform(position, 0);
    }

    if (accelerationX < 0) {
      if (!_angryPigComponent.isFlippedHorizontally) {
        _angryPigComponent.flipHorizontally();
      }
    } else if (accelerationX > 0) {
      if (_angryPigComponent.isFlippedHorizontally) {
        _angryPigComponent.flipHorizontally();
      }
    }
  }

  @override
  Body createBody() {
    // debugMode = true;
    final bodyDef = BodyDef(
      userData: this,
      position: _position,
      type: BodyType.dynamic,
    );

    final shape = PolygonShape()
      ..setAsBox(
        (_size.x / 2 - 7) / zoomLevel,
        (_size.y / 2 - 5) / zoomLevel,
        Vector2(0, .035),
        0,
      );

    final fixtureDef = FixtureDef(shape)
      ..density = 15
      ..friction = 0
      ..restitution = 0;
    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..setFixedRotation(true);
  }
}

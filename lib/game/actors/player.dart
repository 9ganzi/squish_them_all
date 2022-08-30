import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/game.dart';
// import 'package:flame/sprite.dart';
// import 'package:flame/components.dart';
// import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';

enum PlayerState {
  idle,
  run,
  jump,
  doubleJump,
  wallJump,
  fall,
  hit,
}

class Player extends BodyComponent with KeyboardHandler {
  final _size = Vector2(32, 32);
  final Vector2 _position;
  int accelerationX = 0;

  late SpriteAnimationGroupComponent _playerComponent;

  Player(this._position, {super.renderBody = false});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await gameRef.images.loadAll(
      [
        'Pink Man - Idle (32x32).png',
        'Pink Man - Run (32x32).png',
        'Pink Man - Jump (32x32).png',
        'Pink Man - Double Jump (32x32).png',
        'Pink Man - Wall Jump (32x32).png',
        'Pink Man - Fall (32x32).png',
        'Pink Man - Hit (32x32).png',
      ],
    );

    final animations = {
      PlayerState.idle: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Idle (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerState.run: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Run (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerState.jump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Jump (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerState.doubleJump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Double Jump (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerState.wallJump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Wall Jump (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerState.fall: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Fall (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      PlayerState.hit: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Hit (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
    };

    _playerComponent = SpriteAnimationGroupComponent<PlayerState>(
      anchor: Anchor.center,
      size: _size / 100,
      animations: animations,
      current: PlayerState.run,
    );

    add(_playerComponent);
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

  void jump() {
    // if (_playerComponent.current == PlayerState.fall) return;
    final velocity = body.linearVelocity;
    body.linearVelocity = Vector2(velocity.x, -3.5);
    _playerComponent.current = PlayerState.jump;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final velocity = body.linearVelocity;
    final position = body.position;

    if (velocity.y > 0.1) {
      _playerComponent.current = PlayerState.fall;
    } else if (velocity.y < 0.1 &&
        _playerComponent.current != PlayerState.jump) {
      if (accelerationX != 0) {
        _playerComponent.current = PlayerState.run;
      } else {
        _playerComponent.current = PlayerState.idle;
      }
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
      if (!_playerComponent.isFlippedHorizontally) {
        _playerComponent.flipHorizontally();
      }
    } else if (accelerationX > 0) {
      if (_playerComponent.isFlippedHorizontally) {
        _playerComponent.flipHorizontally();
      }
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        jump();
      }
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      walkRight();
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      walkLeft();
    } else {
      idle();
    }
    return false;
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
        (_size.x / 2 - 7) / 100,
        (_size.x / 2 - 5.7) / 100,
        Vector2(0, .043),
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

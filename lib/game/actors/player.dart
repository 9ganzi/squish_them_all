import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum PlayerState {
  idle,
  run,
  jump,
  doubleJump,
  wallJump,
  fall,
  hit,
}

class Player extends BodyComponent with KeyboardHandler, ContactCallbacks {
  final _size = Vector2.all(32);
  final Vector2 _position;

  late SpriteAnimationGroupComponent _playerComponent;

  Player(this._position, {super.renderBody = false});

  int accelerationX = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;

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
        size: _size,
        animations: animations,
        current: PlayerState.run);

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
    if (_playerComponent.current == PlayerState.jump ||
        _playerComponent.current == PlayerState.fall) return;
    final velocity = body.linearVelocity;
    body.linearVelocity = Vector2(velocity.x, -10);
    _playerComponent.current = PlayerState.jump;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final velocity = body.linearVelocity;
    // final position = body.position;

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

    velocity.x = accelerationX * 3;
    body.linearVelocity = velocity;

    // if (position.x > worldSize.x) {
    //   position.x = 0;
    //   body.setTransform(position, 0);
    // } else if (position.x < 0) {
    //   position.x = worldSize.x;
    //   body.setTransform(position, 0);
    // }

    if (accelerationX < 0) {
      if (_playerComponent.isFlippedHorizontally) {
        _playerComponent.flipHorizontally();
      }
    } else {
      if (_playerComponent.isFlippedHorizontally) {
        _playerComponent.flipHorizontally();
      }
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;
    if (isKeyDown) {
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        walkLeft();
        // print("walking left");
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        walkRight();
        // print("walking right");
      }
    } else {
      idle();
      // print("idle");
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      jump();
      print("jump");
    }
    return false;
  }

  @override
  void beginContact(Object other, Contact contact) {
    debugPrint(contact.tangentSpeed.toString());
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    debugPrint(contact.tangentSpeed.toString());
    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    debugMode = true;

    // final velocity = (Vector2.random() - Vector2.random()) * 200;

    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: _position + _size / 2,
      userData: this,
      // bullet: true,
      // fixedRotation: true,
      // linearDamping: 0,
      // angle: velocity.angleTo(Vector2(1, 0)),
      // linearVelocity: velocity,
      gravityScale: Vector2(0, 20),
    );

    final shape = PolygonShape()..setAsBox(9, 12, Vector2(.5, 4), 0);

    final fixtureDef = FixtureDef(shape)
      ..density = 15
      ..friction = 0
      ..restitution = 0;
    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..setFixedRotation(true);
  }
}

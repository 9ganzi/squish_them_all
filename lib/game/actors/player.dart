import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:flutter/services.dart';
import 'package:squish_them_all/game/actors/wall.dart';

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
  final _size = Vector2(32, 32);
  final Vector2 _position;
  static const double _maxSpeed = 1.25;
  static const double _maxSpeed2 = _maxSpeed * _maxSpeed;
  double _direction = 0;
  int _jumpCount = 0;
  bool _isOnGround = false;
  bool _changeDir = false;
  bool _acceleratingTurn = false;
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
      ).createAnimation(row: 0, stepTime: .05),
      PlayerState.run: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Run (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05),
      PlayerState.jump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Jump (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05),
      PlayerState.doubleJump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Double Jump (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05),
      PlayerState.wallJump: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Wall Jump (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05),
      PlayerState.fall: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Fall (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05),
      PlayerState.hit: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Hit (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05),
    };

    _playerComponent = SpriteAnimationGroupComponent<PlayerState>(
      anchor: Anchor.center,
      size: _size / 100,
      animations: animations,
      current: PlayerState.idle,
    );

    add(_playerComponent);
  }

  void jump() {
    if (_jumpCount > 2 ||
        _playerComponent.current == PlayerState.fall ||
        _playerComponent.current == PlayerState.jump) return;
    final velocity = body.linearVelocity.clone();

    body.linearVelocity = Vector2(velocity.x, -3.75);
    // body.applyLinearImpulse(Vector2(velocity.x, body.mass * -3));
    _playerComponent.current = PlayerState.jump;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // print(body.linearVelocity.x);

    final velocity = body.linearVelocity.clone();
    final position = body.position;

    if (velocity.y > 0) {
      if (_jumpCount == 0) {
        _jumpCount = 1;
      }
      if (velocity.y > .1) {
        _playerComponent.current = PlayerState.fall;
      }
    } else if (velocity.y < .1 &&
        _playerComponent.current != PlayerState.jump) {
      if (velocity.x != 0) {
        _playerComponent.current = PlayerState.run;
      } else {
        _playerComponent.current = PlayerState.idle;
      }
    }

    if (_direction != 0) {
      // velocity is slower or equalt to the _maxSpeed
      if (!(velocity.x * velocity.x > _maxSpeed2)) {
        // when you are not making a turn
        if (!_changeDir && !_acceleratingTurn) {
          if (!(velocity.x * velocity.x == _maxSpeed2)) {
            body.applyForce(Vector2(_direction, 0));
          }
          // print("steady force");
          //  when you are making a turn
        } else {
          // apply bigger force to make the turn faster
          body.applyForce(Vector2(_direction * 2.5, 0));
          if (velocity.x * velocity.x >= _maxSpeed2 * .5) {
            _acceleratingTurn = true;
          } else {
            _changeDir = false;
          }
        }
      }
    }
    if (velocity.x * velocity.x > _maxSpeed2) {
      body.linearVelocity =
          Vector2(body.linearVelocity.x.sign * _maxSpeed, velocity.y);
      _acceleratingTurn = false;
    }

    if (position.x > worldSize.x) {
      position.x = 0;
      body.setTransform(position, 0);
    } else if (position.x < 0) {
      position.x = worldSize.x;
      body.setTransform(position, 0);
    }

    if (_direction < 0) {
      if (!_playerComponent.isFlippedHorizontally) {
        _changeDir = true;
        _playerComponent.flipHorizontally();
      }
    } else if (_direction > 0) {
      if (_playerComponent.isFlippedHorizontally) {
        _changeDir = true;
        _playerComponent.flipHorizontally();
      }
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _direction = 0;

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        jump();
      }
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _direction -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _direction += 1;
    }
    if (!keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
        !keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      body.linearVelocity.x = 0;
    }

    return false;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Wall) {}
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
        (_size.x / 2 - 9.5) / 100,
        (_size.x / 2 - 5.7) / 100,
        Vector2(0, .033),
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

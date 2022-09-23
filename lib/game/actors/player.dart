import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/actors/ground.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:flutter/services.dart';
// import 'package:flame/input.dart';
// import 'package:squish_them_all/game/actors/wall.dart';
// import 'package:flame/components.dart';
// import 'package:flame_forge2d/flame_forge2d.dart';
// import 'package:flutter/services.dart';
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

class Player extends BodyComponent with KeyboardHandler, ContactCallbacks {
  final _size = Vector2(32, 32);
  final Vector2 _position;
  static const double _maxSpeed = 1.25;
  static const double _maxSpeed2 = _maxSpeed * _maxSpeed;
  double _direction = 0;
  final double _jumpForce = -3.75;
  final double _changeDirForce = 2.5;
  int _numGroundContacts = 0;
  bool _changeDir = false;
  bool _acceleratingTurn = false;
  int extraJumpsValue = 1;
  late int _extraJumps = extraJumpsValue;
  late SpriteAnimationGroupComponent _playerComponent;

  Player(this._position, {super.renderBody = false});

  @override
  Future<void> onLoad() async {
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
      size: _size / zoomLevel,
      animations: animations,
      current: PlayerState.idle,
    );

    add(_playerComponent);
    return super.onLoad();
  }

  void jump() {
    final velocity = body.linearVelocity.clone();

    if (_numGroundContacts > 0) {
      body.linearVelocity = Vector2(velocity.x, _jumpForce);
    } else if (_extraJumps > 0) {
      body.linearVelocity = Vector2(velocity.x, _jumpForce);
      _extraJumps -= 1;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final velocity = body.linearVelocity.clone();
    final position = body.position;

    // print(_numGroundContacts > 0);

    // player is in the air
    if (_numGroundContacts == 0) {
      // downward velocity
      if (velocity.y > 0) {
        _playerComponent.current = PlayerState.fall;
        // upward velocity
      } else if (velocity.y < 0) {
        if (_extraJumps != 0) {
          _playerComponent.current = PlayerState.jump;
          // using different animation for the last jump
        } else {
          _playerComponent.current = PlayerState.doubleJump;
        }
      }
      // player is on the ground
    } else {
      // player is either moving left or right
      if (velocity.x != 0) {
        _playerComponent.current = PlayerState.run;
      } else {
        _playerComponent.current = PlayerState.idle;
      }
    }

    // player is either moving left or right
    if (_direction != 0) {
      // velocity is slower or equal to the _maxSpeed
      if (!(velocity.x * velocity.x > _maxSpeed2)) {
        // when you are not making a turn
        if (!_changeDir && !_acceleratingTurn) {
          if (!(velocity.x * velocity.x == _maxSpeed2)) {
            body.applyForce(Vector2(_direction, 0));
          }
          //  when you are making a turn
        } else {
          // apply greater force to make the turn faster
          body.applyForce(Vector2(_direction * _changeDirForce, 0));
          // until the velocity reaches half of the max speed, apply greater force
          if (velocity.x * velocity.x >= _maxSpeed2 * .5) {
            _acceleratingTurn = true;
            // once the velocity surpasses half of the max speed, apply normal force
          } else {
            _changeDir = false;
          }
        }
      }
    }

    // if the velocity surpasses the max speed, directly set the velocity to be max speed. This will prevent further applyForce, i.e. repetitive calculation
    if (velocity.x * velocity.x > _maxSpeed2) {
      body.linearVelocity =
          Vector2(body.linearVelocity.x.sign * _maxSpeed, velocity.y);
      _acceleratingTurn = false;
    }

    // // When a player passes one side of the boundary, it will reappear on the other side of the boundary
    // if (position.x > worldSize.x) {
    //   position.x = 0;
    //   body.setTransform(position, 0);
    // } else if (position.x < 0) {
    //   position.x = worldSize.x;
    //   body.setTransform(position, 0);
    // }

    // flip animations according to player directions
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
    if (other is Ground) {
      if (contact.fixtureA.isSensor) {
        _numGroundContacts += 1;
        _extraJumps = extraJumpsValue;
      }
      if (contact.fixtureB.isSensor) {
        _numGroundContacts += 1;
        _extraJumps = extraJumpsValue;
      }
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Ground) {
      if (contact.fixtureA.isSensor) {
        _numGroundContacts -= 1;
      }
      if (contact.fixtureB.isSensor) {
        _numGroundContacts -= 1;
      }
    }
    super.endContact(other, contact);
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
        (_size.x / 2 - 9.5) / zoomLevel,
        (_size.x / 2 - 5.7) / zoomLevel,
        Vector2(0, 3.3) / zoomLevel,
        0,
      );

    final footSensor = PolygonShape()
      ..setAsBox(
        shape.vertices[2][0],
        (shape.vertices[2][1] - shape.centroid[1]) / 2,
        Vector2(0, shape.vertices[2][1]),
        0,
      );

    final fixtureDef = FixtureDef(shape)
      ..density = 15
      ..friction = 0
      ..restitution = 0;

    // final footSensor = CircleShape()
    //   ..position.setFrom(Vector2(0, shape.vertices[2][1]))
    //   ..radius = shape.vertices[2][0] + 0.75 / zoomLevel;

    final footSensorFixture = FixtureDef(footSensor)..isSensor = true;

    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..createFixture(footSensorFixture)
      ..setFixedRotation(true);
  }
}

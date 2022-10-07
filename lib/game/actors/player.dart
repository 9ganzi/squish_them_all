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
  bool _isTouchingFront = false;
  bool _wallJumping = false;
  bool _leftSensorOn = false;
  bool _rightSensorOn = false;
  final int _jumpTimeoutValue = 5;
  late int _jumpTimeout = _jumpTimeoutValue;
  // fixtures are only needed for testing
  late Fixture fixture;
  late Fixture footSensorFixture;
  late Fixture leftSensorFixture;
  late Fixture rightSensorFixture;
  final int _extraJumpsValue = 1;
  late int _extraJumps = _extraJumpsValue;
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
    // jump from the ground
    if (_numGroundContacts > 0) {
      double x = velocity.x;
      if (_isTouchingFront) {
        int wallBounceDir = _playerComponent.isFlippedHorizontally ? 1 : -1;
        x = wallBounceDir * 1;
        _wallJumping = true;
      }
      if (!(_playerComponent.current == PlayerState.jump && _isTouchingFront)) {
        body.linearVelocity = Vector2(x, _jumpForce);
      }
      // jump in the air
    } else if (_extraJumps > 0) {
      body.linearVelocity = Vector2(velocity.x, _jumpForce);
      _extraJumps -= 1;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _jumpTimeout -= 1;
    final velocity = body.linearVelocity.clone();
    // final position = body.position;

    // print(_numGroundContacts);
    // print(velocity.x);
    // print(_wallJumping);

    // player is in the air
    if (_numGroundContacts == 0 ||
        (_numGroundContacts == 1 && _isTouchingFront)) {
      // downward velocity
      if (velocity.y > 0) {
        if (_isTouchingFront && !_changeDir) {
          body.linearVelocity = Vector2(velocity.x, .5);
          if ((_leftSensorOn && !_playerComponent.isFlippedHorizontally) ||
              (_rightSensorOn && _playerComponent.isFlippedHorizontally)) {
            _playerComponent.flipHorizontally();
          }
          _playerComponent.current = PlayerState.wallJump;
        } else {
          _playerComponent.current = PlayerState.fall;
        }
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
      // player is either running left or right
      if (velocity.x != 0 && !_isTouchingFront) {
        _playerComponent.current = PlayerState.run;
      } else {
        _playerComponent.current = PlayerState.idle;
      }
    }

    double wallStop = 1;

    if (_isTouchingFront) {
      wallStop = _changeDirForce;
    }

    // player is either moving left or right
    if (_direction != 0) {
      // velocity is slower or equal to the _maxSpeed
      if (!(velocity.x * velocity.x > _maxSpeed2)) {
        // when you are not making a turn
        if (!_changeDir && !_acceleratingTurn && !_wallJumping) {
          // print('weak');
          if (!(velocity.x * velocity.x == _maxSpeed2) &&
              _numGroundContacts < 3) {
            body.applyForce(Vector2(_direction, 0));
          }
          //  when you are making a turn
        } else {
          // print('strong');
          // apply greater force to make the turn faster
          body.applyForce(Vector2(_direction * _changeDirForce / wallStop, 0));
          // until the velocity reaches half of the max speed, apply greater force
          if (velocity.x * velocity.x >= _maxSpeed2 / 2) {
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
      if (!_playerComponent.isFlippedHorizontally &&
          _playerComponent.current != PlayerState.wallJump) {
        _changeDir = true;
        _playerComponent.flipHorizontally();
      }
    } else if (_direction > 0) {
      if (_playerComponent.isFlippedHorizontally &&
          _playerComponent.current != PlayerState.wallJump) {
        _changeDir = true;
        _playerComponent.flipHorizontally();
      }
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _direction = 0;

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp && _jumpTimeout < 0) {
        jump();
        _jumpTimeout = _jumpTimeoutValue;
      }
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _direction -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _direction += 1;
    }
    if (!keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
        !keysPressed.contains(LogicalKeyboardKey.arrowRight) &&
        _playerComponent.current != PlayerState.wallJump) {
      body.linearVelocity.x = 0;
    }

    return false;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ground) {
      if (contact.fixtureA.isSensor) {
        if (contact.fixtureA == footSensorFixture) {
          _numGroundContacts += 1;
          _extraJumps = _extraJumpsValue;
          _wallJumping = false;
        } else {
          _isTouchingFront = true;
          if (contact.fixtureA == leftSensorFixture) {
            _leftSensorOn = true;
          } else if (contact.fixtureA == rightSensorFixture) {
            _rightSensorOn = true;
          }
        }
      }
      if (contact.fixtureB.isSensor) {
        if (contact.fixtureB == footSensorFixture) {
          _numGroundContacts += 1;
          _extraJumps = _extraJumpsValue;
          _wallJumping = false;
        } else {
          _isTouchingFront = true;
          if (contact.fixtureB == leftSensorFixture) {
            _leftSensorOn = true;
          } else if (contact.fixtureB == rightSensorFixture) {
            _rightSensorOn = true;
          }
        }
      }
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Ground) {
      if (contact.fixtureA.isSensor) {
        if (contact.fixtureA == footSensorFixture) {
          _numGroundContacts -= 1;
        } else {
          _isTouchingFront = true;
          if (contact.fixtureA == leftSensorFixture) {
            _leftSensorOn = false;
          } else if (contact.fixtureA == rightSensorFixture) {
            _rightSensorOn = false;
          }
        }
      }
      if (contact.fixtureB.isSensor) {
        if (contact.fixtureB == footSensorFixture) {
          _numGroundContacts -= 1;
        } else {
          _isTouchingFront = false;
          if (contact.fixtureB == leftSensorFixture) {
            _leftSensorOn = false;
          } else if (contact.fixtureB == rightSensorFixture) {
            _rightSensorOn = false;
          }
        }
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
        (_size.x / 2 - 10) / zoomLevel,
        (_size.x / 2 - 5.7) / zoomLevel,
        Vector2(0, 3.3) / zoomLevel,
        0,
      );

    final fixtureDef = FixtureDef(shape)
      ..density = 15
      ..friction = 0
      ..restitution = 0;

    final footSensor = PolygonShape()
      ..setAsBox(
        shape.vertices[2][0],
        shape.vertices[2][0] / 4,
        Vector2(0, _size.y / 2) / zoomLevel,
        0,
      );

    final footSensorFixtureDef = FixtureDef(footSensor)..isSensor = true;

    final leftSensor = PolygonShape()
      ..setAsBox(
        shape.vertices[2][0] * .3,
        (shape.vertices[2][1] - shape.centroid.y) * .85,
        Vector2(-(shape.vertices[2][0] * .7), shape.centroid.y),
        0,
      );

    final leftSensorFixtureDef = FixtureDef(
      leftSensor,
      userData: this,
      isSensor: true,
    );

    final rightSensor = PolygonShape()
      ..setAsBox(
        leftSensor.vertices[2][0] - leftSensor.centroid.x,
        (leftSensor.vertices[2][1] - leftSensor.centroid.y),
        Vector2(-leftSensor.centroid.x, leftSensor.centroid.y),
        0,
      );

    final rightSensorFixtureDef = FixtureDef(
      rightSensor,
      userData: this,
      isSensor: true,
    );

    final body = world.createBody(bodyDef)..setFixedRotation(true);

    fixture = body.createFixture(fixtureDef);

    footSensorFixture = body.createFixture(footSensorFixtureDef);

    leftSensorFixture = body.createFixture(leftSensorFixtureDef);

    rightSensorFixture = body.createFixture(rightSensorFixtureDef);

    return body;
  }
}

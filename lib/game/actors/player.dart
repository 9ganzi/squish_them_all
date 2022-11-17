import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/actors/enemy.dart';
import 'package:squish_them_all/game/actors/fruit.dart';
import 'package:squish_them_all/game/actors/ground.dart';
import 'package:squish_them_all/game/actors/portal.dart';
import 'package:squish_them_all/game/actors/wall.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:flutter/services.dart';
// import 'package:squish_them_all/game/actors/wall.dart';
// import 'package:flame/input.dart';
// import 'package:flame/components.dart';
// import 'package:flame_forge2d/flame_forge2d.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';

enum PlayerState {
  idle,
  run,
  jump,
  doubleJump,
  wallSlide,
  fall,
  hit,
  disappear,
}

class Player extends BodyComponent<SquishThemAll>
    with KeyboardHandler, ContactCallbacks {
  final _size = Vector2(32, 32);
  final Vector2 _position;
  static const double _maxSpeed = 1.25;
  static const double _maxSpeed2 = _maxSpeed * _maxSpeed;
  double _dir = 0;
  final double _jumpForce = -3.75;
  final double _changeDirForce = 2.5;
  final double _wallBounceForce = .3;
  late double _wallSlidePosition;
  late double _hitDir;
  int _numGroundContacts = 0;
  bool _isAccelerating = false;
  bool _isTouchingFront = false;
  bool _isWallJumping = false;
  bool _offWall = false;
  bool _leftSensorOn = false;
  bool _rightSensorOn = false;
  final double _stopBouncingDistance = .08;
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
        'Pink Man - Wall Slide (32x32).png',
        'Pink Man - Fall (32x32).png',
        'Pink Man - Hit (32x32).png',
        'Main Characters - Disappearing (96x96).png',
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
      PlayerState.wallSlide: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Wall Slide (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05),
      PlayerState.fall: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Fall (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05),
      PlayerState.hit: SpriteSheet(
        image: gameRef.images.fromCache('Pink Man - Hit (32x32).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .05, loop: false)
        ..onStart = () {
          body.setFixedRotation(false);
          body.linearVelocity = Vector2.zero();
          body.applyLinearImpulse(Vector2(_hitDir * .2, -1.5));
          body.applyAngularImpulse(.01);
          body.destroyFixture(_fixture);
        },
      PlayerState.disappear: SpriteSheet(
        image: gameRef.images
            .fromCache('Main Characters - Disappearing (96x96).png'),
        srcSize: _size * 3,
      ).createAnimation(row: 0, stepTime: .8 / 7, loop: false),
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
    if (_playerComponent.current == PlayerState.hit) {
      return;
    }
    final velocity = body.linearVelocity.clone();
    // jump from the ground
    if (_numGroundContacts > 0) {
      //  player can jump unless it is already jumping and touching the wall
      if (!(_playerComponent.current == PlayerState.jump && _isTouchingFront)) {
        // regular jump
        if (_playerComponent.current != PlayerState.wallSlide) {
          body.linearVelocity = Vector2(velocity.x, _jumpForce);
          // wall jump
        } else {
          int wallBounceDir = _playerComponent.isFlippedHorizontally ? 1 : -1;
          _isWallJumping = true;
          _offWall = true;
          body.applyLinearImpulse(
              Vector2(wallBounceDir * _wallBounceForce, -1.7));
        }
      }
      // jump in the air
    } else if (_extraJumps > 0) {
      body.linearVelocity = Vector2(velocity.x, _jumpForce);
      _extraJumps -= 1;
    }
  }

  final double _jumpTimeoutValue = .1;
  late double _jumpTimeout = _jumpTimeoutValue;
  late final double _destroyHeight = _size.y / 2 / zoomLevel + worldSize.y;

  @override
  void update(double dt) {
    super.update(dt);

    _jumpTimeout -= dt;
    final velocity = body.linearVelocity.clone();

    // print(body.position.y);

    if (_playerComponent.current == PlayerState.hit) {
      if (body.position.y >= _destroyHeight) {
        world.destroyBody(body);
        removeFromParent();
      }
      return;
    }

    if (_playerComponent.current == PlayerState.disappear) {
      body.linearVelocity = Vector2.zero();
      body.gravityOverride = Vector2.zero();
      world.destroyBody(body);
      return;
    }

    // player is in the air or wall sliding
    if (_numGroundContacts == 0 ||
        (_numGroundContacts == 1 && _isTouchingFront)) {
      // downward velocity (either falling or wall sliding)
      if (velocity.y > 0) {
        // player is wall sliding
        if (_isTouchingFront) {
          body.linearVelocity = Vector2(velocity.x, .5);
          // to prevent applying wall sliding animations in the air
          if ((_leftSensorOn && !_playerComponent.isFlippedHorizontally) ||
              (_rightSensorOn && _playerComponent.isFlippedHorizontally)) {
            _playerComponent.flipHorizontally();
          }
          _playerComponent.current = PlayerState.wallSlide;
          // record wall slide position to later stop wall bounce
          _wallSlidePosition = body.position.x;
          // player is falling
        } else {
          _playerComponent.current = PlayerState.fall;
          // when player is moving away from the wall
          if (_offWall) {
            // make player stop
            body.linearVelocity.x = 0;
            _offWall = false;
            // make player face away from the wall
            _playerComponent.flipHorizontally();
          }
        }
        // upward velocity (jumping)
      } else if (velocity.y < 0) {
        // stop the bouncing effect when the player is away from the wall by _stopBouncingDistance
        if (_isWallJumping &&
            _dir == 0 &&
            (_wallSlidePosition - body.position.x).abs() >
                _stopBouncingDistance) {
          body.linearVelocity.x = 0;
        }
        // use regular jump animation
        if (_extraJumps != 0) {
          _playerComponent.current = PlayerState.jump;
          if (_offWall) {
            _playerComponent.flipHorizontally();
            _offWall = false;
          }
          // use double jump animation for the last jump
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
        if (_numGroundContacts == 2 &&
            _playerComponent.current == PlayerState.wallSlide) {
          _playerComponent.flipHorizontally();
        }
        _playerComponent.current = PlayerState.idle;
      }
    }

    // player is moving
    if (_dir != 0) {
      // velocity is slower or equal to the _maxSpeed
      if (velocity.x * velocity.x <= _maxSpeed2) {
        // when you are not making a turn
        if (!_isAccelerating && !_isWallJumping || _isTouchingFront) {
          if (!(velocity.x * velocity.x == _maxSpeed2) &&
              _numGroundContacts < 3) {
            body.applyForce(Vector2(_dir, 0));
          }
          //  when you are making a turn
        } else {
          body.applyForce(Vector2(_dir * _changeDirForce, 0));
          // once the velocity surpasses half of the max speed, apply normal force
          if (velocity.x * velocity.x >= _maxSpeed2 / 2) {
            _isAccelerating = true;
          }
        }
        // velocity is greater than _maxSpeed
      } else {
        // if the velocity surpasses the max speed, directly set the velocity to be max speed. This will prevent further applyForce, i.e. repetitive calculation
        body.linearVelocity =
            Vector2(body.linearVelocity.x.sign * _maxSpeed, velocity.y);
        _isAccelerating = false;
      }
    }

    // // When a player passes one side of the boundary, it will reappear on the other side of the boundary
    // final position = body.position;
    // if (position.x > worldSize.x) {
    //   position.x = 0;
    //   body.setTransform(position, 0);
    // } else if (position.x < 0) {
    //   position.x = worldSize.x;
    //   body.setTransform(position, 0);
    // }

    // flip animations according to player directions
    if (_dir < 0) {
      if (!_playerComponent.isFlippedHorizontally &&
          _playerComponent.current != PlayerState.wallSlide) {
        _isAccelerating = true;
        _playerComponent.flipHorizontally();
      }
    } else if (_dir > 0) {
      if (_playerComponent.isFlippedHorizontally &&
          _playerComponent.current != PlayerState.wallSlide) {
        _isAccelerating = true;
        _playerComponent.flipHorizontally();
      }
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _dir = 0;

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp && _jumpTimeout < 0) {
        jump();
        _jumpTimeout = _jumpTimeoutValue;
      }
    }

    if (!keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
        !keysPressed.contains(LogicalKeyboardKey.arrowRight) &&
        _playerComponent.current != PlayerState.wallSlide) {
      body.linearVelocity.x = 0;
      _isAccelerating = false;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _dir -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _dir += 1;
    }

    return false;
  }

  // fixtures are used to identify which sensor is triggered
  late final Fixture _fixture;
  late final Fixture _footSensorFixture;
  late final Fixture _leftSensorFixture;
  late final Fixture _rightSensorFixture;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Enemy) {
      if (_playerComponent.current == PlayerState.hit) {
        return;
      }
      final playerDir =
          (body.worldCenter - other.body.worldCenter).normalized();
      if (playerDir.dot(Vector2(0, -1)) > .85) {
        _extraJumps = _extraJumpsValue + 1;
        jump();
        other.hit();
      } else {
        if (contact.fixtureA == _leftSensorFixture ||
            contact.fixtureB == _leftSensorFixture) {
          // print('left hit');
          _hitDir = 1;
          _playerComponent.current = PlayerState.hit;
          if (gameRef.playerData.health.value > 0) {
            gameRef.playerData.health.value -= 1;
          }
        } else if (contact.fixtureA == _rightSensorFixture ||
            contact.fixtureB == _rightSensorFixture) {
          // print('right hit');
          _hitDir = -1;
          _playerComponent.current = PlayerState.hit;
          if (gameRef.playerData.health.value > 0) {
            gameRef.playerData.health.value -= 1;
          }
        }
      }
    }

    if (other is Ground || other is Wall) {
      if (contact.fixtureA.isSensor || contact.fixtureB.isSensor) {
        if (contact.fixtureA == _footSensorFixture ||
            contact.fixtureB == _footSensorFixture) {
          _numGroundContacts += 1;
          _extraJumps = _extraJumpsValue;
          _isWallJumping = false;
        } else {
          _isTouchingFront = true;
          _isAccelerating = false;
          if (contact.fixtureA == _leftSensorFixture ||
              contact.fixtureB == _leftSensorFixture) {
            _leftSensorOn = true;
          } else if (contact.fixtureA == _rightSensorFixture ||
              contact.fixtureB == _rightSensorFixture) {
            _rightSensorOn = true;
          }
        }
      }
    }

    if (other is Portal) {
      if (_playerComponent.current == PlayerState.hit) {
        return;
      }
      other.disappear();
      _playerComponent.current = PlayerState.disappear;
    }

    if (other is Fruit) {
      if (contact.fixtureA == _fixture || contact.fixtureB == _fixture) {
        gameRef.playerData.score.value += 10;
        other.collected();
      }
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Ground || other is Wall) {
      if (contact.fixtureA.isSensor || contact.fixtureB.isSensor) {
        if (contact.fixtureA == _footSensorFixture ||
            contact.fixtureB == _footSensorFixture) {
          _numGroundContacts -= 1;
        } else {
          if (!_isWallJumping && _numGroundContacts == 0) {
            _offWall = true;
          }
          _isTouchingFront = false;
          if (contact.fixtureA == _leftSensorFixture ||
              contact.fixtureB == _leftSensorFixture) {
            _leftSensorOn = false;
          } else if (contact.fixtureA == _rightSensorFixture ||
              contact.fixtureB == _rightSensorFixture) {
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
        shape.vertices[2][0] * .5,
        (shape.vertices[2][1] - shape.centroid.y) * .85,
        Vector2(-(shape.vertices[2][0] * .5), shape.centroid.y),
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

    _fixture = body.createFixture(fixtureDef)..filterData.groupIndex = -1;
    _footSensorFixture = body.createFixture(footSensorFixtureDef);
    _leftSensorFixture = body.createFixture(leftSensorFixtureDef);
    _rightSensorFixture = body.createFixture(rightSensorFixtureDef);

    return body;
  }
}

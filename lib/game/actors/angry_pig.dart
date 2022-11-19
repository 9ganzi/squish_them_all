part of "enemy.dart";

enum AngryPigState {
  idle,
  walk,
  hit1,
  run,
  hit2,
}

class AngryPig extends Enemy {
  bool _isAngry = false;
  double _walkSpeed = 30;
  int _step = 0;

  AngryPig(Vector2 position)
      : super(
          position,
          Vector2(36, 30),
        );

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

    _direction = Random().nextInt(2) == 0 ? -1 : 1;

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
      ).createAnimation(row: 0, stepTime: 0.05, loop: false)
        ..onComplete = () {
          _enemyComponent.current = AngryPigState.run;
        },
      AngryPigState.run: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Run (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05),
      AngryPigState.hit2: SpriteSheet(
        image: gameRef.images.fromCache('Angry Pig - Hit 2 (36x30).png'),
        srcSize: Vector2(36, 30),
      ).createAnimation(row: 0, stepTime: 0.05, loop: false)
        ..onStart = () {
          body.setFixedRotation(false);
          body.linearVelocity = Vector2.zero();
          body.applyLinearImpulse(Vector2(-_direction * .2, -1.5));
          body.applyAngularImpulse(.01);
          body.destroyFixture(_fixture);
        },
    };

    _enemyComponent = SpriteAnimationGroupComponent<AngryPigState>(
      anchor: Anchor.center,
      size: _size / zoomLevel,
      animations: animations,
      current: AngryPigState.idle,
    );

    add(_enemyComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _turnTimeout -= dt;

    if (_waitTimeout >= 0) {
      _waitTimeout -= dt;
    }

    if (_enemyComponent.current == AngryPigState.hit2) {
      if (body.position.y >= _destroyHeight) {
        world.destroyBody(body);
        removeFromParent();
      }
      return;
    }

    // print(body.position.x);
    // print(turnStep);

    final velocity = body.linearVelocity.clone();

    if (!_isAngry) {
      if (velocity.x != 0) {
        _enemyComponent.current = AngryPigState.walk;
      } else {
        _enemyComponent.current = AngryPigState.idle;
      }
    }

    // todo: uncomment this
    // if (_turningPoints.length == 2 && _waitTimeout <= 0) {
    //   // step 0: stop
    //   if ((body.position.x <= _turningPoints[0] ||
    //           body.position.x >= _turningPoints[1]) &&
    //       _step == 0) {
    //     body.linearVelocity.x = 0;
    //     _direction = -_direction;
    //     _turnTimeout = _turnTimeoutValue;
    //     _step += 1;
    //     // step 1: wait
    //   } else if (_step == 1 && _turnTimeout <= 0) {
    //     // step 2: walk
    //     body.applyForce(Vector2(_direction * _walkSpeed, 0));
    //     _step += 1;
    //   } else if (_step == 2 &&
    //       (body.position.x > _turningPoints[0] &&
    //           body.position.x < _turningPoints[1])) {
    //     _step = 0;
    //   }
    // }

    // change direction
    if (_direction < 0 && _step == 2) {
      if (_enemyComponent.isFlippedHorizontally) {
        _enemyComponent.flipHorizontally();
      }
    } else if (_direction > 0 && _step == 2) {
      if (!_enemyComponent.isFlippedHorizontally) {
        _enemyComponent.flipHorizontally();
      }
    }
  }

  @override
  void hit() {
    if (!_isAngry) {
      _enemyComponent.current = AngryPigState.hit1;
      _isAngry = true;
      _turnTimeoutValue = 0;
      _turnTimeout = 0;
      _walkSpeed *= 1.5;
    } else {
      // todo: uncomment this
      // _enemyComponent.current = AngryPigState.hit2;
    }
  }

  @override
  Body createBody() {
    debugMode = true;

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

    final body = world.createBody(bodyDef)..setFixedRotation(true);

    _fixture = body.createFixture(fixtureDef)..filterData.groupIndex = -1;

    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ground) {
      if (_turningPoints.length != 2) {
        for (final fixture in other.fixtures) {
          if (contact.fixtureA == fixture[0] ||
              contact.fixtureB == fixture[0]) {
            _turningPoints.add(fixture[1] + _size.y / 2 / zoomLevel);
            _turningPoints.add(fixture[2] - _size.y / 2 / zoomLevel);
            // print('[${body.position.x}]');
            // print('[${turningPoints[0]}, ${turningPoints[1]}]');
            bool case1 = body.position.x <= _turningPoints[0];
            bool case2 = body.position.x >= _turningPoints[1];
            if (case1 || case2) {
              _step = 0;
              if ((case1 && _direction == 1) || (case2 && _direction == -1)) {
                _direction = -_direction;
              }
            } else {
              _step = 1;
            }
          }
        }
      }
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Ground) {
      if (contact.fixtureA == _fixture || contact.fixtureB == _fixture) {
        for (final fixture in other.fixtures) {
          if (contact.fixtureA == fixture[0] ||
              contact.fixtureB == fixture[0]) {
            _turningPoints.clear();
          }
        }
      }
    }
    super.endContact(other, contact);
  }
}

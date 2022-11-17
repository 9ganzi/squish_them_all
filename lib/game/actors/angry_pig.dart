import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
// import 'package:squish_them_all/game/actors/player.dart';
import 'dart:math';

import 'package:squish_them_all/game/actors/enemy.dart';
import 'package:squish_them_all/game/actors/ground.dart';
import 'package:squish_them_all/game/game.dart';
// import 'package:squish_them_all/game/actors/wall.dart';

enum AngryPigState {
  idle,
  walk,
  hit1,
  run,
  hit2,
}

class AngryPig extends Enemy {
  final _size = Vector2(36, 30);
  final Vector2 _position;
  final List<double> turningPoints = List<double>.empty(growable: true);
  bool angry = false;
  double walkSpeed = 30;
  int turnStep = 0;
  late Fixture fixture;
  late SpriteAnimationGroupComponent _angryPigComponent;

  AngryPig(this._position, {super.renderBody = false}) : super(_position);

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

    direction = Random().nextInt(2) == 0 ? -1 : 1;

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
      current: AngryPigState.idle,
    );

    add(_angryPigComponent);
  }

  double waitTimeout = 1;
  final double turnTimeoutValue = 1.5;
  double turnTimeout = 0;

  @override
  void update(double dt) {
    super.update(dt);

    turnTimeout -= dt;

    if (waitTimeout >= 0) {
      waitTimeout -= dt;
    }

    // print(body.position.x);
    // print(turnStep);

    final velocity = body.linearVelocity.clone();

    if (!angry) {
      if (velocity.x != 0) {
        _angryPigComponent.current = AngryPigState.walk;
      } else {
        _angryPigComponent.current = AngryPigState.idle;
      }
    } else {
      _angryPigComponent.current = AngryPigState.run;
    }

    if (turningPoints.length == 2 && waitTimeout <= 0) {
      // step 0: stop
      if ((body.position.x <= turningPoints[0] ||
              body.position.x >= turningPoints[1]) &&
          turnStep == 0) {
        body.linearVelocity.x = 0;
        direction = -direction;
        turnTimeout = turnTimeoutValue;
        turnStep += 1;
        // step 1: wait
      } else if (turnStep == 1 && turnTimeout <= 0) {
        // step 2: walk
        body.applyForce(Vector2(direction * walkSpeed, 0));
        turnStep += 1;
      } else if (turnStep == 2 &&
          (body.position.x > turningPoints[0] &&
              body.position.x < turningPoints[1])) {
        turnStep = 0;
      }
    }

    // change direction
    if (direction < 0 && turnStep == 2) {
      if (_angryPigComponent.isFlippedHorizontally) {
        _angryPigComponent.flipHorizontally();
      }
    } else if (direction > 0 && turnStep == 2) {
      if (!_angryPigComponent.isFlippedHorizontally) {
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

    final body = world.createBody(bodyDef)..setFixedRotation(true);

    fixture = body.createFixture(fixtureDef)..filterData.groupIndex = -1;

    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ground) {
      if (turningPoints.length != 2) {
        for (final fixture in other.fixtures) {
          if (contact.fixtureA == fixture[0] ||
              contact.fixtureB == fixture[0]) {
            turningPoints.add(fixture[1] + _size.y / 2 / zoomLevel);
            turningPoints.add(fixture[2] - _size.y / 2 / zoomLevel);
            // print('[${body.position.x}]');
            // print('[${turningPoints[0]}, ${turningPoints[1]}]');
            bool case1 = body.position.x <= turningPoints[0];
            bool case2 = body.position.x >= turningPoints[1];
            if (case1 || case2) {
              turnStep = 0;
              if ((case1 && direction == 1) || (case2 && direction == -1)) {
                direction = -direction;
              }
            } else {
              turnStep = 1;
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
      if (contact.fixtureA == fixture || contact.fixtureB == fixture) {
        for (final fixture in other.fixtures) {
          if (contact.fixtureA == fixture[0] ||
              contact.fixtureB == fixture[0]) {
            turningPoints.clear();
          }
        }
      }
    }
    super.endContact(other, contact);
  }
}

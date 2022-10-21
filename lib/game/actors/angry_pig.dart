import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/actors/enemy.dart';
import 'package:squish_them_all/game/actors/ground.dart';
import 'package:squish_them_all/game/actors/wall.dart';
import 'package:squish_them_all/game/game.dart';

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
  late double destination;
  bool angry = false;
  bool stop = false;
  final int turnTimeoutValue = 15;
  late int turnTimeout = 0;
  int turnStep = 0;
  late Fixture fixture;
  late Fixture leftSensorFixture;
  late Fixture rightSensorFixture;
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
    // delete below
    direction = -1;

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

  @override
  void update(double dt) {
    super.update(dt);

    turnTimeout -= 1;

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

    if (turningPoints.length == 2) {
      // step 0: stop
      if ((body.position.x < turningPoints[0] ||
              body.position.x > turningPoints[1]) &&
          turnStep == 0) {
        body.linearVelocity.x = 0;
        direction = -direction;
        turnTimeout = turnTimeoutValue;
        turnStep += 1;
        // step 1: wait
      } else if (turnStep == 1 && turnTimeout <= 0) {
        // step 2: walk
        body.linearVelocity.x = direction * .5;
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

    fixture = body.createFixture(fixtureDef);
    leftSensorFixture = body.createFixture(leftSensorFixtureDef);
    rightSensorFixture = body.createFixture(rightSensorFixtureDef);

    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ground) {
      // print(contact.fixtureA.body.userData is Ground);

      // fixtureB is ground
      if (contact.fixtureA == fixture && turningPoints.length != 2) {
        for (final fixture in other.fixtures) {
          if (contact.fixtureB == fixture[0]) {
            turningPoints.add(fixture[1] + _size.y / 2 / zoomLevel);
            turningPoints.add(fixture[2] + _size.y / 2 / zoomLevel);
          }
        }
        // fixtureA is ground
      } else if (contact.fixtureB == fixture && turningPoints.length != 2) {
        for (final fixture in other.fixtures) {
          if (contact.fixtureA == fixture[0]) {
            turningPoints.add(fixture[1] + _size.y / 2 / zoomLevel);
            turningPoints.add(fixture[2] - _size.y / 2 / zoomLevel);
          }
        }
      }

      if (turningPoints.length == 2) {
        if ((body.position.x < turningPoints[0] ||
            body.position.x > turningPoints[1])) {
          turnStep = 0;
        } else {
          turnStep = 1;
        }
      }
      super.beginContact(other, contact);
    }
  }
}

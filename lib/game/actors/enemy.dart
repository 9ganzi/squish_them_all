// ignore_for_file: prefer_final_fields

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'dart:math';
import 'package:squish_them_all/game/actors/ground.dart';

part "angry_pig.dart";

class Enemy extends BodyComponent<SquishThemAll> with ContactCallbacks {
  late final Vector2 _position;
  late final Vector2 _size;
  final List<double> _turningPoints = List<double>.empty(growable: true);
  late int _direction;
  late Fixture _fixture;
  late SpriteAnimationGroupComponent _enemyComponent;
  late final double _destroyHeight = _size.y / 2 / zoomLevel + worldSize.y;
  double _waitTimeout = 2;
  double _turnTimeoutValue = 1.5;
  double _turnTimeout = 0;

  Enemy(this._position, this._size, {super.renderBody = false});

  @override
  Body createBody() {
    throw UnimplementedError();
  }

  void hit() {}
}

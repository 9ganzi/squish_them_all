import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:squish_them_all/game/game.dart';

class Wall extends BodyComponent<SquishThemAll> {
  final Vector2 _worldSize;
  final List<EdgeShape> edges;

  Wall(this.edges, this._worldSize);

  @override
  Body createBody() {
    // debugMode = true;
    late Body wall;

    final bodyDef = BodyDef(
      type: BodyType.static,
      userData: this,
    );

    wall = world.createBody(bodyDef);

    final shape1 = EdgeShape()..set(Vector2.zero(), Vector2(0, _worldSize.y));
    final shape2 = EdgeShape()
      ..set(Vector2(_worldSize.x, 0), Vector2(_worldSize.x, _worldSize.y));
    // final shape3 = EdgeShape()..set(Vector2.zero(), Vector2(_worldSize.x, 0));

    wall
      ..createFixtureFromShape(shape1)
      ..createFixtureFromShape(shape2);
    // ..createFixtureFromShape(shape3);

    return wall;
  }
}

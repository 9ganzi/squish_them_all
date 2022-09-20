import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:squish_them_all/game/game.dart';

class Wall extends BodyComponent<SquishThemAll> {
  final List<Rect> rects;

  Wall.fromRects(this.rects) {
    renderBody = false;
  }

  @override
  Body createBody() {
    debugMode = true;
    late Body wall;

    final bodyDef = BodyDef()..userData = this;
    bodyDef.type = BodyType.static;
    wall = world.createBody(bodyDef);

    for (final rect in rects) {
      final shape = PolygonShape();
      shape.setAsBox(rect.width / 2, rect.height / 2,
          Vector2(rect.center.dx, rect.center.dy), 0.0);

      wall.createFixtureFromShape(shape);
    }

    return wall;
  }
}

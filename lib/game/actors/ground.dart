import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:squish_them_all/game/game.dart';

class Ground extends BodyComponent<SquishThemAll> {
  final List<Rect> rects;

  Ground.fromRects(this.rects) {
    renderBody = false;
  }

  @override
  Body createBody() {
    // debugMode = true;
    late Body ground;

    final bodyDef = BodyDef()..userData = this;
    bodyDef.type = BodyType.static;
    ground = world.createBody(bodyDef);

    for (final rect in rects) {
      final shape = PolygonShape();
      shape.setAsBox(rect.width / 2, rect.height / 2,
          Vector2(rect.center.dx, rect.center.dy), 0.0);

      ground.createFixtureFromShape(shape);
    }

    return ground;
  }
}

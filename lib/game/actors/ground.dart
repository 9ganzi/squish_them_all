import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:squish_them_all/game/game.dart';

class Ground extends BodyComponent<SquishThemAll> {
  final List<Rect> rects;
  late final List<List> fixtures = List<List>.empty(growable: true);

  Ground.fromRects(this.rects) {
    renderBody = false;
  }

  @override
  Body createBody() {
    // debugMode = true;
    late Body ground;

    final bodyDef = BodyDef(
      type: BodyType.static,
      userData: this,
    );

    ground = world.createBody(bodyDef);

    for (final rect in rects) {
      final shape = PolygonShape();
      shape.setAsBox(rect.width / 2, rect.height / 2,
          Vector2(rect.center.dx, rect.center.dy), 0.0);
      fixtures.add([ground.createFixtureFromShape(shape), rect.left, rect.right]);
    }

    return ground;
  }
}

import 'dart:ui';

import 'package:flame/components.dart';

class Player extends SpriteComponent {
  Player(
    Image image, {
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super.fromImage(
          image,
          // this defines the top left corner of the sprit image we want to draw from the input image.
          srcPosition: Vector2.zero(),
          srcSize: Vector2.all(32),
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );
}

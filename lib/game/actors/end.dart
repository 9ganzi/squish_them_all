import 'dart:ui';

import 'package:flame/components.dart';

class End extends SpriteComponent {
  End(
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
          srcSize: Vector2(64, 64),
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );
}

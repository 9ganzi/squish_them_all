import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/actors/player.dart';

class End extends BodyComponent with ContactCallbacks {
  final _size = Vector2(64, 64);
  late final Vector2 _scaledSize;
  bool isTaken = false;

  late SpriteAnimationComponent _endComponent;

  final Vector2 position;

  End(this.position, {super.renderBody = false});

  @override
  Future<void> onLoad() async {
    _scaledSize = _size / 100;
    await gameRef.images.load('Checkpoints - End (Idle).png');

    await super.onLoad();

    _endComponent = SpriteAnimationComponent(
      animation: SpriteSheet(
        image: gameRef.images.fromCache('Checkpoints - End (Idle).png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      anchor: Anchor.center,
      size: _scaledSize,
    );

    add(_endComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isTaken) {
      world.destroyBody(body);
      // // Causes error!
      // gameRef.remove(this);
    }
  }

  void hit() {
    isTaken = true;
  }

  @override
  Body createBody() {
    // debugMode = true;
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.static,
    );

    final shape = EdgeShape()
      ..set(Vector2((-_size.x / 2 + 17) / 100, -.115),
          Vector2((_size.x / 2 - 17) / 100, -.115));
    final fixtureDef = FixtureDef(shape);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Player) {
      hit();
    }
  }
}

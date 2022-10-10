import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/actors/player.dart';

class Fruit extends BodyComponent with ContactCallbacks {
  final _size = Vector2(32, 32);
  bool isTaken = false;

  final Vector2 position;
  String sprite;
  late SpriteAnimationComponent _fruitComponent;

  Fruit(this.position, this.sprite, {super.renderBody = false});

  @override
  Future<void> onLoad() async {
    await gameRef.images.load(sprite);

    await super.onLoad();

    _fruitComponent = SpriteAnimationComponent(
      animation: SpriteSheet(
        image: gameRef.images.fromCache(sprite),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      anchor: Anchor.center,
      size: _size / 100,
    );

    add(_fruitComponent);
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
      type: BodyType.kinematic,
    );

    final shape = CircleShape()..radius = .05;
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

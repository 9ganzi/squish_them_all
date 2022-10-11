import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/actors/player.dart';
import 'package:squish_them_all/game/game.dart';

class Bananas extends BodyComponent<SquishThemAll> with ContactCallbacks {
  final _size = Vector2(32, 32);
  bool isTaken = false;

  late SpriteAnimationComponent _bananasComponent;

  final Vector2 position;

  Bananas(this.position, {super.renderBody = false});

  @override
  Future<void> onLoad() async {
    await gameRef.images.load('Fruits - Bananas.png');

    await super.onLoad();

    _bananasComponent = SpriteAnimationComponent(
      animation: SpriteSheet(
        image: gameRef.images.fromCache('Fruits - Bananas.png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      anchor: Anchor.center,
      size: _size / 100,
    );

    add(_bananasComponent);
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
      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.3),
        )..onFinishCallback = () {
            add(RemoveEffect());
          },
      );
      gameRef.playerData.score.value += 10;
    }
    super.beginContact(other, contact);
  }
}

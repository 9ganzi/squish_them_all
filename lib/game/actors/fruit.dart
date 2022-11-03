import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:squish_them_all/game/actors/player.dart';

enum FruitState {
  idle,
  collected,
}

class Fruit extends BodyComponent<SquishThemAll> with ContactCallbacks {
  final _size = Vector2(32, 32);
  final Vector2 position;
  String sprite;
  late SpriteAnimationGroupComponent _fruitComponent;

  Fruit(this.position, this.sprite, {super.renderBody = false});

  @override
  Future<void> onLoad() async {
    await gameRef.images.loadAll([sprite, "Checkpoints - Collected.png"]);

    await super.onLoad();

    final animations = {
      FruitState.idle: SpriteSheet(
        image: gameRef.images.fromCache(sprite),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05),
      FruitState.collected: SpriteSheet(
        image: gameRef.images.fromCache("Checkpoints - Collected.png"),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: 0.05)
        ..onComplete = () {
          world.destroyBody(body);
          removeFromParent();
        }
        ..loop = false,
    };

    _fruitComponent = SpriteAnimationGroupComponent<FruitState>(
      anchor: Anchor.center,
      size: _size / zoomLevel,
      animations: animations,
      current: FruitState.idle,
    );

    add(_fruitComponent);
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
    final fixtureDef = FixtureDef(shape)..isSensor = true;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Player) {
      _fruitComponent.current = FruitState.collected;
      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.3),
          onComplete: () {
            add(RemoveEffect());
          },
        ),
      );
      gameRef.playerData.score.value += 10;
    }
  }
}

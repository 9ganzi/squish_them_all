import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:squish_them_all/game/game.dart';
import 'package:squish_them_all/game/actors/player.dart';

enum PortalState {
  idle,
  disappear,
}

class Portal extends BodyComponent with ContactCallbacks {
  final _size = Vector2(64, 64);
  bool _isTaken = false;
  final Vector2 position;
  late SpriteAnimationGroupComponent _portalComponent;
  Function? onPlayerEnter;

  Portal(this.position, {this.onPlayerEnter, super.renderBody = false});

  @override
  Future<void> onLoad() async {
    await gameRef.images.load('Checkpoints - Portal.png');

    await super.onLoad();

    final animations = {
      PortalState.idle: SpriteSheet(
        image: gameRef.images.fromCache('Checkpoints - Portal.png'),
        srcSize: _size,
      ).createAnimation(row: 0, stepTime: .1),
      PortalState.disappear: SpriteSheet(
        image: gameRef.images.fromCache('Checkpoints - Portal.png'),
        srcSize: _size,
      ).createAnimation(row: 2, stepTime: .1),
    };

    _portalComponent = SpriteAnimationGroupComponent<PortalState>(
      anchor: Anchor.center,
      size: _size / zoomLevel,
      animations: animations,
      current: PortalState.idle,
    );

    add(_portalComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isTaken) {
      world.destroyBody(body);
      onPlayerEnter?.call();
      // _portalComponent.current = PortalState.disappear;
      // // Causes error!
      // gameRef.remove(this);
    }
  }

  void hit() {
    _isTaken = true;
  }

  @override
  Body createBody() {
    // debugMode = true;
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.static,
    );

    final shape = PolygonShape()
      ..setAsBox(
        (_size.x / 2 - 28) / zoomLevel,
        (_size.x / 2 - 15) / zoomLevel,
        Vector2(0, 5) / zoomLevel,
        0,
      );

    final fixtureDef = FixtureDef(shape)
      ..density = 15
      ..friction = 0
      ..restitution = 0;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Player) {
      hit();
    }
  }
}

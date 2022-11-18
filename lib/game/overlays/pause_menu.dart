import 'package:flutter/material.dart';
// import 'package:flame/components.dart';
// import 'package:flame/input.dart';

import 'package:squish_them_all/game/game.dart';
import '../utils/audio_manager.dart';
import 'main_menu.dart';
// import 'package:squish_them_all/game/overlays/game_over.dart';

class PauseMenu extends StatelessWidget {
  static const id = 'PauseMenu';
  final SquishThemAll gameRef;

  const PauseMenu({super.key, required this.gameRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  AudioManager.resumeBgm();
                  gameRef.overlays.remove(id);
                  gameRef.resumeEngine();
                },
                child: const Text('Resume'),
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  gameRef.overlays.remove(id);
                  gameRef.resumeEngine();
                  gameRef.removeAll(gameRef.children);
                  gameRef.overlays.add(MainMenu.id);
                },
                child: const Text('Exit'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

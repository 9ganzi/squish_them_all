import 'package:flutter/material.dart';

import 'package:squish_them_all/game/game.dart';
import 'main_menu.dart';

class GameOver extends StatelessWidget {
  static const id = 'GameOver';
  final SquishThemAll gameRef;

  const GameOver({super.key, required this.gameRef});

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
                  gameRef.overlays.remove(id);
                  gameRef.resumeEngine();
                  gameRef.removeAll(gameRef.children);
                },
                child: const Text('Restart'),
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

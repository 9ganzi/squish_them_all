import 'package:squish_them_all/game/overlays/settings.dart';
import 'package:flutter/material.dart';
import '../game.dart';

class MainMenu extends StatelessWidget {
  static const id = 'MainMenu';
  final SquishThemAll gameRef;

  const MainMenu({super.key, required this.gameRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  gameRef.overlays.remove(id);
                },
                child: const Text('Play'),
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  gameRef.overlays.remove(id);
                  gameRef.overlays.add(Settings.id);
                },
                child: const Text('Settings'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

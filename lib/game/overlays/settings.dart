import 'package:squish_them_all/game/overlays/main_menu.dart';
import 'package:flutter/material.dart';

import '../game.dart';

class Settings extends StatelessWidget {
  static const id = 'Settings';
  final SquishThemAll gameRef;

  const Settings({super.key, required this.gameRef});

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
                  gameRef.overlays.add(MainMenu.id);
                },
                child: const Text('Back'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

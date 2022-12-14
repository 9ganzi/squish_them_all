// import 'package:flame_audio/bgm.dart';
import 'package:squish_them_all/game/overlays/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:squish_them_all/game/utils/audio_manager.dart';

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
              width: 300,
              child: ValueListenableBuilder<bool>(
                valueListenable: AudioManager.sfx,
                builder: (context, sfx, child) => SwitchListTile(
                  title: const Text('Sound Effects'),
                  value: sfx,
                  onChanged: (value) => AudioManager.sfx.value = value,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: ValueListenableBuilder<bool>(
                valueListenable: AudioManager.bgm,
                builder: (context, bgm, child) => SwitchListTile(
                  title: const Text('Background Music'),
                  value: bgm,
                  onChanged: (value) => AudioManager.bgm.value = value,
                ),
              ),
            ),
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

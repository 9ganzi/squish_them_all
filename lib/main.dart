import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'game/game.dart';
import 'package:squish_them_all/game/overlays/game_over.dart';
import 'package:squish_them_all/game/overlays/main_menu.dart';
import 'package:squish_them_all/game/overlays/pause_menu.dart';
import 'package:squish_them_all/game/overlays/settings.dart';

void main() {
  runApp(const MyApp());
}

final _game = SquishThemAll();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Squish Them All!',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: GameWidget<SquishThemAll>(
          game: kDebugMode ? SquishThemAll() : _game,
          overlayBuilderMap: {
            MainMenu.id: (context, game) => MainMenu(gameRef: game),
            PauseMenu.id: (context, game) => PauseMenu(gameRef: game),
            GameOver.id: (context, game) => GameOver(gameRef: game),
            Settings.id: (context, game) => Settings(gameRef: game),
          },
          initialActiveOverlays: const [MainMenu.id],
        ),
      ),
    );
  }
}

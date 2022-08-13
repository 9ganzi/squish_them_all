import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/game.dart';

void main() {
  runApp(const MyApp());
}

// Todo: Use this!
final _game = SquishThemAll();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squish Them All!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: GameWidget(
          game: SquishThemAll(),
        ),
      ),
    );
  }
}

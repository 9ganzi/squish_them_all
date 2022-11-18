import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final sfx = ValueNotifier(true);
  static final bgm = ValueNotifier(true);

  static Future<void> init() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'background1.wav',
      'background2.wav',
      'Blop.wav',
      'Collectibles.wav',
      'Hit.wav',
      'Jump.wav',
      'Steps.wav',
      'Win.wav',
    ]);
  }

  static void playSfx(String file) {
    if (sfx.value) {
      FlameAudio.play(file);
    }
  }

  static void playBgm(String file) {
    if (bgm.value) {
      FlameAudio.bgm.play(file);
    }
  }

  static void pauseBgm() {
    FlameAudio.bgm.pause();
  }

  static void resumeBgm() {
    FlameAudio.bgm.resume();
  }

  static void stopBgm() {
    FlameAudio.bgm.stop();
  }
}

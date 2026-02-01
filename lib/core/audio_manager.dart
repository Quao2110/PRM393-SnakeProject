import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  //nhạc nền
  static final AudioPlayer _bgPlayer = AudioPlayer();
  //hiệu ứng
  static final AudioPlayer _sfxPlayer = AudioPlayer();

  //NHẠC NỀN
  static Future<void> playBackground() async {
    if (_bgPlayer.state == PlayerState.playing) return;

    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audios/trinh.m4a'));
      await _bgPlayer.setVolume(0.5);
    } catch (e) {
      debugPrint("Chưa có file nhạc nền: $e");
    }
  }

  static Future<void> stopBackground() async {
    try {
      await _bgPlayer.stop();
    } catch (e) {
      debugPrint("Lỗi dừng nhạc: $e");
    }
  }

  // HIỆU ỨNG
  static Future<void> playSFX(String fileName) async {
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource('audios/$fileName'));
      await _sfxPlayer.setVolume(1.0);
    } catch (e) {
      debugPrint("Thiếu file SFX ($fileName): $e");
    }
  }
}


import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer _bgPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();

  static bool isMusicOn = true;
  static double musicVolume = 0.5;

  static Future<void> playBackground([String fileName = 'background.mp3']) async {
    if (!isMusicOn) return;
    try {
      if (_bgPlayer.state == PlayerState.playing) {
        await _bgPlayer.stop();
      }
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setSource(AssetSource('audios/$fileName'));
      await _bgPlayer.setVolume(musicVolume);
      await _bgPlayer.resume();
    } catch (e) {
      print("Lỗi phát nhạc nền ($fileName): $e");
    }
  }

  static Future<void> stopBackground() async {
    try {
      await _bgPlayer.stop();
    } catch (e) {
      print("Lỗi dừng nhạc: $e");
    }
  }

  static Future<void> toggleMusic(bool isOn) async {
    isMusicOn = isOn;
    if (isOn) {
      await playBackground('background.mp3');
    } else {
      await stopBackground();
    }
  }

  static Future<void> setMusicVolume(double volume) async {
    musicVolume = volume;
    try {
      await _bgPlayer.setVolume(volume);
    } catch (e) {
      print("Lỗi set volume: $e");
    }
  }

  // HIỆU ỨNG (Chạy 1 lần)
  static Future<void> playSFX(String fileName) async {
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource('audios/$fileName'));
      await _sfxPlayer.setVolume(1.0);
    } catch (e) {
      print("Thiếu file SFX ($fileName): $e");
    }
  }

  // Phát và CHỜ đến khi xong
  static Future<void> playSFXAndWait(String fileName) async {
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }

      // Thiết lập source và play
      await _sfxPlayer.setSource(AssetSource('audios/$fileName'));
      await _sfxPlayer.setVolume(1.0);
      await _sfxPlayer.resume();

      // Dùng stream onPlayerComplete để chờ sự kiện kết thúc
      // .first sẽ trả về Future hoàn thành ngay khi sự kiện tiếp theo xảy ra
      await _sfxPlayer.onPlayerComplete.first;

    } catch (e) {
      print("Lỗi phát SFX và chờ ($fileName): $e");
    }
  }
}
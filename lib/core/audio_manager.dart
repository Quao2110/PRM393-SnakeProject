import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  //nhạc nền
  static final AudioPlayer _bgPlayer = AudioPlayer();
  //hiệu ứng
  static final AudioPlayer _sfxPlayer = AudioPlayer();

  // Trạng thái nhạc
  static bool isMusicOn = true;
  static double musicVolume = 0.5;

  //NHẠC NỀN
  static Future<void> playBackground() async {
    if (_bgPlayer.state == PlayerState.playing) return;

    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audios/trinh.m4a'));
      await _bgPlayer.setVolume(musicVolume);
    } catch (e) {
      print("Chưa có file nhạc nền: $e");
    }
  }

  static Future<void> stopBackground() async {
    try {
      await _bgPlayer.stop();
    } catch (e) {
      print("Lỗi dừng nhạc: $e");
    }
  }

  // BẬT/TẮT NHẠC
  static Future<void> toggleMusic(bool isOn) async {
    isMusicOn = isOn;
    if (isOn) {
      await playBackground();
    } else {
      await stopBackground();
    }
  }

  // ĐIỀU CHỈNH ÂM LƯỢNG
  static Future<void> setMusicVolume(double volume) async {
    musicVolume = volume;
    try {
      await _bgPlayer.setVolume(volume);
    } catch (e) {
      print("Lỗi set volume: $e");
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
      print("Thiếu file SFX ($fileName): $e");
    }
  }
}
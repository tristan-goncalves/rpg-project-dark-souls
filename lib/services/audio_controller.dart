import 'package:flame_audio/flame_audio.dart';

class AudioController {
  AudioController._();
  static final AudioController I = AudioController._();

  bool _bgmActive = false;

  Future<void> init() async {
    await FlameAudio.audioCache.loadAll([
      'darksouls_fog_sound.mp3',
      'darksouls_boss_theme.mp3',
      'darksouls_victory_sound.mp3',
    ]);
  }

  Future<void> playSfx(String path, {double volume = 1.0}) async {
    await FlameAudio.play(path, volume: volume);
  }

  Future<void> playBgm(String path, {double volume = 1.0, bool loop = true}) async {
    await FlameAudio.bgm.stop();
    _bgmActive = true;
    await FlameAudio.bgm.play(path, volume: volume);
  }

  Future<void> stopBgm() async {
    if (_bgmActive) {
      _bgmActive = false;
      await FlameAudio.bgm.stop();
    }
  }

  Future<void> fadeOutBgm({Duration duration = const Duration(milliseconds: 600)}) async {
    if (!_bgmActive) return;
    final steps = 6;
    final stepDuration = duration ~/ steps;
    double vol = 0.1;
    for (int i = 0; i < steps; i++) {
      vol = (1.0 - (i + 1) / steps).clamp(0.0, 0.1);
      await FlameAudio.bgm.audioPlayer.setVolume(vol);
      await Future.delayed(stepDuration);
    }
    await stopBgm();
  }
}

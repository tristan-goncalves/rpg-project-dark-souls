import 'package:bonfire/bonfire.dart';
import '../audio_controller.dart';

class VictoryMusicController extends GameComponent {
  final String bgmPath;
  final double volume;

  VictoryMusicController({
    this.bgmPath = 'darksouls_victory_sound.mp3',
    this.volume = 0.1,
  });

  @override
  void onMount() {
    super.onMount();
    AudioController.I.playBgm(bgmPath, volume: volume);
  }

  @override
  void onRemove() {
    AudioController.I.stopBgm();
    super.onRemove();
  }
}

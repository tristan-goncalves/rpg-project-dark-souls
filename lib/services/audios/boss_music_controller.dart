import 'package:bonfire/bonfire.dart';
import '../audio_controller.dart';

class BossMusicController extends GameComponent {
  final String bgmPath;
  final double volume;

  BossMusicController({
    this.bgmPath = 'darksouls_boss_theme.mp3',
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

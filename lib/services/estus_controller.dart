import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';

class EstusController {
  EstusController._();
  static final EstusController I = EstusController._();

  static const int maxCount = 3;

  // Nombre de fioles restantes
  final ValueNotifier<int> count = ValueNotifier<int>(0);

  // Débloque la mécanique de soin
  final ValueNotifier<bool> unlocked = ValueNotifier<bool>(false);

  // Consomme 1 fiole et soigne +50 HP si le joueur est blessé
  bool consumeAndHeal(BonfireGameInterface game) {
    if (count.value <= 0) return false;
    final player = game.player;
    if (player == null || player.life >= player.maxLife) return false;

    count.value -= 1;
    player.addLife(50);
    return true;
  }

  int refillToMax() {
    final before = count.value;
    final gain = (maxCount - before).clamp(0, maxCount);
    if (gain > 0) {
      count.value = before + gain;
      unlocked.value = true;
    }
    return gain;
  }

  void reset() {
    count.value = 0;
    unlocked.value = false;
  }
}

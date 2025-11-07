import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../../services/estus_controller.dart';

class TreasureChest extends GameDecoration {
  static const double interactionDistance = 24.0;
  bool dialogOpened = false;
  bool isLooted = false;

  TreasureChest(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load(
            'items/chest_spritesheet.png',
            srcPosition: Vector2.zero(),
            srcSize: Vector2(16, 16),
          ),
          size: Vector2.all(16),
          position: position,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (isLooted || dialogOpened) return;

    final player = gameRef.player;
    if (player == null) return;

    if (player.center.distanceTo(center) < interactionDistance) {
      dialogOpened = true;
      showLegendaryLootDialog();
    }
  }

  void showLegendaryLootDialog() {
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: const [
            TextSpan(
              text: '✨ Coffre LÉGENDAIRE !\n\n',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'Vous recevez 3 Fioles d’Estus.\nCliquez sur l’icône pour soigner +50 PV.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
      onClose: () {
        grantEstusToPlayer();
        isLooted = true;
        removeFromParent();
      },
    );
  }

  void grantEstusToPlayer() {
    final gained = EstusController.I.refillToMax();

    if (gained > 0) {
      final text = TextComponent(
        text: '+$gained Estus',
        position: center - Vector2(0, 8),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      text.add(
        MoveEffect.by(
          Vector2(0, -16),
          EffectController(duration: 1.0, curve: Curves.easeOut),
          onComplete: () => text.removeFromParent(),
        ),
      );

      gameRef.add(text);
    }
  }

}

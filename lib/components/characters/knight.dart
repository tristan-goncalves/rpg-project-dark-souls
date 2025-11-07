import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../../util/player_sprite_sheet.dart';
import '../../services/estus_controller.dart';

class Knight extends SimplePlayer with BlockMovementCollision, UseLifeBar {
  static const double tileSize = 24;
  static const double maxLifePlayer = 100;
  static const double meleeDamage = 25;
  static const double rangeDamage = 15;
  static const double rangeSpeed = 40;

  Knight(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(tileSize),
          speed: 60,
          animation: PlayerSpriteSheet.playerAnimations(),
          life: maxLifePlayer,
        ) {
    setupLifeBar(
      size: Vector2(tileSize * 1.2, tileSize / 8),
      barLifeDrawPosition: BarLifeDrawPosition.top,
      showLifeText: false,
      borderWidth: 1,
      borderColor: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(2),
      textOffset: Vector2(16, tileSize * 0.5),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: Vector2(14, 14), position: Vector2(1, 1)));
    print('[Knight] Vie initiale : $maxLifePlayer');
  }

  // Gestion du joystick
  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      switch (event.id) {
        case 0:
          attackMelee();
          break;
        case 1:
          attackRange();
          break;
        case 2:
          useEstus();
          break;
      }
    }
    super.onJoystickAction(event);
  }

  void useEstus() {
    final success = EstusController.I.consumeAndHeal(gameRef); // OK: interface
    if (!success) {
      final text = TextComponent(
        text: 'Plus de fioles !',
        position: center - Vector2(0, 12),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.redAccent,
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



  // Attaque de mêlée
  void attackMelee() async {
    simpleAttackMelee(
      damage: meleeDamage,
      size: Vector2(24, 24),
      animationRight: PlayerSpriteSheet.attackEffectRight(),
      withPush: true,
      sizePush: 3,
      diagonalEnabled: false,
    );
  }

  // Attaque à distance
  void attackRange() async {
    simpleAttackRange(
      damage: rangeDamage,
      size: Vector2(24, 24),
      speed: rangeSpeed,
      animationRight: PlayerSpriteSheet.fireballRight(),
      collision: RectangleHitbox(
        size: Vector2(8, 8),
        position: Vector2(4, 4),
      ),
    );
  }

  // Gestion des dégâts
  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    super.onReceiveDamage(attacker, damage, id);
    print('[Knight] Dégâts reçus : $damage | Vie restante : $life');
  }

  @override
  void onDie() {
    print('[Knight] Joueur mort.');
    removeFromParent();
    super.onDie();
  }
}
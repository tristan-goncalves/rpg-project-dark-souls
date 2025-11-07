import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../../util/priest_sprite.sheet.dart';

class Priest extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  static const double tileSize = 16;
  static const double visionRadius = tileSize * 6;
  static const double attackRange = tileSize * 1.2;
  static const double attackDamage = 0;
  static const double speedPriest = 0;
  static const double maxLifePriest = 10000;

  late final Vector2 spawnPosition;

  bool dialogShown = false;
  bool dialogOpening = false;

  Priest(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(16),
          speed: speedPriest,
          animation: PriestSpriteSheet.priestAnimations(),
          life: maxLifePriest,
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
    spawnPosition = position.clone();

    add(RectangleHitbox(size: Vector2(14, 14), position: Vector2(1, 1)));
    seeAndMoveToPlayer(
      closePlayer: (player) {},
      radiusVision: 0,
      margin: 0,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (dialogShown || dialogOpening) return;
    if (other is! Player) return;

    dialogOpening = true;
    showCongratsDialog();
  }

  void showCongratsDialog() {
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: const [
            TextSpan(
              text: '🙏 Prêtre d’Astora\n\n',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  'Héroïque Mort-vivant, vous avez surmonté l’épreuve.\n'
                  'Recevez mes félicitations, et que la Flamme vous guide.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        Say(
          text: const [
            TextSpan(
              text: '\n🎖️ Votre destin vous attend.\n\n',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  'Quittez ce sanctuaire et poursuivez votre route.\n'
                  'Les ténèbres reculent devant votre volonté.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        Say(
          text: const [
            TextSpan(
              text: '\n🎖️ Votre prochain objectif.\n\n',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  'Faites sonner les deux cloches qui vous permettront d\'atteindre la cité des dieux.\n'
                  'Que la Première Flamme perdure...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
      onClose: () {
        dialogShown = true;
        dialogOpening = false;
      },
    );
  }

  @override
  void update(double dt) {
    if (isDead) return;
    super.update(dt);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    super.onReceiveDamage(attacker, damage, id);
    print('[Prêtre] Dégâts reçus : $damage | Vie restante : $life');
  }

  @override
  void onDie() {
    removeFromParent();
    super.onDie();
  }
}

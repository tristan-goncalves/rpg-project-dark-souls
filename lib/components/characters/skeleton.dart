import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../../util/skeleton_sprite_sheet.dart';

class Skeleton extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  static const double tileSize = 16;
  static const double visionRadius = tileSize * 6;
  static const double attackRange = tileSize * 1.2;
  static const double attackDamage = 15;
  static const double speedSkeleton = 40;
  static const double maxLifeSkeleton = 50;

  late final Vector2 spawnPosition;
  bool returningToSpawn = false;
  bool isAttacking = false;

  Skeleton(Vector2 position, {double hpMultiplier = 1.0})
      : super(
          position: position,
          size: Vector2.all(32),
          speed: speedSkeleton,
          animation: SkeletonSpriteSheet.skeletonAnimations(),
          life: maxLifeSkeleton * hpMultiplier,
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
    print('[Skeleton] Vie initiale : $maxLifeSkeleton');
  }

  @override
  void update(double dt) {
    if (isDead) return;

    if (returningToSpawn) {
      moveBackToSpawn();
      super.update(dt);
      return;
    }

    seeAndMoveToPlayer(
      radiusVision: visionRadius,
      closePlayer: (player) {
        attackPlayer(player);
        return true;
      },
      notObserved: () {
        startReturnToSpawn();
        return true;
      },
    );

    super.update(dt);
  }

  void attackPlayer(GameComponent player) async {
    if (isAttacking || isDead) return;

    final distance = position.distanceTo(player.position);
    if (distance > attackRange) return;

    isAttacking = true;

    simpleAttackMelee(
      damage: attackDamage,
      size: Vector2(16, 16),
      animationRight: SkeletonSpriteSheet.attackRight(),
      withPush: false,
      id: 1,
    );

    Future.delayed(const Duration(milliseconds: 10), () {
      isAttacking = false;
    });
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    super.onReceiveDamage(attacker, damage, id);
    print('[Skeleton] Dégâts reçus : $damage | Vie restante : $life');
  }

  @override
  void onDie() {
    print('[Skeleton] Mort du squelette.');
    removeFromParent();
    super.onDie();
  }

  void startReturnToSpawn() {
    if (returningToSpawn) return;
    final distance = position.distanceTo(spawnPosition);
    if (distance <= 20.0) {
      stopMove();
      idle();
      return;
    }
    returningToSpawn = true;
    moveToPosition(spawnPosition);
  }

  void moveBackToSpawn() {
    final distance = position.distanceTo(spawnPosition);
    if (distance <= 20.0) {
      stopMove();
      idle();
      returningToSpawn = false;
      return;
    }
    moveToPosition(spawnPosition);
  }
}


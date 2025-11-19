import 'dart:math' as math;
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../../util/boss_sprite_sheet.dart';
import '../../services/audio_controller.dart';

// États: idle (rien), volley (pattern de boules de feu), charging (charge AoE en cercle).
enum BossState { idle, volley, charging }

class Boss extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  static const double tileSize = 112;
  static const double visionRadius = tileSize * 6;

  static const double nearDistance = tileSize * 0.5; // Distance nécessaire pour déclencher la charge

  // Dégâts & vitesses
  static const double meleeDamage = 15;
  static const double aoeDamage = 25;
  static const double rangeDamage = 8;
  static const double rangeSpeed = 25; // px/s des boules de feu

  static const double speedBoss = 0;
  static const double maxLifeBoss = 500;

  // Temps nécessaire à l'activation de la charge du boss (2s) en fonction de si le joueur est près de lui
  static const double needCloseFor = 2.0;
  static const double chargeDuration = 5.0; // charge pendant 5s avant l'AoE
  static const double volleyCooldown = 8.0; // 8 s de cooldown entre deux jets de boules de feu

  late final Vector2 spawnPosition;

  BossState state = BossState.idle;
  double nearTimer = 0.0;
  double chargeTimer = 0.0;
  double volleyTimer = 0.0;
  bool isAttacking = false;

  // FX AoE (procéduraux)
  ShapeComponent? ring;
  double aoeMaxRadius = 120; // rayon maximum de l'AoE (visuel & dégâts)
  double aoeMinRadius = 24;  // rayon de départ de l'AoE

  // On cache les animations pour éviter les Futures pendant la salve de boule de feu
  late SpriteAnimation animFireball;
  late SpriteAnimation animFireballDestroy;

  Boss(Vector2 position, {double hpMultiplier = 1.0})
      : super(
          position: position,
          size: Vector2.all(112),
          speed: speedBoss,
          animation: BossSpriteSheet.bossAnimations(),
          life: maxLifeBoss * hpMultiplier,
        ) {
    anchor = Anchor.center;

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

    add(RectangleHitbox(
      anchor: Anchor.center,
      size: Vector2(64, 64),
      position: Vector2(50, 50),
    ));

    // Précharge les animations des boules de feu
    animFireball = await BossSpriteSheet.fireball();
    animFireballDestroy = await BossSpriteSheet.fireballDestroy();
  }

  @override
  void update(double dt) {
    if (isDead) return;

    final player = gameRef.player;
    if (player == null) return;

    // On démarre le cooldown lorsque le boss a terminé son attaque de boules de feu
    if (volleyTimer > 0) {
      volleyTimer -= dt;
      if (volleyTimer < 0) volleyTimer = 0;
    }

    final dist = center.distanceTo(player.center);

    switch (state) {
      case BossState.charging:
        chargeTimer += dt;
        showChargeTelegraph(progress: (chargeTimer / chargeDuration).clamp(0, 1));
        if (chargeTimer >= chargeDuration) {
          chargeTimer = 0;
          doAoe();
          nearTimer = 0;
          state = BossState.idle;
        }
        break;

      case BossState.volley:
        break;

      case BossState.idle:
        if (dist > visionRadius) {
          nearTimer = 0;
        } else if (dist <= nearDistance) {
          // Si le joueur est proche du boss : on démarre l'animation de charge
          nearTimer += dt;
          if (nearTimer >= needCloseFor) {
            startCharge();
          }
        } else {
          // Si le joueur en vue mais pas "near" : on tente les boules de feu si le cooldown est terminé
          if (volleyTimer <= 0 && !isAttacking) {
            state = BossState.volley;
            startRadialBarrage();
          }
        }
        break;
    }

    // Le boss ne bouge pas
    stopMove();
    if (state == BossState.idle) {
      idle();
    }

    // On bloque le boss à chaque attaque du joueur, afin qu'il ne soit pas décalé de sa position initiale
    if ((center - spawnPosition).length2 > 0.0001) {
      center = spawnPosition.clone();
    }

    super.update(dt);
  }

  // ----------------- ATTAQUE À DISTANCE : BARRAGE RADIAL (Les boules de feu) -----------------

  // Barrage radial pendant 5 secondes, une vague toutes les 0.5 s,
  // avec des "trous" pour laisser des zones safe au joueur.
  Future<void> startRadialBarrage() async {
    if (isAttacking || isDead) return;
    isAttacking = true;

    animation?.playOther('distance'); // Sprite d'animation d'attaque à distance

    const double duration = 5.0;
    const double waveInterval = 0.5;
    const int dirsPerWave = 10;
    const int gapEvery = 3;
    // On éloigne le spawn des boules de feu depuis le centre du boss pour éviter une collision immédiate avec la hitbox du boss
    const double spawnOffset = 56 + 12 + 4;

    double elapsed = 0.0;

    while (elapsed < duration && !isDead) {
      const double rotation = 0;

      for (int j = 0; j < dirsPerWave; j++) {
        if (j % gapEvery == 0) continue; // laisse un trou dans la salve

        final double shotAngle = rotation + (2 * math.pi) * (j / dirsPerWave);

        // Orientation instantanée et éloignement du point de spawn des boules de feu
        final Vector2 oldCenter = center.clone();
        final double oldAngle = angle;

        angle = shotAngle;
        final Vector2 forward = Vector2(math.cos(shotAngle), math.sin(shotAngle));
        center = oldCenter + forward * spawnOffset;

        simpleAttackRange(
          animation: Future.value(animFireball),
          animationDestroy: Future.value(animFireballDestroy),
          size: Vector2(24, 24),
          speed: rangeSpeed,
          damage: rangeDamage,
          useAngle: true,
          interval: 0, // Permet de tirer plusieurs projectiles à la fois
          withCollision: true,
          id: 2000 + j, // id unique pour chaque projectile
          collision: RectangleHitbox(
            size: Vector2(10, 10),
            anchor: Anchor.center,
          ),
        );

        // Restaure la position et l'angle du boss
        center = oldCenter;
        angle = oldAngle;
      }

      // Attente entre deux vagues
      await Future.delayed(const Duration(milliseconds: 500));
      elapsed += waveInterval;
    }

    // Fin du barrage : cooldown de 8 s puis retour idle
    isAttacking = false;
    volleyTimer = volleyCooldown;

    animation?.play(SimpleAnimationEnum.idleRight); // retour à l'animation idle
    state = BossState.idle;
  }

  // ----------------- CHARGE & AOE -----------------

  void startCharge() {
    state = BossState.charging;
    chargeTimer = 0;

    animation?.playOther('aoe'); // Sprite d'animation de charge AoE

    spawnChargeTelegraph();
  }

  // AoE finale (Cercle violet -> flash blanc)
  void doAoe() {
    // Dégâts en zone : diamètre = 1.8 * rayon final
    final diameter = aoeMaxRadius * 1.8;
    simpleAttackMelee(
      damage: aoeDamage,
      size: Vector2.all(diameter),
      withPush: false,
    );

    // Flash blanc
    final flash = CircleComponent(
      radius: aoeMaxRadius,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = Colors.white.withOpacity(0.9),
      anchor: Anchor.center,
      position: center.clone(),
      priority: 9999,
    );
    gameRef.add(flash);

    Future.delayed(const Duration(milliseconds: 80), () {
      flash.paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.white.withOpacity(0.4);
    });
    Future.delayed(const Duration(milliseconds: 160), () {
      flash.removeFromParent();
    });

    // On efface le cercle
    clearChargeTelegraph();

    animation?.play(SimpleAnimationEnum.idleRight); // retour à l'animation idle
  }


  //  Le CERCLE de l'AoE
  void spawnChargeTelegraph() {
    ring = CircleComponent(
      radius: aoeMinRadius,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF9C27B0).withOpacity(0.6),
      anchor: Anchor.center,
      position: center.clone(),
      priority: 9998,
    );
    if (ring != null) gameRef.add(ring!);
  }

  // Grandi petit à petit durant la charge (5s)
  void showChargeTelegraph({required double progress}) {
    final _ring = ring;
    if (_ring == null) return;

    final radius = aoeMinRadius + (aoeMaxRadius - aoeMinRadius) * progress;
    _ring
      ..position = center.clone()
      ..size = Vector2.all(radius * 2);

    final start = const Color(0xFF9C27B0);
    final end = const Color(0xFFF8BBD0);
    final c = Color.lerp(start, end, progress)!;
    final stroke = 3 + 6 * progress;

    _ring.paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = c.withOpacity(0.7);
  }

  void clearChargeTelegraph() {
    ring?.removeFromParent();
    ring = null;
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    velocity = Vector2.zero(); // Le boss ne prend pas de recul comme les autres ennemis
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    AudioController.I.fadeOutBgm();
    clearChargeTelegraph();
    removeFromParent();
    super.onDie();
  }
}

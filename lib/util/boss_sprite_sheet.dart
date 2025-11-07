import 'package:bonfire/bonfire.dart';

/// SpriteSheet du Boss : gère les animations d’attente et de course.
class BossSpriteSheet {
  static Future<SpriteAnimation> idleRight() => SpriteAnimation.load(
        'enemies/boss_idle.png',
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.15,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> idleLeft() => SpriteAnimation.load(
        'enemies/boss_idle.png',
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.15,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> runRight() => SpriteAnimation.load(
        'enemies/boss_idle.png',
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.10,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> runLeft() => SpriteAnimation.load(
        'enemies/boss_idle.png',
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.10,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> attackRight() => SpriteAnimation.load(
        'enemies/attack_effect_right.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(100, 100),
        ),
      );

  /// Assemblage global pour Bonfire
  static SimpleDirectionAnimation bossAnimations() => SimpleDirectionAnimation(
        idleRight: idleRight(),
        idleLeft: idleLeft(),
        runRight: runRight(),
        runLeft: runLeft(),
        others: {
          'distance': distanceAttack(),
          'aoe': aoeAttack(),
        },
      );

  // Projectile du boss (on réutilise l’anim fireball du player).
  static Future<SpriteAnimation> fireball() => SpriteAnimation.load(
        'player/fireball_right.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(23, 23),
        ),
      );

  static Future<SpriteAnimation> distanceAttack() => SpriteAnimation.load(
        'enemies/boss_distance_attack.png',
        SpriteAnimationData.sequenced(
          amount: 9,
          stepTime: 0.12,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> aoeAttack() => SpriteAnimation.load(
        'enemies/boss_aoe_attack.png',
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.12,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> fireballDestroy() => fireball();
}

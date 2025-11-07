import 'package:bonfire/bonfire.dart';

/// SpriteSheet du Squelette : gère les animations d’attente et de course.
class SkeletonSpriteSheet {
  static Future<SpriteAnimation> idleRight() => SpriteAnimation.load(
        'enemies/skeleton_idle.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(32, 32),
        ),
      );

  static Future<SpriteAnimation> idleLeft() => SpriteAnimation.load(
        'enemies/skeleton_idle_left.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(32, 32),
        ),
      );

  static Future<SpriteAnimation> runRight() => SpriteAnimation.load(
        'enemies/skeleton_run.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.10,
          textureSize: Vector2(32, 32),
        ),
      );

  static Future<SpriteAnimation> runLeft() => SpriteAnimation.load(
        'enemies/skeleton_run_left.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.10,
          textureSize: Vector2(32, 32),
        ),
      );
  
  static Future<SpriteAnimation> attackRight() => SpriteAnimation.load(
    'enemies/attack_effect_right.png',
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2(32, 32),
    ),
  );

  /// Assemblage global pour Bonfire
  static SimpleDirectionAnimation skeletonAnimations() =>
      SimpleDirectionAnimation(
        idleRight: idleRight(),
        idleLeft: idleLeft(),
        runRight: runRight(),
        runLeft: runLeft(),
      );
}




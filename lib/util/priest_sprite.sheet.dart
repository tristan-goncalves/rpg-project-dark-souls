import 'package:bonfire/bonfire.dart';

/// SpriteSheet du Prêtre : gère les animations d’attente et de course.
class PriestSpriteSheet {
  static Future<SpriteAnimation> idleRight() => SpriteAnimation.load(
        'enemies/priest_idle.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> idleLeft() => SpriteAnimation.load(
        'enemies/priest_idle_left.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> runRight() => SpriteAnimation.load(
        'enemies/priest_idle.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.10,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> runLeft() => SpriteAnimation.load(
        'enemies/priest_idle_left.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.10,
          textureSize: Vector2(16, 16),
        ),
      );
  
  static Future<SpriteAnimation> attackRight() => SpriteAnimation.load(
    'enemies/attack_effect_right.png',
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2(16, 16),
    ),
  );

  /// Assemblage global pour Bonfire
  static SimpleDirectionAnimation priestAnimations() =>
      SimpleDirectionAnimation(
        idleRight: idleRight(),
        idleLeft: idleLeft(),
        runRight: runRight(),
        runLeft: runLeft(),
      );
}




import 'package:bonfire/bonfire.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'audio_controller.dart';

class TeleportZone extends GameDecoration {
  final VoidCallback onTeleport;
  final bool oneShot;
  final bool debugPaint_;
  final Color fadeColor;
  final Duration fadeDuration;
  final String? sfxKey;
  final String? sfxPath;
  final double sfxVolume;
  final Duration delayBeforeTeleport;

  bool triggered = false;

  TeleportZone.rect({
    required Vector2 position,
    required Vector2 size,
    required this.onTeleport,
    this.oneShot = true,
    this.debugPaint_ = false,
    this.fadeColor = const Color(0xCC000000),
    this.fadeDuration = const Duration(milliseconds: 600),
    this.sfxKey,
    this.sfxPath,
    this.sfxVolume = 1.0,
    this.delayBeforeTeleport = Duration.zero,
    Sprite? sprite,
  }) : super(position: position, size: size, sprite: sprite);

  factory TeleportZone.tile({
    required int tx,
    required int ty,
    required VoidCallback onTeleport,
    int tileSize = 16,
    bool oneShot = true,
    bool debugPaint = false,
    Color fadeColor = const Color(0xCC000000),
    Duration fadeDuration = const Duration(milliseconds: 300),
    String? sfxKey,
    String? sfxPath,
    double sfxVolume = 1.0,
    Duration delayBeforeTeleport = Duration.zero,
    Sprite? sprite,
  }) {
    return TeleportZone.rect(
      position: Vector2(tx * tileSize.toDouble(), ty * tileSize.toDouble()),
      size: Vector2.all(tileSize.toDouble()),
      onTeleport: onTeleport,
      oneShot: oneShot,
      debugPaint_: debugPaint,
      fadeColor: fadeColor,
      fadeDuration: fadeDuration,
      sfxKey: sfxKey,
      sfxPath: sfxPath,
      sfxVolume: sfxVolume,
      delayBeforeTeleport: delayBeforeTeleport,
      sprite: sprite,
    );
  }

  factory TeleportZone.tileRect({
    required int tx,
    required int ty,
    required int w,
    required int h,
    required VoidCallback onTeleport,
    int tileSize = 16,
    bool oneShot = true,
    bool debugPaint = false,
    Color fadeColor = const Color(0xCC000000),
    Duration fadeDuration = const Duration(milliseconds: 600),
    String? sfxKey,
    String? sfxPath,
    double sfxVolume = 1.0,
    Duration delayBeforeTeleport = Duration.zero,
    Sprite? sprite,
  }) {
    return TeleportZone.rect(
      position: Vector2(tx * tileSize.toDouble(), ty * tileSize.toDouble()),
      size: Vector2(w * tileSize.toDouble(), h * tileSize.toDouble()),
      onTeleport: onTeleport,
      oneShot: oneShot,
      debugPaint_: debugPaint,
      fadeColor: fadeColor,
      fadeDuration: fadeDuration,
      sfxKey: sfxKey,
      sfxPath: sfxPath,
      sfxVolume: sfxVolume,
      delayBeforeTeleport: delayBeforeTeleport,
      sprite: sprite,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (sfxPath != null) {
      try {
        await FlameAudio.audioCache.load(sfxPath!);
      } catch (_) {
        debugPrint('[TeleportZone] Impossible de précharger $sfxPath');
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (triggered) return;

    final player = gameRef.player;
    if (player == null) return;

    if (toRect().overlaps(player.toRect())) {
      triggered = true;

      if (delayBeforeTeleport > Duration.zero) {
        Future.delayed(delayBeforeTeleport, playSfxAndActivate);
      } else {
        playSfxAndActivate();
      }
    }
  }

  Future<void> playSfxAndActivate() async {
    if (sfxKey != null) {
      AudioController.I.playSfx('darksouls_fog_sound.mp3', volume: sfxVolume);
    } else if (sfxPath != null) {
      await AudioController.I.playSfx(sfxPath!, volume: sfxVolume);
    }
    await activateTeleport();
  }

  Future<void> activateTeleport() async {
    gameRef.add(
      RectangleComponent(
        size: gameRef.size,
        paint: Paint()..color = fadeColor,
        priority: 9999,
      ),
    );

    await Future.delayed(fadeDuration);
    onTeleport();

    if (!oneShot) {
      await Future.delayed(const Duration(milliseconds: 300));
      triggered = false;
    } else {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (debugPaint_) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.purpleAccent.withOpacity(0.9);
      canvas.drawRect(Offset.zero & size.toSize(), p);
    }
  }
}

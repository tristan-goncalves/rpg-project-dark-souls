import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rpg_game_project/components/ui/back_button_widget.dart';
import 'package:rpg_game_project/util/game_session.dart';
import '../components/characters/skeleton.dart';
import '../components/characters/boss.dart';
import '../components/characters/knight.dart';
import '../components/characters/priest.dart';
import '../services/teleport_controller.dart';
import '../components/game-items/treasure_chest.dart';
import '../services/audios/boss_music_controller.dart';
import '../services/audios/victory_music_controller.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController fadeController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double tileSize = 16.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MapNavigator(
        initialMap: '/map1',
        maps: {
          '/map1': (context, args) => MapItem(
                id: '/map1',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled3/map1_dungeon.json'),
                ),
                properties: {
                  'player_position': Vector2(tileSize * 27, tileSize * 46),
                },
              ),
          '/map2': (context, args) => MapItem(
                id: '/map2',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled4/map_dungeon_2.json'),
                ),
                properties: {
                  'player_position': Vector2(tileSize * 24, tileSize * 47),
                },
              ),
          '/map3': (context, args) => MapItem(
                id: '/map3',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled5/map_dungeon_3.json'),
                ),
                properties: {
                  'player_position': Vector2(tileSize * 24, tileSize * 47),
                },
              ),
          '/map4': (context, args) => MapItem(
                id: '/map4',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled6/map_dungeon_4.json'),
                ),
                properties: {
                  'player_position': Vector2(tileSize * 23, tileSize * 47),
                },
              ),
        },
        builder: (context, arguments, map) {
          final id = map.id;
          final components = <GameComponent>[];

          if (id == '/map1') {
            components.addAll([
              TeleportZone.tileRect(
                tx: 23,
                ty: 21,
                w: 1,
                h: 1,
                onTeleport: () {
                  MapNavigator.of(context).toNamed('/map2');
                },
                sfxPath: 'darksouls_fog_sound.mp3',
                sfxVolume: 0.1,
                fadeDuration: const Duration(milliseconds: 5000),
                delayBeforeTeleport: const Duration(milliseconds: 500),
              ),
              Skeleton(Vector2(tileSize * 22, tileSize * 31)),
              Skeleton(Vector2(tileSize * 24, tileSize * 24)),
            ]);
          } else if (id == '/map2') {
            components.addAll([
              TeleportZone.tileRect(
                tx: 32,
                ty: 36,
                w: 2,
                h: 1,
                onTeleport: () => MapNavigator.of(context).toNamed('/map3'),
              ),
              TeleportZone.tileRect(
                tx: 23,
                ty: 49,
                w: 4,
                h: 1,
                onTeleport: () => MapNavigator.of(context).toNamed('/map1'),
              ),
              TreasureChest(Vector2(tileSize * 19, tileSize * 40)),
            ]);
          }
          else if (id == '/map3') {
            components.addAll([
              TeleportZone.tileRect(
                tx: 24,
                ty: 49,
                w: 2,
                h: 1,
                onTeleport: () => MapNavigator.of(context).toNamed('/map2'),
              ),
              TeleportZone.tileRect(
                tx: 24,
                ty: 32,
                w: 2,
                h: 1,
                onTeleport: () {
                  MapNavigator.of(context).toNamed('/map4');
                },
                sfxPath: 'darksouls_fog_sound.mp3',
                sfxVolume: 0.1,
                fadeDuration: const Duration(milliseconds:4000),
                delayBeforeTeleport: const Duration(milliseconds: 500),
              ),
              BossMusicController(),
              Boss(Vector2(tileSize * 24, tileSize * 36)),
            ]);
          }
          else if (id == '/map4') {
            components.addAll([
              TeleportZone.tileRect(
                tx: 22,
                ty: 49,
                w: 5,
                h: 1,
                onTeleport: () => MapNavigator.of(context).toNamed('/map3'),
              ),
              VictoryMusicController(),
              Priest(Vector2(tileSize * 24, tileSize * 32)),
            ]);
          }

          return Stack(
            children: [
              FadeTransition(
                opacity: fadeController,
                child: BonfireWidget(
                  map: map.map,
                  player: Knight(map.properties['player_position'], initialLife: GameSession.I.life),
                  components: components,
                  playerControllers: [
                    Joystick(
                      directional: JoystickDirectional(
                        size: 100,
                        isFixed: true,
                        margin: const EdgeInsets.only(left: 30, bottom: 30),
                        color: Colors.white.withOpacity(0.25),
                      ),
                      actions: [
                        JoystickAction(
                          actionId: 0,
                          size: 60,
                          color: Colors.redAccent.withOpacity(0.8),
                          alignment: Alignment.bottomRight,
                          margin: const EdgeInsets.only(right: 60, bottom: 40),
                        ),
                        JoystickAction(
                          actionId: 1,
                          size: 50,
                          color: Colors.orangeAccent.withOpacity(0.8),
                          alignment: Alignment.bottomRight,
                          margin: const EdgeInsets.only(right: 20, bottom: 100),
                        ),
                        JoystickAction(
                          actionId: 2,
                          size: 55,
                          color: const Color.fromARGB(255, 255, 249, 64),
                          opacityBackground: 0.85,
                          opacityKnob: 1.0,
                          sprite: Sprite.load('items/fiole_estus.png'),
                          alignment: Alignment.bottomRight,
                          margin: const EdgeInsets.only(right: 120, bottom: 100),
                        ),
                      ],
                    ),
                  ],
                  cameraConfig: CameraConfig(
                    moveOnlyMapArea: true,
                    zoom: getZoomFromMaxVisibleTile(context, tileSize, 25),
                  ),
                  backgroundColor: Colors.black,
                  onReady: (game) async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    fadeController.forward();

                    if (map.id == '/map1') {
                      TalkDialog.show(
                        context,
                        [
                          Say(
                            text: const [
                              TextSpan(
                                text: '🌑 Vous reprenez conscience...\n\n',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'Dans ce lieu sombre et humide, les murmures du passé résonnent encore. '
                                    'La Flamme s’éteint peu à peu, et les Âmes sombrent dans l’oubli...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Say(
                            text: const [
                              TextSpan(
                                text: '\n🔥 La Première Flamme s’affaiblit.\n\n',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'Mais peut-être... qu’un mort-vivant ordinaire pourrait rallumer l’étincelle.\n'
                                    'Sortez de ce lieu maudit, et affrontez votre destinée.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                        onClose: () {
                        },
                      );
                    }
                  },
                ),
              ),
              const BackButtonWidget()
            ],
          );
        },
      ),
    );
  }
}





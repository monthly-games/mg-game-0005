import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/theme/game_theme.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'ui/main_menu_screen.dart';
import 'game/logic/meta_progression_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  runApp(const RoguelikeDungeonApp());
}

void _setupDI() {
  final goldManager = GoldManager();
  GetIt.I.registerSingleton<GoldManager>(goldManager);

  final audioManager = AudioManager();
  GetIt.I.registerSingleton<AudioManager>(audioManager);
  audioManager.initialize();

  final metaManager = MetaProgressionManager();
  GetIt.I.registerSingleton<MetaProgressionManager>(metaManager);
}

class RoguelikeDungeonApp extends StatelessWidget {
  const RoguelikeDungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roguelike Dungeon',
      theme: GameTheme.darkTheme,
      home: const MainMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

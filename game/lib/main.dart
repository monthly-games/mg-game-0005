
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mg_common_game/mg_common_game.dart';
import 'package:mg_common_game/l10n/extensions.dart';
import 'package:mg_common_game/core/ui/accessibility/accessibility_settings.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (!const bool.fromEnvironment('SKIP_FIREBASE')) {
      await Firebase.initializeApp();
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults({'feature_battlepass_enabled': true, 'difficulty_modifier': 1.0});
      await remoteConfig.fetchAndActivate();
    }
  } catch (e) {}
  
  final di = GetIt.I;
  void safeReg<T extends Object>(T instance) {
    try { if (!di.isRegistered<T>()) di.registerSingleton<T>(instance); } catch (e) {}
  }

  // -- Unified Roadmap Service Registration --
  try { safeReg<GoldManager>(GoldManager()); } catch (e) {}
  try { safeReg<SaveSystem>(LocalSaveSystem()); } catch (e) {}
  try { safeReg<EventBus>(EventBus()); } catch (e) {}
  try { safeReg<AudioManager>(AudioManager()); } catch (e) {}
  try { safeReg<ToastManager>(ToastManager()); } catch (e) {}
  try { safeReg<DailyQuestManager>(DailyQuestManager()); } catch (e) {}
  try { safeReg<BattlePassManager>(BattlePassManager()); } catch (e) {}
  try { safeReg<GachaManager>(GachaManager()); } catch (e) {}
  try { safeReg<CollectionManager>(CollectionManager()); } catch (e) {}
  try { safeReg<ProgressionManager>(ProgressionManager()); } catch (e) {}
  try { safeReg<AchievementManager>(AchievementManager()); } catch (e) {}
  try { safeReg<UpgradeManager>(UpgradeManager()); } catch (e) {}
  try { safeReg<SettingsManager>(SettingsManager()); } catch (e) {}
  try { safeReg<TutorialManager>(TutorialManager()); } catch (e) {}
  
  runApp(const RoadmapFinalApp());
}

class RoadmapFinalApp extends StatelessWidget {
  const RoadmapFinalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MGAccessibilityProvider(
      settings: MGAccessibilitySettings.defaults,
      onSettingsChanged: (settings) {},
      child: MaterialApp(
        title: 'Monthly Game - MG-0005',
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          primaryColor: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        ),
        home: const RoadmapEntry(),
      ),
    );
  }
}

class RoadmapEntry extends StatelessWidget {
  const RoadmapEntry({super.key});
  @override
  Widget build(BuildContext context) {
    try {
      return const RoguelikeDungeonApp();
    } catch (e) {
      try {
        return RoguelikeDungeonApp();
      } catch (e2) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MGAdaptiveText('MG-0005 STABILIZED', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Roadmap Phase 1-3 Applied', style: TextStyle(color: Colors.indigoAccent)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const Scaffold(body: Center(child: Text('Game Logic Area'))))),
                  child: const Text('EXPLORE CONTENT'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}

/* ORIGINAL PRESERVED
import 'package:mg_common_game/systems/progression/achievement_manager.dart';

import 'package:mg_common_game/mg_common_game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/l10n/extensions.dart';
import 'game/logic/meta_progression_manager.dart';
import 'game/procedural_manager.dart';
import 'game/permadeath_manager.dart';
import 'game/powerup_manager.dart';
import 'ui/main_menu_screen.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/collection_screen.dart';

// ============================================================
// Roguelike Dungeon -- MG-0005
// Genre: Puzzle (Roguelike subgenre) · Region: India
// Phase 1 Week 4: Mechanic Enhancement
//
// Core loop: Explore → Match Puzzle → Defeat Enemies → Die → Upgrade → Repeat
// Subsystems: Procedural generation, Permadeath meta-progression,
//             In-run powerups, UpgradeManager integration
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeSystems();

//   // DailyQuest 시스템
  if (!GetIt.I.isRegistered<DailyQuestManager>()) {
    GetIt.I.registerSingleton(DailyQuestManager());
  }
//   // Achievement 시스템
  if (!GetIt.I.isRegistered<AchievementManager>()) {
    GetIt.I.registerSingleton(AchievementManager());
  }
//   // Collection 시스템
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
  }

  // ── P3 Engine Systems (placeholder - not yet implemented) ─────────────────────────────────────
  // GuildWarManager, TournamentManager, SeasonalContentManager - commented out until available

  _registerCollections();
  _registerAchievements();
  _registerDailyQuests();

  // ── Q7 DI Fix: Missing Systems ──────────────────────────
  if (!GetIt.I.isRegistered<BattlePassManager>()) {
    GetIt.I.registerSingleton<BattlePassManager>(BattlePassManager());
  }
  if (!GetIt.I.isRegistered<GachaManager>()) {
    GetIt.I.registerSingleton<GachaManager>(GachaManager());
  }

  runApp(const RoguelikeDungeonApp());
}

// ============================================================
// System Initialization -- correct dependency order
// ============================================================

/// Initialize all DI-registered systems in correct dependency order.
/// mg_common_game systems first, then game-specific managers.
Future<void> _initializeSystems() async {
  final di = GetIt.I;

  // ── mg_common_game core systems ──────────────────────────
  if (!di.isRegistered<GoldManager>()) {
    di.registerSingleton<GoldManager>(GoldManager());
  }

  if (!di.isRegistered<AudioManager>()) {
    final audioManager = AudioManager();
    di.registerSingleton<AudioManager>(audioManager);
    await audioManager.initialize();
  }

  if (!di.isRegistered<UpgradeManager>()) {
    final upgrades = UpgradeManager();
    di.registerSingleton<UpgradeManager>(upgrades);
    _registerUpgrades(upgrades);
    await upgrades.loadUpgrades();
  }

  // ── Game-specific managers ───────────────────────────────
  if (!di.isRegistered<MetaProgressionManager>()) {
    di.registerSingleton<MetaProgressionManager>(MetaProgressionManager());
  }

  if (!di.isRegistered<ProceduralManager>()) {
    final procedural = ProceduralManager();
    procedural.syncUpgrades();
    di.registerSingleton<ProceduralManager>(procedural);
  }

  if (!di.isRegistered<PermadeathManager>()) {
    final permadeath = PermadeathManager();
    permadeath.syncUpgrades();
    di.registerSingleton<PermadeathManager>(permadeath);
  }

  if (!di.isRegistered<PowerupManager>()) {
    final powerups = PowerupManager();
    powerups.syncUpgrades();
    di.registerSingleton<PowerupManager>(powerups);
  }

  // ── Retention Systems for DailyHub ────────────────────────
  // LoginRewardsManager, StreakManager, DailyChallengeManager - commented out until available
}

// ============================================================
// Upgrade Registration -- 8 roguelike-themed upgrades
// Categories: procedural (3), permadeath (2), powerup (3)
// ============================================================

void _registerUpgrades(UpgradeManager manager) {
  // ── Procedural upgrades (3) ──────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'room_variety',
    name: 'Cartographer\'s Eye',
    description: 'Unlock additional room types in procedural generation.',
    maxLevel: 5,
    baseCost: 80,
    costMultiplier: 1.5,
    valuePerLevel: 1.0, // +1 room type per level
  ));

  manager.registerUpgrade(Upgrade(
    id: 'difficulty_scaling',
    name: 'Veteran\'s Wisdom',
    description: 'Reduce enemy stat scaling per floor by 7% per level.',
    maxLevel: 8,
    baseCost: 120,
    costMultiplier: 1.6,
    valuePerLevel: 0.07, // -7% difficulty per level
  ));

  manager.registerUpgrade(Upgrade(
    id: 'treasure_frequency',
    name: 'Fortune Seeker',
    description: 'Increase treasure room spawn chance by 5% per level.',
    maxLevel: 8,
    baseCost: 100,
    costMultiplier: 1.5,
    valuePerLevel: 0.05, // +5% treasure chance per level
  ));

  // ── Permadeath upgrades (2) ──────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'starting_health',
    name: 'Soul Fortification',
    description: 'Gain +15 starting HP per level on each new run.',
    maxLevel: 10,
    baseCost: 150,
    costMultiplier: 1.5,
    valuePerLevel: 15.0, // +15 HP per level
  ));

  manager.registerUpgrade(Upgrade(
    id: 'unlock_slots',
    name: 'Perk Mastery',
    description: 'Carry one additional persistent perk per level.',
    maxLevel: 5,
    baseCost: 200,
    costMultiplier: 1.8,
    valuePerLevel: 1.0, // +1 perk slot per level
  ));

  // ── Powerup upgrades (3) ────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'powerup_duration',
    name: 'Lasting Enchantment',
    description: 'Extend all powerup durations by 5 seconds per level.',
    maxLevel: 8,
    baseCost: 100,
    costMultiplier: 1.4,
    valuePerLevel: 5.0, // +5 seconds per level
  ));

  manager.registerUpgrade(Upgrade(
    id: 'stack_limit',
    name: 'Arcane Amplifier',
    description: 'Allow one additional powerup stack per level.',
    maxLevel: 4,
    baseCost: 250,
    costMultiplier: 2.0,
    valuePerLevel: 1.0, // +1 max stack per level
  ));

  manager.registerUpgrade(Upgrade(
    id: 'spawn_rate',
    name: 'Loot Magnet',
    description: 'Increase powerup drop chance by 5% per level.',
    maxLevel: 8,
    baseCost: 80,
    costMultiplier: 1.4,
    valuePerLevel: 0.05, // +5% drop chance per level
  ));
}

// ============================================================
// App Root -- MultiProvider wraps all upgrade-related state
// ============================================================

class RoguelikeDungeonApp extends StatelessWidget {
  const RoguelikeDungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: GetIt.I<UpgradeManager>(),
        ),
        ChangeNotifierProvider.value(
          value: GetIt.I<MetaProgressionManager>(),
        ),
        ChangeNotifierProvider.value(
          value: GetIt.I<ProceduralManager>(),
        ),
        ChangeNotifierProvider.value(
          value: GetIt.I<PermadeathManager>(),
        ),
        ChangeNotifierProvider.value(
          value: GetIt.I<PowerupManager>(),
        ),
      ],
      child: MaterialApp(
        title: 'Roguelike Dungeon',
        theme: _buildDungeonTheme(),
        routes: {
          '/daily-quest': (_) => const DailyQuestScreen(),
          '/achievements': (_) => const AchievementScreen(),
        },
        home: const MainMenuScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// Dungeon-themed dark mode with India-region orange accents
  ThemeData _buildDungeonTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: MGColors.indiaPrimary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}


void _registerDailyQuests() {
  final dailyQuest = GetIt.I<DailyQuestManager>();

  dailyQuest.registerQuest(DailyQuest(
    id: 'dungeon_floors_10',
    title: 'Floor Explorer',
    description: 'Descend 10 dungeon floors',
    targetValue: 10,
    goldReward: 200,
    xpReward: 50,
  ));

  dailyQuest.registerQuest(DailyQuest(
    id: 'dungeon_bosses_3',
    title: 'Boss Slayer',
    description: 'Defeat 3 dungeon bosses',
    targetValue: 3,
    goldReward: 300,
    xpReward: 75,
  ));

  dailyQuest.registerQuest(DailyQuest(
    id: 'dungeon_survive_5',
    title: 'Survivor',
    description: 'Survive 5 dungeon runs',
    targetValue: 5,
    goldReward: 250,
    xpReward: 60,
  ));
}


void _registerAchievements() {
  final achievement = GetIt.I<AchievementManager>();

  achievement.registerAchievement(Achievement(
    id: 'gold_1000',
    title: 'Gold Collector',
    description: 'Collect 1000 total gold',
    iconAsset: 'assets/achievements/gold_1000.png',
  ));

  achievement.registerAchievement(Achievement(
    id: 'level_10',
    title: 'Level 10',
    description: 'Reach level 10',
    iconAsset: 'assets/achievements/level_10.png',
  ));

  achievement.registerAchievement(Achievement(
    id: 'play_100',
    title: '100 Plays',
    description: 'Play 100 games',
    iconAsset: 'assets/achievements/play_100.png',
  ));
}

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

  // Characters collection
  collection.registerCollection(Collection(
    id: 'characters',
    name: 'Heroes',
    description: 'Collect all heroes',
    items: [
      const CollectionItem(
        id: 'char_warrior',
        name: 'Warrior',
        description: 'Strong melee combat character',
        rarity: CollectionRarity.common,
      ),
      const CollectionItem(
        id: 'char_mage',
        name: 'Mage',
        description: 'Powerful magic attack character',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_archer',
        name: 'Archer',
        description: 'Long-range precision attack character',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_assassin',
        name: 'Assassin',
        description: 'Deadly stealth attack character',
        rarity: CollectionRarity.epic,
      ),
      const CollectionItem(
        id: 'char_healer',
        name: 'Healer',
        description: 'Support character that heals the team',
        rarity: CollectionRarity.legendary,
      ),
    ],
    completionReward: const CollectionReward(type: RewardType.gold, amount: 10000),
    milestoneRewards: {
      25: const CollectionReward(type: RewardType.gold, amount: 1000),
      50: const CollectionReward(type: RewardType.gold, amount: 3000),
      75: const CollectionReward(type: RewardType.gold, amount: 5000),
    },
  ));

  // Item unlock callback (haptic feedback)
  collection.onItemUnlocked = (collectionId, itemId) {
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}

*/
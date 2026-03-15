import 'package:mg_common_game/mg_common_game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'game/logic/meta_progression_manager.dart';
import 'game/procedural_manager.dart';
import 'game/permadeath_manager.dart';
import 'game/powerup_manager.dart';
import 'ui/main_menu_screen.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/collection_screen.dart';

// ============================================================
// Roguelike Dungeon — MG-0005
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
  // DailyQuest 시스템
  GetIt.I.registerSingleton(DailyQuestManager());
  // Achievement 시스템
  GetIt.I.registerSingleton(AchievementManager());
  // Collection 시스템
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
  // ── P3 Engine Systems ─────────────────────────────────────
  if (!GetIt.I.isRegistered<GuildWarManager>()) {
    GetIt.I.registerSingleton(GuildWarManager());
  }
  if (!GetIt.I.isRegistered<TournamentManager>()) {
    GetIt.I.registerSingleton(TournamentManager());
  }
  if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
    GetIt.I.registerSingleton(SeasonalContentManager());
  }
_registerCollections();
  }
  _registerAchievements();
  _registerDailyQuests();
  runApp(const RoguelikeDungeonApp());
}

// ============================================================
// System Initialization — correct dependency order
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
    audioManager.initialize();
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
  // ── Retention Systems for DailyHub ────────────────────────
  if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
    GetIt.I.registerSingleton(LoginRewardsManager());
  }
  if (!GetIt.I.isRegistered<StreakManager>()) {
    GetIt.I.registerSingleton(StreakManager());
  }
  if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
    GetIt.I.registerSingleton(DailyChallengeManager());
  }
  }
}

// ============================================================
// Upgrade Registration — 8 roguelike-themed upgrades
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
// App Root — MultiProvider wraps all upgrade-related state
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
        '/daily-hub': (context) => DailyHubScreen(
          questManager: GetIt.I<DailyQuestManager>(),
          loginRewardsManager: GetIt.I<LoginRewardsManager>(),
          streakManager: GetIt.I<StreakManager>(),
          challengeManager: GetIt.I<DailyChallengeManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
        ),
        
          '/collection': (context) => CollectionScreen(
            collectionManager: GetIt.I<CollectionManager>(),
          ),
          '/guild-war': (context) => GuildWarScreen(
            guildWarManager: GetIt.I<GuildWarManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
          '/tournament': (context) => TournamentScreen(
            tournamentManager: GetIt.I<TournamentManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
          '/seasonal-event': (context) => SeasonalEventScreen(
            seasonalContentManager: GetIt.I<SeasonalContentManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
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
    id: 'collect_gold',
    title: '골드 모으기',
    description: '골드 1000 획득',
    targetValue: 1000,
    goldReward: 500,
    xpReward: 10,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'play_games',
    title: '게임 플레이',
    description: '게임 5판 플레이',
    targetValue: 5,
    goldReward: 300,
    xpReward: 5,
  ));
  
  dailyQuest.registerQuest(DailyQuest(
    id: 'level_up',
    title: '레벨업',
    description: '레벨 1 상승',
    targetValue: 1,
    goldReward: 200,
    xpReward: 3,
  ));
}


void _registerAchievements() {
  final achievement = GetIt.I<AchievementManager>();
  
  achievement.registerAchievement(Achievement(
    id: 'gold_1000',
    title: '골드 1000 달성',
    description: '총 골드 1000을 모으세요',
    iconAsset: 'assets/achievements/gold_1000.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'level_10',
    title: '레벨 10 달성',
    description: '레벨 10에 도달하세요',
    iconAsset: 'assets/achievements/level_10.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'play_100',
    title: '100판 플레이',
    description: '게임을 100판 플레이하세요',
    iconAsset: 'assets/achievements/play_100.png',
  ));
}

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

  // Characters 컬렉션
  collection.registerCollection(Collection(
    id: 'characters',
    name: '캐릭터',
    description: '모든 캐릭터를 수집하세요',
    items: [
      const CollectionItem(
        id: 'char_warrior',
        name: '전사',
        description: '강인한 근접 전투 캐릭터',
        rarity: CollectionRarity.common,
      ),
      const CollectionItem(
        id: 'char_mage',
        name: '마법사',
        description: '강력한 마법 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_archer',
        name: '궁수',
        description: '원거리 정밀 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_assassin',
        name: '암살자',
        description: '치명적인 은신 공격 캐릭터',
        rarity: CollectionRarity.epic,
      ),
      const CollectionItem(
        id: 'char_healer',
        name: '힐러',
        description: '팀을 치유하는 지원 캐릭터',
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

  // 아이템 해제 콜백 (햅틱 피드백)
  collection.onItemUnlocked = (collectionId, itemId) {
    // SettingsManager가 등록되어 있으면 햅틱 피드백
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}

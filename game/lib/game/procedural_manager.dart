import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// ProceduralManager -- MG-0005 Roguelike Dungeon
// Handles procedural level generation, difficulty scaling,
// and room variety for dungeon floors.
// ============================================================

/// Room types that can appear in procedurally generated dungeons.
enum RoomType {
  combat,
  treasure,
  trap,
  rest,
  elite,
  mystery,
  shop,
  boss,
}

/// Configuration for a single dungeon room.
class RoomConfig {
  final RoomType type;
  final int difficulty;
  final double treasureMultiplier;
  final String displayName;

  const RoomConfig({
    required this.type,
    required this.difficulty,
    required this.treasureMultiplier,
    required this.displayName,
  });
}

/// Manages procedural dungeon generation driven by UpgradeManager values.
///
/// Upgrade effects:
/// - `room_variety`: Unlocks additional room types per level
/// - `difficulty_scaling`: Reduces enemy stat scaling per floor
/// - `treasure_frequency`: Increases chance of treasure rooms
class ProceduralManager extends ChangeNotifier {

  // ── Base constants ───────────────────────────────────────
  static const int kBaseRoomTypeCount = 3;
  static final int kMaxRoomTypes = RoomType.values.length;
  static const double kBaseDifficultyPerFloor = 1.0;
  static const double kMinDifficultyPerFloor = 0.3;
  static const double kBaseTreasureChance = 0.10;
  static const double kMaxTreasureChance = 0.50;

  // ── Cached upgrade values ────────────────────────────────
  int _roomVarietyLevel = 0;
  int _difficultyScalingLevel = 0;
  int _treasureFrequencyLevel = 0;

  // ── State ────────────────────────────────────────────────
  List<RoomConfig> _currentFloorRooms = [];
  int _currentSeed = 0;

  List<RoomConfig> get currentFloorRooms => _currentFloorRooms;
  int get currentSeed => _currentSeed;

  /// Refreshes cached upgrade levels from the registered UpgradeManager.
  void syncUpgrades() {
    final um = GetIt.I<UpgradeManager>();

    final roomVariety = um.getUpgrade('room_variety');
    _roomVarietyLevel = roomVariety?.currentLevel ?? 0;

    final diffScaling = um.getUpgrade('difficulty_scaling');
    _difficultyScalingLevel = diffScaling?.currentLevel ?? 0;

    final treasureFreq = um.getUpgrade('treasure_frequency');
    _treasureFrequencyLevel = treasureFreq?.currentLevel ?? 0;
  }

  // ── Derived stats ────────────────────────────────────────

  /// Number of available room types (base + room_variety level).
  int get availableRoomTypeCount {
    return (kBaseRoomTypeCount + _roomVarietyLevel).clamp(
      kBaseRoomTypeCount,
      kMaxRoomTypes,
    );
  }

  /// Difficulty multiplier applied per floor.
  /// Lower = easier scaling for the player.
  double get difficultyPerFloor {
    final reduction = _difficultyScalingLevel * 0.07;
    return (kBaseDifficultyPerFloor - reduction).clamp(
      kMinDifficultyPerFloor,
      kBaseDifficultyPerFloor,
    );
  }

  /// Probability of a treasure room appearing instead of combat.
  double get treasureChance {
    final boost = _treasureFrequencyLevel * 0.05;
    return (kBaseTreasureChance + boost).clamp(
      kBaseTreasureChance,
      kMaxTreasureChance,
    );
  }

  // ── Generation ───────────────────────────────────────────

  /// Generates room layout for the given [floor].
  /// Boss rooms always appear on floors divisible by 10.
  /// Shop rooms always appear on floors divisible by 5 (non-boss).
  List<RoomConfig> generateFloor(int floor) {
    syncUpgrades();
    _currentSeed = DateTime.now().microsecondsSinceEpoch;
    final seededRandom = Random(_currentSeed);

    final rooms = <RoomConfig>[];

    // Mandatory boss/shop check
    if (floor % 10 == 0) {
      rooms.add(RoomConfig(
        type: RoomType.boss,
        difficulty: _scaledDifficulty(floor, isBoss: true),
        treasureMultiplier: 3.0,
        displayName: 'Boss Chamber -- Floor $floor',
      ));
      _currentFloorRooms = rooms;
      notifyListeners();
      return rooms;
    }

    if (floor % 5 == 0) {
      rooms.add(const RoomConfig(
        type: RoomType.shop,
        difficulty: 0,
        treasureMultiplier: 1.0,
        displayName: 'Wandering Merchant',
      ));
      _currentFloorRooms = rooms;
      notifyListeners();
      return rooms;
    }

    // Standard floor: choose room type probabilistically
    final availableTypes = RoomType.values.sublist(0, availableRoomTypeCount);
    final roll = seededRandom.nextDouble();

    RoomType selectedType;
    if (roll < treasureChance) {
      selectedType = RoomType.treasure;
    } else if (availableTypes.contains(RoomType.elite) &&
        seededRandom.nextDouble() < 0.12) {
      selectedType = RoomType.elite;
    } else if (availableTypes.contains(RoomType.rest) &&
        seededRandom.nextDouble() < 0.10) {
      selectedType = RoomType.rest;
    } else if (availableTypes.contains(RoomType.trap) &&
        seededRandom.nextDouble() < 0.08) {
      selectedType = RoomType.trap;
    } else if (availableTypes.contains(RoomType.mystery) &&
        seededRandom.nextDouble() < 0.06) {
      selectedType = RoomType.mystery;
    } else {
      selectedType = RoomType.combat;
    }

    rooms.add(RoomConfig(
      type: selectedType,
      difficulty: _scaledDifficulty(floor),
      treasureMultiplier: selectedType == RoomType.treasure ? 2.0 : 1.0,
      displayName: _roomDisplayName(selectedType, floor),
    ));

    _currentFloorRooms = rooms;
    notifyListeners();
    return rooms;
  }

  /// Calculates enemy difficulty for a given floor accounting for upgrades.
  int _scaledDifficulty(int floor, {bool isBoss = false}) {
    final baseMultiplier = isBoss ? 3.0 : 1.0;
    return (floor * difficultyPerFloor * baseMultiplier).ceil();
  }

  /// Returns a themed display name for the room.
  String _roomDisplayName(RoomType type, int floor) {
    switch (type) {
      case RoomType.combat:
        return 'Dungeon Room -- Floor $floor';
      case RoomType.treasure:
        return 'Treasure Vault -- Floor $floor';
      case RoomType.trap:
        return 'Trap Corridor -- Floor $floor';
      case RoomType.rest:
        return 'Sanctuary -- Floor $floor';
      case RoomType.elite:
        return 'Elite Guardian -- Floor $floor';
      case RoomType.mystery:
        return 'Mysterious Portal -- Floor $floor';
      case RoomType.shop:
        return 'Wandering Merchant';
      case RoomType.boss:
        return 'Boss Chamber -- Floor $floor';
    }
  }
}

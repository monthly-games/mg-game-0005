import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// PermadeathManager — MG-0005 Roguelike Dungeon
// Meta-progression system: persists unlocks across deaths,
// provides starting bonuses, and tracks best-run statistics.
// ============================================================

/// Represents a persistent unlock that carries across runs.
class PersistentUnlock {
  final String id;
  final String name;
  final String description;
  final int requiredDeaths;
  bool isUnlocked;

  PersistentUnlock({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredDeaths,
    this.isUnlocked = false,
  });
}

/// Manages permadeath meta-progression driven by UpgradeManager values.
///
/// Upgrade effects:
/// - `starting_health`: Bonus HP at the start of each run
/// - `unlock_slots`: Number of persistent perks carried into new runs
class PermadeathManager extends ChangeNotifier {
  // ── Base constants ───────────────────────────────────────
  static const int kBaseStartingHp = 100;
  static const int kHpBonusPerLevel = 15;
  static const int kBaseUnlockSlots = 1;
  static const int kSlotsPerLevel = 1;
  static const int kMaxUnlockSlots = 6;
  static const int kSoulStonesPerFloor = 10;

  // ── Cached upgrade values ────────────────────────────────
  int _startingHealthLevel = 0;
  int _unlockSlotsLevel = 0;

  // ── Run state ────────────────────────────────────────────
  int _totalDeaths = 0;
  int _bestFloor = 0;
  int _currentRunFloor = 0;
  int _lifetimeSoulStones = 0;

  // ── Persistent unlocks ───────────────────────────────────
  final List<PersistentUnlock> _availableUnlocks = [
    PersistentUnlock(
      id: 'second_wind',
      name: 'Second Wind',
      description: 'Revive once per run with 25% HP.',
      requiredDeaths: 3,
    ),
    PersistentUnlock(
      id: 'gold_inheritance',
      name: 'Gold Inheritance',
      description: 'Start runs with 20% of previous gold.',
      requiredDeaths: 5,
    ),
    PersistentUnlock(
      id: 'map_memory',
      name: 'Map Memory',
      description: 'Reveal room types one floor ahead.',
      requiredDeaths: 8,
    ),
    PersistentUnlock(
      id: 'soul_magnet',
      name: 'Soul Magnet',
      description: 'Earn 25% more Soul Stones on death.',
      requiredDeaths: 12,
    ),
    PersistentUnlock(
      id: 'resilience',
      name: 'Resilience',
      description: 'Take 10% less damage on floor 1-5.',
      requiredDeaths: 15,
    ),
    PersistentUnlock(
      id: 'treasure_sense',
      name: 'Treasure Sense',
      description: 'Treasure rooms drop 50% more gold.',
      requiredDeaths: 20,
    ),
  ];

  // ── Getters ──────────────────────────────────────────────
  int get totalDeaths => _totalDeaths;
  int get bestFloor => _bestFloor;
  int get currentRunFloor => _currentRunFloor;
  int get lifetimeSoulStones => _lifetimeSoulStones;
  List<PersistentUnlock> get availableUnlocks =>
      List.unmodifiable(_availableUnlocks);

  /// Returns only the unlocks that have been unlocked.
  List<PersistentUnlock> get unlockedPerks =>
      _availableUnlocks.where((u) => u.isUnlocked).toList();

  /// Number of active perk slots (base + unlock_slots level).
  int get activeSlotCount {
    return (kBaseUnlockSlots + _unlockSlotsLevel * kSlotsPerLevel).clamp(
      kBaseUnlockSlots,
      kMaxUnlockSlots,
    );
  }

  /// Active perks limited by slot count.
  List<PersistentUnlock> get activePerks {
    final unlocked = unlockedPerks;
    return unlocked.length <= activeSlotCount
        ? unlocked
        : unlocked.sublist(0, activeSlotCount);
  }

  /// Starting HP accounting for base + upgrade bonus.
  int get startingHp => kBaseStartingHp + (_startingHealthLevel * kHpBonusPerLevel);

  /// Whether a specific perk is currently active for this run.
  bool isPerkActive(String perkId) {
    return activePerks.any((p) => p.id == perkId);
  }

  // ── Upgrade sync ─────────────────────────────────────────

  /// Refreshes cached upgrade levels from the registered UpgradeManager.
  void syncUpgrades() {
    final um = GetIt.I<UpgradeManager>();

    final startingHealth = um.getUpgrade('starting_health');
    _startingHealthLevel = startingHealth?.currentLevel ?? 0;

    final unlockSlots = um.getUpgrade('unlock_slots');
    _unlockSlotsLevel = unlockSlots?.currentLevel ?? 0;
  }

  // ── Run lifecycle ────────────────────────────────────────

  /// Call at the start of each new dungeon run.
  void beginRun() {
    syncUpgrades();
    _currentRunFloor = 1;
    notifyListeners();
  }

  /// Call when the player advances to the next floor.
  void advanceFloor() {
    _currentRunFloor++;
    if (_currentRunFloor > _bestFloor) {
      _bestFloor = _currentRunFloor;
    }
    notifyListeners();
  }

  /// Call when the player dies — handles meta-progression rewards.
  /// Returns the number of Soul Stones earned this run.
  int onPlayerDeath() {
    _totalDeaths++;

    // Calculate Soul Stones earned
    int stonesEarned = _currentRunFloor * kSoulStonesPerFloor;
    if (isPerkActive('soul_magnet')) {
      stonesEarned = (stonesEarned * 1.25).ceil();
    }
    _lifetimeSoulStones += stonesEarned;

    // Check for newly unlocked perks
    for (final unlock in _availableUnlocks) {
      if (!unlock.isUnlocked && _totalDeaths >= unlock.requiredDeaths) {
        unlock.isUnlocked = true;
      }
    }

    notifyListeners();
    return stonesEarned;
  }

  /// Gold carried over from last run (if gold_inheritance is active).
  int calculateInheritedGold(int lastRunGold) {
    if (isPerkActive('gold_inheritance')) {
      return (lastRunGold * 0.20).floor();
    }
    return 0;
  }

  /// Damage reduction for early floors (if resilience is active).
  double earlyFloorDamageReduction(int currentFloor) {
    if (isPerkActive('resilience') && currentFloor <= 5) {
      return 0.10;
    }
    return 0.0;
  }
}

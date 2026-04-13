import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// PowerupManager -- MG-0005 Roguelike Dungeon
// Handles temporary in-run powerup spawning, duration tracking,
// stacking logic, and expiration.
// ============================================================

/// Types of powerups that can spawn during dungeon runs.
enum PowerupType {
  attackBoost,
  defenseBoost,
  healOverTime,
  goldMagnet,
  criticalStrike,
  manaRegen,
  shieldBubble,
  doubleXp,
}

/// An active powerup instance with remaining duration.
class ActivePowerup {
  final PowerupType type;
  final String name;
  final double magnitude;
  double remainingDuration;
  int stackCount;

  ActivePowerup({
    required this.type,
    required this.name,
    required this.magnitude,
    required this.remainingDuration,
    this.stackCount = 1,
  });

  bool get isExpired => remainingDuration <= 0;

  /// Effective magnitude accounting for stack count.
  double get effectiveMagnitude => magnitude * stackCount;
}

/// Manages temporary powerup spawning and lifecycle driven by UpgradeManager.
///
/// Upgrade effects:
/// - `powerup_duration`: Base duration extension for all powerups
/// - `stack_limit`: Maximum number of stacks per powerup type
/// - `spawn_rate`: Chance of powerup dropping from enemy kills
class PowerupManager extends ChangeNotifier {
  final Random _random = Random();

  // ── Base constants ───────────────────────────────────────
  static const double kBasePowerupDuration = 30.0; // seconds
  static const double kDurationBonusPerLevel = 5.0;
  static const int kBaseStackLimit = 1;
  static const int kStackBonusPerLevel = 1;
  static const int kMaxStackLimit = 5;
  static const double kBaseSpawnRate = 0.15;
  static const double kSpawnRateBonusPerLevel = 0.05;
  static const double kMaxSpawnRate = 0.60;

  // ── Cached upgrade values ────────────────────────────────
  int _powerupDurationLevel = 0;
  int _stackLimitLevel = 0;
  int _spawnRateLevel = 0;

  // ── State ────────────────────────────────────────────────
  final List<ActivePowerup> _activePowerups = [];

  List<ActivePowerup> get activePowerups =>
      List.unmodifiable(_activePowerups);

  int get activePowerupCount => _activePowerups.length;

  /// Refreshes cached upgrade levels from the registered UpgradeManager.
  void syncUpgrades() {
    final um = GetIt.I<UpgradeManager>();

    final duration = um.getUpgrade('powerup_duration');
    _powerupDurationLevel = duration?.currentLevel ?? 0;

    final stackLimit = um.getUpgrade('stack_limit');
    _stackLimitLevel = stackLimit?.currentLevel ?? 0;

    final spawnRate = um.getUpgrade('spawn_rate');
    _spawnRateLevel = spawnRate?.currentLevel ?? 0;
  }

  // ── Derived stats ────────────────────────────────────────

  /// Duration (in seconds) for newly spawned powerups.
  double get powerupDuration {
    return kBasePowerupDuration + (_powerupDurationLevel * kDurationBonusPerLevel);
  }

  /// Maximum stacks per powerup type.
  int get maxStackCount {
    return (kBaseStackLimit + _stackLimitLevel * kStackBonusPerLevel).clamp(
      kBaseStackLimit,
      kMaxStackLimit,
    );
  }

  /// Probability of a powerup dropping on enemy kill.
  double get spawnRate {
    return (kBaseSpawnRate + _spawnRateLevel * kSpawnRateBonusPerLevel).clamp(
      kBaseSpawnRate,
      kMaxSpawnRate,
    );
  }

  // ── Powerup lifecycle ────────────────────────────────────

  /// Rolls for a powerup drop. Call after defeating an enemy.
  /// Returns the spawned [ActivePowerup] or `null` if no drop.
  ActivePowerup? rollForDrop() {
    syncUpgrades();
    if (_random.nextDouble() >= spawnRate) return null;

    const availableTypes = PowerupType.values;
    final type = availableTypes[_random.nextInt(availableTypes.length)];
    return _spawnPowerup(type);
  }

  /// Forces a specific powerup type to spawn (e.g., from treasure rooms).
  ActivePowerup spawnSpecific(PowerupType type) {
    syncUpgrades();
    return _spawnPowerup(type);
  }

  ActivePowerup _spawnPowerup(PowerupType type) {
    // Check for existing stack
    final existing = _findActive(type);
    if (existing != null && existing.stackCount < maxStackCount) {
      existing.stackCount++;
      existing.remainingDuration = powerupDuration; // refresh duration
      notifyListeners();
      return existing;
    }

    // Create new powerup
    final powerup = ActivePowerup(
      type: type,
      name: _powerupName(type),
      magnitude: _powerupMagnitude(type),
      remainingDuration: powerupDuration,
    );
    _activePowerups.add(powerup);
    notifyListeners();
    return powerup;
  }

  /// Updates all active powerup durations. Call each game tick.
  void update(double dt) {
    bool changed = false;
    for (final powerup in _activePowerups) {
      powerup.remainingDuration -= dt;
      if (powerup.isExpired) changed = true;
    }
    if (changed) {
      _activePowerups.removeWhere((p) => p.isExpired);
      notifyListeners();
    }
  }

  /// Clears all active powerups (e.g., on run reset).
  void clearAll() {
    _activePowerups.clear();
    notifyListeners();
  }

  // ── Query helpers ────────────────────────────────────────

  /// Returns the currently active powerup of [type], or null.
  ActivePowerup? _findActive(PowerupType type) {
    for (final p in _activePowerups) {
      if (p.type == type) return p;
    }
    return null;
  }

  /// Whether a specific powerup type is currently active.
  bool isActive(PowerupType type) => _findActive(type) != null;

  /// Returns the effective magnitude for a powerup type, or 0.0 if inactive.
  double getEffectiveMagnitude(PowerupType type) {
    return _findActive(type)?.effectiveMagnitude ?? 0.0;
  }

  /// Total attack bonus from active powerups.
  double get attackBonus => getEffectiveMagnitude(PowerupType.attackBoost);

  /// Total defense bonus from active powerups.
  double get defenseBonus => getEffectiveMagnitude(PowerupType.defenseBoost);

  /// Gold collection multiplier (1.0 = normal).
  double get goldMultiplier {
    final mag = getEffectiveMagnitude(PowerupType.goldMagnet);
    return mag > 0 ? 1.0 + mag : 1.0;
  }

  /// Critical strike chance bonus.
  double get critChanceBonus => getEffectiveMagnitude(PowerupType.criticalStrike);

  // ── Powerup definitions ──────────────────────────────────

  String _powerupName(PowerupType type) {
    switch (type) {
      case PowerupType.attackBoost:
        return 'Battle Fury';
      case PowerupType.defenseBoost:
        return 'Iron Skin';
      case PowerupType.healOverTime:
        return 'Regeneration';
      case PowerupType.goldMagnet:
        return 'Gold Magnet';
      case PowerupType.criticalStrike:
        return 'Eagle Eye';
      case PowerupType.manaRegen:
        return 'Arcane Flow';
      case PowerupType.shieldBubble:
        return 'Magic Barrier';
      case PowerupType.doubleXp:
        return 'Wisdom Aura';
    }
  }

  double _powerupMagnitude(PowerupType type) {
    switch (type) {
      case PowerupType.attackBoost:
        return 5.0; // +5 attack per stack
      case PowerupType.defenseBoost:
        return 3.0; // +3 defense per stack
      case PowerupType.healOverTime:
        return 2.0; // +2 HP per tick per stack
      case PowerupType.goldMagnet:
        return 0.5; // +50% gold per stack
      case PowerupType.criticalStrike:
        return 0.15; // +15% crit chance per stack
      case PowerupType.manaRegen:
        return 3.0; // +3 mana per tick per stack
      case PowerupType.shieldBubble:
        return 10.0; // +10 shield HP per stack
      case PowerupType.doubleXp:
        return 1.0; // +100% XP per stack
    }
  }
}

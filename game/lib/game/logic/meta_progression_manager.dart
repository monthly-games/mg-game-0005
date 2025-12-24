import 'package:flutter/foundation.dart';

class MetaProgressionManager extends ChangeNotifier {
  int _soulStones = 1000; // Start with some for testing
  final Map<String, int> _upgradeLevels = {'hp': 0, 'attack': 0, 'gold': 0};

  int get soulStones => _soulStones;

  // Upgrade Config
  // Logic: Cost = BaseCost * (Multiplier ^ Level)
  // HP: Base 100, +10 per level. Cost: 100 * (1.5 ^ L)
  // Atk: Base 10, +1 per level. Cost: 150 * (1.5 ^ L)
  // Gold: Base 0, +10 per level. Cost: 50 * (1.5 ^ L)

  int get hpLevel => _upgradeLevels['hp'] ?? 0;
  int get attackLevel => _upgradeLevels['attack'] ?? 0;
  int get goldLevel => _upgradeLevels['gold'] ?? 0;

  int getStartingHp() => 100 + (hpLevel * 10);
  int getStartingAttack() => 10 + (attackLevel * 1);
  int getStartingGold() => goldLevel * 10;

  int getUpgradeCost(String type) {
    int level = _upgradeLevels[type] ?? 0;
    int baseCost = 100;
    if (type == 'attack') baseCost = 150;
    if (type == 'gold') baseCost = 50;

    // Simple exponential cost
    return (baseCost * _pow(1.5, level)).toInt();
  }

  double _pow(double x, int exponent) {
    double res = 1;
    for (int i = 0; i < exponent; i++) {
      res *= x;
    }
    return res;
  }

  bool canAfford(String type) {
    return _soulStones >= getUpgradeCost(type);
  }

  void buyUpgrade(String type) {
    if (canAfford(type)) {
      _soulStones -= getUpgradeCost(type);
      _upgradeLevels[type] = (_upgradeLevels[type] ?? 0) + 1;
      notifyListeners();
    }
  }

  void addSoulStones(int amount) {
    _soulStones += amount;
    notifyListeners();
  }
}

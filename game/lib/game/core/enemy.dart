import 'dart:math';
import 'player.dart';

enum EnemyType { goblin, orc, bat, shaman, dragon }

class Enemy {
  final String name;
  final EnemyType type;
  int hp;
  final int maxHp;
  int attack;
  int defense;

  int _currentShield = 0;

  // Intent System
  String _intention = 'Attack';
  int _intentionValue = 0;

  Enemy({
    required this.name,
    required this.type,
    required this.maxHp,
    required this.attack,
    required this.defense,
  }) : hp = maxHp {
    decideNextMove();
  }

  String get intention => _intention;
  int get intentionValue => _intentionValue;

  void decideNextMove() {
    final rand = Random();

    // Reset temporary states if needed, though usually handled in performAction/turn end

    switch (type) {
      case EnemyType.goblin:
        // Goblin: 80% Attack, 20% Do nothing/Wait
        if (rand.nextDouble() < 0.8) {
          _intention = 'Attack';
          _intentionValue = attack;
        } else {
          _intention = 'Wait';
          _intentionValue = 0;
        }
        break;

      case EnemyType.orc:
        // Orc (Defensive): 60% Attack, 40% Defend
        if (rand.nextDouble() < 0.6) {
          _intention = 'Attack';
          _intentionValue = attack + 2; // Orc hits hard
        } else {
          _intention = 'Defend';
          _intentionValue = 5; // Gain 5 Shield
        }
        break;

      case EnemyType.bat:
        // Bat (Aggressive): 90% Attack (Weak but fast), 10% Lifesteal
        if (rand.nextDouble() < 0.9) {
          _intention = 'Attack';
          _intentionValue = (attack * 0.8)
              .toInt(); // Faster but weaker (simulated)
          if (_intentionValue < 1) _intentionValue = 1;
        } else {
          _intention = 'Leech'; // Life steal
          _intentionValue = attack;
        }
        break;

      case EnemyType.shaman:
        // Shaman (Healer): If HP < 50%, 50% chance to Heal. Else Attack.
        bool lowHp = hp < (maxHp * 0.5);
        if (lowHp && rand.nextDouble() < 0.5) {
          _intention = 'Heal';
          _intentionValue = (maxHp * 0.2).toInt(); // Heal 20%
        } else {
          _intention = 'Bolt'; // Magic Attack
          _intentionValue = attack + 1;
        }
        break;

      case EnemyType.dragon:
        // Boss Logic: Dragon
        // 30% Roar (Buff Def), 70% Fire Breath (Massive Dmg)
        if (rand.nextDouble() < 0.3) {
          _intention = 'Roar';
          _intentionValue = 10; // Gain 10 Shield
        } else {
          _intention = 'Breath';
          _intentionValue = (attack * 1.5).toInt(); // 1.5x Dmg
        }
        break;
    }
  }

  void performAction(Player target) {
    if (_intention == 'Attack' ||
        _intention == 'Bolt' ||
        _intention == 'Breath') {
      target.takeDamage(_intentionValue);
    } else if (_intention == 'Defend' || _intention == 'Roar') {
      _currentShield += _intentionValue;
    } else if (_intention == 'Heal') {
      heal(_intentionValue);
    } else if (_intention == 'Leech') {
      target.takeDamage(_intentionValue);
      heal(_intentionValue);
    }
  }

  bool get isDead => hp <= 0;

  void heal(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  void takeDamage(int amount) {
    int effectiveDamage = amount;

    if (_currentShield > 0) {
      if (_currentShield >= amount) {
        _currentShield -= amount;
        effectiveDamage = 0;
      } else {
        effectiveDamage -= _currentShield;
        _currentShield = 0;
      }
    }

    // Applying base defense (flat reduction for now, maybe remove for MVP simplicity or keep)
    effectiveDamage = (effectiveDamage - defense).clamp(0, effectiveDamage);

    hp = (hp - effectiveDamage).clamp(0, maxHp);
  }
}

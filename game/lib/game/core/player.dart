class Player {
  int hp;
  final int maxHp;
  int attack;
  int defense;

  int mana;
  final int maxMana;

  Player({
    required this.maxHp,
    required this.attack,
    required this.defense,
    this.maxMana = 100,
  }) : hp = maxHp,
       mana = 0; // Start with 0 mana or 50? Let's say 0 and earn it.

  bool get isDead => hp <= 0;

  void takeDamage(int amount) {
    int actualDamage = (amount - defense).clamp(0, amount);
    hp = (hp - actualDamage).clamp(0, maxHp);
  }

  void heal(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  void gainMana(int amount) {
    mana = (mana + amount).clamp(0, maxMana);
  }

  bool canSpendMana(int amount) => mana >= amount;

  void spendMana(int amount) {
    if (canSpendMana(amount)) {
      mana -= amount;
    }
  }
}

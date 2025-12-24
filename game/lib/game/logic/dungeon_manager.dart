import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import '../core/puzzle_board.dart';
import '../core/player.dart';
import '../core/enemy.dart';
import 'meta_progression_manager.dart';

enum GameEventType { damageTaken, healed, goldGained }

class GameEvent {
  final GameEventType type;
  final int value;
  final dynamic
  position; // Placeholder for offset if needed, simplified for now
  GameEvent(this.type, this.value, this.position);
}

class DungeonManager extends ChangeNotifier {
  late Player _player;
  Enemy? _currentEnemy;
  int _currentFloor = 1;
  late PuzzleBoard _puzzleBoard;

  // Dependencies
  final MetaProgressionManager _metaManager = GetIt.I<MetaProgressionManager>();
  final AudioManager _audioManager = GetIt.I<AudioManager>();

  Player get player => _player;
  Enemy? get currentEnemy => _currentEnemy;
  // Economy
  int _gold = 0;
  bool _isShopAvailable = false;

  int get gold => _gold;
  bool get isShopAvailable => _isShopAvailable;

  // Event System for UI Effects
  final _eventController = StreamController<GameEvent>.broadcast();
  Stream<GameEvent> get eventStream => _eventController.stream;

  void dispose() {
    _eventController.close();
    super.dispose();
  }

  void initialize() {
    // Utilize Meta Stats for Player Initialization
    int startHp = _metaManager.getStartingHp();
    int startAtk = _metaManager.getStartingAttack();
    int startGold = _metaManager.getStartingGold();

    _player = Player(
      maxHp: startHp,
      attack: startAtk,
      defense: 2,
    ); // Base def 2
    _puzzleBoard = PuzzleBoard();
    _puzzleBoard.onMatch = _handleMatches;
    _currentFloor = 1;
    _gold = startGold;
    _startFloor();
  }

  void _startFloor() {
    // Every 5th floor is a shop
    if (_currentFloor % 5 == 0) {
      _isShopAvailable = true;
      _currentEnemy = null; // No enemy in shop
      notifyListeners();
    } else {
      _isShopAvailable = false;
      _spawnEnemy();
    }
  }

  void leaveShop() {
    _isShopAvailable = false;
    _currentFloor++; // Proceed to next floor after shop
    _startFloor();
  }

  void buyItem(String itemId, int cost) {
    if (_gold >= cost) {
      _gold -= cost;
      if (itemId == 'heal') {
        _player.heal(30);
      } else if (itemId == 'attack_up') {
        _player.attack += 2;
      }
      notifyListeners();
    }
  }

  void _spawnEnemy() {
    // Determine Enemy Type
    // Every 10th floor is a BOSS
    bool isBoss = _currentFloor % 10 == 0;

    EnemyType type;
    if (isBoss) {
      type = EnemyType.dragon;
    } else {
      // Normal Floors: Random non-boss
      final random = Random();
      final normalTypes = [
        EnemyType.goblin,
        EnemyType.orc,
        EnemyType.bat,
        EnemyType.shaman,
      ];
      type = normalTypes[random.nextInt(normalTypes.length)];
    }

    // Stats Scaling
    // Bosses scale much harder
    int hpBase = isBoss ? 200 : 20;
    int atkBase = isBoss ? 20 : 5;

    int hp = hpBase + (_currentFloor * (isBoss ? 20 : 5));
    int atk = atkBase + (_currentFloor * (isBoss ? 2 : 1));

    String name = '';
    int def = 0;

    switch (type) {
      case EnemyType.goblin:
        name = 'Goblin';
        break;
      case EnemyType.orc:
        name = 'Orc';
        hp = (hp * 1.5).toInt();
        def = 2;
        break;
      case EnemyType.bat:
        name = 'Vampire Bat';
        hp = (hp * 0.7).toInt();
        atk = (atk * 0.8).toInt();
        break;
      case EnemyType.shaman:
        name = 'Dark Shaman';
        atk = (atk * 1.2).toInt();
        break;
      case EnemyType.dragon:
        name = 'Ancient Dragon';
        def = 5;
        break;
    }

    _currentEnemy = Enemy(
      name: '$name Lv.$_currentFloor',
      type: type,
      maxHp: hp,
      attack: atk,
      defense: def,
    );
    notifyListeners();
  }

  void _handleMatches(List<BlockType> matchedTypes) {
    _audioManager.playSfx('sfx_match.wav');
    int damage = 0;
    int heal = 0;
    int shield = 0;

    for (final type in matchedTypes) {
      switch (type) {
        case BlockType.sword:
          // Simple: 1 Sword Block = 2 Damage (Flat) for MVP
          damage += 2;
          break;
        case BlockType.potion:
          heal += 5;
          break;
        case BlockType.shield:
          shield += 2;
          break;
        case BlockType.coin:
          _gold += 5; // 5 Gold per block
          _audioManager.playSfx('sfx_gold.wav');
          break;
        case BlockType.mana:
          _player.gainMana(10);
          break;
      }
    }

    if (damage > 0) {
      bool hasSword = matchedTypes.contains(BlockType.sword);
      int finalDamage = damage + (hasSword ? _player.attack : 0);
      onPlayerAttack(finalDamage);
    }

    if (heal > 0) {
      _player.heal(heal);
      _eventController.add(GameEvent(GameEventType.healed, heal, null));
    }

    notifyListeners();

    // Trigger Enemy Turn if enemy is still alive and NOT in a shop
    if (_currentEnemy != null && !_currentEnemy!.isDead) {
      _executeEnemyTurn();
    }
  }

  void castSkill(String skillId) {
    if (_currentEnemy == null) return;

    if (skillId == 'fireball' && _player.canSpendMana(30)) {
      _player.spendMana(30);
      _audioManager.playSfx('sfx_attack.wav');
      int dmg = (_player.attack * 2.5).toInt();
      onPlayerAttack(dmg); // Treats as player attack (triggers win/gold logic)

      // Visual feedback could be added here
    } else if (skillId == 'stun' && _player.canSpendMana(50)) {
      _player.spendMana(50);
      _audioManager.playSfx('sfx_match.wav');
      // Hacky stun: delay enemy turn or just damage for MVP
      // For MVP: Stun deals moderate damage AND heals player (Divine Smite)
      int dmg = _player.attack;
      _player.heal(50);
      onPlayerAttack(dmg);
      _eventController.add(GameEvent(GameEventType.healed, 50, null));
    }
  }

  Future<void> _executeEnemyTurn() async {
    // Delay for dramatic effect / visual clarity
    await Future.delayed(const Duration(seconds: 1));

    if (_currentEnemy != null && !_currentEnemy!.isDead) {
      _currentEnemy!.performAction(_player);

      // Calculate Damage Taken (simplified)
      if (_currentEnemy!.intention == 'Attack' ||
          _currentEnemy!.intention == 'Breath') {
        _audioManager.playSfx('sfx_damage.wav');
        _eventController.add(
          GameEvent(
            GameEventType.damageTaken,
            _currentEnemy!.intentionValue,
            null,
          ),
        );
      }

      _currentEnemy!.decideNextMove(); // Prepare intent for next turn

      if (_player.isDead) {
        // Game Over Logic
        // Grant Soul Stones based on Progress
        int stonesEarned = _currentFloor * 10;
        _metaManager.addSoulStones(stonesEarned);

        // For MVP: Restart Floor 1
        initialize();
      }

      notifyListeners();
    }
  }

  void onPlayerAttack(int damage) {
    if (_currentEnemy != null) {
      _audioManager.playSfx('sfx_attack.wav');
      _currentEnemy!.takeDamage(damage);
      if (_currentEnemy!.isDead) {
        _currentEnemy = null;
        // Drop Gold
        int goldDrop = 10 + (_currentFloor * 2);
        _gold += goldDrop;
        _eventController.add(
          GameEvent(GameEventType.goldGained, goldDrop, null),
        );

        // Go to next floor
        _currentFloor++;
        _startFloor();
      }
      notifyListeners();
    }
  }
}

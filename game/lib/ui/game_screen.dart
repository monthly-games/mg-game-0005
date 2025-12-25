import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import '../game/logic/dungeon_manager.dart';
import '../game/core/enemy.dart';
import '../game/core/player.dart';
import '../game/core/puzzle_board.dart';
import 'hud/mg_dungeon_hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late DungeonManager _dungeonManager;

  @override
  void initState() {
    super.initState();
    _dungeonManager = DungeonManager();
    _dungeonManager.initialize();
    GetIt.I.registerSingleton<DungeonManager>(_dungeonManager);

    _dungeonManager.eventStream.listen(_handleGameEvent);

    // BGM
    final audioManager = GetIt.I<AudioManager>();
    audioManager.playBgm('bgm_dungeon.mp3', volume: 0.4);
  }

  @override
  void dispose() {
    GetIt.I<AudioManager>().stopBgm();
    super.dispose();
  }

  void _handleGameEvent(GameEvent event) {
    if (event.type == GameEventType.damageTaken) {
      _showFloatingText("-${event.value}", Colors.red, event.position);
    } else if (event.type == GameEventType.healed) {
      _showFloatingText("+${event.value}", Colors.green, event.position);
    } else if (event.type == GameEventType.goldGained) {
      _showFloatingText("+${event.value} G", Colors.amber, event.position);
    }
  }

  void _showFloatingText(String text, Color color, Offset? pos) {
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: MediaQuery.of(context).size.width * 0.5 - 40,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: 1.0 - value,
                  child: Transform.translate(
                    offset: Offset(0, -50 * value),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: color,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(blurRadius: 4, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                );
              },
              onEnd: () {
                entry?.remove();
              },
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _dungeonManager,
        builder: (context, child) {
          final player = _dungeonManager.player;
          final enemy = _dungeonManager.currentEnemy;
          return Stack(
            children: [
              // 게임 콘텐츠
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 80), // HUD 공간 확보
                    // Top: Enemy Area
                    Expanded(flex: 2, child: _buildEnemyArea(enemy)),
                    // Middle: Player Status
                    _buildPlayerStatus(player),
                    // Bottom: Puzzle/Action Area
                    Expanded(flex: 3, child: _buildPuzzleArea()),
                  ],
                ),
              ),
              // MG Dungeon HUD
              MGDungeonHud(
                playerHp: player.hp.toInt(),
                playerMaxHp: player.maxHp.toInt(),
                playerMp: player.mana.toInt(),
                playerMaxMp: player.maxMana.toInt(),
                floor: 1, // floor 정보는 DungeonManager에서 private
                gold: _dungeonManager.gold,
                enemyName: enemy?.name,
                enemyHp: enemy?.hp.toInt(),
                enemyMaxHp: enemy?.maxHp.toInt(),
                onPause: () {
                  // TODO: Implement pause
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnemyArea(Enemy? enemy) {
    if (_dungeonManager.isShopAvailable) {
      return _buildShopArea();
    }

    if (enemy == null) {
      return const Center(
        child: Text("Exploring...", style: TextStyle(color: Colors.white)),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.black26,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bug_report, size: 80, color: Colors.redAccent),
          const SizedBox(height: 10),
          Text(
            enemy.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "HP: ${enemy.hp} / ${enemy.maxHp}",
            style: const TextStyle(color: Colors.redAccent, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.yellow,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  "${enemy.intention}: ${enemy.intentionValue}",
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopArea() {
    return Container(
      width: double.infinity,
      color: Colors.brown[900],
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store, size: 60, color: Colors.amber),
          const SizedBox(height: 10),
          const Text(
            "Wandering Merchant",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Gold: ${_dungeonManager.gold}",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShopItem(
                "Potion",
                "Heal 30 HP",
                50,
                Icons.local_drink,
                () => _dungeonManager.buyItem('heal', 50),
              ),
              const SizedBox(width: 16),
              _buildShopItem(
                "Sharpen",
                "Atk +2",
                100,
                Icons.upgrade,
                () => _dungeonManager.buyItem('attack_up', 100),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _dungeonManager.leaveShop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text("Leave Shop"),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(
    String name,
    String desc,
    int cost,
    IconData icon,
    VoidCallback onTap,
  ) {
    bool canBuy = _dungeonManager.gold >= cost;
    return GestureDetector(
      onTap: canBuy ? onTap : null,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: canBuy ? Colors.black54 : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: canBuy ? Colors.amber : Colors.grey),
        ),
        child: Column(
          children: [
            Icon(icon, color: canBuy ? Colors.white : Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: canBuy ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              desc,
              style: TextStyle(
                color: canBuy ? Colors.white70 : Colors.white30,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$cost G",
              style: TextStyle(
                color: canBuy ? Colors.amber : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatus(Player player) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          color: Colors.grey[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Player",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "HP: ${player.hp} / ${player.maxHp}",
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                  Text(
                    "MP: ${player.mana} / ${player.maxMana}",
                    style: const TextStyle(color: Colors.purpleAccent),
                  ),
                ],
              ),
              Text(
                "Floor: ${_dungeonManager.currentFloor}",
                style: const TextStyle(color: Colors.amber, fontSize: 20),
              ),
            ],
          ),
        ),
        _buildSkillsArea(player),
      ],
    );
  }

  Widget _buildSkillsArea(Player player) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSkillButton(
            "Fireball",
            "30 MP",
            Colors.orange,
            () => _dungeonManager.castSkill('fireball'),
            player.canSpendMana(30),
          ),
          _buildSkillButton(
            "Smite",
            "50 MP",
            Colors.yellow,
            () => _dungeonManager.castSkill('stun'),
            player.canSpendMana(50),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillButton(
    String label,
    String cost,
    Color color,
    VoidCallback onTap,
    bool enabled,
  ) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled
            ? color.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: enabled ? color : Colors.grey),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(cost, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPuzzleArea() {
    final board = _dungeonManager.puzzleBoard;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black45,
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate grid dimensions
          final boardSize = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;

          return Center(
            child: SizedBox(
              width: boardSize,
              height: boardSize,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // 6x6 Grid
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 36,
                itemBuilder: (context, index) {
                  final r = index ~/ 6;
                  final c = index % 6;
                  final block = board.grid[r][c];

                  return GestureDetector(
                    onTap: () {
                      board.selectBlock(r, c);
                      _dungeonManager.notifyListeners(); // Force rebuild
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: block?.isSelected == true
                            ? Colors.white.withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: block?.isSelected == true
                              ? Colors.yellow
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(child: _buildBlockIcon(block?.type)),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlockIcon(BlockType? type) {
    if (type == null) return const SizedBox.shrink();

    IconData icon;
    Color color;

    switch (type) {
      case BlockType.sword:
        icon = Icons.flash_on; // Sword-ish
        color = Colors.red;
        break;
      case BlockType.shield:
        icon = Icons.security;
        color = Colors.blue;
        break;
      case BlockType.potion:
        icon = Icons.favorite;
        color = Colors.green;
        break;
      case BlockType.coin:
        icon = Icons.monetization_on;
        color = Colors.amber;
        break;
      case BlockType.mana:
        icon = Icons.auto_awesome;
        color = Colors.purple;
        break;
    }

    return Icon(icon, color: color, size: 32);
  }
}

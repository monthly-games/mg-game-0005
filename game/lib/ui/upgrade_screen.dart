import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../game/logic/meta_progression_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meta = GetIt.I<MetaProgressionManager>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Soul Shop'),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBuilder(
        animation: meta,
        builder: (context, _) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.diamond,
                      color: Colors.purpleAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${meta.soulStones}",
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildUpgradeTile(
                      meta,
                      'hp',
                      'Max HP',
                      'Start with +10 HP',
                      Icons.favorite,
                      Colors.redAccent,
                    ),
                    _buildUpgradeTile(
                      meta,
                      'attack',
                      'Attack Power',
                      'Start with +1 Attack',
                      Icons.flash_on,
                      Colors.orangeAccent,
                    ),
                    _buildUpgradeTile(
                      meta,
                      'gold',
                      'Starting Gold',
                      'Start with +10 Gold',
                      Icons.monetization_on,
                      Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpgradeTile(
    MetaProgressionManager meta,
    String id,
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    int level = 0;
    if (id == 'hp') level = meta.hpLevel;
    if (id == 'attack') level = meta.attackLevel;
    if (id == 'gold') level = meta.goldLevel;

    int cost = meta.getUpgradeCost(id);
    bool canAfford = meta.canAfford(id);

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Lv.$level  •  $desc",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: canAfford ? () => meta.buyUpgrade(id) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? Colors.purple : Colors.grey[800],
                foregroundColor: Colors.white,
              ),
              child: Text("$cost Souls"),
            ),
          ],
        ),
      ),
    );
  }
}

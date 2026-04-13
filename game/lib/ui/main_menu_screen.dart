import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'game_screen.dart';
import 'upgrade_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.castle, size: 100, color: Colors.purpleAccent),
                const SizedBox(height: MGSpacing.lg),
                const Text(
                  "Roguelike Dungeon",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.purple, blurRadius: 20)],
                  ),
                ),
                const SizedBox(height: 60),
            _buildMenuButton(
              context,
              "Play Game",
              Icons.play_arrow,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              ),
            ),
            const SizedBox(height: MGSpacing.lg),
            _buildMenuButton(
              context,
              "Soul Shop",
              Icons.upgrade,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpgradeScreen()),
              ),
            ),
          ],
        ),
      ),
      // Spine character placeholder (top-right corner)
      Positioned(
        top: 60,
        right: 16,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Dungeon Explorer greets you!"),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purpleAccent, width: 2),
            ),
            child: const Icon(
              Icons.explore,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
    ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

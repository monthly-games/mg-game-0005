import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final int value;

  const TileWidget({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: value > 0
            ? Text(
                '$value',
                style: TextStyle(
                  fontSize: _getFontSize(value),
                  fontWeight: FontWeight.bold,
                  color: value <= 4 ? Colors.black87 : Colors.white,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 0:
        return const Color(0xFF0f3460).withValues(alpha: 0.3);
      case 2:
        return const Color(0xFFe4e4e4);
      case 4:
        return const Color(0xFFe0d9c8);
      case 8:
        return const Color(0xFFf2b179);
      case 16:
        return const Color(0xFFf59563);
      case 32:
        return const Color(0xFFf67c5f);
      case 64:
        return const Color(0xFFf65e3b);
      case 128:
        return const Color(0xFFedcf72);
      case 256:
        return const Color(0xFFedcc61);
      case 512:
        return const Color(0xFFedc850);
      case 1024:
        return const Color(0xFFedc53f);
      case 2048:
        return const Color(0xFFedc22e);
      default:
        return const Color(0xFF3c3a32);
    }
  }

  double _getFontSize(int value) {
    if (value < 100) return 32;
    if (value < 1000) return 28;
    return 24;
  }
}

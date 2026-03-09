import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';

/// MG UI 기반 던전 로그라이크 HUD
/// mg_common_game의 공통 UI 컴포넌트 활용
class MGDungeonHud extends StatelessWidget {
  final int playerHp;
  final int playerMaxHp;
  final int playerMp;
  final int playerMaxMp;
  final int floor;
  final int gold;
  final String? enemyName;
  final int? enemyHp;
  final int? enemyMaxHp;
  final VoidCallback? onPause;
  final VoidCallback? onInventory;

  const MGDungeonHud({
    super.key,
    required this.playerHp,
    required this.playerMaxHp,
    this.playerMp = 0,
    this.playerMaxMp = 0,
    this.floor = 1,
    this.gold = 0,
    this.enemyName,
    this.enemyHp,
    this.enemyMaxHp,
    this.onPause,
    this.onInventory,
  });

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    return Positioned.fill(
      child: Column(
        children: [
          // 상단 HUD: 층 + 골드 + 일시정지
          Container(
            padding: EdgeInsets.only(
              top: safeArea.top + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 층 정보
                _buildFloorInfo(),

                // 골드 표시
                MGResourceBar(
                  icon: Icons.monetization_on,
                  value: _formatNumber(gold),
                  iconColor: MGColors.gold,
                  onTap: null,
                ),

                // 일시정지 버튼
                MGIconButton(
                  icon: Icons.pause,
                  onPressed: onPause,
                  size: 44,
                  backgroundColor: Colors.black54,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          MGSpacing.vSm,

          // 플레이어 HP/MP 바
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: safeArea.left + MGSpacing.hudMargin,
            ),
            child: Column(
              children: [
                _buildPlayerHpBar(),
                if (playerMaxMp > 0) ...[
                  MGSpacing.vXs,
                  _buildPlayerMpBar(),
                ],
              ],
            ),
          ),

          // 중앙 영역 확장 (게임 영역)
          const Expanded(child: SizedBox()),

          // 적 정보 (있을 경우)
          if (enemyName != null && enemyHp != null)
            Container(
              padding: EdgeInsets.only(
                bottom: safeArea.bottom + MGSpacing.hudMargin,
                left: safeArea.left + MGSpacing.hudMargin,
                right: safeArea.right + MGSpacing.hudMargin,
              ),
              child: _buildEnemyInfo(),
            ),
        ],
      ),
    );
  }

  Widget _buildFloorInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MGColors.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.layers,
            color: Colors.amber,
            size: 20,
          ),
          MGSpacing.hXs,
          Text(
            'Floor $floor',
            style: MGTextStyles.hud.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHpBar() {
    final percentage = playerMaxHp > 0 ? playerHp / playerMaxHp : 0.0;
    final isLow = percentage <= 0.25;

    return Row(
      children: [
        const Icon(Icons.favorite, color: Colors.red, size: 20),
        MGSpacing.hXs,
        Expanded(
          child: MGLinearProgress(
            value: percentage,
            height: 16,
            valueColor: isLow ? MGColors.error : Colors.green,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            borderRadius: 8,
          ),
        ),
        MGSpacing.hXs,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$playerHp/$playerMaxHp',
            style: MGTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerMpBar() {
    final percentage = playerMaxMp > 0 ? playerMp / playerMaxMp : 0.0;

    return Row(
      children: [
        const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
        MGSpacing.hXs,
        Expanded(
          child: MGLinearProgress(
            value: percentage,
            height: 12,
            valueColor: Colors.blue,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            borderRadius: 6,
          ),
        ),
        MGSpacing.hXs,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$playerMp/$playerMaxMp',
            style: MGTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnemyInfo() {
    final percentage =
        enemyMaxHp != null && enemyMaxHp! > 0 ? enemyHp! / enemyMaxHp! : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            enemyName ?? 'Enemy',
            style: MGTextStyles.hud.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          MGSpacing.vXs,
          MGLinearProgress(
            value: percentage,
            height: 12,
            valueColor: Colors.red,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            borderRadius: 6,
          ),
          MGSpacing.vXs,
          Text(
            'HP: $enemyHp/$enemyMaxHp',
            style: MGTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// 가챠 시스템 어댑터 - MG-0005 Roguelike Puzzle Dungeon
library;

import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/gacha/gacha_config.dart';
import 'package:mg_common_game/systems/gacha/gacha_manager.dart';

/// 게임 내 Card 모델
class Card {
  final String id;
  final String name;
  final GachaRarity rarity;
  final Map<String, dynamic> stats;

  const Card({
    required this.id,
    required this.name,
    required this.rarity,
    this.stats = const {},
  });
}

/// Roguelike Puzzle Dungeon 가챠 어댑터
class CardGachaAdapter extends ChangeNotifier {
  final GachaManager _gachaManager = GachaManager(
    pityConfig: const PityConfig(
      softPityStart: 70,
      hardPity: 80,
      softPityBonus: 6.0,
    ),
    multiPullGuarantee: const MultiPullGuarantee(
      minRarity: GachaRarity.rare,
    ),
  );

  static const String _poolId = 'dungeon_pool';

  CardGachaAdapter() {
    _initPool();
  }

  void _initPool() {
    final pool = GachaPool(
      id: _poolId,
      name: 'Roguelike Puzzle Dungeon 가챠',
      items: _generateItems(),
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 365)),
    );
    _gachaManager.registerPool(pool);
  }

  List<GachaItem> _generateItems() {
    return [
      // UR (0.6%)
      GachaItem(id: 'ur_dungeon_001', name: '전설의 Card', rarity: GachaRarity.ultraRare, weight: 1.0),
      GachaItem(id: 'ur_dungeon_002', name: '신화의 Card', rarity: GachaRarity.ultraRare, weight: 1.0),
      // SSR (2.4%)
      GachaItem(id: 'ssr_dungeon_001', name: '영웅의 Card', rarity: GachaRarity.superSuperRare, weight: 1.0),
      GachaItem(id: 'ssr_dungeon_002', name: '고대의 Card', rarity: GachaRarity.superSuperRare, weight: 1.0),
      GachaItem(id: 'ssr_dungeon_003', name: '황금의 Card', rarity: GachaRarity.superSuperRare, weight: 1.0),
      // SR (12%)
      GachaItem(id: 'sr_dungeon_001', name: '희귀한 Card A', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_dungeon_002', name: '희귀한 Card B', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_dungeon_003', name: '희귀한 Card C', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_dungeon_004', name: '희귀한 Card D', rarity: GachaRarity.superRare, weight: 1.0),
      // R (35%)
      GachaItem(id: 'r_dungeon_001', name: '우수한 Card A', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_dungeon_002', name: '우수한 Card B', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_dungeon_003', name: '우수한 Card C', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_dungeon_004', name: '우수한 Card D', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_dungeon_005', name: '우수한 Card E', rarity: GachaRarity.rare, weight: 1.0),
      // N (50%)
      GachaItem(id: 'n_dungeon_001', name: '일반 Card A', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeon_002', name: '일반 Card B', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeon_003', name: '일반 Card C', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeon_004', name: '일반 Card D', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeon_005', name: '일반 Card E', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeon_006', name: '일반 Card F', rarity: GachaRarity.normal, weight: 1.0),
    ];
  }

  /// 단일 뽑기
  Card? pullSingle() {
    final result = _gachaManager.pull(_poolId);
    if (result == null) return null;
    notifyListeners();
    return _convertToItem(result.item);
  }

  /// 10연차
  List<Card> pullTen() {
    final results = _gachaManager.multiPull(_poolId, count: 10);
    notifyListeners();
    return results.map((r) => _convertToItem(r.item)).toList();
  }

  Card _convertToItem(GachaItem item) {
    return Card(
      id: item.id,
      name: item.name,
      rarity: item.rarity,
    );
  }

  /// 천장까지 남은 횟수
  int get pullsUntilPity => _gachaManager.remainingPity(_poolId);

  /// 총 뽑기 횟수
  int get totalPulls => _gachaManager.getPityState(_poolId)?.totalPulls ?? 0;

  /// 통계
  GachaStats get stats => _gachaManager.getStats(_poolId);

  Map<String, dynamic> toJson() => _gachaManager.toJson();
  void loadFromJson(Map<String, dynamic> json) {
    _gachaManager.loadFromJson(json);
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';

enum SkinRarity { common, rare, epic, legendary }

class CharacterSkin {
  final String id;
  final String name;
  final String description;
  final SkinRarity rarity;
  final int cost;
  final String assetPath;
  bool isOwned;
  bool isEquipped;

  CharacterSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.cost,
    required this.assetPath,
    this.isOwned = false,
    this.isEquipped = false,
  });

  double get incomeBonus {
    switch (rarity) {
      case SkinRarity.common:
        return 1.0;
      case SkinRarity.rare:
        return 1.1;
      case SkinRarity.epic:
        return 1.25;
      case SkinRarity.legendary:
        return 1.5;
    }
  }

  int get xpBonus {
    switch (rarity) {
      case SkinRarity.common:
        return 0;
      case SkinRarity.rare:
        return 5;
      case SkinRarity.epic:
        return 10;
      case SkinRarity.legendary:
        return 20;
    }
  }
}

class CharacterSkinManager extends ChangeNotifier {
  final GoldManager _goldManager = GetIt.I<GoldManager>();
  final List<CharacterSkin> _skins = [];

  List<CharacterSkin> get skins => _skins;
  List<CharacterSkin> get ownedSkins => _skins.where((s) => s.isOwned).toList();
  CharacterSkin? get equippedSkin =>
      _skins.firstWhere((s) => s.isEquipped, orElse: () => _skins.first);

  CharacterSkinManager() {
    _initializeSkins();
  }

  void _initializeSkins() {
    _skins.addAll([
      // Common Skins (Free)
      CharacterSkin(
        id: 'basic_adventurer',
        name: '모험가',
        description: '기본 모험가 스킨',
        rarity: SkinRarity.common,
        cost: 0,
        assetPath: 'assets/images/character_skin_basic.png',
        isOwned: true,
        isEquipped: true,
      ),
      CharacterSkin(
        id: 'villager',
        name: '마을 사람',
        description: '소박한 마을 주민',
        rarity: SkinRarity.common,
        cost: 0,
        assetPath: 'assets/images/character_skin_basic.png',
        isOwned: true,
      ),

      // Rare Skins (100-500 gold)
      CharacterSkin(
        id: 'scout',
        name: '정찰병',
        description: '빠른 이동에 특화된 정찰병',
        rarity: SkinRarity.rare,
        cost: 100,
        assetPath: 'assets/images/character_skin_basic.png',
      ),
      CharacterSkin(
        id: 'ninja',
        name: '닌자',
        description: '그림자 속의 암살자',
        rarity: SkinRarity.rare,
        cost: 250,
        assetPath: 'assets/images/character_skin_ninja.png',
      ),
      CharacterSkin(
        id: 'archer',
        name: '궁수',
        description: '정확한 사격의 달인',
        rarity: SkinRarity.rare,
        cost: 300,
        assetPath: 'assets/images/character_skin_basic.png',
      ),
      CharacterSkin(
        id: 'squire',
        name: '종자 기사',
        description: '기사가 되기를 꿈꾸는 종자',
        rarity: SkinRarity.rare,
        cost: 400,
        assetPath: 'assets/images/character_skin_basic.png',
      ),
      CharacterSkin(
        id: 'thief',
        name: '도적',
        description: '재빠른 손놀림의 도적',
        rarity: SkinRarity.rare,
        cost: 500,
        assetPath: 'assets/images/character_skin_basic.png',
      ),

      // Epic Skins (1000-2000 gold)
      CharacterSkin(
        id: 'punk',
        name: '펑크 록커',
        description: '리듬에 맞춰 난다!',
        rarity: SkinRarity.epic,
        cost: 1000,
        assetPath: 'assets/images/character_skin_punk.png',
      ),
      CharacterSkin(
        id: 'samurai',
        name: '사무라이',
        description: '명예와 검을 지키는 무사',
        rarity: SkinRarity.epic,
        cost: 1200,
        assetPath: 'assets/images/character_skin_basic.png',
      ),
      CharacterSkin(
        id: 'dark_knight',
        name: '다크 나이트',
        description: '어둠의 기사',
        rarity: SkinRarity.epic,
        cost: 1500,
        assetPath: 'assets/images/character_skin_basic.png',
      ),
      CharacterSkin(
        id: 'wizard',
        name: '마법사',
        description: '고대 마법의 사용자',
        rarity: SkinRarity.epic,
        cost: 1800,
        assetPath: 'assets/images/character_skin_basic.png',
      ),
      CharacterSkin(
        id: 'pirate_captain',
        name: '해적 선장',
        description: '일곱 바다의 지배자',
        rarity: SkinRarity.epic,
        cost: 2000,
        assetPath: 'assets/images/character_skin_basic.png',
      ),

      // Legendary Skins (5000+ gold)
      CharacterSkin(
        id: 'robot',
        name: '메카 로봇',
        description: '최첨단 기술의 결정체',
        rarity: SkinRarity.legendary,
        cost: 5000,
        assetPath: 'assets/images/character_skin_robot.png',
      ),
      CharacterSkin(
        id: 'dragon_warrior',
        name: '드래곤 워리어',
        description: '용의 힘을 가진 전사',
        rarity: SkinRarity.legendary,
        cost: 7500,
        assetPath: 'assets/images/character_skin_basic.png',
      ),
      CharacterSkin(
        id: 'celestial',
        name: '천상의 존재',
        description: '별에서 내려온 신성한 존재',
        rarity: SkinRarity.legendary,
        cost: 10000,
        assetPath: 'assets/images/character_skin_basic.png',
      ),
    ]);
  }

  List<CharacterSkin> getSkinsByRarity(SkinRarity rarity) {
    return _skins.where((skin) => skin.rarity == rarity).toList();
  }

  List<CharacterSkin> getAvailableSkins() {
    return _skins.where((skin) => !skin.isOwned).toList();
  }

  bool purchaseSkin(String skinId) {
    final skin = _skins.firstWhere(
      (s) => s.id == skinId,
      orElse: () => _skins.first,
    );

    if (skin.isOwned) return false;
    if (_goldManager.currentGold < skin.cost) return false;

    _goldManager.trySpendGold(skin.cost);
    skin.isOwned = true;
    notifyListeners();
    return true;
  }

  bool equipSkin(String skinId) {
    final skin = _skins.firstWhere(
      (s) => s.id == skinId,
      orElse: () => _skins.first,
    );

    if (!skin.isOwned) return false;

    // Unequip current skin
    for (var s in _skins) {
      s.isEquipped = false;
    }

    // Equip new skin
    skin.isEquipped = true;
    notifyListeners();
    return true;
  }

  CharacterSkin? getSkinById(String id) {
    try {
      return _skins.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  int getTotalOwnedSkins() {
    return ownedSkins.length;
  }

  double getCurrentBonus() {
    final skin = equippedSkin;
    if (skin == null) return 1.0;
    return skin.incomeBonus;
  }

  int getCurrentXpBonus() {
    final skin = equippedSkin;
    if (skin == null) return 0;
    return skin.xpBonus;
  }
}

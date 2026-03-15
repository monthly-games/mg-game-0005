import 'package:mg_common_game/core/assets/asset_types.dart';

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Dungeon Hero ─────────────────────────────────────────────

const kDungeonHeroMeta = SpineAssetMeta(
  key: 'dungeon_hero',
  path: 'spine/characters/dungeon_hero',
  atlasPath:
      'assets/spine/characters/dungeon_hero/dungeon_hero.atlas',
  skeletonPath:
      'assets/spine/characters/dungeon_hero/dungeon_hero.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Dungeon Scout ────────────────────────────────────────────

const kDungeonScoutMeta = SpineAssetMeta(
  key: 'dungeon_scout',
  path: 'spine/characters/dungeon_scout',
  atlasPath:
      'assets/spine/characters/dungeon_scout/dungeon_scout.atlas',
  skeletonPath:
      'assets/spine/characters/dungeon_scout/dungeon_scout.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Dungeon Healer ───────────────────────────────────────────

const kDungeonHealerMeta = SpineAssetMeta(
  key: 'dungeon_healer',
  path: 'spine/characters/dungeon_healer',
  atlasPath:
      'assets/spine/characters/dungeon_healer/dungeon_healer.atlas',
  skeletonPath:
      'assets/spine/characters/dungeon_healer/dungeon_healer.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

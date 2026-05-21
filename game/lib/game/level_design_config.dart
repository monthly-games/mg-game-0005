class GameLevelDesign {
  const GameLevelDesign({
    required this.levelIndex,
    required this.stage,
    required this.wave,
    required this.difficulty,
    required this.objective,
    required this.goldReward,
    required this.xpReward,
    required this.progressionUnlock,
  });

  final int levelIndex;
  final String stage;
  final int wave;
  final double difficulty;
  final String objective;
  final int goldReward;
  final int xpReward;
  final String progressionUnlock;
}

const kGameTitle = 'Roguelike Puzzle Dungeon';
const kCoreFunLoop = 'Solve and Combo';

const kCoreLoopPillars = <String>[
  'Start',
  'Act',
  'React',
  'Reward',
  'Upgrade',
  'Return',
];

const kLevelTensionBeats = <String>[
  'onboarding',
  'first_choice',
  'combo_lesson',
  'pressure_spike',
  'midgame_twist',
  'boss_gate',
  'mastery_remix',
  'repeatable_loop',
];

const kDefaultBalancingConfig = <String, Object>{
  'difficultyCurve': 'eight_step_three_act',
  'targetSessionSeconds': 120,
  'rewardCadence': 'every_level_with_boss_bonus',
  'progressionReset': 'repeatable_loop',
  'failureRecovery': 'keep_progress_retry_level',
};

const kMetaProgressionSystems = <String>[
  'DailyQuest',
  'Achievement',
  'BattlePass',
  'Gacha',
  'Collection',
  'Progression',
];

const kLevelDesign = <GameLevelDesign>[
  GameLevelDesign(levelIndex: 1, stage: 'Onboarding', wave: 1, difficulty: 1.00, objective: 'Chain a combo: Learn the core action', goldReward: 50, xpReward: 20, progressionUnlock: 'tutorial complete'),
  GameLevelDesign(levelIndex: 2, stage: 'First Choice', wave: 2, difficulty: 1.15, objective: 'Chain a combo: Choose the first upgrade path', goldReward: 80, xpReward: 35, progressionUnlock: 'daily quest'),
  GameLevelDesign(levelIndex: 3, stage: 'Combo Lesson', wave: 3, difficulty: 1.35, objective: 'Chain a combo: Chain two systems for a stronger result', goldReward: 120, xpReward: 54, progressionUnlock: 'upgrade option'),
  GameLevelDesign(levelIndex: 4, stage: 'Pressure Spike', wave: 4, difficulty: 1.65, objective: 'Chain a combo: React before timer or resource pressure peaks', goldReward: 170, xpReward: 78, progressionUnlock: 'booster'),
  GameLevelDesign(levelIndex: 5, stage: 'Midgame Twist', wave: 5, difficulty: 1.95, objective: 'Chain a combo: Solve a secondary objective while staying efficient', goldReward: 235, xpReward: 108, progressionUnlock: 'collection slot'),
  GameLevelDesign(levelIndex: 6, stage: 'Boss Gate', wave: 6, difficulty: 2.30, objective: 'Chain a combo: Clear the boss wave and protect progress', goldReward: 315, xpReward: 144, progressionUnlock: 'rank promotion'),
  GameLevelDesign(levelIndex: 7, stage: 'Mastery Remix', wave: 7, difficulty: 2.70, objective: 'Chain a combo: Combine three decisions under higher pressure', goldReward: 410, xpReward: 188, progressionUnlock: 'tournament ticket'),
  GameLevelDesign(levelIndex: 8, stage: 'Repeatable Loop', wave: 8, difficulty: 3.15, objective: 'Chain a combo: Return for a harder run and better reward', goldReward: 525, xpReward: 240, progressionUnlock: 'season score'),
];

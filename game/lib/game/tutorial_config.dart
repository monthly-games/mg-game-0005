import 'package:mg_common_game/systems/tutorial/tutorial.dart';
import 'package:mg_common_game/systems/tutorial/tutorial_data.dart';

const kOnboardingTutorial = TutorialConfig(
  id: 'onboarding',
  name: 'Roguelike Puzzle Dungeon Tutorial',
  skippable: true,
  showOnFirstLaunch: true,
  trigger: TutorialTrigger.firstLaunch,
  steps: [
    TutorialStep(
      id: 'welcome',
      title: 'Welcome',
      description: 'Learn the main goal and the first action before starting a run.',
      actionHint: 'Tap Next',
    ),
    TutorialStep(
      id: 'core_action',
      title: 'Core Action',
      description: 'Use the highlighted action to create progress during the session.',
      actionHint: 'Try the main action',
    ),
    TutorialStep(
      id: 'reward',
      title: 'Rewards',
      description: 'Complete objectives to earn currency, experience, and unlocks.',
      actionHint: 'Claim rewards',
    ),
    TutorialStep(
      id: 'return_loop',
      title: 'Return Stronger',
      description: 'Upgrade, return to the next level, and repeat the loop with higher pressure.',
      actionHint: 'Start playing',
    ),
  ],
);

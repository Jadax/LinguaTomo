import 'achievement_data.dart';

class MiniAchievementDefinition {
  const MiniAchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
  });

  final String id;
  final String title;
  final String description;
  final int Function(AchievementSnapshot) progress;
  final int target;

  bool unlocked(AchievementSnapshot snapshot) => progress(snapshot) >= target;
}

final miniAchievements = <MiniAchievementDefinition>[
  MiniAchievementDefinition(
    id: 'mini_first_lesson',
    title: 'First Lesson',
    description: 'Complete your first word lesson.',
    progress: (s) => s.wordLessonsCompleted,
    target: 1,
  ),
  MiniAchievementDefinition(
    id: 'mini_10_lessons',
    title: 'Lesson Regular',
    description: 'Complete 10 word lessons.',
    progress: (s) => s.wordLessonsCompleted,
    target: 10,
  ),
  MiniAchievementDefinition(
    id: 'mini_50_lessons',
    title: 'Dedicated Learner',
    description: 'Complete 50 word lessons.',
    progress: (s) => s.wordLessonsCompleted,
    target: 50,
  ),
  MiniAchievementDefinition(
    id: 'mini_100_lessons',
    title: 'Lesson Marathon',
    description: 'Complete 100 word lessons.',
    progress: (s) => s.wordLessonsCompleted,
    target: 100,
  ),
  MiniAchievementDefinition(
    id: 'mini_perfect',
    title: 'Flawless',
    description: 'Get 100% in a word lesson.',
    progress: (s) => s.perfectLessons,
    target: 1,
  ),
  MiniAchievementDefinition(
    id: 'mini_5_perfect',
    title: 'High Five',
    description: 'Get 5 perfect word lessons.',
    progress: (s) => s.perfectLessons,
    target: 5,
  ),
  MiniAchievementDefinition(
    id: 'mini_10_perfect',
    title: 'Perfectionist',
    description: 'Get 10 perfect word lessons.',
    progress: (s) => s.perfectLessons,
    target: 10,
  ),
  MiniAchievementDefinition(
    id: 'mini_first_postcard',
    title: 'Postcard Started',
    description: 'Read your first postcard.',
    progress: (s) => s.postcards,
    target: 1,
  ),
  MiniAchievementDefinition(
    id: 'mini_first_grammar',
    title: 'Grammar Curious',
    description: 'Open your first grammar lesson.',
    progress: (s) => s.grammarPlanted,
    target: 1,
  ),
  MiniAchievementDefinition(
    id: 'mini_first_mission',
    title: 'Can-Do Starter',
    description: 'Complete your first Can-Do mission.',
    progress: (s) => s.missions,
    target: 1,
  ),
  MiniAchievementDefinition(
    id: 'mini_all_tiers',
    title: 'Tier Champion',
    description: 'Unlock all 5 difficulty tiers.',
    progress: (s) => s.tiersUnlocked,
    target: 5,
  ),
  MiniAchievementDefinition(
    id: 'mini_first_category',
    title: 'Category Complete',
    description: 'Complete all words in one category.',
    progress: (s) => s.categoriesCompleted,
    target: 1,
  ),
  MiniAchievementDefinition(
    id: 'mini_half_words',
    title: 'Halfway There',
    description: 'Learn 100 of the 400 words.',
    progress: (s) => s.wordsLearned,
    target: 100,
  ),
  MiniAchievementDefinition(
    id: 'mini_word_streak_3',
    title: 'Word Streak',
    description: 'Learn words 3 days in a row.',
    progress: (s) => s.wordStreak,
    target: 3,
  ),
  MiniAchievementDefinition(
    id: 'mini_word_streak_7',
    title: 'Week of Words',
    description: 'Learn words 7 days in a row.',
    progress: (s) => s.wordStreak,
    target: 7,
  ),
  MiniAchievementDefinition(
    id: 'mini_first_handwriting',
    title: 'Pen Pal',
    description: 'Save your first handwriting check.',
    progress: (s) => s.handwritingAttempts,
    target: 1,
  ),
];

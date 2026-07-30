import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ExperienceMode { visualExplorer, standard, comfort }

enum WordCategory {
  greetings,
  home,
  people,
  food,
  activities,
  places,
  nature,
  animals,
}

extension WordCategoryX on WordCategory {
  String get label => switch (this) {
    WordCategory.greetings => 'Greetings & Phrases',
    WordCategory.home => 'Home & Daily Life',
    WordCategory.people => 'People & Family',
    WordCategory.food => 'Food & Drink',
    WordCategory.activities => 'Activities & Sports',
    WordCategory.places => 'Places & Travel',
    WordCategory.nature => 'Nature & World',
    WordCategory.animals => 'Animals & Pets',
  };

  String get emoji => switch (this) {
    WordCategory.greetings => '👋',
    WordCategory.home => '🏠',
    WordCategory.people => '👨‍👩‍👧',
    WordCategory.food => '🍜',
    WordCategory.activities => '⚽',
    WordCategory.places => '✈️',
    WordCategory.nature => '🌍',
    WordCategory.animals => '🐱',
  };
}

enum DifficultyTier {
  starter,
  elementary,
  intermediate,
  advanced,
  expert,
}

extension DifficultyTierX on DifficultyTier {
  String get label => switch (this) {
    DifficultyTier.starter => 'Starter',
    DifficultyTier.elementary => 'Elementary',
    DifficultyTier.intermediate => 'Intermediate',
    DifficultyTier.advanced => 'Advanced',
    DifficultyTier.expert => 'Expert',
  };

  String get description => switch (this) {
    DifficultyTier.starter => 'Your first words — greetings, home, food and animals',
    DifficultyTier.elementary =>
      'Everyday life — family, places, activities and nature',
    DifficultyTier.intermediate =>
      'Conversations — feelings, descriptions and daily routines',
    DifficultyTier.advanced =>
      'Complex topics — abstract ideas and detailed expression',
    DifficultyTier.expert =>
      'Nuanced language — formal registers and specialist vocabulary',
  };

  int get wordCount => switch (this) {
    DifficultyTier.starter => 40,
    DifficultyTier.elementary => 40,
    DifficultyTier.intermediate => 40,
    DifficultyTier.advanced => 40,
    DifficultyTier.expert => 40,
  };
}

enum NestEnvironment {
  fireside,
  springVeranda,
  nightTrain,
  snowLodge,
  japanHome,
  rainyLibrary,
}

extension NestEnvironmentX on NestEnvironment {
  String get label => switch (this) {
    NestEnvironment.fireside => 'Fireside Nest',
    NestEnvironment.springVeranda => 'Sakura Veranda',
    NestEnvironment.nightTrain => 'Night Train Nook',
    NestEnvironment.snowLodge => 'Snow-country Lodge',
    NestEnvironment.japanHome => 'Home in Japan',
    NestEnvironment.rainyLibrary => 'Rainy Reading Room',
  };

  String get asset => switch (this) {
    NestEnvironment.fireside => 'assets/branding/nest-home-pixel.webp',
    NestEnvironment.springVeranda => 'assets/branding/nest-spring-pixel.webp',
    NestEnvironment.nightTrain => 'assets/branding/nest-journey-pixel.webp',
    NestEnvironment.snowLodge => 'assets/branding/nest-winter-pixel.webp',
    NestEnvironment.japanHome => 'assets/branding/nest-japan-pixel.webp',
    NestEnvironment.rainyLibrary => 'assets/branding/leo-nest-room.webp',
  };
}

enum JourneyStart { starter, elementary, intermediate, advanced, expert }

extension JourneyStartX on JourneyStart {
  String get label => switch (this) {
    JourneyStart.starter => 'Starter',
    JourneyStart.elementary => 'Elementary',
    JourneyStart.intermediate => 'Intermediate',
    JourneyStart.advanced => 'Advanced',
    JourneyStart.expert => 'Expert',
  };

  String get guide => switch (this) {
    JourneyStart.starter => 'I am beginning with kana and first conversations.',
    JourneyStart.elementary => 'I know some basics and may be around JLPT N5.',
    JourneyStart.intermediate =>
      'I can manage daily topics and may be around N4 or N3.',
    JourneyStart.advanced =>
      'I can follow detailed Japanese and may be around N2.',
    JourneyStart.expert =>
      'I am preparing for N1 and professional working ability.',
  };

  int get suggestedPlacementSkip => switch (this) {
    JourneyStart.starter => 0,
    JourneyStart.elementary => 2,
    JourneyStart.intermediate => 6,
    JourneyStart.advanced => 12,
    JourneyStart.expert => 16,
  };
}

@immutable
class LearnerProfile {
  const LearnerProfile({this.start, this.onboardingComplete = false});

  final JourneyStart? start;
  final bool onboardingComplete;
}

extension ExperienceModeX on ExperienceMode {
  String get label => switch (this) {
    ExperienceMode.visualExplorer => 'Visual Explorer',
    ExperienceMode.standard => 'Standard',
    ExperienceMode.comfort => 'Comfort',
  };

  String get description => switch (this) {
    ExperienceMode.visualExplorer =>
      'Large visuals, narration, and minimal typing',
    ExperienceMode.standard => 'The complete cosy, animated experience',
    ExperienceMode.comfort => 'Large type, strong contrast, and reduced motion',
  };
}

enum ProficiencyStage {
  kittenSteps,
  firstEncounters,
  dailyLife,
  independent,
  connected,
  professional,
}

extension ProficiencyStageX on ProficiencyStage {
  String get label => switch (this) {
    ProficiencyStage.kittenSteps => 'Kitten Steps',
    ProficiencyStage.firstEncounters => 'First Encounters',
    ProficiencyStage.dailyLife => 'Daily Life',
    ProficiencyStage.independent => 'Independent Japan',
    ProficiencyStage.connected => 'Connected Japan',
    ProficiencyStage.professional => 'Professional Japan',
  };

  String get jlpt => switch (this) {
    ProficiencyStage.kittenSteps => 'Pre-N5',
    ProficiencyStage.firstEncounters => 'N5',
    ProficiencyStage.dailyLife => 'N4',
    ProficiencyStage.independent => 'N3',
    ProficiencyStage.connected => 'N2',
    ProficiencyStage.professional => 'N1+',
  };

  String get cefr => switch (this) {
    ProficiencyStage.kittenSteps => 'Pre-A1',
    ProficiencyStage.firstEncounters => 'A1',
    ProficiencyStage.dailyLife => 'A2',
    ProficiencyStage.independent => 'B1',
    ProficiencyStage.connected => 'B2',
    ProficiencyStage.professional => 'C1',
  };

  String get ilr => switch (this) {
    ProficiencyStage.kittenSteps => 'ILR 0',
    ProficiencyStage.firstEncounters => 'ILR 0+',
    ProficiencyStage.dailyLife => 'ILR 1',
    ProficiencyStage.independent => 'ILR 1+/2',
    ProficiencyStage.connected => 'ILR 2',
    ProficiencyStage.professional => 'ILR 2+/3',
  };
}

enum SkillArea { listening, speaking, reading, writing, interaction, culture }

extension SkillAreaX on SkillArea {
  String get label => name[0].toUpperCase() + name.substring(1);

  IconData get icon => switch (this) {
    SkillArea.listening => Icons.headphones_rounded,
    SkillArea.speaking => Icons.mic_rounded,
    SkillArea.reading => Icons.menu_book_rounded,
    SkillArea.writing => Icons.draw_rounded,
    SkillArea.interaction => Icons.forum_rounded,
    SkillArea.culture => Icons.temple_buddhist_rounded,
  };
}

@immutable
class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.district,
    required this.canDo,
    required this.stage,
    required this.skills,
    required this.phrase,
    required this.reading,
    required this.translation,
    required this.options,
    required this.correctOption,
    required this.cultureNote,
    required this.reward,
    required this.rewardEmoji,
    this.prerequisite,
    this.xp = 50,
  });

  final String id;
  final String title;
  final String district;
  final String canDo;
  final ProficiencyStage stage;
  final Set<SkillArea> skills;
  final String phrase;
  final String reading;
  final String translation;
  final List<String> options;
  final int correctOption;
  final String cultureNote;
  final String reward;
  final String rewardEmoji;
  final String? prerequisite;
  final int xp;
}

@immutable
class DailyPostcard {
  const DailyPostcard({
    required this.id,
    required this.location,
    required this.emoji,
    required this.words,
    required this.phrase,
    required this.translation,
    required this.cultureNote,
  });

  final String id;
  final String location;
  final String emoji;
  final List<String> words;
  final String phrase;
  final String translation;
  final String cultureNote;
}

@immutable
class LearnerProgress {
  const LearnerProgress({
    this.completedMissions = const {},
    this.placedOutMissions = const {},
    this.completedPostcards = const {},
    this.unlockedRewards = const {'Welcome cushion'},
    this.skillEvidence = const {},
    this.activityDates = const {},
    this.xp = 0,
    this.streakFreezes = 2,
  });

  final Set<String> completedMissions;
  final Set<String> placedOutMissions;
  final Set<String> completedPostcards;
  final Set<String> unlockedRewards;
  final Map<SkillArea, int> skillEvidence;
  final Set<String> activityDates;
  final int xp;
  final int streakFreezes;

  LearnerProgress copyWith({
    Set<String>? completedMissions,
    Set<String>? placedOutMissions,
    Set<String>? completedPostcards,
    Set<String>? unlockedRewards,
    Map<SkillArea, int>? skillEvidence,
    Set<String>? activityDates,
    int? xp,
    int? streakFreezes,
  }) => LearnerProgress(
    completedMissions: completedMissions ?? this.completedMissions,
    placedOutMissions: placedOutMissions ?? this.placedOutMissions,
    completedPostcards: completedPostcards ?? this.completedPostcards,
    unlockedRewards: unlockedRewards ?? this.unlockedRewards,
    skillEvidence: skillEvidence ?? this.skillEvidence,
    activityDates: activityDates ?? this.activityDates,
    xp: xp ?? this.xp,
    streakFreezes: streakFreezes ?? this.streakFreezes,
  );

  /// Value equality keeps Riverpod from rebuilding — and the cloud debounce
  /// from re-syncing — when a merge or restore produces identical progress.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearnerProgress &&
          setEquals(completedMissions, other.completedMissions) &&
          setEquals(placedOutMissions, other.placedOutMissions) &&
          setEquals(completedPostcards, other.completedPostcards) &&
          setEquals(unlockedRewards, other.unlockedRewards) &&
          mapEquals(skillEvidence, other.skillEvidence) &&
          setEquals(activityDates, other.activityDates) &&
          xp == other.xp &&
          streakFreezes == other.streakFreezes;

  @override
  int get hashCode => Object.hash(
    completedMissions.length,
    placedOutMissions.length,
    completedPostcards.length,
    unlockedRewards.length,
    skillEvidence.length,
    activityDates.length,
    xp,
    streakFreezes,
  );

  int get verifiedCanDos => completedMissions.length;

  int get streak => consecutiveDayStreak(activityDates);

  int get level => (xp / 100).floor();

  String get levelTitle => switch (level) {
    < 5 => 'Explorer',
    < 10 => 'Traveller',
    < 20 => 'Scholar',
    < 35 => 'Sage',
    < 50 => 'Master',
    _ => 'Grand Master',
  };

  ProficiencyStage get stage {
    final count = {...completedMissions, ...placedOutMissions}.length;
    if (count >= 18) return ProficiencyStage.professional;
    if (count >= 14) return ProficiencyStage.connected;
    if (count >= 10) return ProficiencyStage.independent;
    if (count >= 6) return ProficiencyStage.dailyLife;
    if (count >= 2) return ProficiencyStage.firstEncounters;
    return ProficiencyStage.kittenSteps;
  }
}

@immutable
class HandwritingRecord {
  const HandwritingRecord({
    required this.character,
    required this.score,
    required this.accuracy,
    required this.balance,
    required this.createdAt,
    required this.evidenceMode,
  });

  final String character;
  final int score;
  final int accuracy;
  final int balance;
  final DateTime createdAt;
  final String evidenceMode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HandwritingRecord &&
          character == other.character &&
          score == other.score &&
          accuracy == other.accuracy &&
          balance == other.balance &&
          createdAt == other.createdAt &&
          evidenceMode == other.evidenceMode;

  @override
  int get hashCode =>
      Object.hash(character, score, accuracy, balance, createdAt, evidenceMode);
}

@immutable
class Word {
  const Word({
    required this.id,
    required this.japanese,
    required this.romaji,
    required this.english,
    required this.category,
    required this.tier,
    required this.emoji,
    this.exampleSentence,
    this.exampleTranslation,
  });

  final String id;
  final String japanese;
  final String romaji;
  final String english;
  final WordCategory category;
  final DifficultyTier tier;
  final String emoji;
  final String? exampleSentence;
  final String? exampleTranslation;

  bool get hasExample => exampleSentence != null && exampleSentence!.isNotEmpty;
}

/// The canonical `YYYY-MM-DD` key for a local calendar day. Every streak,
/// activity set and daily goal in the app must use this one function, so a
/// day recorded by one feature is always the same day to every other.
String dateKey(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

/// Counts back from today over consecutive days present in [activityDates].
///
/// A learner who has not studied yet today keeps yesterday's streak, so the
/// number never drops until a whole day has genuinely been missed.
int consecutiveDayStreak(Set<String> activityDates) {
  if (activityDates.isEmpty) return 0;
  var cursor = DateTime.now();
  var count = 0;
  while (activityDates.contains(dateKey(cursor))) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  if (count == 0) {
    cursor = DateTime.now().subtract(const Duration(days: 1));
    while (activityDates.contains(dateKey(cursor))) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
  }
  return count;
}

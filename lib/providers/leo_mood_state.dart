import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'word_progress_state.dart';
import 'review_state.dart';

enum LeoMood { excited, proud, sleepy, curious, playful, encouraging, cozy }

extension LeoMoodX on LeoMood {
  String get label => switch (this) {
    LeoMood.excited => 'Excited',
    LeoMood.proud => 'Proud',
    LeoMood.sleepy => 'Sleepy',
    LeoMood.curious => 'Curious',
    LeoMood.playful => 'Playful',
    LeoMood.encouraging => 'Encouraging',
    LeoMood.cozy => 'Cozy',
  };

  String get greeting => switch (this) {
    LeoMood.excited => "You're on a roll! Let's keep going!",
    LeoMood.proud => "I'm so proud of how far you've come!",
    LeoMood.sleepy => "Welcome back! I missed you.",
    LeoMood.curious => "There's something to review — shall we?",
    LeoMood.playful => "Purr! Ready for an adventure?",
    LeoMood.encouraging => "You're doing great. Every word counts!",
    LeoMood.cozy => "Nice to see you! What shall we learn?",
  };
}

const _wordMilestones = [5, 10, 25, 50, 75, 100, 150, 200, 300, 500];

final leoMoodProvider = Provider<LeoMood>((ref) {
  final progress = ref.watch(progressProvider);
  final wordProgress = ref.watch(wordProgressProvider);
  final reviewDeck = ref.watch(reviewDeckProvider);

  final words = wordProgress.wordsLearned;

  // 1. Milestone pride
  if (_wordMilestones.contains(words)) return LeoMood.proud;

  // 2. Streak excitement (3+ days)
  if (progress.streak >= 3) return LeoMood.excited;

  // 3. Due reviews — curious
  if (reviewDeck.dueMissions.isNotEmpty) return LeoMood.curious;

  // 4. Inactivity, while a first visit remains a warm welcome.
  final lastActive = wordProgress.wordActivityDates.isEmpty
      ? null
      : wordProgress.wordActivityDates.reduce(
          (a, b) => a.compareTo(b) > 0 ? a : b,
        );
  final hasStartedLearning =
      words > 0 || wordProgress.wordLessonHistory.isNotEmpty;
  if (hasStartedLearning && lastActive != null) {
    final lastDate = DateTime.tryParse(lastActive);
    if (lastDate != null) {
      final daysSince = DateTime.now().difference(lastDate).inDays;
      if (daysSince >= 2) return LeoMood.sleepy;
    }
  }

  // 5. Recent performance — encouraging if few perfects relative to lessons
  final totalLessons = wordProgress.wordLessonHistory.length;
  if (totalLessons >= 3) {
    final perfectRatio = wordProgress.perfectLessonCount / totalLessons;
    if (perfectRatio < 0.4) return LeoMood.encouraging;
  }

  // 6. Random playful (~14% chance based on time-of-day hour)
  final hour = DateTime.now().hour;
  if (hour % 7 == 3) return LeoMood.playful;

  // 7. Default cozy
  return LeoMood.cozy;
});

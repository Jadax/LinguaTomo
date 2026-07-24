import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/festival_calendar_data.dart';
import 'app_state.dart';

class SeasonalProgress {
  const SeasonalProgress({
    required this.month,
    required this.year,
    required this.lessonsCompleted,
    required this.wordsLearned,
    required this.xpEarned,
    required this.activeFestivals,
  });

  final int month;
  final int year;
  final int lessonsCompleted;
  final int wordsLearned;
  final int xpEarned;
  final List<FestivalEvent> activeFestivals;

  String get seasonName => switch (month) {
    1 || 2 || 12 => 'Winter',
    3 || 4 || 5 => 'Spring',
    6 || 7 || 8 => 'Summer',
    _ => 'Autumn',
  };

  String get monthName => switch (month) {
    1 => 'January',
    2 => 'February',
    3 => 'March',
    4 => 'April',
    5 => 'May',
    6 => 'June',
    7 => 'July',
    8 => 'August',
    9 => 'September',
    10 => 'October',
    11 => 'November',
    _ => 'December',
  };

  int get targetLessons => 20;

  double get lessonProgress =>
      (lessonsCompleted / targetLessons).clamp(0.0, 1.0);

  bool get completedSeason => lessonsCompleted >= targetLessons;

  String get reward => completedSeason
      ? 'Season Champion badge'
      : '$lessonsCompleted/$targetLessons lessons towards your $seasonName badge';
}

final seasonalProgressProvider = Provider<SeasonalProgress>((ref) {
  final progress = ref.watch(progressProvider);
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  final activeFestivals = festivalCalendar
      .where((f) => f.isCurrent(now))
      .toList();

  return SeasonalProgress(
    month: currentMonth,
    year: currentYear,
    lessonsCompleted: progress.activityDates
        .where((date) {
          final parsed = DateTime.tryParse(date);
          return parsed != null &&
              parsed.month == currentMonth &&
              parsed.year == currentYear;
        })
        .length,
    wordsLearned: progress.completedMissions.length,
    xpEarned: progress.xp,
    activeFestivals: activeFestivals,
  );
});

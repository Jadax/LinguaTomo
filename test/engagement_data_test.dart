import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/achievement_data.dart';
import 'package:linguatomo/data/festival_calendar_data.dart';

void main() {
  test('achievement catalogue is large, unique and reward-backed', () {
    expect(achievements.length, greaterThanOrEqualTo(45));
    expect(
      achievements.map((item) => item.id).toSet().length,
      achievements.length,
    );
    expect(achievements.every((item) => item.reward.trim().isNotEmpty), isTrue);
    expect(
      achievements.where((item) => item.secret).length,
      greaterThanOrEqualTo(5),
    );
    expect(
      achievements.map((item) => item.rewardType).toSet(),
      containsAll(AchievementRewardType.values),
    );
  });

  test('festival calendar covers the year with usable learning content', () {
    expect(festivalCalendar.length, greaterThanOrEqualTo(30));
    expect(
      festivalCalendar.map((item) => item.id).toSet().length,
      festivalCalendar.length,
    );
    for (var month = 1; month <= 12; month++) {
      expect(
        festivalCalendar.any((item) => item.months.contains(month)),
        isTrue,
        reason: 'Month $month needs at least one cultural window.',
      );
    }
    expect(
      festivalCalendar.every(
        (item) => item.vocabulary.length >= 3 && item.reward.isNotEmpty,
      ),
      isTrue,
    );
  });
}

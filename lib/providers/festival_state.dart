import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/storage_keys.dart';
import '../data/festival_calendar_data.dart';

Box<dynamic>? get _box => Hive.isBoxOpen(StorageKeys.userData)
    ? Hive.box<dynamic>(StorageKeys.userData)
    : null;

/// The Japan-standard-time "today" used by every seasonal feature.
DateTime japanToday() =>
    DateTime.now().toUtc().add(const Duration(hours: 9));

/// Remembers which festival windows the learner has experienced inside the
/// app. Entries are stored as `festivalId@month` so seasonal counts can
/// be derived without a second key.
class FestivalMemoryNotifier extends Notifier<Set<String>> {
  static const _key = 'festival_memories_v1';

  @override
  Set<String> build() {
    final raw = _box?.get(_key);
    return raw is Iterable ? raw.map((item) => '$item').toSet() : <String>{};
  }

  /// Marks one festival window covering today in Japan as experienced,
  /// rotating through simultaneous events day by day. Returning on different
  /// days of a festival season is what completes the collection.
  Future<void> markToday() async {
    final today = japanToday();
    final events = festivalCalendar
        .where((event) => event.isCurrent(today))
        .toList();
    if (events.isEmpty) return;
    final event = events[today.day % events.length];
    final entry = '${event.id}@${today.month}';
    if (state.contains(entry)) return;
    state = {...state, entry};
    await _box?.put(_key, state.toList());
  }
}

final festivalMemoryProvider =
    NotifierProvider<FestivalMemoryNotifier, Set<String>>(
      FestivalMemoryNotifier.new,
    );

Set<String> celebratedFestivalIds(Set<String> entries) =>
    entries.map((entry) => entry.split('@').first).toSet();

int _seasonOf(int month) => switch (month) {
  3 || 4 || 5 => 0,
  6 || 7 || 8 => 1,
  9 || 10 || 11 => 2,
  _ => 3,
};

Set<int> celebratedSeasons(Set<String> entries) => entries
    .map((entry) => int.tryParse(entry.split('@').last) ?? 1)
    .map(_seasonOf)
    .toSet();

int summerFestivalCount(Set<String> entries) => entries
    .where((entry) {
      final month = int.tryParse(entry.split('@').last) ?? 0;
      return month >= 6 && month <= 8;
    })
    .map((entry) => entry.split('@').first)
    .toSet()
    .length;

int winterFestivalCount(Set<String> entries) => entries
    .where((entry) {
      final month = int.tryParse(entry.split('@').last) ?? 0;
      return month == 12 || month <= 2;
    })
    .map((entry) => entry.split('@').first)
    .toSet()
    .length;

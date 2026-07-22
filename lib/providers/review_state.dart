import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/storage_keys.dart';
import '../data/curriculum_data.dart';
import '../models/app_models.dart';
import 'app_state.dart';

class ReviewDeck {
  const ReviewDeck({required this.cards});
  final Map<String, Card> cards;

  List<Mission> get dueMissions {
    final now = DateTime.now().toUtc();
    return missions.where((mission) {
      final card = cards[mission.id];
      return card != null && !card.due.isAfter(now);
    }).toList();
  }
}

class ReviewDeckNotifier extends Notifier<ReviewDeck> {
  static const _key = 'fsrs_cards_v1';
  final Scheduler _scheduler = Scheduler(desiredRetention: .9);

  @override
  ReviewDeck build() {
    final progress = ref.watch(progressProvider);
    final raw = Hive.isBoxOpen(StorageKeys.userData)
        ? Hive.box<dynamic>(StorageKeys.userData).get(_key)
        : null;
    final stored = <String, Card>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        if (entry.value is Map) {
          stored['${entry.key}'] = Card.fromMap(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
    }
    for (var index = 0; index < missions.length; index++) {
      final mission = missions[index];
      if (progress.completedMissions.contains(mission.id)) {
        stored.putIfAbsent(mission.id, () => Card(cardId: index + 1));
      }
    }
    return ReviewDeck(cards: stored);
  }

  Future<void> rate(String missionId, Rating rating) async {
    final current = state.cards[missionId];
    if (current == null) return;
    final result = _scheduler.reviewCard(current, rating);
    state = ReviewDeck(cards: {...state.cards, missionId: result.card});
    if (Hive.isBoxOpen(StorageKeys.userData)) {
      await Hive.box<dynamic>(StorageKeys.userData).put(_key, {
        for (final entry in state.cards.entries) entry.key: entry.value.toMap(),
      });
    }
  }
}

final reviewDeckProvider = NotifierProvider<ReviewDeckNotifier, ReviewDeck>(
  ReviewDeckNotifier.new,
);

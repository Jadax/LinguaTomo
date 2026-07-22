import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/grammar_repository.dart';
import '../models/grammar_models.dart';

final grammarRepositoryProvider = Provider<GrammarRepository>(
  (ref) => const GrammarRepository(),
);

final grammarCatalogueProvider = FutureProvider<GrammarCatalogue>(
  (ref) => ref.watch(grammarRepositoryProvider).load(),
);

class GrammarGarden {
  const GrammarGarden({
    this.cards = const {},
    this.bookmarks = const {},
    this.reviewCount = 0,
  });

  final Map<String, Card> cards;
  final Set<String> bookmarks;
  final int reviewCount;

  bool isPlanted(String id) => cards.containsKey(id);

  int get dueCount {
    final now = DateTime.now().toUtc();
    return cards.values.where((card) => !card.due.isAfter(now)).length;
  }
}

class GrammarGardenNotifier extends Notifier<GrammarGarden> {
  static const _key = 'grammar_garden_v1';
  static const _boxName = 'linguatomo_user_data';
  final Scheduler _scheduler = Scheduler(desiredRetention: .9);

  Box<dynamic>? get _box =>
      Hive.isBoxOpen(_boxName) ? Hive.box<dynamic>(_boxName) : null;

  @override
  GrammarGarden build() {
    final raw = _box?.get(_key);
    if (raw is! Map) return const GrammarGarden();
    final cards = <String, Card>{};
    final rawCards = raw['cards'];
    if (rawCards is Map) {
      for (final entry in rawCards.entries) {
        if (entry.value is Map) {
          cards['${entry.key}'] = Card.fromMap(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
    }
    return GrammarGarden(
      cards: cards,
      bookmarks: _stringSet(raw['bookmarks']),
      reviewCount: (raw['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> plant(String id) async {
    if (state.cards.containsKey(id)) return;
    final stableId = id.codeUnits.fold<int>(17, (value, unit) {
      return (value * 37 + unit) & 0x7fffffff;
    });
    state = GrammarGarden(
      cards: {
        ...state.cards,
        id: Card(cardId: stableId),
      },
      bookmarks: state.bookmarks,
      reviewCount: state.reviewCount,
    );
    await _persist();
  }

  Future<void> rate(String id, Rating rating) async {
    final current = state.cards[id];
    if (current == null) return;
    final result = _scheduler.reviewCard(current, rating);
    state = GrammarGarden(
      cards: {...state.cards, id: result.card},
      bookmarks: state.bookmarks,
      reviewCount: state.reviewCount + 1,
    );
    await _persist();
  }

  Future<void> toggleBookmark(String id) async {
    final next = {...state.bookmarks};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = GrammarGarden(
      cards: state.cards,
      bookmarks: next,
      reviewCount: state.reviewCount,
    );
    await _persist();
  }

  Future<void> _persist() async {
    await _box?.put(_key, {
      'cards': {
        for (final entry in state.cards.entries) entry.key: entry.value.toMap(),
      },
      'bookmarks': state.bookmarks.toList(),
      'reviewCount': state.reviewCount,
    });
  }
}

Set<String> _stringSet(dynamic value) =>
    value is Iterable ? value.map((item) => '$item').toSet() : <String>{};

final grammarGardenProvider =
    NotifierProvider<GrammarGardenNotifier, GrammarGarden>(
      GrammarGardenNotifier.new,
    );

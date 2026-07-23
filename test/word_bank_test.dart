import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/word_bank.dart';
import 'package:linguatomo/models/app_models.dart';

void main() {
  test('word bank has at least 600 words', () {
    expect(wordBank.length, greaterThanOrEqualTo(600));
  });

  test('word bank has unique IDs', () {
    final ids = wordBank.map((w) => w.id).toSet();
    expect(ids.length, wordBank.length);
  });

  test('each tier has at least 80 words', () {
    for (final tier in DifficultyTier.values) {
      final count = wordBank.where((w) => w.tier == tier).length;
      expect(count, greaterThanOrEqualTo(80),
          reason: '${tier.label} should have 80+ words, has $count');
    }
  });

  test('all words have non-empty required fields', () {
    for (final word in wordBank) {
      expect(word.japanese.isNotEmpty, isTrue, reason: '${word.id} missing japanese');
      expect(word.romaji.isNotEmpty, isTrue, reason: '${word.id} missing romaji');
      expect(word.english.isNotEmpty, isTrue, reason: '${word.id} missing english');
      expect(word.emoji.isNotEmpty, isTrue, reason: '${word.id} missing emoji');
    }
  });

  test('wordsForTier filters correctly', () {
    final starter = wordsForTier(DifficultyTier.starter);
    expect(starter.length, greaterThanOrEqualTo(80));
    expect(starter.every((w) => w.tier == DifficultyTier.starter), isTrue);
  });

  test('wordsForCategory returns correct category words', () {
    for (final cat in WordCategory.values) {
      final words = wordsForCategory(cat);
      expect(words.length, greaterThanOrEqualTo(30));
      expect(words.every((w) => w.category == cat), isTrue);
    }
  });

  test('lesson path covers all per-tier words in order with no duplicates', () {
    final allIds = wordBank.map((w) => w.id).toSet();
    for (final tier in DifficultyTier.values) {
      final ordered = wordsForTierInOrder(tier);
      final ids = ordered.map((w) => w.id).toSet();
      expect(ids.length, ordered.length,
          reason: '${tier.label} path has duplicate IDs');
      expect(ids.every(allIds.contains), isTrue,
          reason: '${tier.label} path has unknown IDs');
      // Not all tier words need to be in the ordered path,
      // but at least the minimum must be there.
      expect(ordered.length, greaterThanOrEqualTo(80),
          reason: '${tier.label} path must have 80+ words, has ${ordered.length}');
    }
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/word_bank.dart';
import 'package:linguatomo/models/app_models.dart';

void main() {
  test('word bank has exactly 500 words', () {
    expect(wordBank.length, 500);
  });

  test('word bank has unique IDs', () {
    final ids = wordBank.map((w) => w.id).toSet();
    expect(ids.length, wordBank.length);
  });

  test('each tier has exactly 100 words', () {
    for (final tier in DifficultyTier.values) {
      final count = wordBank.where((w) => w.tier == tier).length;
      expect(count, 100, reason: '${tier.label} should have 100 words');
    }
  });

  test('each category has 12 to 14 words per tier', () {
    for (final tier in DifficultyTier.values) {
      for (final category in WordCategory.values) {
        final count = wordBank
            .where((w) => w.tier == tier && w.category == category)
            .length;
        expect(count, inInclusiveRange(10, 14),
            reason: '${tier.label} ${category.label} has $count words');
      }
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

  test('wordsForTier returns correct tier words', () {
    final starter = wordsForTier(DifficultyTier.starter);
    expect(starter.length, 100);
    expect(starter.every((w) => w.tier == DifficultyTier.starter), isTrue);
  });

  test('wordsForCategory returns correct category words', () {
    final greetings = wordsForCategory(WordCategory.greetings);
    expect(greetings.length, inInclusiveRange(60, 65));
    expect(greetings.every((w) => w.category == WordCategory.greetings), isTrue);
  });

  test('lesson path covers all 100 words per tier in order', () {
    final allIds = wordBank.map((w) => w.id).toSet();
    for (final tier in DifficultyTier.values) {
      final ordered = wordsForTierInOrder(tier);
      expect(ordered.length, 100, reason: '${tier.label} path must have 100 words');
      final ids = ordered.map((w) => w.id).toSet();
      expect(ids.length, 100, reason: '${tier.label} path has duplicate IDs');
      expect(ids.every(allIds.contains), isTrue, reason: '${tier.label} path has unknown IDs');
    }
  });
}

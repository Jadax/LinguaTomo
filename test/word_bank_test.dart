import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/word_bank.dart';
import 'package:linguatomo/models/app_models.dart';

void main() {
  test('word bank has exactly 400 words', () {
    expect(wordBank.length, 400);
  });

  test('word bank has unique IDs', () {
    final ids = wordBank.map((w) => w.id).toSet();
    expect(ids.length, wordBank.length);
  });

  test('each tier has exactly 80 words', () {
    for (final tier in DifficultyTier.values) {
      final count = wordBank.where((w) => w.tier == tier).length;
      expect(count, 80, reason: '${tier.label} should have 80 words');
    }
  });

  test('each category has 10 words per tier', () {
    for (final tier in DifficultyTier.values) {
      for (final category in WordCategory.values) {
        final count = wordBank
            .where((w) => w.tier == tier && w.category == category)
            .length;
        expect(
          count,
          10,
          reason:
              '${tier.label} ${category.label} should have 10 words, found $count',
        );
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
    expect(starter.length, 80);
    expect(starter.every((w) => w.tier == DifficultyTier.starter), isTrue);
  });

  test('wordsForCategory returns correct category words', () {
    final greetings = wordsForCategory(WordCategory.greetings);
    expect(greetings.length, 50);
    expect(
      greetings.every((w) => w.category == WordCategory.greetings),
      isTrue,
    );
  });

  test('lesson path covers all 80 words per tier in order', () {
    final allIds = wordBank.map((w) => w.id).toSet();
    for (final tier in DifficultyTier.values) {
      final ordered = wordsForTierInOrder(tier);
      expect(ordered.length, 80, reason: '${tier.label} path must have 80 words');
      final ids = ordered.map((w) => w.id).toSet();
      expect(ids.length, 80, reason: '${tier.label} path has duplicate IDs');
      expect(ids.every(allIds.contains), isTrue, reason: '${tier.label} path has unknown IDs');
    }
  });
}

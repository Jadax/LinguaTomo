import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/word_bank.dart';
import 'package:linguatomo/models/app_models.dart';

void main() {
  test('word bank has exactly 200 words', () {
    expect(wordBank.length, 200);
  });

  test('word bank has unique IDs', () {
    final ids = wordBank.map((w) => w.id).toSet();
    expect(ids.length, wordBank.length);
  });

  test('each tier has exactly 40 words', () {
    for (final tier in DifficultyTier.values) {
      final count = wordBank.where((w) => w.tier == tier).length;
      expect(count, 40, reason: '${tier.label} should have 40 words');
    }
  });

  test('each category has 4 words per tier', () {
    for (final tier in DifficultyTier.values) {
      for (final category in WordCategory.values) {
        final count = wordBank
            .where((w) => w.tier == tier && w.category == category)
            .length;
        expect(
          count,
          4,
          reason:
              '${tier.label} ${category.label} should have 4 words, found $count',
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
    expect(starter.length, 40);
    expect(starter.every((w) => w.tier == DifficultyTier.starter), isTrue);
  });

  test('wordsForCategory returns correct category words', () {
    final greetings = wordsForCategory(WordCategory.greetings);
    expect(greetings.length, 20);
    expect(
      greetings.every((w) => w.category == WordCategory.greetings),
      isTrue,
    );
  });
}

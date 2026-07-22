import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/character_data.dart';
import 'package:linguatomo/models/character_entry.dart';

void main() {
  test('basic syllabaries contain all 46 distinct characters', () {
    for (final set in [CharacterSet.hiragana, CharacterSet.katakana]) {
      final entries = characterLibrary[set]!;
      expect(entries, hasLength(46));
      expect(entries.map((entry) => entry.symbol).toSet(), hasLength(46));
      expect(entries.every((entry) => entry.reading.isNotEmpty), isTrue);
    }
  });

  test('isolated characters do not contain fabricated pitch data', () {
    for (final entries in characterLibrary.values) {
      for (final entry in entries) {
        expect(entry.toString().contains('pitchPattern'), isFalse);
      }
    }
  });
}

import 'package:flutter/foundation.dart';

enum CharacterSet { hiragana, katakana, kanjiN5 }

@immutable
class CharacterEntry {
  const CharacterEntry({
    required this.symbol,
    required this.reading,
    required this.meaning,
    this.examples = const [],
  });

  final String symbol;
  final String reading;
  final String meaning;
  final List<String> examples;

  String get kanjiVgUrl {
    final code = symbol.runes.first.toRadixString(16).padLeft(5, '0');
    return 'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/$code.svg';
  }
}

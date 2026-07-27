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

}

import 'package:flutter/foundation.dart';

@immutable
class GrammarExample {
  const GrammarExample({
    required this.japanese,
    required this.romaji,
    required this.english,
  });

  final String japanese;
  final String romaji;
  final String english;
}

@immutable
class GrammarPoint {
  const GrammarPoint({
    required this.id,
    required this.level,
    required this.order,
    required this.title,
    required this.summary,
    required this.explanation,
    required this.formation,
    required this.examples,
  });

  final String id;
  final String level;
  final int order;
  final String title;
  final String summary;
  final String explanation;
  final String formation;
  final List<GrammarExample> examples;

  String get searchText => [
    title,
    summary,
    explanation,
    formation,
    ...examples.expand((item) => [item.japanese, item.romaji, item.english]),
  ].join(' ').toLowerCase();
}

@immutable
class GrammarCatalogue {
  const GrammarCatalogue(this.points);

  final List<GrammarPoint> points;

  int countFor(String level) =>
      points.where((point) => point.level == level).length;
}

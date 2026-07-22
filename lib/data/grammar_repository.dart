import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/grammar_models.dart';

class GrammarRepository {
  const GrammarRepository();

  static const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  Future<GrammarCatalogue> load() async {
    final points = <GrammarPoint>[];
    for (final level in levels) {
      final raw = await rootBundle.loadString(
        'assets/content/grammar/grammar_$level.json',
      );
      final records = jsonDecode(raw) as List<dynamic>;
      for (var index = 0; index < records.length; index++) {
        final record = Map<String, dynamic>.from(records[index] as Map);
        final rawExamples = record['examples'] as List<dynamic>? ?? const [];
        points.add(
          GrammarPoint(
            id: 'grammar-${level.toLowerCase()}-${index + 1}',
            level: level,
            order: index + 1,
            title: '${record['title'] ?? ''}'.trim(),
            summary: '${record['short_explanation'] ?? ''}'.trim(),
            explanation: '${record['long_explanation'] ?? ''}'.trim(),
            formation: '${record['formation'] ?? ''}'.trim(),
            examples: rawExamples
                .map((value) {
                  final example = Map<String, dynamic>.from(value as Map);
                  return GrammarExample(
                    japanese: '${example['jp'] ?? ''}'.trim(),
                    romaji: '${example['romaji'] ?? ''}'.trim(),
                    english: '${example['en'] ?? ''}'.trim(),
                  );
                })
                .toList(growable: false),
          ),
        );
      }
    }
    return GrammarCatalogue(List.unmodifiable(points));
  }
}

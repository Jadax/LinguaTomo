import 'app_models.dart';

/// A themed group of words, like a Duolingo unit or skill.
class CourseSection {
  const CourseSection({
    required this.id,
    required this.title,
    required this.emoji,
    required this.tier,
    required this.cefr,
    required this.jlpt,
    required this.description,
    required this.words,
  });

  final String id;
  final String title;
  final String emoji;
  final DifficultyTier tier;
  final String cefr;
  final String jlpt;
  final String description;
  final List<Word> words;
}

/// CEFR level descriptors for the explanation view.
const cefrDescriptions = <String, String>{
  'Pre-A1': 'Absolute beginner. Greetings, numbers, colours, basic phrases. You can say hello and introduce yourself.',
  'A1': 'Foundation. Daily life, simple sentences, present tense. You can order food and describe your family.',
  'A2': 'Elementary. Social interactions, past tense, making plans. You can travel and handle simple conversations.',
  'B1': 'Intermediate. Opinions, media, abstract ideas. You can discuss news and express viewpoints.',
  'B2': 'Upper Intermediate. Formal language, business, nuanced expression. You can work in Japanese and debate topics.',
  'N1/N2': 'Advanced. Literature, specialised vocabulary, full fluency. You can read newspapers and negotiate professionally.',
};

/// JLPT level descriptors.
const jlptDescriptions = <String, String>{
  'N5': 'Basic Japanese. ~100 kanji, ~800 words. Understand typical daily expressions.',
  'N4': 'Elementary Japanese. ~300 kanji, ~1500 words. Understand basic passages on familiar topics.',
  'N3': 'Intermediate Japanese. ~650 kanji, ~3750 words. Understand everyday situations at natural speed.',
  'N2': 'Pre-advanced Japanese. ~1000 kanji, ~6000 words. Understand complex topics and conversations.',
  'N1': 'Advanced Japanese. ~2000 kanji, ~10000 words. Understand nuanced arguments and abstract texts.',
};

/// A themed word section — the building block for browsing and lessons.
class WordThemeSection {
  const WordThemeSection({
    required this.theme,
    required this.emoji,
    required this.tier,
    required this.cefr,
    required this.jlpt,
    required this.desc,
    required this.words,
  });

  final String theme, emoji, cefr, jlpt, desc;
  final DifficultyTier tier;
  final List<Word> words;
}

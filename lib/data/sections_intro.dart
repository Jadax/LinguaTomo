import '../models/app_models.dart';

/// Pre-A1 sections — the first words any beginner needs.
const introSections = <_RawSection>[
  _RawSection(
    id: 'basics_hello',
    title: 'Hello & Goodbye',
    emoji: '👋',
    tier: DifficultyTier.starter,
    cefr: 'Pre-A1',
    jlpt: 'N5',
    desc: 'Your very first Japanese words. Greetings and partings.',
    ids: const [
      's_01', 's_02', 's_03', 's_04', 's_08', 's_09', 's_10', 's_05',
      's_81', 's_82', 's_83',
    ],
  ),
  _RawSection(
    id: 'basics_people',
    title: 'Family & People',
    emoji: '👨‍👩‍👧',
    tier: DifficultyTier.starter,
    cefr: 'Pre-A1',
    jlpt: 'N5',
    desc: 'Words for family members and the people around you.',
    ids: const [
      's_21', 's_22', 's_23', 's_24', 's_25', 's_26', 's_27', 's_86', 's_87',
    ],
  ),
  _RawSection(
    id: 'basics_home',
    title: 'My Home',
    emoji: '🏠',
    tier: DifficultyTier.starter,
    cefr: 'Pre-A1',
    jlpt: 'N5',
    desc: 'Things you find around the house, everyday objects.',
    ids: const [
      's_11', 's_12', 's_13', 's_14', 's_16', 's_17', 's_18', 's_84', 's_85',
      's_93',
    ],
  ),
  _RawSection(
    id: 'basics_food',
    title: 'Yummy Food',
    emoji: '🍙',
    tier: DifficultyTier.starter,
    cefr: 'Pre-A1',
    jlpt: 'N5',
    desc: 'Basic food, drink, and mealtime words.',
    ids: const [
      's_31', 's_32', 's_33', 's_34', 's_36', 's_37', 's_88', 's_89',
    ],
  ),
  _RawSection(
    id: 'basics_animals',
    title: 'Cute Animals',
    emoji: '🐱',
    tier: DifficultyTier.starter,
    cefr: 'Pre-A1',
    jlpt: 'N5',
    desc: 'Common animals and pets, always popular with kids.',
    ids: const [
      's_71', 's_72', 's_73', 's_74', 's_75', 's_76', 's_78', 's_98', 's_99',
    ],
  ),
  _RawSection(
    id: 'basics_verbs',
    title: 'First Actions',
    emoji: '🏃',
    tier: DifficultyTier.starter,
    cefr: 'Pre-A1',
    jlpt: 'N5',
    desc: 'Essential action words — go, come, eat, see, sleep.',
    ids: const [
      's_41', 's_42', 's_43', 's_44', 's_45', 's_90', 's_91', 's_92',
    ],
  ),
  _RawSection(
    id: 'basics_nature',
    title: 'Outdoors',
    emoji: '🌿',
    tier: DifficultyTier.starter,
    cefr: 'Pre-A1',
    jlpt: 'N5',
    desc: 'Nature, weather, and things you see outside.',
    ids: const [
      's_61', 's_62', 's_63', 's_64', 's_65', 's_70', 's_96', 's_97', 's_100',
    ],
  ),
  _RawSection(
    id: 'basics_places',
    title: 'Places To Go',
    emoji: '🏫',
    tier: DifficultyTier.starter,
    cefr: 'Pre-A1',
    jlpt: 'N5',
    desc: 'Common places — school, shop, station, park, hospital.',
    ids: const [
      's_51', 's_52', 's_55', 's_56', 's_58', 's_59', 's_94', 's_95',
    ],
  ),
  _RawSection(
    id: 'numbers_days',
    title: 'Numbers & Time',
    emoji: '🔢',
    tier: DifficultyTier.elementary,
    cefr: 'A1',
    jlpt: 'N5',
    desc: 'Counting, days, and telling the time.',
    ids: const [
      'e_01', 'e_02',
    ],
  ),
  _RawSection(
    id: 'daily_life',
    title: 'Daily Routines',
    emoji: '☀️',
    tier: DifficultyTier.elementary,
    cefr: 'A1',
    jlpt: 'N5',
    desc: 'Words for everyday activities and morning-to-night routines.',
    ids: const [
      'e_03', 'e_04', 'e_05', 'e_06', 'e_07', 'e_91', 'e_92',
    ],
  ),
];

class _RawSection {
  const _RawSection({
    required this.id,
    required this.title,
    required this.emoji,
    required this.tier,
    required this.cefr,
    required this.jlpt,
    required this.desc,
    required this.ids,
  });
  final String id, title, emoji, cefr, jlpt, desc;
  final DifficultyTier tier;
  final List<String> ids;
}

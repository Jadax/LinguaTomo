import '../models/app_models.dart';

/// A2 intermediate vocabulary — social, travel, work, descriptions.
const a2WordSections = <_WordSection>[
  _WordSection(
    theme: 'Describing People',
    emoji: '🧑‍🤝‍🧑',
    tier: DifficultyTier.intermediate,
    words: [
      Word(id: 'dp_01', japanese: '優しい', romaji: 'yasashii', english: 'Kind/gentle', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😊'),
      Word(id: 'dp_02', japanese: '厳しい', romaji: 'kibishii', english: 'Strict', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😠'),
      Word(id: 'dp_03', japanese: '面白い', romaji: 'omoshiroi', english: 'Interesting/funny', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😄'),
      Word(id: 'dp_04', japanese: '親切', romaji: 'shinsetsu', english: 'Kind/helpful', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '🤗'),
      Word(id: 'dp_05', japanese: '若い', romaji: 'wakai', english: 'Young', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '🧒'),
      Word(id: 'dp_06', japanese: '年上', romaji: 'toshiue', english: 'Older/senior', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '👴'),
      Word(id: 'dp_07', japanese: '年下', romaji: 'toshishita', english: 'Younger/junior', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '👶'),
      Word(id: 'dp_08', japanese: '有名', romaji: 'yuumei', english: 'Famous', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '⭐'),
      Word(id: 'dp_09', japanese: '性格', romaji: 'seikaku', english: 'Personality', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '🧠'),
      Word(id: 'dp_10', japanese: '気持ち', romaji: 'kimochi', english: 'Feeling', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '💭'),
    ],
  ),
  _WordSection(
    theme: 'Restaurant & Cafe',
    emoji: '🍽️',
    tier: DifficultyTier.intermediate,
    words: [
      Word(id: 'rc_01', japanese: '注文', romaji: 'chuumon', english: 'Order (food)', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '📝'),
      Word(id: 'rc_02', japanese: '定食', romaji: 'teishoku', english: 'Set meal', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🍱'),
      Word(id: 'rc_03', japanese: 'メニュー', romaji: 'menyuu', english: 'Menu', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '📋'),
      Word(id: 'rc_04', japanese: '店員', romaji: 'tenin', english: 'Shop staff', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '👨‍💼'),
      Word(id: 'rc_05', japanese: 'お勘定', romaji: 'okanjou', english: 'Bill/check', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🧾'),
      Word(id: 'rc_06', japanese: '予約する', romaji: 'yoyaku suru', english: 'To reserve', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '📅'),
      Word(id: 'rc_07', japanese: '空いてる', romaji: 'aiteru', english: 'Available/vacant', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🟢'),
      Word(id: 'rc_08', japanese: '美味しい', romaji: 'oishii', english: 'Delicious', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '😋'),
      Word(id: 'rc_09', japanese: 'まずい', romaji: 'mazui', english: 'Bad tasting', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🤢'),
      Word(id: 'rc_10', japanese: 'おかわり', romaji: 'okawari', english: 'Second helping', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🔄'),
    ],
  ),
  _WordSection(
    theme: 'Work & Office',
    emoji: '💼',
    tier: DifficultyTier.intermediate,
    words: [
      Word(id: 'wo_01', japanese: '仕事', romaji: 'shigoto', english: 'Work/job', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '💼'),
      Word(id: 'wo_02', japanese: '会社', romaji: 'kaisha', english: 'Company', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🏢'),
      Word(id: 'wo_03', japanese: '会議', romaji: 'kaigi', english: 'Meeting', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '👥'),
      Word(id: 'wo_04', japanese: '電話する', romaji: 'denwa suru', english: 'To phone', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '📞'),
      Word(id: 'wo_05', japanese: '連絡', romaji: 'renraku', english: 'Contact', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '📧'),
      Word(id: 'wo_06', japanese: '休み', romaji: 'yasumi', english: 'Holiday/rest', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '🏖️'),
      Word(id: 'wo_07', japanese: '遅刻', romaji: 'chikoku', english: 'Lateness', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '⏰'),
      Word(id: 'wo_08', japanese: '給料', romaji: 'kyuuryou', english: 'Salary', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '💵'),
      Word(id: 'wo_09', japanese: '社長', romaji: 'shachou', english: 'Company president', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '👔'),
      Word(id: 'wo_10', japanese: '残業', romaji: 'zangyou', english: 'Overtime', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '😮‍💨'),
    ],
  ),
  _WordSection(
    theme: 'Travel & Hotels',
    emoji: '🏨',
    tier: DifficultyTier.intermediate,
    words: [
      Word(id: 'tr_01', japanese: '旅館', romaji: 'ryokan', english: 'Japanese inn', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🏯'),
      Word(id: 'tr_02', japanese: '温泉', romaji: 'onsen', english: 'Hot spring', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '♨️'),
      Word(id: 'tr_03', japanese: '観光', romaji: 'kankou', english: 'Sightseeing', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '📸'),
      Word(id: 'tr_04', japanese: '地図', romaji: 'chizu', english: 'Map', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🗺️'),
      Word(id: 'tr_05', japanese: '荷物', romaji: 'nimotsu', english: 'Luggage', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🧳'),
      Word(id: 'tr_06', japanese: '案内所', romaji: 'annaijo', english: 'Information centre', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: 'ℹ️'),
      Word(id: 'tr_07', japanese: '旅', romaji: 'tabi', english: 'Journey', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🗾'),
      Word(id: 'tr_08', japanese: '景色', romaji: 'keshiki', english: 'Scenery', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '🌄'),
      Word(id: 'tr_09', japanese: 'お土産', romaji: 'omiyage', english: 'Souvenir', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🎁'),
      Word(id: 'tr_10', japanese: '案内', romaji: 'annai', english: 'Guide/information', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '📖'),
    ],
  ),
  _WordSection(
    theme: 'Feelings & Emotions',
    emoji: '😊',
    tier: DifficultyTier.intermediate,
    words: [
      Word(id: 'fe_01', japanese: '嬉しい', romaji: 'ureshii', english: 'Happy', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😄'),
      Word(id: 'fe_02', japanese: '悲しい', romaji: 'kanashii', english: 'Sad', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😢'),
      Word(id: 'fe_03', japanese: '怒る', romaji: 'okoru', english: 'To get angry', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😡'),
      Word(id: 'fe_04', japanese: '驚く', romaji: 'odoroku', english: 'To be surprised', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😲'),
      Word(id: 'fe_05', japanese: '心配', romaji: 'shinpai', english: 'Worry', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😟'),
      Word(id: 'fe_06', japanese: '安心', romaji: 'anshin', english: 'Relief', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😌'),
      Word(id: 'fe_07', japanese: '楽しい', romaji: 'tanoshii', english: 'Fun/enjoyable', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '🥳'),
      Word(id: 'fe_08', japanese: '寂しい', romaji: 'sabishii', english: 'Lonely', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '🥺'),
      Word(id: 'fe_09', japanese: '緊張', romaji: 'kinchou', english: 'Nervous', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '😰'),
      Word(id: 'fe_10', japanese: '自信', romaji: 'jishin', english: 'Confidence', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '💪'),
    ],
  ),
  _WordSection(
    theme: 'Technology',
    emoji: '📱',
    tier: DifficultyTier.intermediate,
    words: [
      Word(id: 'te_01', japanese: '携帯', romaji: 'keitai', english: 'Mobile phone', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '📱'),
      Word(id: 'te_02', japanese: '写真を撮る', romaji: 'shashin wo toru', english: 'Take a photo', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '📸'),
      Word(id: 'te_03', japanese: '送る', romaji: 'okuru', english: 'To send', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '📤'),
      Word(id: 'te_04', japanese: '調べる', romaji: 'shiraberu', english: 'To look up', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '🔍'),
      Word(id: 'te_05', japanese: '返事', romaji: 'henji', english: 'Reply', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '📩'),
      Word(id: 'te_06', japanese: '入力', romaji: 'nyuuryoku', english: 'Input/type', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '⌨️'),
      Word(id: 'te_07', japanese: '画面', romaji: 'gamen', english: 'Screen', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🖥️'),
      Word(id: 'te_08', japanese: '電池', romaji: 'denchi', english: 'Battery', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🔋'),
      Word(id: 'te_09', japanese: '電源', romaji: 'dengen', english: 'Power source', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🔌'),
      Word(id: 'te_10', japanese: 'SNS', romaji: 'esu enu esu', english: 'Social media', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '💬'),
    ],
  ),
];

class _WordSection {
  const _WordSection({
    required this.theme,
    required this.emoji,
    required this.tier,
    required this.words,
  });
  final String theme, emoji;
  final DifficultyTier tier;
  final List<Word> words;
}

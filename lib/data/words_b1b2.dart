import '../models/app_models.dart';

/// B1/B2 intermediate-advanced vocabulary — abstract ideas, media, culture, business.
const b1b2WordSections = <_WordSection>[
  _WordSection(
    theme: 'Media & News',
    emoji: '📰',
    tier: DifficultyTier.advanced,
    words: [
      Word(id: 'mn_01', japanese: '新聞', romaji: 'shinbun', english: 'Newspaper', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '📰'),
      Word(id: 'mn_02', japanese: '記事', romaji: 'kiji', english: 'Article', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '📝'),
      Word(id: 'mn_03', japanese: '報道', romaji: 'houdou', english: 'News report', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '📡'),
      Word(id: 'mn_04', japanese: '調査', romaji: 'chousa', english: 'Survey/investigation', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🔍'),
      Word(id: 'mn_05', japanese: '放送', romaji: 'housou', english: 'Broadcast', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '📻'),
      Word(id: 'mn_06', japanese: '討論', romaji: 'touron', english: 'Debate', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🗣️'),
      Word(id: 'mn_07', japanese: '発表', romaji: 'happyou', english: 'Presentation', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🎤'),
      Word(id: 'mn_08', japanese: '世論', romaji: 'seron', english: 'Public opinion', category: WordCategory.people, tier: DifficultyTier.advanced, emoji: '📊'),
      Word(id: 'mn_09', japanese: '取材', romaji: 'shuzai', english: 'Interview/reporting', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🎙️'),
      Word(id: 'mn_10', japanese: '編集', romaji: 'henshuu', english: 'Editing', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '✂️'),
    ],
  ),
  _WordSection(
    theme: 'Business & Economy',
    emoji: '💼',
    tier: DifficultyTier.advanced,
    words: [
      Word(id: 'be_01', japanese: '経済', romaji: 'keizai', english: 'Economy', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '📈'),
      Word(id: 'be_02', japanese: '貿易', romaji: 'boueki', english: 'Trade', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🚢'),
      Word(id: 'be_03', japanese: '投資', romaji: 'toushi', english: 'Investment', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '💹'),
      Word(id: 'be_04', japanese: '契約', romaji: 'keiyaku', english: 'Contract', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '📋'),
      Word(id: 'be_05', japanese: '交渉', romaji: 'koushou', english: 'Negotiation', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🤝'),
      Word(id: 'be_06', japanese: '経営', romaji: 'keiei', english: 'Management', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '👨‍💼'),
      Word(id: 'be_07', japanese: '売上', romaji: 'uriage', english: 'Sales/revenue', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '💰'),
      Word(id: 'be_08', japanese: '利益', romaji: 'rieki', english: 'Profit', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '💎'),
      Word(id: 'be_09', japanese: '負債', romaji: 'fusai', english: 'Debt', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '📉'),
      Word(id: 'be_10', japanese: '市場', romaji: 'ichiba', english: 'Market', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🏪'),
    ],
  ),
  _WordSection(
    theme: 'Culture & Arts',
    emoji: '🎭',
    tier: DifficultyTier.advanced,
    words: [
      Word(id: 'ca_01', japanese: '芸術', romaji: 'geijutsu', english: 'Art', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🎨'),
      Word(id: 'ca_02', japanese: '文化', romaji: 'bunka', english: 'Culture', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🏛️'),
      Word(id: 'ca_03', japanese: '文学', romaji: 'bungaku', english: 'Literature', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '📚'),
      Word(id: 'ca_04', japanese: '建築', romaji: 'kenchiku', english: 'Architecture', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🏗️'),
      Word(id: 'ca_05', japanese: '展覧会', romaji: 'tenrankai', english: 'Exhibition', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🖼️'),
      Word(id: 'ca_06', japanese: '劇場', romaji: 'gekijou', english: 'Theatre', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🎭'),
      Word(id: 'ca_07', japanese: '作品', romaji: 'sakuhin', english: 'Work (art)', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🖌️'),
      Word(id: 'ca_08', japanese: '芸能', romaji: 'geinou', english: 'Performing arts', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🎪'),
      Word(id: 'ca_09', japanese: '陶芸', romaji: 'tougei', english: 'Pottery', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🏺'),
      Word(id: 'ca_10', japanese: '詩', romaji: 'shi', english: 'Poetry', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '✒️'),
    ],
  ),
  _WordSection(
    theme: 'Abstract Ideas',
    emoji: '💭',
    tier: DifficultyTier.expert,
    words: [
      Word(id: 'ai_01', japanese: '概念', romaji: 'gainen', english: 'Concept', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '🧩'),
      Word(id: 'ai_02', japanese: '理論', romaji: 'riron', english: 'Theory', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '📐'),
      Word(id: 'ai_03', japanese: '哲学', romaji: 'tetsugaku', english: 'Philosophy', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '🤔'),
      Word(id: 'ai_04', japanese: '倫理', romaji: 'rinri', english: 'Ethics', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '⚖️'),
      Word(id: 'ai_05', japanese: '価値', romaji: 'kachi', english: 'Value', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '💎'),
      Word(id: 'ai_06', japanese: '理想', romaji: 'risou', english: 'Ideal', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '✨'),
      Word(id: 'ai_07', japanese: '現実', romaji: 'genjitsu', english: 'Reality', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '🌍'),
      Word(id: 'ai_08', japanese: '認識', romaji: 'ninshiki', english: 'Recognition', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '👁️'),
      Word(id: 'ai_09', japanese: '矛盾', romaji: 'mujun', english: 'Contradiction', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '⚡'),
      Word(id: 'ai_10', japanese: '存在', romaji: 'sonzai', english: 'Existence', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '🌟'),
    ],
  ),
  _WordSection(
    theme: 'Society & Politics',
    emoji: '🏛️',
    tier: DifficultyTier.expert,
    words: [
      Word(id: 'sp_01', japanese: '政治', romaji: 'seiji', english: 'Politics', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '🏛️'),
      Word(id: 'sp_02', japanese: '社会', romaji: 'shakai', english: 'Society', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '👥'),
      Word(id: 'sp_03', japanese: '法律', romaji: 'houritsu', english: 'Law', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '⚖️'),
      Word(id: 'sp_04', japanese: '国際', romaji: 'kokusai', english: 'International', category: WordCategory.places, tier: DifficultyTier.expert, emoji: '🌐'),
      Word(id: 'sp_05', japanese: '権利', romaji: 'kenri', english: 'Rights', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '✊'),
      Word(id: 'sp_06', japanese: '責任', romaji: 'sekinin', english: 'Responsibility', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '🏋️'),
      Word(id: 'sp_07', japanese: '政府', romaji: 'seifu', english: 'Government', category: WordCategory.places, tier: DifficultyTier.expert, emoji: '🏢'),
      Word(id: 'sp_08', japanese: '選挙', romaji: 'senkyo', english: 'Election', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '🗳️'),
      Word(id: 'sp_09', japanese: '政策', romaji: 'seisaku', english: 'Policy', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '📜'),
      Word(id: 'sp_10', japanese: '環境問題', romaji: 'kankyou mondai', english: 'Environmental issue', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🌍'),
    ],
  ),
  _WordSection(
    theme: 'Advanced Verbs',
    emoji: '⚡',
    tier: DifficultyTier.expert,
    words: [
      Word(id: 'av_01', japanese: '表現する', romaji: 'hyougen suru', english: 'To express', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🎤'),
      Word(id: 'av_02', japanese: '判断する', romaji: 'handan suru', english: 'To judge', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '⚖️'),
      Word(id: 'av_03', japanese: '解決する', romaji: 'kaiketsu suru', english: 'To solve', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🔧'),
      Word(id: 'av_04', japanese: '提案する', romaji: 'teian suru', english: 'To propose', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '💡'),
      Word(id: 'av_05', japanese: '確認する', romaji: 'kakunin suru', english: 'To confirm', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '✅'),
      Word(id: 'av_06', japanese: '管理する', romaji: 'kanri suru', english: 'To manage', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '📋'),
      Word(id: 'av_07', japanese: '分析する', romaji: 'bunseki suru', english: 'To analyse', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🔬'),
      Word(id: 'av_08', japanese: '評価する', romaji: 'hyouka suru', english: 'To evaluate', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '⭐'),
      Word(id: 'av_09', japanese: '貢献する', romaji: 'kouken suru', english: 'To contribute', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🤝'),
      Word(id: 'av_10', japanese: '達成する', romaji: 'tassei suru', english: 'To achieve', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🏆'),
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

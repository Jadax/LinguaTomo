import '../models/app_models.dart';

class ConversationPair {
  const ConversationPair({
    required this.question,
    required this.questionRomaji,
    required this.answer,
    required this.answerRomaji,
    required this.tier,
    required this.emoji,
  });

  final String question;
  final String questionRomaji;
  final String answer;
  final String answerRomaji;
  final DifficultyTier tier;
  final String emoji;
}

final conversationPairs = <ConversationPair>[
  // ── Starter ──────────────────────────────────────────
  const ConversationPair(
    question: 'おはよう！',
    questionRomaji: 'ohayou!',
    answer: 'おはよう！元気？',
    answerRomaji: 'ohayou! genki?',
    tier: DifficultyTier.starter,
    emoji: '🌅',
  ),
  const ConversationPair(
    question: 'ありがとう！',
    questionRomaji: 'arigatou!',
    answer: 'どういたしまして。',
    answerRomaji: 'dou itashimashite.',
    tier: DifficultyTier.starter,
    emoji: '🙏',
  ),
  const ConversationPair(
    question: 'すみません、',
    questionRomaji: 'sumimasen,',
    answer: 'はい？大丈夫ですよ。',
    answerRomaji: 'hai? daijoubu desu yo.',
    tier: DifficultyTier.starter,
    emoji: '🤗',
  ),
  // ── Elementary ───────────────────────────────────────
  const ConversationPair(
    question: 'お元気ですか？',
    questionRomaji: 'ogenki desu ka?',
    answer: 'はい、元気です。ありがとう。',
    answerRomaji: 'hai, genki desu. arigatou.',
    tier: DifficultyTier.elementary,
    emoji: '😊',
  ),
  const ConversationPair(
    question: 'どこに行きますか？',
    questionRomaji: 'doko ni ikimasu ka?',
    answer: '駅に行きます。',
    answerRomaji: 'eki ni ikimasu.',
    tier: DifficultyTier.elementary,
    emoji: '🚉',
  ),
  const ConversationPair(
    question: 'これはいくらですか？',
    questionRomaji: 'kore wa ikura desu ka?',
    answer: '100円です。',
    answerRomaji: 'hyakuen desu.',
    tier: DifficultyTier.elementary,
    emoji: '💰',
  ),
  // ── Intermediate ─────────────────────────────────────
  const ConversationPair(
    question: 'すみません、道を教えてください。',
    questionRomaji: 'sumimasen, michi wo oshiete kudasai.',
    answer: 'あそこを右に曲がってください。',
    answerRomaji: 'asoko wo migi ni magatte kudasai.',
    tier: DifficultyTier.intermediate,
    emoji: '🗺️',
  ),
  const ConversationPair(
    question: 'おすすめは何ですか？',
    questionRomaji: 'osusume wa nan desu ka?',
    answer: 'このラーメンが人気ですよ。',
    answerRomaji: 'kono raamen ga ninki desu yo.',
    tier: DifficultyTier.intermediate,
    emoji: '🍜',
  ),
  const ConversationPair(
    question: '明日の天気はどうですか？',
    questionRomaji: 'ashita no tenki wa dou desu ka?',
    answer: '晴れると思います。',
    answerRomaji: 'hareru to omoimasu.',
    tier: DifficultyTier.intermediate,
    emoji: '☀️',
  ),
  // ── Advanced ─────────────────────────────────────────
  const ConversationPair(
    question: 'もしもし、山田と申します。',
    questionRomaji: 'moshi moshi, yamada to moushimasu.',
    answer: 'いつもお世話になっております。',
    answerRomaji: 'itsumo osewa ni natte orimasu.',
    tier: DifficultyTier.advanced,
    emoji: '📞',
  ),
  const ConversationPair(
    question: 'ご意見をお聞かせください。',
    questionRomaji: 'goiken wo okikase kudasai.',
    answer: '私はこの案に賛成です。',
    answerRomaji: 'watashi wa kono an ni sansei desu.',
    tier: DifficultyTier.advanced,
    emoji: '💬',
  ),
  // ── Expert ───────────────────────────────────────────
  const ConversationPair(
    question: '恐れ入りますが、ご検討いただけませんか。',
    questionRomaji: 'osore irimasu ga, gokentou itadakemasen ka.',
    answer: '承知いたしました。早速取り掛かります。',
    answerRomaji: 'shouchi itashimashita. sassoku torikakarimasu.',
    tier: DifficultyTier.expert,
    emoji: '📋',
  ),
  const ConversationPair(
    question: '先日は大変お世話になり、厚く御礼申し上げます。',
    questionRomaji: 'senjitsu wa taihen osewa ni nari, atsuku onrei moushiagemasu.',
    answer: 'とんでもございません。また何なりとお申し付けください。',
    answerRomaji: 'tondemo gozaimasen. mata naninari to omoushitsuke kudasai.',
    tier: DifficultyTier.expert,
    emoji: '🎩',
  ),
];

import '../models/app_models.dart';

class ConversationPair {
  const ConversationPair({
    required this.question,
    required this.answer,
    required this.tier,
    required this.emoji,
  });

  final String question;
  final String answer;
  final DifficultyTier tier;
  final String emoji;
}

final conversationPairs = <ConversationPair>[
  // ── Starter ──────────────────────────────────────────
  const ConversationPair(
    question: 'おはよう！',
    answer: 'おはよう！元気？',
    tier: DifficultyTier.starter,
    emoji: '🌅',
  ),
  const ConversationPair(
    question: 'ありがとう！',
    answer: 'どういたしまして。',
    tier: DifficultyTier.starter,
    emoji: '🙏',
  ),
  const ConversationPair(
    question: 'すみません、',
    answer: 'はい？大丈夫ですよ。',
    tier: DifficultyTier.starter,
    emoji: '🤗',
  ),
  // ── Elementary ───────────────────────────────────────
  const ConversationPair(
    question: 'お元気ですか？',
    answer: 'はい、元気です。ありがとう。',
    tier: DifficultyTier.elementary,
    emoji: '😊',
  ),
  const ConversationPair(
    question: 'どこに行きますか？',
    answer: '駅に行きます。',
    tier: DifficultyTier.elementary,
    emoji: '🚉',
  ),
  const ConversationPair(
    question: 'これはいくらですか？',
    answer: '100円です。',
    tier: DifficultyTier.elementary,
    emoji: '💰',
  ),
  // ── Intermediate ─────────────────────────────────────
  const ConversationPair(
    question: 'すみません、道を教えてください。',
    answer: 'あそこを右に曲がってください。',
    tier: DifficultyTier.intermediate,
    emoji: '🗺️',
  ),
  const ConversationPair(
    question: 'おすすめは何ですか？',
    answer: 'このラーメンが人気ですよ。',
    tier: DifficultyTier.intermediate,
    emoji: '🍜',
  ),
  const ConversationPair(
    question: '明日の天気はどうですか？',
    answer: '晴れると思います。',
    tier: DifficultyTier.intermediate,
    emoji: '☀️',
  ),
  // ── Advanced ─────────────────────────────────────────
  const ConversationPair(
    question: 'もしもし、山田と申します。',
    answer: 'いつもお世話になっております。',
    tier: DifficultyTier.advanced,
    emoji: '📞',
  ),
  const ConversationPair(
    question: 'ご意見をお聞かせください。',
    answer: '私はこの案に賛成です。',
    tier: DifficultyTier.advanced,
    emoji: '💬',
  ),
  // ── Expert ───────────────────────────────────────────
  const ConversationPair(
    question: '恐れ入りますが、ご検討いただけませんか。',
    answer: '承知いたしました。早速取り掛かります。',
    tier: DifficultyTier.expert,
    emoji: '📋',
  ),
  const ConversationPair(
    question: '先日は大変お世話になり、厚く御礼申し上げます。',
    answer: 'とんでもございません。また何なりとお申し付けください。',
    tier: DifficultyTier.expert,
    emoji: '🎩',
  ),
];

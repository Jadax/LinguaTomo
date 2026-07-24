import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/word_bank.dart';
import '../models/app_models.dart';
import '../providers/word_progress_state.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../widgets/leo_sprite.dart';

/// Sample Japanese texts for the reader, organised by difficulty.
const _sampleTexts = <({String title, String text, DifficultyTier tier})>[
  (
    title: 'My morning',
    text: '毎朝六時に起きます。コーヒーを飲みます。学校に行きます。',
    tier: DifficultyTier.starter,
  ),
  (
    title: 'At the restaurant',
    text: 'レストランで寿司を食べました。天ぷらもとてもおいしかったです。',
    tier: DifficultyTier.elementary,
  ),
  (
    title: 'A rainy day',
    text: '今日は雨が降っています。図書館で本を読みます。友達とカフェに行きます。',
    tier: DifficultyTier.elementary,
  ),
  (
    title: 'Shopping',
    text: '新しい靴を買いました。店は駅の近くにあります。とてもきれいでした。',
    tier: DifficultyTier.elementary,
  ),
  (
    title: 'Weekend',
    text: '週末は公園で散歩しました。桜がとてもきれいに咲いていました。写真をたくさん撮りました。',
    tier: DifficultyTier.intermediate,
  ),
  (
    title: 'Family dinner',
    text: '家族でご飯を食べました。母が作った料理はいつもおいしいです。ごちそうさまでした。',
    tier: DifficultyTier.intermediate,
  ),
];

class ImmersiveReaderView extends ConsumerStatefulWidget {
  const ImmersiveReaderView({super.key});

  @override
  ConsumerState<ImmersiveReaderView> createState() =>
      _ImmersiveReaderViewState();
}

class _ImmersiveReaderViewState extends ConsumerState<ImmersiveReaderView> {
  final _textController = TextEditingController();
  final _speech = SpeechService();
  List<_Token> _tokens = [];
  bool _showingDetail = false;
  _Token? _selectedToken;

  @override
  void dispose() {
    _textController.dispose();
    _speech.dispose();
    super.dispose();
  }

  void _parseText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    // Segment into Japanese runs and non-Japanese separators.
    final tokens = <_Token>[];
    final buf = StringBuffer();
    var isJapanese = false;
    void flush() {
      if (buf.isEmpty) return;
      final s = buf.toString();
      tokens.add(_Token(text: s, isJapanese: isJapanese));
      buf.clear();
    }

    for (final ch in text.codeUnits) {
      final unit = ch;
      final jq = _isJapanese(unit);
      if (jq != isJapanese && buf.isNotEmpty) {
        flush();
      }
      isJapanese = jq;
      buf.write(String.fromCharCode(ch));
    }
    flush();
    setState(() {
      _tokens = tokens;
      _showingDetail = false;
      _selectedToken = null;
    });
  }

  void _loadSample(String text) {
    _textController.text = text;
    _parseText();
  }

  void _onTokenTap(_Token token) {
    if (!token.isJapanese) return;
    final match = _lookupWord(token.text);
    setState(() {
      _selectedToken = token.copyWith(lookupResult: match);
      _showingDetail = true;
    });
  }

  Word? _lookupWord(String text) {
    // Try exact match first.
    for (final w in wordBank) {
      if (w.japanese == text) return w;
    }
    // Try any word that appears inside the segment.
    for (final w in wordBank) {
      if (text.contains(w.japanese) && w.japanese.length >= 2) return w;
    }
    return null;
  }

  void _dismissDetail() {
    setState(() {
      _showingDetail = false;
      _selectedToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordProgress = ref.watch(wordProgressProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Immersive Reader',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sample text chips.
            if (_tokens.isEmpty) ...[
              Text(
                'Paste Japanese text or try a sample',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Tap any word you don\'t know to look it up.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sample in _sampleTexts)
                    ActionChip(
                      avatar: Text(_tierEmoji(sample.tier)),
                      label: Text(
                        sample.title,
                        style: const TextStyle(fontSize: 13),
                      ),
                      onPressed: () => _loadSample(sample.text),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Text input.
            TextField(
              controller: _textController,
              maxLines: _tokens.isEmpty ? 4 : 2,
              decoration: InputDecoration(
                hintText: _tokens.isEmpty
                    ? 'ここに日本語を貼り付けてください…'
                    : 'Edit text…',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.play_arrow_rounded),
                  tooltip: 'Read aloud',
                  onPressed: _textController.text.isNotEmpty
                      ? () => _speech.speakJapanese(_textController.text)
                      : null,
                ),
              ),
              onSubmitted: (_) => _parseText(),
            ),
            if (_tokens.isEmpty) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _parseText,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_stories_rounded),
                    SizedBox(width: 6),
                    Text('Start reading'),
                  ],
                ),
              ),
            ],
            if (_tokens.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Tap a word to look it up',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_tokens.where((t) => t.isJapanese).length} segments',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted.withValues(alpha: .7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _speech.speakJapanese(_textController.text),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.persimmon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Reading area.
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_showingDetail) _dismissDetail();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withValues(alpha: .05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 2,
                      runSpacing: 4,
                      children: [
                        for (final token in _tokens)
                          GestureDetector(
                            onTap: token.isJapanese
                                ? () => _onTokenTap(token)
                                : null,
                            child: Container(
                              padding: token.isJapanese
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 2,
                                    )
                                  : EdgeInsets.zero,
                              decoration: token.isJapanese
                                  ? BoxDecoration(
                                      color: _selectedToken == token
                                          ? AppColors.sakura
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  : null,
                              child: Text(
                                token.text,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: token.isJapanese
                                      ? AppColors.charcoal
                                      : AppColors.muted,
                                  height: 1.8,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Word detail panel.
              if (_showingDetail && _selectedToken != null) ...[
                const SizedBox(height: 12),
                _WordDetailPanel(
                  token: _selectedToken!,
                  wordProgress: wordProgress,
                  onDismiss: _dismissDetail,
                ),
              ],
            ],
            if (_tokens.isEmpty) ...[
              const Spacer(),
              Center(
                child: LeoSprite(pose: LeoPose.smile, size: 120),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Leo is reading too!',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }

  bool _isJapanese(int codeUnit) {
    // Hiragana, katakana, CJK unified ideographs, common punctuation.
    return (codeUnit >= 0x3040 && codeUnit <= 0x309F) || // Hiragana
        (codeUnit >= 0x30A0 && codeUnit <= 0x30FF) || // Katakana
        (codeUnit >= 0x4E00 && codeUnit <= 0x9FFF) || // CJK
        (codeUnit >= 0x3400 && codeUnit <= 0x4DBF) || // CJK Extension A
        (codeUnit >= 0xF900 && codeUnit <= 0xFAFF) || // CJK Compatibility
        (codeUnit >= 0xFF01 && codeUnit <= 0xFF60); // Fullwidth forms
  }

  String _tierEmoji(DifficultyTier tier) => switch (tier) {
    DifficultyTier.starter => '🌱',
    DifficultyTier.elementary => '🌿',
    DifficultyTier.intermediate => '🌸',
    DifficultyTier.advanced => '🌺',
    DifficultyTier.expert => '🏆',
  };
}

class _Token {
  const _Token({
    required this.text,
    required this.isJapanese,
    this.lookupResult,
  });

  final String text;
  final bool isJapanese;
  final Word? lookupResult;

  _Token copyWith({Word? lookupResult}) => _Token(
        text: text,
        isJapanese: isJapanese,
        lookupResult: lookupResult ?? this.lookupResult,
      );
}

class _WordDetailPanel extends StatelessWidget {
  const _WordDetailPanel({
    required this.token,
    required this.wordProgress,
    required this.onDismiss,
  });

  final _Token token;
  final WordProgress wordProgress;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final word = token.lookupResult;
    final isKnown = word != null && wordProgress.completedWords.contains(word.id);
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      token.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (word != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isKnown
                            ? AppColors.matcha.withValues(alpha: .15)
                            : AppColors.persimmon.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isKnown ? 'Known' : 'New word',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isKnown
                              ? AppColors.matcha
                              : AppColors.persimmon,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: onDismiss,
                  ),
                ],
              ),
              if (word != null) ...[
                const SizedBox(height: 6),
                Text(
                  word.romaji,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  word.english,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.matcha,
                  ),
                ),
                if (word.hasExample) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.exampleSentence!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          word.exampleTranslation!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted.withValues(alpha: .8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _DetailChip(
                      label: word.tier.label,
                      color: AppColors.persimmon,
                    ),
                    const SizedBox(width: 6),
                    _DetailChip(
                      label: word.category.label,
                      color: AppColors.teal,
                    ),
                    if (isKnown) ...[
                      const SizedBox(width: 6),
                      _DetailChip(
                        label: '${wordProgress.growthStage(word.id).emoji} ${wordProgress.growthStage(word.id).label}',
                        color: AppColors.matcha,
                      ),
                    ],
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'No match in your word bank yet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.muted.withValues(alpha: .7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep learning — you\'ll recognise this word soon!',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.muted.withValues(alpha: .6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

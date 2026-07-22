import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../services/speech_service.dart';

enum CharacterSet { hiragana, katakana, kanjiN5 }

@immutable
class CharacterEntry {
  const CharacterEntry({
    required this.symbol,
    required this.reading,
    required this.meaning,
    required this.examples,
    required this.pitchPattern,
  });

  final String symbol;
  final String reading;
  final String meaning;
  final List<String> examples;
  final List<int> pitchPattern;

  String get kanjiVgUrl {
    final code = symbol.runes.first.toRadixString(16).padLeft(5, '0');
    return 'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/$code.svg';
  }
}

@immutable
class GridFilterState {
  const GridFilterState({this.set = CharacterSet.hiragana, this.query = ''});

  final CharacterSet set;
  final String query;

  GridFilterState copyWith({CharacterSet? set, String? query}) =>
      GridFilterState(set: set ?? this.set, query: query ?? this.query);
}

class GridFilterNotifier extends Notifier<GridFilterState> {
  @override
  GridFilterState build() => const GridFilterState();

  void selectSet(CharacterSet value) => state = state.copyWith(set: value);

  void search(String value) =>
      state = state.copyWith(query: value.trim().toLowerCase());
}

final gridFilterProvider =
    NotifierProvider<GridFilterNotifier, GridFilterState>(
      GridFilterNotifier.new,
    );

const _characters = <CharacterSet, List<CharacterEntry>>{
  CharacterSet.hiragana: [
    CharacterEntry(
      symbol: 'あ',
      reading: 'a',
      meaning: 'a',
      examples: ['あさ · asa · morning', 'あめ · ame · rain'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: 'い',
      reading: 'i',
      meaning: 'i',
      examples: ['いぬ · inu · dog', 'いえ · ie · house'],
      pitchPattern: [1, 0, 0],
    ),
    CharacterEntry(
      symbol: 'う',
      reading: 'u',
      meaning: 'u',
      examples: ['うみ · umi · sea', 'うえ · ue · above'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: 'え',
      reading: 'e',
      meaning: 'e',
      examples: ['えき · eki · station', 'え · e · picture'],
      pitchPattern: [1, 0],
    ),
    CharacterEntry(
      symbol: 'お',
      reading: 'o',
      meaning: 'o',
      examples: ['おと · oto · sound', 'おちゃ · ocha · tea'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: 'か',
      reading: 'ka',
      meaning: 'ka',
      examples: ['かさ · kasa · umbrella', 'かお · kao · face'],
      pitchPattern: [1, 0, 0],
    ),
    CharacterEntry(
      symbol: 'き',
      reading: 'ki',
      meaning: 'ki',
      examples: ['き · ki · tree', 'きた · kita · north'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: 'く',
      reading: 'ku',
      meaning: 'ku',
      examples: ['くち · kuchi · mouth', 'くも · kumo · cloud'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: 'け',
      reading: 'ke',
      meaning: 'ke',
      examples: ['けさ · kesa · this morning', 'け · ke · hair'],
      pitchPattern: [1, 0],
    ),
    CharacterEntry(
      symbol: 'こ',
      reading: 'ko',
      meaning: 'ko',
      examples: ['こえ · koe · voice', 'ここ · koko · here'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: 'さ',
      reading: 'sa',
      meaning: 'sa',
      examples: ['さかな · sakana · fish', 'さる · saru · monkey'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: 'し',
      reading: 'shi',
      meaning: 'shi',
      examples: ['しお · shio · salt', 'しま · shima · island'],
      pitchPattern: [1, 0, 0],
    ),
    CharacterEntry(
      symbol: 'す',
      reading: 'su',
      meaning: 'su',
      examples: ['すし · sushi', 'すな · suna · sand'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: 'せ',
      reading: 'se',
      meaning: 'se',
      examples: ['せかい · sekai · world', 'せみ · semi · cicada'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: 'そ',
      reading: 'so',
      meaning: 'so',
      examples: ['そら · sora · sky', 'そと · soto · outside'],
      pitchPattern: [1, 0, 0],
    ),
  ],
  CharacterSet.katakana: [
    CharacterEntry(
      symbol: 'ア',
      reading: 'a',
      meaning: 'a',
      examples: ['アイス · aisu · ice cream', 'アジア · Ajia · Asia'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: 'イ',
      reading: 'i',
      meaning: 'i',
      examples: ['インク · inku · ink', 'イタリア · Itaria · Italy'],
      pitchPattern: [1, 0, 0],
    ),
    CharacterEntry(
      symbol: 'ウ',
      reading: 'u',
      meaning: 'u',
      examples: ['ウール · uuru · wool', 'ウイルス · uirusu · virus'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: 'エ',
      reading: 'e',
      meaning: 'e',
      examples: ['エアコン · eakon · air conditioner', 'エネルギー · enerugii · energy'],
      pitchPattern: [1, 0, 0],
    ),
    CharacterEntry(
      symbol: 'オ',
      reading: 'o',
      meaning: 'o',
      examples: ['オレンジ · orenji · orange', 'オイル · oiru · oil'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: 'カ',
      reading: 'ka',
      meaning: 'ka',
      examples: ['カメラ · kamera · camera', 'カレー · karee · curry'],
      pitchPattern: [1, 0, 0],
    ),
    CharacterEntry(
      symbol: 'キ',
      reading: 'ki',
      meaning: 'ki',
      examples: ['キス · kisu · kiss', 'キロ · kiro · kilo'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: 'ク',
      reading: 'ku',
      meaning: 'ku',
      examples: ['クラス · kurasu · class', 'クリーム · kuriimu · cream'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: 'ケ',
      reading: 'ke',
      meaning: 'ke',
      examples: ['ケーキ · keeki · cake', 'ケース · keesu · case'],
      pitchPattern: [1, 0],
    ),
    CharacterEntry(
      symbol: 'コ',
      reading: 'ko',
      meaning: 'ko',
      examples: ['コーヒー · koohii · coffee', 'コート · kooto · coat'],
      pitchPattern: [0, 1, 0],
    ),
  ],
  CharacterSet.kanjiN5: [
    CharacterEntry(
      symbol: '一',
      reading: 'いち · ichi',
      meaning: 'one',
      examples: ['一つ · hitotsu · one thing', '一日 · ichinichi · one day'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: '人',
      reading: 'ひと · hito',
      meaning: 'person',
      examples: [
        '日本人 · nihonjin · Japanese person',
        '一人 · hitori · one person',
      ],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: '日',
      reading: 'ひ · hi / にち · nichi',
      meaning: 'day, sun',
      examples: ['日本 · nihon · Japan', '休日 · kyuujitsu · holiday'],
      pitchPattern: [1, 0, 0],
    ),
    CharacterEntry(
      symbol: '月',
      reading: 'つき · tsuki / げつ · getsu',
      meaning: 'moon, month',
      examples: ['月曜日 · getsuyoubi · Monday', '今月 · kongetsu · this month'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: '火',
      reading: 'ひ · hi / か · ka',
      meaning: 'fire',
      examples: ['火曜日 · kayoubi · Tuesday', '花火 · hanabi · fireworks'],
      pitchPattern: [1, 0, 0],
    ),
    CharacterEntry(
      symbol: '水',
      reading: 'みず · mizu',
      meaning: 'water',
      examples: ['水曜日 · suiyoubi · Wednesday', '水 · mizu · water'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: '木',
      reading: 'き · ki',
      meaning: 'tree, wood',
      examples: ['木曜日 · mokuyoubi · Thursday', '木 · ki · tree'],
      pitchPattern: [1, 0],
    ),
    CharacterEntry(
      symbol: '金',
      reading: 'かね · kane / きん · kin',
      meaning: 'gold, money',
      examples: ['金曜日 · kinyoubi · Friday', 'お金 · okane · money'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: '土',
      reading: 'つち · tsuchi',
      meaning: 'earth, soil',
      examples: ['土曜日 · doyoubi · Saturday', '土地 · tochi · land'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: '山',
      reading: 'やま · yama',
      meaning: 'mountain',
      examples: ['富士山 · fujisan · Mt Fuji', '山道 · yamamichi · mountain road'],
      pitchPattern: [0, 1, 1],
    ),
    CharacterEntry(
      symbol: '川',
      reading: 'かわ · kawa',
      meaning: 'river',
      examples: ['川 · kawa · river', '小川 · ogawa · stream'],
      pitchPattern: [0, 1, 0],
    ),
    CharacterEntry(
      symbol: '本',
      reading: 'ほん · hon',
      meaning: 'book, origin',
      examples: ['本 · hon · book', '日本 · nihon · Japan'],
      pitchPattern: [1, 0],
    ),
  ],
};

class KanaGridView extends ConsumerStatefulWidget {
  const KanaGridView({super.key});

  @override
  ConsumerState<KanaGridView> createState() => _KanaGridViewState();
}

class _KanaGridViewState extends ConsumerState<KanaGridView> {
  final SpeechService _speech = SpeechService();
  String? _playing;

  @override
  void dispose() {
    _speech.dispose();
    super.dispose();
  }

  Future<void> _play(CharacterEntry entry) async {
    setState(() => _playing = entry.symbol);
    try {
      await _speech.speakJapanese(entry.symbol);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio is unavailable. Check your connection and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _playing = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(gridFilterProvider);
    final entries = _characters[filter.set]!.where((entry) {
      final haystack = '${entry.symbol} ${entry.reading} ${entry.meaning}'
          .toLowerCase();
      return haystack.contains(filter.query);
    }).toList();

    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Meet the characters',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text('Tap a card to see how it is written and spoken.'),
          const SizedBox(height: 16),
          SegmentedButton<CharacterSet>(
            segments: const [
              ButtonSegment(
                value: CharacterSet.hiragana,
                label: Text('Hiragana'),
              ),
              ButtonSegment(
                value: CharacterSet.katakana,
                label: Text('Katakana'),
              ),
              ButtonSegment(
                value: CharacterSet.kanjiN5,
                label: Text('N5 Kanji'),
              ),
            ],
            selected: {filter.set},
            showSelectedIcon: false,
            onSelectionChanged: (value) =>
                ref.read(gridFilterProvider.notifier).selectSet(value.first),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: ref.read(gridFilterProvider.notifier).search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search a character, reading, or meaning',
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const _EmptyResults()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 520
                    ? 5
                    : constraints.maxWidth >= 380
                    ? 4
                    : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: .86,
                  ),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _CharacterCard(
                      entry: entry,
                      playing: _playing == entry.symbol,
                      onAudio: () => _play(entry),
                      onOpen: () => _showDetails(context, entry),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, CharacterEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (_) =>
          _CharacterDetails(entry: entry, onAudio: () => _play(entry)),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.entry,
    required this.playing,
    required this.onAudio,
    required this.onOpen,
  });

  final CharacterEntry entry;
  final bool playing;
  final VoidCallback onAudio;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  child: Text(
                    entry.symbol,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Text(
                entry.reading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (entry.meaning != entry.reading)
                Text(
                  entry.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              SizedBox(
                height: 34,
                child: IconButton(
                  tooltip: 'Play ${entry.reading}',
                  visualDensity: VisualDensity.compact,
                  onPressed: playing ? null : onAudio,
                  icon: playing
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.volume_up_rounded,
                          size: 20,
                          color: AppColors.teal,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterDetails extends StatefulWidget {
  const _CharacterDetails({required this.entry, required this.onAudio});

  final CharacterEntry entry;
  final VoidCallback onAudio;

  @override
  State<_CharacterDetails> createState() => _CharacterDetailsState();
}

class _CharacterDetailsState extends State<_CharacterDetails>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  entry.symbol,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.reading,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        entry.meaning,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: widget.onAudio,
                  icon: const Icon(Icons.volume_up_rounded),
                  tooltip: 'Play pronunciation',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Stroke order',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: SizedBox(
                height: 210,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => ClipRect(
                    child: Align(
                      alignment: Alignment.topLeft,
                      widthFactor: _controller.value,
                      child: child,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SvgPicture.network(
                      entry.kanjiVgUrl,
                      semanticsLabel:
                          '${entry.symbol} stroke order from KanjiVG',
                      placeholderBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _controller.forward(from: 0),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Replay strokes'),
              ),
            ),
            Text(
              'Pitch accent',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: SizedBox(
                height: 96,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: CustomPaint(
                    painter: _PitchAccentPainter(entry.pitchPattern),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Example words',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            ...entry.examples.map(
              (example) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.peach,
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.coral,
                    size: 19,
                  ),
                ),
                title: Text(example),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PitchAccentPainter extends CustomPainter {
  const _PitchAccentPainter(this.pattern);

  final List<int> pattern;

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern.isEmpty) return;
    final line = Paint()
      ..color = AppColors.coral
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = AppColors.coral;
    final guide = Paint()
      ..color = AppColors.charcoal.withValues(alpha: .1)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * .25),
      Offset(size.width, size.height * .25),
      guide,
    );
    canvas.drawLine(
      Offset(0, size.height * .75),
      Offset(size.width, size.height * .75),
      guide,
    );
    final step = pattern.length == 1 ? 0.0 : size.width / (pattern.length - 1);
    final points = <Offset>[];
    for (var i = 0; i < pattern.length; i++) {
      points.add(
        Offset(
          i * step,
          pattern[i] == 1 ? size.height * .25 : size.height * .75,
        ),
      );
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, line);
    for (final point in points) {
      canvas.drawCircle(point, math.min(5, size.height / 10), dot);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchAccentPainter oldDelegate) =>
      oldDelegate.pattern != pattern;
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Text('🐾', style: TextStyle(fontSize: 38)),
            const SizedBox(height: 8),
            Text(
              'Leo could not find that one.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('Try a character, romaji reading, or English meaning.'),
          ],
        ),
      ),
    );
  }
}

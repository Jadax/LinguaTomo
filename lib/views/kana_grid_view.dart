import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/character_data.dart';
import '../models/character_entry.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';

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
            content: Text('Audio is unavailable just now. Please try again.'),
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
    final entries = characterLibrary[filter.set]!.where((entry) {
      return '${entry.symbol} ${entry.reading} ${entry.meaning}'
          .toLowerCase()
          .contains(filter.query);
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
          const Text(
            'Learn the basic syllabaries, then connect kanji to useful words.',
          ),
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
              hintText: 'Search a character, reading or meaning',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${entries.length} characters',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
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
                      onOpen: () => _showDetails(entry),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  void _showDetails(CharacterEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
  Widget build(BuildContext context) => Card(
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

class _CharacterDetails extends StatelessWidget {
  const _CharacterDetails({required this.entry, required this.onAudio});
  final CharacterEntry entry;
  final VoidCallback onAudio;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
                onPressed: onAudio,
                icon: const Icon(Icons.volume_up_rounded),
                tooltip: 'Play pronunciation',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Stroke order', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SizedBox(
              height: 210,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SvgPicture.network(
                  entry.kanjiVgUrl,
                  semanticsLabel: '${entry.symbol} stroke order from KanjiVG',
                  placeholderBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.teal.withValues(alpha: .08),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Pitch accent belongs to whole words and can vary by word and region. LinguaTomo teaches it with verified word audio, never as an invented property of an isolated character.',
              ),
            ),
          ),
          if (entry.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Example words',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            for (final example in entry.examples)
              ListTile(
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
          ],
        ],
      ),
    ),
  );
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();
  @override
  Widget build(BuildContext context) => Card(
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
          const Text('Try a character, romaji reading or English meaning.'),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/grammar_repository.dart';
import '../models/grammar_models.dart';
import '../providers/grammar_state.dart';
import '../theme/app_theme.dart';
import 'content_sources_view.dart';
import 'grammar_lesson_view.dart';

class GrammarLibraryView extends ConsumerStatefulWidget {
  const GrammarLibraryView({super.key});

  @override
  ConsumerState<GrammarLibraryView> createState() => _GrammarLibraryViewState();
}

class _GrammarLibraryViewState extends ConsumerState<GrammarLibraryView> {
  String _level = 'N5';
  String _query = '';
  bool _bookmarksOnly = false;

  @override
  Widget build(BuildContext context) {
    final catalogue = ref.watch(grammarCatalogueProvider);
    final garden = ref.watch(grammarGardenProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Course Atlas'),
        actions: [
          IconButton(
            tooltip: 'Sources and licences',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContentSourcesView()),
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: catalogue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 42),
                const SizedBox(height: 10),
                const Text('The local course library could not be opened.'),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => ref.invalidate(grammarCatalogueProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (value) {
          final filtered = value.points
              .where((point) {
                if (point.level != _level) return false;
                if (_bookmarksOnly && !garden.bookmarks.contains(point.id)) {
                  return false;
                }
                return _query.isEmpty || point.searchText.contains(_query);
              })
              .toList(growable: false);
          return ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '828 gentle steps into grammar',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '${garden.cards.length} planted • ${garden.dueCount} ready to revisit',
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: _bookmarksOnly
                          ? 'Show every lesson'
                          : 'Show bookmarks only',
                      onPressed: () =>
                          setState(() => _bookmarksOnly = !_bookmarksOnly),
                      icon: Icon(
                        _bookmarksOnly
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                TextField(
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search English, Japanese or romaji',
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<String>(
                    segments: [
                      for (final level in GrammarRepository.levels)
                        ButtonSegment(
                          value: level,
                          label: Text('$level (${value.countFor(level)})'),
                        ),
                    ],
                    selected: {_level},
                    onSelectionChanged: (value) =>
                        setState(() => _level = value.first),
                  ),
                ),
                const SizedBox(height: 10),
                _LevelGuide(level: _level),
                const SizedBox(height: 12),
                Text(
                  '${filtered.length} lessons',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                if (filtered.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No lessons match yet. Try a broader search or show all lessons.',
                      ),
                    ),
                  )
                else
                  for (final point in filtered)
                    _GrammarRow(
                      point: point,
                      planted: garden.isPlanted(point.id),
                      bookmarked: garden.bookmarks.contains(point.id),
                      onBookmark: () => ref
                          .read(grammarGardenProvider.notifier)
                          .toggleBookmark(point.id),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LevelGuide extends StatelessWidget {
  const _LevelGuide({required this.level});
  final String level;

  static const guidance = {
    'N5': 'Foundations for basic sentences and familiar daily situations',
    'N4': 'Everyday narration, reasons, requests and comparisons',
    'N3': 'Independent conversation, viewpoints and connected text',
    'N2': 'Detailed reading, formal interaction and nuanced relationships',
    'N1': 'Dense written Japanese, rhetoric and subtle stance',
  };

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.bambooMist,
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Text('$level study reference: ${guidance[level]}'),
    ),
  );
}

class _GrammarRow extends StatelessWidget {
  const _GrammarRow({
    required this.point,
    required this.planted,
    required this.bookmarked,
    required this.onBookmark,
  });

  final GrammarPoint point;
  final bool planted;
  final bool bookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(15, 8, 7, 8),
      leading: CircleAvatar(
        backgroundColor: planted ? AppColors.bambooMist : AppColors.peach,
        child: planted
            ? const Text('🌱')
            : Text(
                '${point.order}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
      ),
      title: Text(
        point.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        point.summary,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark lesson',
        onPressed: onBookmark,
        icon: Icon(
          bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GrammarLessonView(point: point)),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../data/festival_calendar_data.dart';
import '../theme/app_theme.dart';

typedef SeasonalFeature = ({String emoji, String title, String description});

DateTime japanToday() => DateTime.now().toUtc().add(const Duration(hours: 9));

class SeasonalStoriesView extends StatelessWidget {
  const SeasonalStoriesView({super.key});

  static const _stories = [
    (
      '🌸',
      'Spring',
      'Hanami invitation',
      '一緒に花見をしませんか。',
      'Invite a friend gently and plan a picnic.',
    ),
    (
      '🎏',
      'Spring',
      'Children’s Day',
      'こいのぼりが泳いでいます。',
      'Describe what you see while learning the celebration’s family context.',
    ),
    (
      '☔',
      'Rainy season',
      'A borrowed umbrella',
      'この傘を使ってください。',
      'Offer practical help and respond politely.',
    ),
    (
      '🎋',
      'Summer',
      'Tanabata wish',
      '願いごとを書きました。',
      'Write a wish and compare regional festival traditions.',
    ),
    (
      '🏮',
      'Summer',
      'Obon homecoming',
      '家族とお墓参りに行きます。',
      'Talk respectfully about family remembrance.',
    ),
    (
      '🍁',
      'Autumn',
      'Maple walk',
      '紅葉を見に行きませんか。',
      'Make a relaxed plan and discuss changing weather.',
    ),
    (
      '🌕',
      'Autumn',
      'Moon viewing',
      '月がきれいに見えます。',
      'Describe appearance and share an observation.',
    ),
    (
      '🎍',
      'Winter',
      'New Year visit',
      '今年もよろしくお願いします。',
      'Use a seasonal greeting with the right relationship and setting.',
    ),
    (
      '❄️',
      'Winter',
      'Snow country journey',
      '電車が遅れているそうです。',
      'Report travel information and adjust a plan.',
    ),
    (
      '🫘',
      'Winter',
      'Setsubun beans',
      '福は内、鬼は外。',
      'Follow a cultural instruction, then compare how households mark Setsubun.',
    ),
    (
      '🎎',
      'Spring',
      'Hinamatsuri display',
      '人形がきれいに飾ってあります。',
      'Describe a prepared display and ask respectfully about a family custom.',
    ),
    (
      '🎓',
      'Spring',
      'Graduation morning',
      '卒業しても、連絡してください。',
      'Share a warm wish and practise ても for a change in circumstances.',
    ),
    (
      '🌱',
      'Spring',
      'First tea harvest',
      '新茶を飲んだことがありますか。',
      'Ask about experience and learn why harvest timing affects tea.',
    ),
    (
      '🌿',
      'Summer',
      'A cool bamboo path',
      '風が通るので、涼しく感じます。',
      'Give a reason and describe a physical impression without exaggeration.',
    ),
    (
      '🎐',
      'Summer',
      'Wind-chime afternoon',
      '風鈴の音を聞くと、涼しい気がします。',
      'Connect a sound with a feeling and notice a seasonal design tradition.',
    ),
    (
      '🎆',
      'Summer',
      'Fireworks meeting point',
      '駅が混む前に会いましょう。',
      'Arrange a safe meeting place and use 前に to sequence a plan.',
    ),
    (
      '🧊',
      'Summer',
      'Kakigoori choice',
      'どの味にしようか迷っています。',
      'Compare flavours and express that you are undecided.',
    ),
    (
      '🎑',
      'Autumn',
      'Dumplings for the moon',
      '月が出るまでに準備しておきます。',
      'Prepare in advance and distinguish まで from までに.',
    ),
    (
      '🍠',
      'Autumn',
      'Roasted sweet potato',
      '寒くなると、焼き芋が食べたくなります。',
      'Describe a seasonal trigger and a changing desire.',
    ),
    (
      '📚',
      'Autumn',
      'A long reading evening',
      '読み終わったら、感想を聞かせてください。',
      'Sequence actions and invite someone to share a response.',
    ),
    (
      '🏃',
      'Autumn',
      'Sports day relay',
      '転ばないように気をつけて。',
      'Give caring advice using ように without sounding commanding.',
    ),
    (
      '🍲',
      'Winter',
      'Hot-pot gathering',
      '野菜が煮えたら、食べられます。',
      'Recognise when food is ready and practise a conditional sequence.',
    ),
    (
      '🔔',
      'Winter',
      'Temple bell at year end',
      '静かに順番を待ちましょう。',
      'Follow shared-space etiquette and make a gentle group suggestion.',
    ),
    (
      '🧣',
      'Winter',
      'A forgotten scarf',
      '忘れ物として届いていませんか。',
      'Ask at lost property and describe an item clearly.',
    ),
  ];

  static int _featuredMonth(String title) => switch (title) {
    'New Year visit' || 'Snow country journey' => 1,
    'Setsubun beans' => 2,
    'Hinamatsuri display' || 'Graduation morning' => 3,
    'Hanami invitation' => 4,
    'Children’s Day' || 'First tea harvest' => 5,
    'A borrowed umbrella' || 'A cool bamboo path' => 6,
    'Tanabata wish' || 'Wind-chime afternoon' => 7,
    'Obon homecoming' || 'Fireworks meeting point' || 'Kakigoori choice' => 8,
    'Moon viewing' || 'Dumplings for the moon' => 9,
    'Maple walk' || 'Sports day relay' => 10,
    'Roasted sweet potato' || 'A long reading evening' => 11,
    'Hot-pot gathering' ||
    'Temple bell at year end' ||
    'A forgotten scarf' => 12,
    _ => 1,
  };

  static SeasonalFeature featured() {
    final month = japanToday().month;
    final story = _stories.firstWhere(
      (item) => _featuredMonth(item.$3) == month,
      orElse: () => _stories.first,
    );
    return (emoji: story.$1, title: story.$3, description: story.$5);
  }

  @override
  Widget build(BuildContext context) {
    final month = japanToday().month;
    final currentFestivals = festivalCalendar
        .where((event) => event.isCurrent(japanToday()))
        .toList();
    final ordered = [..._stories]
      ..sort((a, b) {
        final aCurrent = _featuredMonth(a.$3) == month ? 0 : 1;
        final bCurrent = _featuredMonth(b.$3) == month ? 0 : 1;
        return aCurrent.compareTo(bCurrent);
      });
    return Scaffold(
      appBar: AppBar(title: const Text('Seasonal Stories')),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '24 stories through the year',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'The first stories match today’s season in Japan. Every story remains in the archive, so nobody loses learning because they took a break. Dates that follow a lunar calendar or local bloom times are presented as cultural windows, not fixed national dates.',
            ),
            const SizedBox(height: 14),
            _FestivalTimeline(events: currentFestivals),
            const SizedBox(height: 16),
            Text(
              'Seasonal story archive',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final story in ordered)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  leading: Text(story.$1, style: const TextStyle(fontSize: 30)),
                  title: Text(
                    story.$3,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    _featuredMonth(story.$3) == month
                        ? 'Now in Japan · ${story.$2}'
                        : story.$2,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        story.$4,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(story.$5),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Story lessons unlock in route order. The preview is always free.',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FestivalTimeline extends StatelessWidget {
  const _FestivalTimeline({required this.events});

  final List<FestivalEvent> events;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.bambooMist,
    child: ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(
        Icons.calendar_month_rounded,
        color: AppColors.matcha,
      ),
      title: const Text(
        'Living festival calendar',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '${festivalCalendar.length} cultural windows · ${events.length} featured this month in Japan',
      ),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Regional schedules, bloom dates and lunar-calendar observances can move. LinguaTomo uses date windows and keeps every activity available in the archive.',
          ),
        ),
        const SizedBox(height: 10),
        for (final event in events.take(6))
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: Text(event.emoji, style: const TextStyle(fontSize: 27)),
              title: Text(
                event.englishName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('${event.japaneseName} · ${event.dateWindow}'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${event.place}. ${event.description}'),
                ),
                const SizedBox(height: 8),
                for (final word in event.vocabulary)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('• $word'),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text('Memory reward: ${event.reward}')),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (context) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: .82,
              builder: (context, controller) => ListView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                itemCount: festivalCalendar.length,
                itemBuilder: (context, index) {
                  final event = festivalCalendar[index];
                  return ListTile(
                    leading: Text(
                      event.emoji,
                      style: const TextStyle(fontSize: 25),
                    ),
                    title: Text(
                      event.englishName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${event.japaneseName} · ${event.dateWindow} · ${event.place}',
                    ),
                  );
                },
              ),
            ),
          ),
          icon: const Icon(Icons.event_note_rounded),
          label: const Text('Browse the full festival year'),
        ),
      ],
    ),
  );
}

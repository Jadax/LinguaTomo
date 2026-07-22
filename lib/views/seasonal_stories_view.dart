import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Seasonal Stories')),
    body: ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Japan through the year',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'Each story is a short practical scene with useful language, a cultural note and a keepsake stamp. Stories remain in the archive after their featured season, so nobody loses learning because they took a break.',
          ),
          const SizedBox(height: 16),
          for (final story in _stories)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: Text(story.$1, style: const TextStyle(fontSize: 30)),
                title: Text(
                  story.$3,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(story.$2),
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
                  Align(alignment: Alignment.centerLeft, child: Text(story.$5)),
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

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

  @override
  Widget build(BuildContext context) => Scaffold(
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
            'Each story is a practical side quest with useful language, a cultural note and a keepsake stamp. Stories remain in the archive after their featured season, so nobody loses learning because they took a break.',
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

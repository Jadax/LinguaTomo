class FestivalEvent {
  const FestivalEvent({
    required this.id,
    required this.emoji,
    required this.englishName,
    required this.japaneseName,
    required this.months,
    required this.dateWindow,
    required this.place,
    required this.description,
    required this.vocabulary,
    required this.reward,
  });

  final String id;
  final String emoji;
  final String englishName;
  final String japaneseName;
  final Set<int> months;
  final String dateWindow;
  final String place;
  final String description;
  final List<String> vocabulary;
  final String reward;

  bool isCurrent(DateTime japanDate) => months.contains(japanDate.month);
}

const festivalCalendar = <FestivalEvent>[
  FestivalEvent(
    id: 'shogatsu',
    emoji: '🎍',
    englishName: 'New Year',
    japaneseName: 'お正月・正月',
    months: {1},
    dateWindow: '1–3 January',
    place: 'Across Japan',
    description:
        'Family gatherings, osechi food and the first shrine or temple visit of the year.',
    vocabulary: [
      '正月 · しょうがつ · New Year',
      '初詣 · はつもうで · first shrine visit',
      'おせち · New Year food',
    ],
    reward: 'Kadomatsu Nest decoration',
  ),
  FestivalEvent(
    id: 'seijin',
    emoji: '👘',
    englishName: 'Coming of Age Day',
    japaneseName: '成人の日',
    months: {1},
    dateWindow: 'Second Monday of January',
    place: 'Across Japan',
    description:
        'Communities celebrate young adults reaching adulthood. Ceremonies and formal clothing are common.',
    vocabulary: [
      '成人 · せいじん · adult',
      '式 · しき · ceremony',
      '振袖 · ふりそで · long-sleeved kimono',
    ],
    reward: 'Furisode postcard stamp',
  ),
  FestivalEvent(
    id: 'shirakawago',
    emoji: '🏘️',
    englishName: 'Shirakawa-go winter light-up',
    japaneseName: '白川郷ライトアップ',
    months: {1, 2},
    dateWindow: 'Selected winter dates',
    place: 'Gifu',
    description:
        'Thatched gassho-style homes glow against deep snow. Dates and entry arrangements change each year.',
    vocabulary: [
      '雪 · ゆき · snow',
      '合掌造り · がっしょうづくり · gassho-style house',
      '明かり · あかり · light',
    ],
    reward: 'Snow village postcard',
  ),
  FestivalEvent(
    id: 'setsubun',
    emoji: '🫘',
    englishName: 'Setsubun',
    japaneseName: '節分',
    months: {2},
    dateWindow: 'Around 3 February',
    place: 'Across Japan',
    description:
        'Roasted beans and the phrase “Oni wa soto, fuku wa uchi” symbolically welcome good fortune.',
    vocabulary: ['節分 · せつぶん', '豆 · まめ · beans', '福 · ふく · good fortune'],
    reward: 'Lucky bean bowl',
  ),
  FestivalEvent(
    id: 'sapporo_snow',
    emoji: '❄️',
    englishName: 'Sapporo Snow Festival',
    japaneseName: 'さっぽろ雪まつり',
    months: {2},
    dateWindow: 'Early February',
    place: 'Sapporo, Hokkaido',
    description:
        'Large snow and ice sculptures transform central Sapporo into a winter gallery.',
    vocabulary: [
      '雪像 · せつぞう · snow sculpture',
      '氷 · こおり · ice',
      '公園 · こうえん · park',
    ],
    reward: 'Snow-lantern profile frame',
  ),
  FestivalEvent(
    id: 'valentine',
    emoji: '🍫',
    englishName: 'Valentine’s Day',
    japaneseName: 'バレンタインデー',
    months: {2},
    dateWindow: '14 February',
    place: 'Across Japan',
    description:
        'Chocolate-giving customs vary between romantic, friendship and workplace contexts and continue to evolve.',
    vocabulary: [
      'チョコレート · chocolate',
      '本命 · ほんめい · romantic favourite',
      '友チョコ · ともちょこ · friend chocolate',
    ],
    reward: 'Chocolate postcard stamp',
  ),
  FestivalEvent(
    id: 'hinamatsuri',
    emoji: '🎎',
    englishName: 'Hinamatsuri',
    japaneseName: 'ひな祭り',
    months: {3},
    dateWindow: '3 March',
    place: 'Across Japan',
    description:
        'Families display hina dolls and wish for the health and happiness of girls.',
    vocabulary: [
      'ひな人形 · ひなにんぎょう · hina doll',
      '飾る · かざる · display',
      '健康 · けんこう · health',
    ],
    reward: 'Hina doll shelf',
  ),
  FestivalEvent(
    id: 'white_day',
    emoji: '🎁',
    englishName: 'White Day',
    japaneseName: 'ホワイトデー',
    months: {3},
    dateWindow: '14 March',
    place: 'Across Japan',
    description: 'A modern gift-giving day one month after Valentine’s Day.',
    vocabulary: [
      'お返し · おかえし · return gift',
      '贈る · おくる · give',
      '包む · つつむ · wrap',
    ],
    reward: 'Ribbon stamp',
  ),
  FestivalEvent(
    id: 'hanami',
    emoji: '🌸',
    englishName: 'Cherry blossom viewing',
    japaneseName: '花見',
    months: {3, 4, 5},
    dateWindow: 'Bloom timing varies by region',
    place: 'Across Japan',
    description:
        'People enjoy blossoms with friends, family or colleagues. The bloom front moves north as the weather warms.',
    vocabulary: [
      '桜 · さくら · cherry blossom',
      '花見 · はなみ · flower viewing',
      '弁当 · べんとう · packed meal',
    ],
    reward: 'Sakura Veranda environment',
  ),
  FestivalEvent(
    id: 'takayama_spring',
    emoji: '🏮',
    englishName: 'Takayama Spring Festival',
    japaneseName: '春の高山祭',
    months: {4},
    dateWindow: '14–15 April',
    place: 'Takayama, Gifu',
    description:
        'Ornate festival floats and traditional performances move through Takayama’s historic streets.',
    vocabulary: [
      '屋台 · やたい · festival float',
      '行列 · ぎょうれつ · procession',
      'からくり · mechanical performance',
    ],
    reward: 'Festival float stamp',
  ),
  FestivalEvent(
    id: 'kodomo',
    emoji: '🎏',
    englishName: 'Children’s Day',
    japaneseName: 'こどもの日',
    months: {5},
    dateWindow: '5 May',
    place: 'Across Japan',
    description:
        'Carp streamers symbolise vitality and hopes for children’s healthy growth.',
    vocabulary: [
      'こいのぼり · carp streamer',
      '子ども · こども · child',
      '元気 · げんき · healthy and lively',
    ],
    reward: 'Koinobori mobile',
  ),
  FestivalEvent(
    id: 'aoi',
    emoji: '🌿',
    englishName: 'Aoi Matsuri',
    japaneseName: '葵祭',
    months: {5},
    dateWindow: '15 May',
    place: 'Kyoto',
    description:
        'A formal procession connected with the Kamo shrines features historical court dress and hollyhock leaves.',
    vocabulary: [
      '葵 · あおい · hollyhock',
      '行列 · ぎょうれつ · procession',
      '装束 · しょうぞく · ceremonial costume',
    ],
    reward: 'Hollyhock postcard',
  ),
  FestivalEvent(
    id: 'sanja',
    emoji: '⛩️',
    englishName: 'Sanja Matsuri',
    japaneseName: '三社祭',
    months: {5},
    dateWindow: 'Usually the third weekend of May',
    place: 'Asakusa, Tokyo',
    description:
        'A lively neighbourhood festival centred on Asakusa Shrine and mikoshi processions.',
    vocabulary: [
      '神輿 · みこし · portable shrine',
      '担ぐ · かつぐ · carry on shoulders',
      '浅草 · あさくさ · Asakusa',
    ],
    reward: 'Mikoshi stamp',
  ),
  FestivalEvent(
    id: 'kanda',
    emoji: '🏮',
    englishName: 'Kanda Matsuri',
    japaneseName: '神田祭',
    months: {5},
    dateWindow: 'May in odd-numbered years; programme varies',
    place: 'Tokyo',
    description:
        'One of Tokyo’s major shrine festivals, with processions connecting Kanda and central districts.',
    vocabulary: [
      '祭礼 · さいれい · shrine festival',
      '神社 · じんじゃ · shrine',
      '町 · まち · neighbourhood',
    ],
    reward: 'Three Great Festivals collection piece',
  ),
  FestivalEvent(
    id: 'tsuyu',
    emoji: '☔',
    englishName: 'Rainy-season traditions',
    japaneseName: '梅雨',
    months: {6},
    dateWindow: 'Timing varies by region',
    place: 'Much of Japan',
    description:
        'Hydrangeas, umbrellas and changing weather provide practical seasonal language.',
    vocabulary: [
      '梅雨 · つゆ · rainy season',
      '紫陽花 · あじさい · hydrangea',
      '傘 · かさ · umbrella',
    ],
    reward: 'Rainy window ambience',
  ),
  FestivalEvent(
    id: 'tanabata',
    emoji: '🎋',
    englishName: 'Tanabata',
    japaneseName: '七夕',
    months: {7, 8},
    dateWindow: '7 July; August in some regions',
    place: 'Across Japan',
    description:
        'Wishes are written on colourful paper strips and hung from bamboo. Regional festival dates differ.',
    vocabulary: ['七夕 · たなばた', '願い事 · ねがいごと · wish', '短冊 · たんざく · wish strip'],
    reward: 'Butterfly and wish mobile',
  ),
  FestivalEvent(
    id: 'gion',
    emoji: '🏮',
    englishName: 'Gion Matsuri',
    japaneseName: '祇園祭',
    months: {7},
    dateWindow: 'July; main processions 17 and 24 July',
    place: 'Kyoto',
    description:
        'A month-long festival known for enormous decorated yamaboko floats and evening street displays.',
    vocabulary: [
      '山鉾 · やまぼこ · festival float',
      '巡行 · じゅんこう · procession',
      '宵山 · よいやま · evening festivities',
    ],
    reward: 'Yamaboko miniature',
  ),
  FestivalEvent(
    id: 'nachi',
    emoji: '🔥',
    englishName: 'Nachi Fire Festival',
    japaneseName: '那智の扇祭り',
    months: {7},
    dateWindow: '14 July',
    place: 'Kumano, Wakayama',
    description:
        'Large torches accompany sacred objects near Nachi Waterfall in a dramatic purification rite.',
    vocabulary: [
      '松明 · たいまつ · torch',
      '滝 · たき · waterfall',
      '清める · きよめる · purify',
    ],
    reward: 'Fire stamp',
  ),
  FestivalEvent(
    id: 'tenjin',
    emoji: '🎆',
    englishName: 'Tenjin Matsuri',
    japaneseName: '天神祭',
    months: {7},
    dateWindow: '24–25 July',
    place: 'Osaka',
    description:
        'Processions on land and water culminate in illuminated boats and fireworks.',
    vocabulary: ['船 · ふね · boat', '花火 · はなび · fireworks', '川 · かわ · river'],
    reward: 'River-fireworks postcard',
  ),
  FestivalEvent(
    id: 'nebuta',
    emoji: '🌟',
    englishName: 'Aomori Nebuta Matsuri',
    japaneseName: '青森ねぶた祭',
    months: {8},
    dateWindow: '2–7 August',
    place: 'Aomori',
    description:
        'Huge illuminated figure floats parade at night with drums, flutes and energetic dancers.',
    vocabulary: [
      'ねぶた · illuminated float',
      '太鼓 · たいこ · drum',
      '跳人 · はねと · festival dancer',
    ],
    reward: 'Nebuta lantern',
  ),
  FestivalEvent(
    id: 'kanto',
    emoji: '🎋',
    englishName: 'Akita Kanto Matsuri',
    japaneseName: '秋田竿燈まつり',
    months: {8},
    dateWindow: '3–6 August',
    place: 'Akita',
    description:
        'Performers balance tall lantern poles shaped to resemble heavy ears of rice.',
    vocabulary: [
      '竿燈 · かんとう · lantern pole',
      '提灯 · ちょうちん · lantern',
      '支える · ささえる · support',
    ],
    reward: 'Balance challenge stamp',
  ),
  FestivalEvent(
    id: 'obon',
    emoji: '🏮',
    englishName: 'Obon',
    japaneseName: 'お盆',
    months: {7, 8},
    dateWindow: 'Dates vary by region, commonly mid-August',
    place: 'Across Japan',
    description:
        'Families remember ancestors. Customs can include homecoming visits, bon dancing and lanterns.',
    vocabulary: ['お盆 · おぼん', '先祖 · せんぞ · ancestors', '盆踊り · ぼんおどり · Bon dance'],
    reward: 'Floating lantern ambience',
  ),
  FestivalEvent(
    id: 'awa',
    emoji: '🪭',
    englishName: 'Awa Odori',
    japaneseName: '阿波おどり',
    months: {8},
    dateWindow: '12–15 August',
    place: 'Tokushima',
    description:
        'Dance groups fill the streets with distinctive rhythms, calls and coordinated movement.',
    vocabulary: ['踊る · おどる · dance', '連 · れん · dance group', '笛 · ふえ · flute'],
    reward: 'Yukata Leo reaction',
  ),
  FestivalEvent(
    id: 'hanabi',
    emoji: '🎇',
    englishName: 'Summer fireworks festivals',
    japaneseName: '花火大会',
    months: {7, 8},
    dateWindow: 'Dates vary by city',
    place: 'Across Japan',
    description:
        'Riversides and bays become gathering places for large fireworks displays and summer food stalls.',
    vocabulary: [
      '花火大会 · はなびたいかい',
      '浴衣 · ゆかた · summer kimono',
      '屋台 · やたい · food stall',
    ],
    reward: 'Fireworks window effect',
  ),
  FestivalEvent(
    id: 'tsukimi',
    emoji: '🌕',
    englishName: 'Moon viewing',
    japaneseName: '月見',
    months: {9, 10},
    dateWindow: 'Lunar-calendar date changes yearly',
    place: 'Across Japan',
    description:
        'Seasonal displays may include pampas grass and dumplings while appreciating the autumn moon.',
    vocabulary: [
      '月見 · つきみ · moon viewing',
      '団子 · だんご · dumpling',
      'すすき · pampas grass',
    ],
    reward: 'Moon lamp',
  ),
  FestivalEvent(
    id: 'takayama_autumn',
    emoji: '🍁',
    englishName: 'Takayama Autumn Festival',
    japaneseName: '秋の高山祭',
    months: {10},
    dateWindow: '9–10 October',
    place: 'Takayama, Gifu',
    description:
        'Decorated floats, evening lanterns and historic streets create a distinctive autumn festival scene.',
    vocabulary: [
      '秋祭り · あきまつり · autumn festival',
      '紅葉 · こうよう · autumn colours',
      '提灯 · ちょうちん · lantern',
    ],
    reward: 'Autumn float postcard',
  ),
  FestivalEvent(
    id: 'kawagoe',
    emoji: '🏯',
    englishName: 'Kawagoe Festival',
    japaneseName: '川越まつり',
    months: {10},
    dateWindow: 'Usually the third weekend of October',
    place: 'Kawagoe, Saitama',
    description:
        'Tall decorated floats meet in the streets of the historic warehouse district for musical exchanges.',
    vocabulary: [
      '蔵造り · くらづくり · warehouse architecture',
      '山車 · だし · float',
      '囃子 · はやし · festival music',
    ],
    reward: 'Little Edo stamp',
  ),
  FestivalEvent(
    id: 'jidai',
    emoji: '📜',
    englishName: 'Jidai Matsuri',
    japaneseName: '時代祭',
    months: {10},
    dateWindow: '22 October',
    place: 'Kyoto',
    description:
        'A historical procession presents clothing and figures associated with different periods of Kyoto’s past.',
    vocabulary: [
      '時代 · じだい · historical period',
      '衣装 · いしょう · costume',
      '歴史 · れきし · history',
    ],
    reward: 'Festival of Ages postcard',
  ),
  FestivalEvent(
    id: 'shichigosan',
    emoji: '🍬',
    englishName: 'Shichi-Go-San',
    japaneseName: '七五三',
    months: {11},
    dateWindow: 'Around 15 November',
    place: 'Across Japan',
    description:
        'Families mark children’s growth with shrine visits and photographs. Practices differ between households.',
    vocabulary: [
      '七五三 · しちごさん',
      '成長 · せいちょう · growth',
      '千歳飴 · ちとせあめ · long-life sweet',
    ],
    reward: 'Chitose-ame stamp',
  ),
  FestivalEvent(
    id: 'omisoka',
    emoji: '🔔',
    englishName: 'New Year’s Eve',
    japaneseName: '大晦日',
    months: {12},
    dateWindow: '31 December',
    place: 'Across Japan',
    description:
        'Year-end customs include cleaning, toshikoshi soba and temple bells, though observance varies.',
    vocabulary: [
      '大晦日 · おおみそか',
      '年越しそば · としこしそば',
      '除夜の鐘 · じょやのかね · year-end bells',
    ],
    reward: 'Temple bell animation',
  ),
];

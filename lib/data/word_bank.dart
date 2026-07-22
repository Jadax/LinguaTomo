import '../models/app_models.dart';

const wordBank = <Word>[
  // ── Starter tier (40 words) ─────────────────────────────────────────────
  // Greetings & Phrases
  Word(id: 's_01', japanese: 'こんにちは', romaji: 'konnichiwa', english: 'Hello', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '👋'),
  Word(id: 's_02', japanese: 'ありがとう', romaji: 'arigatou', english: 'Thank you', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '🙏'),
  Word(id: 's_03', japanese: 'さようなら', romaji: 'sayounara', english: 'Goodbye', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '👋'),
  Word(id: 's_04', japanese: 'はい', romaji: 'hai', english: 'Yes', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '✅'),
  Word(id: 's_05', japanese: 'すみません', romaji: 'sumimasen', english: 'Excuse me', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '🙇'),
  // Home & Daily Life
  Word(id: 's_06', japanese: '家', romaji: 'ie', english: 'House', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '🏠'),
  Word(id: 's_07', japanese: '机', romaji: 'tsukue', english: 'Table', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '🪑'),
  Word(id: 's_08', japanese: '椅子', romaji: 'isu', english: 'Chair', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '💺'),
  Word(id: 's_09', japanese: '時計', romaji: 'tokei', english: 'Clock', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '⏰'),
  Word(id: 's_10', japanese: 'ベッド', romaji: 'beddo', english: 'Bed', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '🛏️'),
  // People & Family
  Word(id: 's_11', japanese: '母', romaji: 'haha', english: 'Mother', category: WordCategory.people, tier: DifficultyTier.starter, emoji: '👩'),
  Word(id: 's_12', japanese: '父', romaji: 'chichi', english: 'Father', category: WordCategory.people, tier: DifficultyTier.starter, emoji: '👨'),
  Word(id: 's_13', japanese: '子', romaji: 'ko', english: 'Child', category: WordCategory.people, tier: DifficultyTier.starter, emoji: '👶'),
  Word(id: 's_14', japanese: '友達', romaji: 'tomodachi', english: 'Friend', category: WordCategory.people, tier: DifficultyTier.starter, emoji: '🤝'),
  Word(id: 's_15', japanese: '先生', romaji: 'sensei', english: 'Teacher', category: WordCategory.people, tier: DifficultyTier.starter, emoji: '🧑‍🏫'),
  // Food & Drink
  Word(id: 's_16', japanese: 'ご飯', romaji: 'gohan', english: 'Rice', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '🍚'),
  Word(id: 's_17', japanese: '水', romaji: 'mizu', english: 'Water', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '💧'),
  Word(id: 's_18', japanese: '魚', romaji: 'sakana', english: 'Fish', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '🐟'),
  Word(id: 's_19', japanese: '肉', romaji: 'niku', english: 'Meat', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '🥩'),
  Word(id: 's_20', japanese: 'パン', romaji: 'pan', english: 'Bread', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '🍞'),
  // Activities & Sports
  Word(id: 's_21', japanese: '歩く', romaji: 'aruku', english: 'Walk', category: WordCategory.activities, tier: DifficultyTier.starter, emoji: '🚶'),
  Word(id: 's_22', japanese: '食べる', romaji: 'taberu', english: 'Eat', category: WordCategory.activities, tier: DifficultyTier.starter, emoji: '🍽️'),
  Word(id: 's_23', japanese: '飲む', romaji: 'nomu', english: 'Drink', category: WordCategory.activities, tier: DifficultyTier.starter, emoji: '🥤'),
  Word(id: 's_24', japanese: '走る', romaji: 'hashiru', english: 'Run', category: WordCategory.activities, tier: DifficultyTier.starter, emoji: '🏃'),
  Word(id: 's_25', japanese: '見る', romaji: 'miru', english: 'See', category: WordCategory.activities, tier: DifficultyTier.starter, emoji: '👁️'),
  // Places & Travel
  Word(id: 's_26', japanese: '学校', romaji: 'gakkou', english: 'School', category: WordCategory.places, tier: DifficultyTier.starter, emoji: '🏫'),
  Word(id: 's_27', japanese: '店', romaji: 'mise', english: 'Shop', category: WordCategory.places, tier: DifficultyTier.starter, emoji: '🏪'),
  Word(id: 's_28', japanese: '駅', romaji: 'eki', english: 'Station', category: WordCategory.places, tier: DifficultyTier.starter, emoji: '🚉'),
  Word(id: 's_29', japanese: '道', romaji: 'michi', english: 'Road', category: WordCategory.places, tier: DifficultyTier.starter, emoji: '🛤️'),
  Word(id: 's_30', japanese: '病院', romaji: 'byouin', english: 'Hospital', category: WordCategory.places, tier: DifficultyTier.starter, emoji: '🏥'),
  // Nature & World
  Word(id: 's_31', japanese: '山', romaji: 'yama', english: 'Mountain', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '⛰️'),
  Word(id: 's_32', japanese: '川', romaji: 'kawa', english: 'River', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '🏞️'),
  Word(id: 's_33', japanese: '花', romaji: 'hana', english: 'Flower', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '🌸'),
  Word(id: 's_34', japanese: '木', romaji: 'ki', english: 'Tree', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '🌳'),
  Word(id: 's_35', japanese: '空', romaji: 'sora', english: 'Sky', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '🌤️'),
  // Animals & Pets
  Word(id: 's_36', japanese: '猫', romaji: 'neko', english: 'Cat', category: WordCategory.animals, tier: DifficultyTier.starter, emoji: '🐱'),
  Word(id: 's_37', japanese: '犬', romaji: 'inu', english: 'Dog', category: WordCategory.animals, tier: DifficultyTier.starter, emoji: '🐶'),
  Word(id: 's_38', japanese: '鳥', romaji: 'tori', english: 'Bird', category: WordCategory.animals, tier: DifficultyTier.starter, emoji: '🐦'),
  Word(id: 's_39', japanese: '兎', romaji: 'usagi', english: 'Rabbit', category: WordCategory.animals, tier: DifficultyTier.starter, emoji: '🐰'),
  Word(id: 's_40', japanese: '魚', romaji: 'uo', english: 'Fish (animal)', category: WordCategory.animals, tier: DifficultyTier.starter, emoji: '🐠'),

  // ── Elementary tier (40 words) ──────────────────────────────────────────
  // Greetings & Phrases
  Word(id: 'e_01', japanese: 'お願いします', romaji: 'onegaishimasu', english: 'Please', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '🙏'),
  Word(id: 'e_02', japanese: 'おはよう', romaji: 'ohayou', english: 'Good morning', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '🌅'),
  Word(id: 'e_03', japanese: 'いいえ', romaji: 'iie', english: 'No', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '❌'),
  Word(id: 'e_04', japanese: 'はじめまして', romaji: 'hajimemashite', english: 'Nice to meet you', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '🤝'),
  Word(id: 'e_05', japanese: 'おやすみ', romaji: 'oyasumi', english: 'Good night', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '🌙'),
  // Home & Daily Life
  Word(id: 'e_06', japanese: 'ドア', romaji: 'doa', english: 'Door', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🚪'),
  Word(id: 'e_07', japanese: '窓', romaji: 'mado', english: 'Window', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🪟'),
  Word(id: 'e_08', japanese: '台所', romaji: 'daidokoro', english: 'Kitchen', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🍳'),
  Word(id: 'e_09', japanese: '部屋', romaji: 'heya', english: 'Room', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🚪'),
  Word(id: 'e_10', japanese: '庭', romaji: 'niwa', english: 'Garden', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🌿'),
  // People & Family
  Word(id: 'e_11', japanese: '兄', romaji: 'ani', english: 'Older brother', category: WordCategory.people, tier: DifficultyTier.elementary, emoji: '👦'),
  Word(id: 'e_12', japanese: '姉', romaji: 'ane', english: 'Older sister', category: WordCategory.people, tier: DifficultyTier.elementary, emoji: '👧'),
  Word(id: 'e_13', japanese: 'おばあさん', romaji: 'obaasan', english: 'Grandmother', category: WordCategory.people, tier: DifficultyTier.elementary, emoji: '👵'),
  Word(id: 'e_14', japanese: 'おじいさん', romaji: 'ojiisan', english: 'Grandfather', category: WordCategory.people, tier: DifficultyTier.elementary, emoji: '👴'),
  Word(id: 'e_15', japanese: '赤ちゃん', romaji: 'akachan', english: 'Baby', category: WordCategory.people, tier: DifficultyTier.elementary, emoji: '👶'),
  // Food & Drink
  Word(id: 'e_16', japanese: 'お茶', romaji: 'ocha', english: 'Tea', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🍵'),
  Word(id: 'e_17', japanese: '卵', romaji: 'tamago', english: 'Egg', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🥚'),
  Word(id: 'e_18', japanese: '果物', romaji: 'kudamono', english: 'Fruit', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🍎'),
  Word(id: 'e_19', japanese: '野菜', romaji: 'yasai', english: 'Vegetable', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🥬'),
  Word(id: 'e_20', japanese: 'ケーキ', romaji: 'keeki', english: 'Cake', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🍰'),
  // Activities & Sports
  Word(id: 'e_21', japanese: '泳ぐ', romaji: 'oyogu', english: 'Swim', category: WordCategory.activities, tier: DifficultyTier.elementary, emoji: '🏊'),
  Word(id: 'e_22', japanese: '読む', romaji: 'yomu', english: 'Read', category: WordCategory.activities, tier: DifficultyTier.elementary, emoji: '📖'),
  Word(id: 'e_23', japanese: '聴く', romaji: 'kiku', english: 'Listen', category: WordCategory.activities, tier: DifficultyTier.elementary, emoji: '🎧'),
  Word(id: 'e_24', japanese: '書く', romaji: 'kaku', english: 'Write', category: WordCategory.activities, tier: DifficultyTier.elementary, emoji: '✍️'),
  Word(id: 'e_25', japanese: '歌う', romaji: 'utau', english: 'Sing', category: WordCategory.activities, tier: DifficultyTier.elementary, emoji: '🎤'),
  // Places & Travel
  Word(id: 'e_26', japanese: '電車', romaji: 'densha', english: 'Train', category: WordCategory.places, tier: DifficultyTier.elementary, emoji: '🚃'),
  Word(id: 'e_27', japanese: '車', romaji: 'kuruma', english: 'Car', category: WordCategory.places, tier: DifficultyTier.elementary, emoji: '🚗'),
  Word(id: 'e_28', japanese: '図書館', romaji: 'toshokan', english: 'Library', category: WordCategory.places, tier: DifficultyTier.elementary, emoji: '📚'),
  Word(id: 'e_29', japanese: '空港', romaji: 'kuukou', english: 'Airport', category: WordCategory.places, tier: DifficultyTier.elementary, emoji: '✈️'),
  Word(id: 'e_30', japanese: '公園', romaji: 'kouen', english: 'Park', category: WordCategory.places, tier: DifficultyTier.elementary, emoji: '🌳'),
  // Nature & World
  Word(id: 'e_31', japanese: '雨', romaji: 'ame', english: 'Rain', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '🌧️'),
  Word(id: 'e_32', japanese: '雪', romaji: 'yuki', english: 'Snow', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '❄️'),
  Word(id: 'e_33', japanese: '風', romaji: 'kaze', english: 'Wind', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '🌬️'),
  Word(id: 'e_34', japanese: '森', romaji: 'mori', english: 'Forest', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '🌲'),
  Word(id: 'e_35', japanese: '海', romaji: 'umi', english: 'Sea', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '🌊'),
  // Animals & Pets
  Word(id: 'e_36', japanese: '牛', romaji: 'ushi', english: 'Cow', category: WordCategory.animals, tier: DifficultyTier.elementary, emoji: '🐄'),
  Word(id: 'e_37', japanese: '馬', romaji: 'uma', english: 'Horse', category: WordCategory.animals, tier: DifficultyTier.elementary, emoji: '🐴'),
  Word(id: 'e_38', japanese: '鶏', romaji: 'niwatori', english: 'Chicken', category: WordCategory.animals, tier: DifficultyTier.elementary, emoji: '🐔'),
  Word(id: 'e_39', japanese: '猿', romaji: 'saru', english: 'Monkey', category: WordCategory.animals, tier: DifficultyTier.elementary, emoji: '🐒'),
  Word(id: 'e_40', japanese: '羊', romaji: 'hitsuji', english: 'Sheep', category: WordCategory.animals, tier: DifficultyTier.elementary, emoji: '🐑'),

  // ── Intermediate tier (40 words) ───────────────────────────────────────
  // Greetings & Phrases
  Word(id: 'i_01', japanese: 'いただきます', romaji: 'itadakimasu', english: 'Bon appetit', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '🍽️'),
  Word(id: 'i_02', japanese: 'ごちそうさま', romaji: 'gochisousama', english: 'Thanks for the meal', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '🙏'),
  Word(id: 'i_03', japanese: 'お元気ですか', romaji: 'ogenki desu ka', english: 'How are you?', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '😊'),
  Word(id: 'i_04', japanese: '大丈夫', romaji: 'daijoubu', english: 'I am fine', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '👍'),
  Word(id: 'i_05', japanese: '頑張って', romaji: 'ganbatte', english: 'Good luck', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '💪'),
  // Home & Daily Life
  Word(id: 'i_06', japanese: '玄関', romaji: 'genkan', english: 'Entrance', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🚪'),
  Word(id: 'i_07', japanese: '階段', romaji: 'kaidan', english: 'Stairs', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🪜'),
  Word(id: 'i_08', japanese: 'バスルーム', romaji: 'basuruumu', english: 'Bathroom', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🛁'),
  Word(id: 'i_09', japanese: '洗濯', romaji: 'sentaku', english: 'Laundry', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '👕'),
  Word(id: 'i_10', japanese: '掃除', romaji: 'souji', english: 'Cleaning', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🧹'),
  // People & Family
  Word(id: 'i_11', japanese: '夫', romaji: 'otto', english: 'Husband', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '👨'),
  Word(id: 'i_12', japanese: '妻', romaji: 'tsuma', english: 'Wife', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '👩'),
  Word(id: 'i_13', japanese: '同僚', romaji: 'douryou', english: 'Colleague', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '👔'),
  Word(id: 'i_14', japanese: '隣の人', romaji: 'tonari no hito', english: 'Neighbour', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '🏡'),
  Word(id: 'i_15', japanese: '赤ちゃん', romaji: 'neobii', english: 'Newborn', category: WordCategory.people, tier: DifficultyTier.intermediate, emoji: '🍼'),
  // Food & Drink
  Word(id: 'i_16', japanese: 'サラダ', romaji: 'sarada', english: 'Salad', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🥗'),
  Word(id: 'i_17', japanese: '天ぷら', romaji: 'tempura', english: 'Tempura', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🍤'),
  Word(id: 'i_18', japanese: 'お酒', romaji: 'osake', english: 'Alcohol', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🍶'),
  Word(id: 'i_19', japanese: 'コーヒー', romaji: 'koohii', english: 'Coffee', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '☕'),
  Word(id: 'i_20', japanese: '弁当', romaji: 'bentou', english: 'Lunchbox', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🍱'),
  // Activities & Sports
  Word(id: 'i_21', japanese: '滑雪', romaji: 'ski', english: 'Skiing', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '⛷️'),
  Word(id: 'i_22', japanese: '旅行', romaji: 'ryokou', english: 'Travel', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '🧳'),
  Word(id: 'i_23', japanese: '写真', romaji: 'shashin', english: 'Photography', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '📷'),
  Word(id: 'i_24', japanese: '料理', romaji: 'ryouri', english: 'Cooking', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '👨‍🍳'),
  Word(id: 'i_25', japanese: '踊り', romaji: 'odori', english: 'Dancing', category: WordCategory.activities, tier: DifficultyTier.intermediate, emoji: '💃'),
  // Places & Travel
  Word(id: 'i_26', japanese: '地下鉄', romaji: 'chikatetsu', english: 'Subway', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🚇'),
  Word(id: 'i_27', japanese: '新幹線', romaji: 'shinkansen', english: 'Bullet train', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🚄'),
  Word(id: 'i_28', japanese: '橋', romaji: 'hashi', english: 'Bridge', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🌉'),
  Word(id: 'i_29', japanese: '港', romaji: 'minato', english: 'Harbour', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '⛵'),
  Word(id: 'i_30', japanese: 'ビル', romaji: 'biru', english: 'Building', category: WordCategory.places, tier: DifficultyTier.intermediate, emoji: '🏢'),
  // Nature & World
  Word(id: 'i_31', japanese: '台風', romaji: 'taifuu', english: 'Typhoon', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '🌀'),
  Word(id: 'i_32', japanese: '地震', romaji: 'jishin', english: 'Earthquake', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '🌋'),
  Word(id: 'i_33', japanese: '紅葉', romaji: 'kouyou', english: 'Autumn leaves', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '🍁'),
  Word(id: 'i_34', japanese: '桜', romaji: 'sakura', english: 'Cherry blossom', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '🌸'),
  Word(id: 'i_35', japanese: '太陽', romaji: 'taiyou', english: 'Sun', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '☀️'),
  // Animals & Pets
  Word(id: 'i_36', japanese: '象', romaji: 'zou', english: 'Elephant', category: WordCategory.animals, tier: DifficultyTier.intermediate, emoji: '🐘'),
  Word(id: 'i_37', japanese: 'ライオン', romaji: 'raion', english: 'Lion', category: WordCategory.animals, tier: DifficultyTier.intermediate, emoji: '🦁'),
  Word(id: 'i_38', japanese: 'パンダ', romaji: 'panda', english: 'Panda', category: WordCategory.animals, tier: DifficultyTier.intermediate, emoji: '🐼'),
  Word(id: 'i_39', japanese: 'イルカ', romaji: 'iruka', english: 'Dolphin', category: WordCategory.animals, tier: DifficultyTier.intermediate, emoji: '🐬'),
  Word(id: 'i_40', japanese: '熊', romaji: 'kuma', english: 'Bear', category: WordCategory.animals, tier: DifficultyTier.intermediate, emoji: '🐻'),

  // ── Advanced tier (40 words) ───────────────────────────────────────────
  // Greetings & Phrases
  Word(id: 'a_01', japanese: 'よろしくお願いします', romaji: 'yoroshiku onegaishimasu', english: 'Nice to meet you (formal)', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '🙇'),
  Word(id: 'a_02', japanese: '申し訳ありません', romaji: 'moushiwake arimasen', english: 'I am very sorry', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '😔'),
  Word(id: 'a_03', japanese: '恐れ入ります', romaji: 'osoreirimasu', english: 'Excuse me (very formal)', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '🙏'),
  Word(id: 'a_04', japanese: '承知しました', romaji: 'shouchi shimashita', english: 'Understood', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '✅'),
  Word(id: 'a_05', japanese: 'お久しぶりです', romaji: 'ohisashiburi desu', english: 'Long time no see', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '😊'),
  // Home & Daily Life
  Word(id: 'a_06', japanese: '畳', romaji: 'tatami', english: 'Tatami mat', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🏠'),
  Word(id: 'a_07', japanese: '襖', romaji: 'fusuma', english: 'Sliding door', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🚪'),
  Word(id: 'a_08', japanese: '縁側', romaji: 'engawa', english: 'Veranda', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🏡'),
  Word(id: 'a_09', japanese: '仏壇', romaji: 'butsudan', english: 'Buddhist altar', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🙏'),
  Word(id: 'a_10', japanese: '板張り', romaji: 'itabari', english: 'Wood flooring', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🪵'),
  // People & Family
  Word(id: 'a_11', japanese: '主人', romaji: 'shujin', english: 'Husband (formal)', category: WordCategory.people, tier: DifficultyTier.advanced, emoji: '👨'),
  Word(id: 'a_12', japanese: '奥さん', romaji: 'okusan', english: 'Wife (polite)', category: WordCategory.people, tier: DifficultyTier.advanced, emoji: '👩'),
  Word(id: 'a_13', japanese: '両親', romaji: 'ryoushin', english: 'Parents', category: WordCategory.people, tier: DifficultyTier.advanced, emoji: '👨‍👩‍👧'),
  Word(id: 'a_14', japanese: '兄弟', romaji: 'kyoudai', english: 'Siblings', category: WordCategory.people, tier: DifficultyTier.advanced, emoji: '👥'),
  Word(id: 'a_15', japanese: '先輩', romaji: 'senpai', english: 'Senior colleague', category: WordCategory.people, tier: DifficultyTier.advanced, emoji: '🎖️'),
  // Food & Drink
  Word(id: 'a_16', japanese: '寿司', romaji: 'sushi', english: 'Sushi', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🍣'),
  Word(id: 'a_17', japanese: 'ラーメン', romaji: 'raamen', english: 'Ramen', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🍜'),
  Word(id: 'a_18', japanese: '焼肉', romaji: 'yakiniku', english: 'Grilled meat', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🥩'),
  Word(id: 'a_19', japanese: '抹茶', romaji: 'matcha', english: 'Matcha tea', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🍵'),
  Word(id: 'a_20', japanese: '味噌汁', romaji: 'misoshiru', english: 'Miso soup', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🥣'),
  // Activities & Sports
  Word(id: 'a_21', japanese: '相撲', romaji: 'sumou', english: 'Sumo', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🤼'),
  Word(id: 'a_22', japanese: '花見', romaji: 'hanami', english: 'Flower viewing', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🌸'),
  Word(id: 'a_23', japanese: '紅葉狩り', romaji: 'momijigari', english: 'Autumn leaf walk', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🍁'),
  Word(id: 'a_24', japanese: 'お花見', romaji: 'ohanami', english: 'Picnic under blossoms', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '🧺'),
  Word(id: 'a_25', japanese: '書道', romaji: 'shodou', english: 'Calligraphy', category: WordCategory.activities, tier: DifficultyTier.advanced, emoji: '✍️'),
  // Places & Travel
  Word(id: 'a_26', japanese: '踏切', romaji: 'fumikiri', english: 'Level crossing', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🚂'),
  Word(id: 'a_27', japanese: '駐車場', romaji: 'chuuashajou', english: 'Car park', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🅿️'),
  Word(id: 'a_28', japanese: '交差点', romaji: 'kousaten', english: 'Intersection', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🚦'),
  Word(id: 'a_29', japanese: '役所', romaji: 'yakusho', english: 'Town hall', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🏛️'),
  Word(id: 'a_30', japanese: '信号', romaji: 'shingou', english: 'Traffic light', category: WordCategory.places, tier: DifficultyTier.advanced, emoji: '🚦'),
  // Nature & World
  Word(id: 'a_31', japanese: '火山', romaji: 'kazan', english: 'Volcano', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '🌋'),
  Word(id: 'a_32', japanese: '高原', romaji: 'kougen', english: 'Plateau', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '🏔️'),
  Word(id: 'a_33', japanese: '渓谷', romaji: 'keikoku', english: 'Valley', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '🏞️'),
  Word(id: 'a_34', japanese: '砂漠', romaji: 'sabaku', english: 'Desert', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '🏜️'),
  Word(id: 'a_35', japanese: '星座', romaji: 'seiza', english: 'Constellation', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '✨'),
  // Animals & Pets
  Word(id: 'a_36', japanese: '虎', romaji: 'tora', english: 'Tiger', category: WordCategory.animals, tier: DifficultyTier.advanced, emoji: '🐅'),
  Word(id: 'a_37', japanese: 'ペンギン', romaji: 'pengin', english: 'Penguin', category: WordCategory.animals, tier: DifficultyTier.advanced, emoji: '🐧'),
  Word(id: 'a_38', japanese: 'キツネ', romaji: 'kitsune', english: 'Fox', category: WordCategory.animals, tier: DifficultyTier.advanced, emoji: '🦊'),
  Word(id: 'a_39', japanese: 'カメ', romaji: 'kame', english: 'Turtle', category: WordCategory.animals, tier: DifficultyTier.advanced, emoji: '🐢'),
  Word(id: 'a_40', japanese: 'カエル', romaji: 'kaeru', english: 'Frog', category: WordCategory.animals, tier: DifficultyTier.advanced, emoji: '🐸'),

  // ── Expert tier (40 words) ─────────────────────────────────────────────
  // Greetings & Phrases
  Word(id: 'x_01', japanese: '拝啓', romaji: 'haikei', english: 'Dear (letter)', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '✉️'),
  Word(id: 'x_02', japanese: '敬具', romaji: 'keigu', english: 'Sincerely (letter)', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '✉️'),
  Word(id: 'x_03', japanese: 'ご挨拶', romaji: 'goaisatsu', english: 'Greetings (formal)', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '📢'),
  Word(id: 'x_04', japanese: 'お忙しいところ', romaji: 'oisogashii tokoro', english: 'I know you are busy', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '🙏'),
  Word(id: 'x_05', japanese: '何卒', romaji: 'nanitozo', english: 'Please (very formal)', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '📜'),
  // Home & Daily Life
  Word(id: 'x_06', japanese: '神社', romaji: 'jinja', english: 'Shrine', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '⛩️'),
  Word(id: 'x_07', japanese: '寺', romaji: 'tera', english: 'Temple', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '🛕'),
  Word(id: 'x_08', japanese: '博物館', romaji: 'hakubutsukan', english: 'Museum', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '🏛️'),
  Word(id: 'x_09', japanese: '城', romaji: 'shiro', english: 'Castle', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '🏯'),
  Word(id: 'x_10', japanese: '茶室', romaji: 'chashitsu', english: 'Tea room', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '🍵'),
  // People & Family
  Word(id: 'x_11', japanese: '親族', romaji: 'shinzoku', english: 'Relatives', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '👨‍👩‍👧'),
  Word(id: 'x_12', japanese: '家族', romaji: 'kazoku', english: 'Family', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '👨‍👩‍👧'),
  Word(id: 'x_13', japanese: '親', romaji: 'oya', english: 'Parent', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '👩'),
  Word(id: 'x_14', japanese: '子供', romaji: 'kodomo', english: 'Children', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '👶'),
  Word(id: 'x_15', japanese: '後輩', romaji: 'kouhai', english: 'Junior colleague', category: WordCategory.people, tier: DifficultyTier.expert, emoji: '🌟'),
  // Food & Drink
  Word(id: 'x_16', japanese: '懷石料理', romaji: 'kaiseki ryouri', english: 'Kaiseki cuisine', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🍱'),
  Word(id: 'x_17', japanese: 'お茶', romaji: 'sadou', english: 'Tea ceremony', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🍵'),
  Word(id: 'x_18', japanese: '刺身', romaji: 'sashimi', english: 'Sashimi', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🍣'),
  Word(id: 'x_19', japanese: '団子', romaji: 'dango', english: 'Dumplings', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🍡'),
  Word(id: 'x_20', japanese: '和菓子', romaji: 'wagashi', english: 'Japanese sweets', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🍬'),
  // Activities & Sports
  Word(id: 'x_21', japanese: '柔道', romaji: 'juudou', english: 'Judo', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🥋'),
  Word(id: 'x_22', japanese: '空手', romaji: 'karate', english: 'Karate', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🥋'),
  Word(id: 'x_23', japanese: '弓道', romaji: 'kyuudou', english: 'Archery', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🏹'),
  Word(id: 'x_24', japanese: '盆踊り', romaji: 'bon odori', english: 'Bon dance', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '💃'),
  Word(id: 'x_25', japanese: '茶道', romaji: 'sadou', english: 'Way of tea', category: WordCategory.activities, tier: DifficultyTier.expert, emoji: '🍵'),
  // Places & Travel
  Word(id: 'x_26', japanese: 'トンネル', romaji: 'tonneru', english: 'Tunnel', category: WordCategory.places, tier: DifficultyTier.expert, emoji: '🚇'),
  Word(id: 'x_27', japanese: '道路', romaji: 'douro', english: 'Highway', category: WordCategory.places, tier: DifficultyTier.expert, emoji: '🛣️'),
  Word(id: 'x_28', japanese: '田舎', romaji: 'inaka', english: 'Countryside', category: WordCategory.places, tier: DifficultyTier.expert, emoji: '🌾'),
  Word(id: 'x_29', japanese: '都会', romaji: 'tokai', english: 'City', category: WordCategory.places, tier: DifficultyTier.expert, emoji: '🏙️'),
  Word(id: 'x_30', japanese: '島', romaji: 'shima', english: 'Island', category: WordCategory.places, tier: DifficultyTier.expert, emoji: '🏝️'),
  // Nature & World
  Word(id: 'x_31', japanese: '季節', romaji: 'kisetsu', english: 'Season', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🗓️'),
  Word(id: 'x_32', japanese: '環境', romaji: 'kankyou', english: 'Environment', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🌍'),
  Word(id: 'x_33', japanese: '景色', romaji: 'keshiki', english: 'Scenery', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🏞️'),
  Word(id: 'x_34', japanese: '星', romaji: 'hoshi', english: 'Star', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '⭐'),
  Word(id: 'x_35', japanese: '朝日', romaji: 'asahi', english: 'Morning sun', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🌅'),
  // Animals & Pets
  Word(id: 'x_36', japanese: '蝶', romaji: 'chou', english: 'Butterfly', category: WordCategory.animals, tier: DifficultyTier.expert, emoji: '🦋'),
  Word(id: 'x_37', japanese: '鷹', romaji: 'taka', english: 'Hawk', category: WordCategory.animals, tier: DifficultyTier.expert, emoji: '🦅'),
  Word(id: 'x_38', japanese: '金魚', romaji: 'kingyo', english: 'Goldfish', category: WordCategory.animals, tier: DifficultyTier.expert, emoji: '🐠'),
  Word(id: 'x_39', japanese: '鹿', romaji: 'shika', english: 'Deer', category: WordCategory.animals, tier: DifficultyTier.expert, emoji: '🦌'),
  Word(id: 'x_40', japanese: '鯨', romaji: 'kujira', english: 'Whale', category: WordCategory.animals, tier: DifficultyTier.expert, emoji: '🐋'),
];

List<Word> wordsForTier(DifficultyTier tier) =>
    wordBank.where((w) => w.tier == tier).toList();

List<Word> wordsForCategory(WordCategory category) =>
    wordBank.where((w) => w.category == category).toList();

int totalWordsForTier(DifficultyTier tier) =>
    wordBank.where((w) => w.tier == tier).length;

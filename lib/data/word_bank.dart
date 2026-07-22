import '../models/app_models.dart';

const wordBank = <Word>[
  // ── Starter tier (40 words) ─────────────────────────────────────────────
  // Greetings
  Word(id: 's_01', japanese: 'こんにちは', romaji: 'konnichiwa', english: 'Hello', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '👋'),
  Word(id: 's_02', japanese: 'ありがとう', romaji: 'arigatou', english: 'Thank you', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '🙏'),
  Word(id: 's_03', japanese: 'さようなら', romaji: 'sayounara', english: 'Goodbye', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '👋'),
  Word(id: 's_04', japanese: 'はい', romaji: 'hai', english: 'Yes', category: WordCategory.greetings, tier: DifficultyTier.starter, emoji: '✅'),
  // Numbers
  Word(id: 's_05', japanese: '一', romaji: 'ichi', english: 'One', category: WordCategory.numbers, tier: DifficultyTier.starter, emoji: '1️⃣'),
  Word(id: 's_06', japanese: '二', romaji: 'ni', english: 'Two', category: WordCategory.numbers, tier: DifficultyTier.starter, emoji: '2️⃣'),
  Word(id: 's_07', japanese: '三', romaji: 'san', english: 'Three', category: WordCategory.numbers, tier: DifficultyTier.starter, emoji: '3️⃣'),
  Word(id: 's_08', japanese: '四', romaji: 'yon', english: 'Four', category: WordCategory.numbers, tier: DifficultyTier.starter, emoji: '4️⃣'),
  // Food
  Word(id: 's_09', japanese: 'ご飯', romaji: 'gohan', english: 'Rice', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '🍚'),
  Word(id: 's_10', japanese: '水', romaji: 'mizu', english: 'Water', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '💧'),
  Word(id: 's_11', japanese: '魚', romaji: 'sakana', english: 'Fish', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '🐟'),
  Word(id: 's_12', japanese: '肉', romaji: 'niku', english: 'Meat', category: WordCategory.food, tier: DifficultyTier.starter, emoji: '🥩'),
  // Family
  Word(id: 's_13', japanese: '母', romaji: 'haha', english: 'Mother', category: WordCategory.family, tier: DifficultyTier.starter, emoji: '👩'),
  Word(id: 's_14', japanese: '父', romaji: 'chichi', english: 'Father', category: WordCategory.family, tier: DifficultyTier.starter, emoji: '👨'),
  Word(id: 's_15', japanese: '子', romaji: 'ko', english: 'Child', category: WordCategory.family, tier: DifficultyTier.starter, emoji: '👶'),
  Word(id: 's_16', japanese: '人', romaji: 'hito', english: 'Person', category: WordCategory.family, tier: DifficultyTier.starter, emoji: '🧑'),
  // Colours
  Word(id: 's_17', japanese: '赤', romaji: 'aka', english: 'Red', category: WordCategory.colours, tier: DifficultyTier.starter, emoji: '🔴'),
  Word(id: 's_18', japanese: '青', romaji: 'ao', english: 'Blue', category: WordCategory.colours, tier: DifficultyTier.starter, emoji: '🔵'),
  Word(id: 's_19', japanese: '白', romaji: 'shiro', english: 'White', category: WordCategory.colours, tier: DifficultyTier.starter, emoji: '⚪'),
  Word(id: 's_20', japanese: '黒', romaji: 'kuro', english: 'Black', category: WordCategory.colours, tier: DifficultyTier.starter, emoji: '⚫'),
  // Body
  Word(id: 's_21', japanese: '目', romaji: 'me', english: 'Eye', category: WordCategory.body, tier: DifficultyTier.starter, emoji: '👁️'),
  Word(id: 's_22', japanese: '手', romaji: 'te', english: 'Hand', category: WordCategory.body, tier: DifficultyTier.starter, emoji: '✋'),
  Word(id: 's_23', japanese: '口', romaji: 'kuchi', english: 'Mouth', category: WordCategory.body, tier: DifficultyTier.starter, emoji: '👄'),
  Word(id: 's_24', japanese: '足', romaji: 'ashi', english: 'Foot', category: WordCategory.body, tier: DifficultyTier.starter, emoji: '🦶'),
  // Clothing
  Word(id: 's_25', japanese: '服', romaji: 'fuku', english: 'Clothes', category: WordCategory.clothing, tier: DifficultyTier.starter, emoji: '👕'),
  Word(id: 's_26', japanese: '靴', romaji: 'kutsu', english: 'Shoes', category: WordCategory.clothing, tier: DifficultyTier.starter, emoji: '👟'),
  Word(id: 's_27', japanese: '帽', romaji: 'bou', english: 'Hat', category: WordCategory.clothing, tier: DifficultyTier.starter, emoji: '🧢'),
  Word(id: 's_28', japanese: '靴下', romaji: 'kutsushita', english: 'Socks', category: WordCategory.clothing, tier: DifficultyTier.starter, emoji: '🧦'),
  // Home
  Word(id: 's_29', japanese: '家', romaji: 'ie', english: 'House', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '🏠'),
  Word(id: 's_30', japanese: '部屋', romaji: 'heya', english: 'Room', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '🚪'),
  Word(id: 's_31', japanese: 'ドア', romaji: 'doa', english: 'Door', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '🚪'),
  Word(id: 's_32', japanese: '机', romaji: 'tsukue', english: 'Desk', category: WordCategory.home, tier: DifficultyTier.starter, emoji: '🪑'),
  // Nature
  Word(id: 's_33', japanese: '山', romaji: 'yama', english: 'Mountain', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '⛰️'),
  Word(id: 's_34', japanese: '川', romaji: 'kawa', english: 'River', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '🏞️'),
  Word(id: 's_35', japanese: '花', romaji: 'hana', english: 'Flower', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '🌸'),
  Word(id: 's_36', japanese: '木', romaji: 'ki', english: 'Tree', category: WordCategory.nature, tier: DifficultyTier.starter, emoji: '🌳'),
  // Transport
  Word(id: 's_37', japanese: '電車', romaji: 'densha', english: 'Train', category: WordCategory.transport, tier: DifficultyTier.starter, emoji: '🚃'),
  Word(id: 's_38', japanese: 'バス', romaji: 'basu', english: 'Bus', category: WordCategory.transport, tier: DifficultyTier.starter, emoji: '🚌'),
  Word(id: 's_39', japanese: '駅', romaji: 'eki', english: 'Station', category: WordCategory.transport, tier: DifficultyTier.starter, emoji: '🚉'),
  Word(id: 's_40', japanese: '道', romaji: 'michi', english: 'Road', category: WordCategory.transport, tier: DifficultyTier.starter, emoji: '🛤️'),

  // ── Elementary tier (40 words) ──────────────────────────────────────────
  // Greetings
  Word(id: 'e_01', japanese: 'すみません', romaji: 'sumimasen', english: 'Excuse me', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '🙇'),
  Word(id: 'e_02', japanese: 'お願いします', romaji: 'onegaishimasu', english: 'Please', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '🙏'),
  Word(id: 'e_03', japanese: 'おはよう', romaji: 'ohayou', english: 'Good morning', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '🌅'),
  Word(id: 'e_04', japanese: 'いいえ', romaji: 'iie', english: 'No', category: WordCategory.greetings, tier: DifficultyTier.elementary, emoji: '❌'),
  // Numbers
  Word(id: 'e_05', japanese: '五', romaji: 'go', english: 'Five', category: WordCategory.numbers, tier: DifficultyTier.elementary, emoji: '5️⃣'),
  Word(id: 'e_06', japanese: '六', romaji: 'roku', english: 'Six', category: WordCategory.numbers, tier: DifficultyTier.elementary, emoji: '6️⃣'),
  Word(id: 'e_07', japanese: '七', romaji: 'nana', english: 'Seven', category: WordCategory.numbers, tier: DifficultyTier.elementary, emoji: '7️⃣'),
  Word(id: 'e_08', japanese: '八', romaji: 'hachi', english: 'Eight', category: WordCategory.numbers, tier: DifficultyTier.elementary, emoji: '8️⃣'),
  // Food
  Word(id: 'e_09', japanese: '野菜', romaji: 'yasai', english: 'Vegetable', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🥬'),
  Word(id: 'e_10', japanese: '果物', romaji: 'kudamono', english: 'Fruit', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🍎'),
  Word(id: 'e_11', japanese: '卵', romaji: 'tamago', english: 'Egg', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🥚'),
  Word(id: 'e_12', japanese: 'パン', romaji: 'pan', english: 'Bread', category: WordCategory.food, tier: DifficultyTier.elementary, emoji: '🍞'),
  // Family
  Word(id: 'e_13', japanese: '兄', romaji: 'ani', english: 'Older brother', category: WordCategory.family, tier: DifficultyTier.elementary, emoji: '👦'),
  Word(id: 'e_14', japanese: '姉', romaji: 'ane', english: 'Older sister', category: WordCategory.family, tier: DifficultyTier.elementary, emoji: '👧'),
  Word(id: 'e_15', japanese: '弟', romaji: 'otouto', english: 'Younger brother', category: WordCategory.family, tier: DifficultyTier.elementary, emoji: '🧒'),
  Word(id: 'e_16', japanese: '妹', romaji: 'imouto', english: 'Younger sister', category: WordCategory.family, tier: DifficultyTier.elementary, emoji: '👧'),
  // Colours
  Word(id: 'e_17', japanese: '黄色', romaji: 'kiiro', english: 'Yellow', category: WordCategory.colours, tier: DifficultyTier.elementary, emoji: '🟡'),
  Word(id: 'e_18', japanese: '緑', romaji: 'midori', english: 'Green', category: WordCategory.colours, tier: DifficultyTier.elementary, emoji: '🟢'),
  Word(id: 'e_19', japanese: '茶色', romaji: 'chairo', english: 'Brown', category: WordCategory.colours, tier: DifficultyTier.elementary, emoji: '🟤'),
  Word(id: 'e_20', japanese: '橙', romaji: 'daidai', english: 'Orange', category: WordCategory.colours, tier: DifficultyTier.elementary, emoji: '🟠'),
  // Body
  Word(id: 'e_21', japanese: '頭', romaji: 'atama', english: 'Head', category: WordCategory.body, tier: DifficultyTier.elementary, emoji: '🧠'),
  Word(id: 'e_22', japanese: '鼻', romaji: 'hana', english: 'Nose', category: WordCategory.body, tier: DifficultyTier.elementary, emoji: '👃'),
  Word(id: 'e_23', japanese: '耳', romaji: 'mimi', english: 'Ear', category: WordCategory.body, tier: DifficultyTier.elementary, emoji: '👂'),
  Word(id: 'e_24', japanese: '歯', romaji: 'ha', english: 'Tooth', category: WordCategory.body, tier: DifficultyTier.elementary, emoji: '🦷'),
  // Clothing
  Word(id: 'e_25', japanese: 'ズボン', romaji: 'zubon', english: 'Trousers', category: WordCategory.clothing, tier: DifficultyTier.elementary, emoji: '👖'),
  Word(id: 'e_26', japanese: '靴', romaji: 'kutsu', english: 'Boots', category: WordCategory.clothing, tier: DifficultyTier.elementary, emoji: '🥾'),
  Word(id: 'e_27', japanese: 'ネクタイ', romaji: 'nekutai', english: 'Tie', category: WordCategory.clothing, tier: DifficultyTier.elementary, emoji: '👔'),
  Word(id: 'e_28', japanese: 'スカート', romaji: 'sukaato', english: 'Skirt', category: WordCategory.clothing, tier: DifficultyTier.elementary, emoji: '👗'),
  // Home
  Word(id: 'e_29', japanese: '椅子', romaji: 'isu', english: 'Chair', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🪑'),
  Word(id: 'e_30', japanese: '窓', romaji: 'mado', english: 'Window', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🪟'),
  Word(id: 'e_31', japanese: 'ベッド', romaji: 'beddo', english: 'Bed', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🛏️'),
  Word(id: 'e_32', japanese: '台所', romaji: 'daidokoro', english: 'Kitchen', category: WordCategory.home, tier: DifficultyTier.elementary, emoji: '🍳'),
  // Nature
  Word(id: 'e_33', japanese: '空', romaji: 'sora', english: 'Sky', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '🌤️'),
  Word(id: 'e_34', japanese: '海', romaji: 'umi', english: 'Sea', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '🌊'),
  Word(id: 'e_35', japanese: '島', romaji: 'shima', english: 'Island', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '🏝️'),
  Word(id: 'e_36', japanese: '森', romaji: 'mori', english: 'Forest', category: WordCategory.nature, tier: DifficultyTier.elementary, emoji: '🌲'),
  // Transport
  Word(id: 'e_37', japanese: '車', romaji: 'kuruma', english: 'Car', category: WordCategory.transport, tier: DifficultyTier.elementary, emoji: '🚗'),
  Word(id: 'e_38', japanese: '自転車', romaji: 'jitensha', english: 'Bicycle', category: WordCategory.transport, tier: DifficultyTier.elementary, emoji: '🚲'),
  Word(id: 'e_39', japanese: '飛行機', romaji: 'hikouki', english: 'Airplane', category: WordCategory.transport, tier: DifficultyTier.elementary, emoji: '✈️'),
  Word(id: 'e_40', japanese: 'タクシー', romaji: 'takushii', english: 'Taxi', category: WordCategory.transport, tier: DifficultyTier.elementary, emoji: '🚕'),

  // ── Intermediate tier (40 words) ───────────────────────────────────────
  // Greetings
  Word(id: 'i_01', japanese: 'いただきます', romaji: 'itadakimasu', english: 'Bon appetit', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '🍽️'),
  Word(id: 'i_02', japanese: 'ごちそうさま', romaji: 'gochisousama', english: 'Thank you for the meal', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '🙏'),
  Word(id: 'i_03', japanese: 'お元気ですか', romaji: 'ogenki desu ka', english: 'How are you?', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '😊'),
  Word(id: 'i_04', japanese: 'はじめまして', romaji: 'hajimemashite', english: 'Nice to meet you', category: WordCategory.greetings, tier: DifficultyTier.intermediate, emoji: '🤝'),
  // Numbers
  Word(id: 'i_05', japanese: '百', romaji: 'hyaku', english: 'Hundred', category: WordCategory.numbers, tier: DifficultyTier.intermediate, emoji: '💯'),
  Word(id: 'i_06', japanese: '千', romaji: 'sen', english: 'Thousand', category: WordCategory.numbers, tier: DifficultyTier.intermediate, emoji: '🔢'),
  Word(id: 'i_07', japanese: '半', romaji: 'han', english: 'Half', category: WordCategory.numbers, tier: DifficultyTier.intermediate, emoji: '🔢'),
  Word(id: 'i_08', japanese: '全部', romaji: 'zenbu', english: 'All', category: WordCategory.numbers, tier: DifficultyTier.intermediate, emoji: '🔢'),
  // Food
  Word(id: 'i_09', japanese: 'お茶', romaji: 'ocha', english: 'Tea', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🍵'),
  Word(id: 'i_10', japanese: 'ケーキ', romaji: 'keeki', english: 'Cake', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🍰'),
  Word(id: 'i_11', japanese: 'サラダ', romaji: 'sarada', english: 'Salad', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🥗'),
  Word(id: 'i_12', japanese: '天ぷら', romaji: 'tempura', english: 'Tempura', category: WordCategory.food, tier: DifficultyTier.intermediate, emoji: '🍤'),
  // Family
  Word(id: 'i_13', japanese: 'おばあさん', romaji: 'obaasan', english: 'Grandmother', category: WordCategory.family, tier: DifficultyTier.intermediate, emoji: '👵'),
  Word(id: 'i_14', japanese: 'おじいさん', romaji: 'ojiisan', english: 'Grandfather', category: WordCategory.family, tier: DifficultyTier.intermediate, emoji: '👴'),
  Word(id: 'i_15', japanese: '夫', romaji: 'otto', english: 'Husband', category: WordCategory.family, tier: DifficultyTier.intermediate, emoji: '👨'),
  Word(id: 'i_16', japanese: '妻', romaji: 'tsuma', english: 'Wife', category: WordCategory.family, tier: DifficultyTier.intermediate, emoji: '👩'),
  // Colours
  Word(id: 'i_17', japanese: '紫色', romaji: 'murasakiiro', english: 'Purple', category: WordCategory.colours, tier: DifficultyTier.intermediate, emoji: '🟣'),
  Word(id: 'i_18', japanese: 'ピンク', romaji: 'pinku', english: 'Pink', category: WordCategory.colours, tier: DifficultyTier.intermediate, emoji: '💗'),
  Word(id: 'i_19', japanese: '灰色', romaji: 'haiiro', english: 'Grey', category: WordCategory.colours, tier: DifficultyTier.intermediate, emoji: '🩶'),
  Word(id: 'i_20', japanese: '金色', romaji: 'kin', english: 'Gold', category: WordCategory.colours, tier: DifficultyTier.intermediate, emoji: '✨'),
  // Body
  Word(id: 'i_21', japanese: '肩', romaji: 'kata', english: 'Shoulder', category: WordCategory.body, tier: DifficultyTier.intermediate, emoji: '💪'),
  Word(id: 'i_22', japanese: '指', romaji: 'yubi', english: 'Finger', category: WordCategory.body, tier: DifficultyTier.intermediate, emoji: '☝️'),
  Word(id: 'i_23', japanese: '腕', romaji: 'ude', english: 'Arm', category: WordCategory.body, tier: DifficultyTier.intermediate, emoji: '💪'),
  Word(id: 'i_24', japanese: '腹', romaji: 'hara', english: 'Stomach', category: WordCategory.body, tier: DifficultyTier.intermediate, emoji: '🫃'),
  // Clothing
  Word(id: 'i_25', japanese: 'コート', romaji: 'kooto', english: 'Coat', category: WordCategory.clothing, tier: DifficultyTier.intermediate, emoji: '🧥'),
  Word(id: 'i_26', japanese: 'セーター', romaji: 'seetaa', english: 'Sweater', category: WordCategory.clothing, tier: DifficultyTier.intermediate, emoji: '🧶'),
  Word(id: 'i_27', japanese: 'ワンピース', romaji: 'wanpiisu', english: 'Dress', category: WordCategory.clothing, tier: DifficultyTier.intermediate, emoji: '👗'),
  Word(id: 'i_28', japanese: 'パジャマ', romaji: 'pajama', english: 'Pyjamas', category: WordCategory.clothing, tier: DifficultyTier.intermediate, emoji: '😴'),
  // Home
  Word(id: 'i_29', japanese: '庭', romaji: 'niwa', english: 'Garden', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🌿'),
  Word(id: 'i_30', japanese: '階段', romaji: 'kaidan', english: 'Stairs', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🪜'),
  Word(id: 'i_31', japanese: 'バスルーム', romaji: 'basuruumu', english: 'Bathroom', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🛁'),
  Word(id: 'i_32', japanese: '玄関', romaji: 'genkan', english: 'Entrance', category: WordCategory.home, tier: DifficultyTier.intermediate, emoji: '🚪'),
  // Nature
  Word(id: 'i_33', japanese: '天気', romaji: 'tenki', english: 'Weather', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '🌤️'),
  Word(id: 'i_34', japanese: '雨', romaji: 'ame', english: 'Rain', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '🌧️'),
  Word(id: 'i_35', japanese: '雪', romaji: 'yuki', english: 'Snow', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '❄️'),
  Word(id: 'i_36', japanese: '風', romaji: 'kaze', english: 'Wind', category: WordCategory.nature, tier: DifficultyTier.intermediate, emoji: '🌬️'),
  // Transport
  Word(id: 'i_37', japanese: '地下鉄', romaji: 'chikatetsu', english: 'Subway', category: WordCategory.transport, tier: DifficultyTier.intermediate, emoji: '🚇'),
  Word(id: 'i_38', japanese: '新幹線', romaji: 'shinkansen', english: 'Bullet train', category: WordCategory.transport, tier: DifficultyTier.intermediate, emoji: '🚄'),
  Word(id: 'i_39', japanese: '船', romaji: 'fune', english: 'Ship', category: WordCategory.transport, tier: DifficultyTier.intermediate, emoji: '🚢'),
  Word(id: 'i_40', japanese: '信号', romaji: 'shingou', english: 'Traffic light', category: WordCategory.transport, tier: DifficultyTier.intermediate, emoji: '🚦'),

  // ── Advanced tier (40 words) ───────────────────────────────────────────
  // Greetings
  Word(id: 'a_01', japanese: 'よろしくお願いします', romaji: 'yoroshiku onegaishimasu', english: 'Nice to meet you (formal)', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '🙇'),
  Word(id: 'a_02', japanese: '申し訳ありません', romaji: 'moushiwake arimasen', english: 'I am very sorry', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '😔'),
  Word(id: 'a_03', japanese: '恐れ入ります', romaji: 'osoreirimasu', english: 'Excuse me (very formal)', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '🙏'),
  Word(id: 'a_04', japanese: '承知しました', romaji: 'shouchi shimashita', english: 'Understood (formal)', category: WordCategory.greetings, tier: DifficultyTier.advanced, emoji: '✅'),
  // Numbers
  Word(id: 'a_05', japanese: '万', romaji: 'man', english: 'Ten thousand', category: WordCategory.numbers, tier: DifficultyTier.advanced, emoji: '🔢'),
  Word(id: 'a_06', japanese: '約', romaji: 'yaku', english: 'About (approximate)', category: WordCategory.numbers, tier: DifficultyTier.advanced, emoji: '🔢'),
  Word(id: 'a_07', japanese: '以上', romaji: 'ijou', english: 'Or more', category: WordCategory.numbers, tier: DifficultyTier.advanced, emoji: '🔢'),
  Word(id: 'a_08', japanese: '以下', romaji: 'ika', english: 'Or less', category: WordCategory.numbers, tier: DifficultyTier.advanced, emoji: '🔢'),
  // Food
  Word(id: 'a_09', japanese: '寿司', romaji: 'sushi', english: 'Sushi', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🍣'),
  Word(id: 'a_10', japanese: 'ラーメン', romaji: 'raamen', english: 'Ramen', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🍜'),
  Word(id: 'a_11', japanese: '焼肉', romaji: 'yakiniku', english: 'Grilled meat', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🥩'),
  Word(id: 'a_12', japanese: '刺身', romaji: 'sashimi', english: 'Raw fish', category: WordCategory.food, tier: DifficultyTier.advanced, emoji: '🍣'),
  // Family
  Word(id: 'a_13', japanese: '主人', romaji: 'shujin', english: 'Husband (formal)', category: WordCategory.family, tier: DifficultyTier.advanced, emoji: '👨'),
  Word(id: 'a_14', japanese: '奥さん', romaji: 'okusan', english: 'Wife (polite)', category: WordCategory.family, tier: DifficultyTier.advanced, emoji: '👩'),
  Word(id: 'a_15', japanese: '両親', romaji: 'ryoushin', english: 'Parents', category: WordCategory.family, tier: DifficultyTier.advanced, emoji: '👨‍👩‍👧'),
  Word(id: 'a_16', japanese: '兄弟', romaji: 'kyoudai', english: 'Siblings', category: WordCategory.family, tier: DifficultyTier.advanced, emoji: '👥'),
  // Colours
  Word(id: 'a_17', japanese: '薄い', romaji: 'usui', english: 'Light (colour)', category: WordCategory.colours, tier: DifficultyTier.advanced, emoji: '🎨'),
  Word(id: 'a_18', japanese: '濃い', romaji: 'koi', english: 'Dark (colour)', category: WordCategory.colours, tier: DifficultyTier.advanced, emoji: '🎨'),
  Word(id: 'a_19', japanese: '鮮やか', romaji: 'adayaka', english: 'Vivid', category: WordCategory.colours, tier: DifficultyTier.advanced, emoji: '🎨'),
  Word(id: 'a_20', japanese: '暗い', romaji: 'kurai', english: 'Dim', category: WordCategory.colours, tier: DifficultyTier.advanced, emoji: '🌑'),
  // Body
  Word(id: 'a_21', japanese: '骨', romaji: 'hone', english: 'Bone', category: WordCategory.body, tier: DifficultyTier.advanced, emoji: '🦴'),
  Word(id: 'a_22', japanese: '筋肉', romaji: 'kinniku', english: 'Muscle', category: WordCategory.body, tier: DifficultyTier.advanced, emoji: '💪'),
  Word(id: 'a_23', japanese: '血', romaji: 'chi', english: 'Blood', category: WordCategory.body, tier: DifficultyTier.advanced, emoji: '🩸'),
  Word(id: 'a_24', japanese: '皮膚', romaji: 'hifu', english: 'Skin', category: WordCategory.body, tier: DifficultyTier.advanced, emoji: '🤲'),
  // Clothing
  Word(id: 'a_25', japanese: '礼服', romaji: 'reifuku', english: 'Formal wear', category: WordCategory.clothing, tier: DifficultyTier.advanced, emoji: '👔'),
  Word(id: 'a_26', japanese: '制服', romaji: 'seifuku', english: 'Uniform', category: WordCategory.clothing, tier: DifficultyTier.advanced, emoji: '🏫'),
  Word(id: 'a_27', japanese: '下着', romaji: 'shitagi', english: 'Underwear', category: WordCategory.clothing, tier: DifficultyTier.advanced, emoji: '🩲'),
  Word(id: 'a_28', japanese: '上着', romaji: 'uwagi', english: 'Jacket', category: WordCategory.clothing, tier: DifficultyTier.advanced, emoji: '🧥'),
  // Home
  Word(id: 'a_29', japanese: '畳', romaji: 'tatami', english: 'Tatami mat', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🏠'),
  Word(id: 'a_30', japanese: '襖', romaji: 'fusuma', english: 'Sliding door', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🚪'),
  Word(id: 'a_31', japanese: '縁側', romaji: 'engawa', english: 'Veranda', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🏡'),
  Word(id: 'a_32', japanese: '仏壇', romaji: 'butsudan', english: 'Buddhist altar', category: WordCategory.home, tier: DifficultyTier.advanced, emoji: '🙏'),
  // Nature
  Word(id: 'a_33', japanese: '台風', romaji: 'taifuu', english: 'Typhoon', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '🌀'),
  Word(id: 'a_34', japanese: '地震', romaji: 'jishin', english: 'Earthquake', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '🌋'),
  Word(id: 'a_35', japanese: '紅葉', romaji: 'kouyou', english: 'Autumn leaves', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '🍁'),
  Word(id: 'a_36', japanese: '桜', romaji: 'sakura', english: 'Cherry blossom', category: WordCategory.nature, tier: DifficultyTier.advanced, emoji: '🌸'),
  // Transport
  Word(id: 'a_37', japanese: '空港', romaji: 'kuukou', english: 'Airport', category: WordCategory.transport, tier: DifficultyTier.advanced, emoji: '✈️'),
  Word(id: 'a_38', japanese: '港', romaji: 'minato', english: 'Harbour', category: WordCategory.transport, tier: DifficultyTier.advanced, emoji: '⛵'),
  Word(id: 'a_39', japanese: '踏切', romaji: 'fumikiri', english: 'Level crossing', category: WordCategory.transport, tier: DifficultyTier.advanced, emoji: '🚂'),
  Word(id: 'a_40', japanese: '駐車場', romaji: 'chuuashajou', english: 'Car park', category: WordCategory.transport, tier: DifficultyTier.advanced, emoji: '🅿️'),

  // ── Expert tier (40 words) ─────────────────────────────────────────────
  // Greetings
  Word(id: 'x_01', japanese: '拝啓', romaji: 'haikei', english: 'Dear (letter)', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '✉️'),
  Word(id: 'x_02', japanese: '敬具', romaji: 'keigu', english: 'Sincerely (letter)', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '✉️'),
  Word(id: 'x_03', japanese: 'ご挨拶', romaji: 'goaisatsu', english: 'Greetings (formal)', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '📢'),
  Word(id: 'x_04', japanese: 'お忙しいところ', romaji: 'oisogashii tokoro', english: 'I know you are busy', category: WordCategory.greetings, tier: DifficultyTier.expert, emoji: '🙏'),
  // Numbers
  Word(id: 'x_05', japanese: '億', romaji: 'oku', english: 'Hundred million', category: WordCategory.numbers, tier: DifficultyTier.expert, emoji: '🔢'),
  Word(id: 'x_06', japanese: '割合', romaji: 'wariai', english: 'Ratio', category: WordCategory.numbers, tier: DifficultyTier.expert, emoji: '📊'),
  Word(id: 'x_07', japanese: '合計', romaji: 'goukei', english: 'Total', category: WordCategory.numbers, tier: DifficultyTier.expert, emoji: '🧮'),
  Word(id: 'x_08', japanese: '平均', romaji: 'heikin', english: 'Average', category: WordCategory.numbers, tier: DifficultyTier.expert, emoji: '📊'),
  // Food
  Word(id: 'x_09', japanese: '懷石料理', romaji: 'kaiseki ryouri', english: 'Kaiseki cuisine', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🍱'),
  Word(id: 'x_10', japanese: '抹茶', romaji: 'matcha', english: 'Matcha tea', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🍵'),
  Word(id: 'x_11', japanese: '味噌汁', romaji: 'misoshiru', english: 'Miso soup', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🥣'),
  Word(id: 'x_12', japanese: 'お酒', romaji: 'osake', english: 'Alcohol', category: WordCategory.food, tier: DifficultyTier.expert, emoji: '🍶'),
  // Family
  Word(id: 'x_13', japanese: '親族', romaji: 'shinzoku', english: 'Relatives', category: WordCategory.family, tier: DifficultyTier.expert, emoji: '👨‍👩‍👧'),
  Word(id: 'x_14', japanese: '家族', romaji: 'kazoku', english: 'Family', category: WordCategory.family, tier: DifficultyTier.expert, emoji: '👨‍👩‍👧'),
  Word(id: 'x_15', japanese: '親', romaji: 'oya', english: 'Parent', category: WordCategory.family, tier: DifficultyTier.expert, emoji: '👩'),
  Word(id: 'x_16', japanese: '子供', romaji: 'kodomo', english: 'Children', category: WordCategory.family, tier: DifficultyTier.expert, emoji: '👶'),
  // Colours
  Word(id: 'x_17', japanese: '真っ白', romaji: 'masshiro', english: 'Pure white', category: WordCategory.colours, tier: DifficultyTier.expert, emoji: '🤍'),
  Word(id: 'x_18', japanese: '真っ赤', romaji: 'makka', english: 'Bright red', category: WordCategory.colours, tier: DifficultyTier.expert, emoji: '❤️'),
  Word(id: 'x_19', japanese: '色', romaji: 'iro', english: 'Colour', category: WordCategory.colours, tier: DifficultyTier.expert, emoji: '🎨'),
  Word(id: 'x_20', japanese: '景色', romaji: 'keshiki', english: 'Scenery', category: WordCategory.colours, tier: DifficultyTier.expert, emoji: '🏞️'),
  // Body
  Word(id: 'x_21', japanese: '体', romaji: 'karada', english: 'Body', category: WordCategory.body, tier: DifficultyTier.expert, emoji: '🧍'),
  Word(id: 'x_22', japanese: '脳', romaji: 'nou', english: 'Brain', category: WordCategory.body, tier: DifficultyTier.expert, emoji: '🧠'),
  Word(id: 'x_23', japanese: '心臓', romaji: 'shinzou', english: 'Heart', category: WordCategory.body, tier: DifficultyTier.expert, emoji: '❤️'),
  Word(id: 'x_24', japanese: '肺', romaji: 'hai', english: 'Lungs', category: WordCategory.body, tier: DifficultyTier.expert, emoji: '🫁'),
  // Clothing
  Word(id: 'x_25', japanese: '和服', romaji: 'wafuku', english: 'Japanese clothing', category: WordCategory.clothing, tier: DifficultyTier.expert, emoji: '👘'),
  Word(id: 'x_26', japanese: '着物', romaji: 'kimono', english: 'Kimono', category: WordCategory.clothing, tier: DifficultyTier.expert, emoji: '👘'),
  Word(id: 'x_27', japanese: '帯', romaji: 'obi', english: 'Sash (kimono)', category: WordCategory.clothing, tier: DifficultyTier.expert, emoji: '🎀'),
  Word(id: 'x_28', japanese: '草履', romaji: 'zouri', english: 'Sandals (traditional)', category: WordCategory.clothing, tier: DifficultyTier.expert, emoji: '🩴'),
  // Home
  Word(id: 'x_29', japanese: '図書館', romaji: 'toshokan', english: 'Library', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '📚'),
  Word(id: 'x_30', japanese: '神社', romaji: 'jinja', english: 'Shrine', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '⛩️'),
  Word(id: 'x_31', japanese: '寺', romaji: 'tera', english: 'Temple', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '🛕'),
  Word(id: 'x_32', japanese: '博物館', romaji: 'hakubutsukan', english: 'Museum', category: WordCategory.home, tier: DifficultyTier.expert, emoji: '🏛️'),
  // Nature
  Word(id: 'x_33', japanese: '火山', romaji: 'kazan', english: 'Volcano', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🌋'),
  Word(id: 'x_34', japanese: '高原', romaji: 'kougen', english: 'Plateau', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🏔️'),
  Word(id: 'x_35', japanese: '渓谷', romaji: 'keikoku', english: 'Valley', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🏞️'),
  Word(id: 'x_36', japanese: '砂漠', romaji: 'sabaku', english: 'Desert', category: WordCategory.nature, tier: DifficultyTier.expert, emoji: '🏜️'),
  // Transport
  Word(id: 'x_37', japanese: '乗り物', romaji: 'norimono', english: 'Vehicle', category: WordCategory.transport, tier: DifficultyTier.expert, emoji: '🚗'),
  Word(id: 'x_38', japanese: '道路', romaji: 'douro', english: 'Highway', category: WordCategory.transport, tier: DifficultyTier.expert, emoji: '🛣️'),
  Word(id: 'x_39', japanese: '橋', romaji: 'hashi', english: 'Bridge', category: WordCategory.transport, tier: DifficultyTier.expert, emoji: '🌉'),
  Word(id: 'x_40', japanese: 'トンネル', romaji: 'tonneru', english: 'Tunnel', category: WordCategory.transport, tier: DifficultyTier.expert, emoji: '🚇'),
];

List<Word> wordsForTier(DifficultyTier tier) =>
    wordBank.where((w) => w.tier == tier).toList();

List<Word> wordsForCategory(WordCategory category) =>
    wordBank.where((w) => w.category == category).toList();

int totalWordsForTier(DifficultyTier tier) =>
    wordBank.where((w) => w.tier == tier).length;

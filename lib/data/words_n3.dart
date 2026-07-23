import '../models/app_models.dart';

final _n3Raw = [
  // ── Abstract Nouns ────────────────────────────────────────────────────
  ('n3_001', '経験', 'keiken', 'Experience', WordCategory.activities, DifficultyTier.advanced, '🧠'),
  ('n3_002', '知識', 'chishiki', 'Knowledge', WordCategory.activities, DifficultyTier.advanced, '📖'),
  ('n3_003', '能力', 'nouryoku', 'Ability / Capability', WordCategory.activities, DifficultyTier.advanced, '💪'),
  ('n3_004', '努力', 'doryoku', 'Effort / Hard work', WordCategory.activities, DifficultyTier.advanced, '🏋️'),
  ('n3_005', '結果', 'kekka', 'Result / Outcome', WordCategory.activities, DifficultyTier.advanced, '📊'),
  ('n3_006', '原因', "gen'in", 'Cause / Reason', WordCategory.activities, DifficultyTier.advanced, '🔍'),
  ('n3_007', '目的', 'mokuteki', 'Purpose / Objective', WordCategory.activities, DifficultyTier.advanced, '🎯'),
  ('n3_008', '方法', 'houhou', 'Method / Way', WordCategory.activities, DifficultyTier.advanced, '🛠️'),
  ('n3_009', '手段', 'shudan', 'Means / Measure', WordCategory.activities, DifficultyTier.advanced, '🔧'),
  ('n3_010', '条件', 'jouken', 'Condition / Requirement', WordCategory.activities, DifficultyTier.advanced, '📋'),
  ('n3_011', '機会', 'kikai', 'Opportunity / Chance', WordCategory.activities, DifficultyTier.advanced, '🎲'),
  ('n3_012', '可能性', 'kanousei', 'Possibility / Potential', WordCategory.activities, DifficultyTier.advanced, '🔮'),

  // ── Work & Business ───────────────────────────────────────────────────
  ('n3_013', '職業', 'shokugyou', 'Occupation / Profession', WordCategory.activities, DifficultyTier.advanced, '💼'),
  ('n3_014', '収入', 'shuunyuu', 'Income / Earnings', WordCategory.activities, DifficultyTier.advanced, '💰'),
  ('n3_015', '税金', 'zeikin', 'Tax', WordCategory.activities, DifficultyTier.advanced, '🧾'),
  ('n3_016', '保険', 'hoken', 'Insurance', WordCategory.activities, DifficultyTier.advanced, '🛡️'),
  ('n3_017', '年金', 'nenkin', 'Pension', WordCategory.activities, DifficultyTier.advanced, '👴'),
  ('n3_018', '手続き', 'tetsuzuki', 'Procedure / Formalities', WordCategory.activities, DifficultyTier.advanced, '📝'),
  ('n3_019', '申請', 'shinsei', 'Application / Request', WordCategory.activities, DifficultyTier.advanced, '📄'),
  ('n3_020', '許可', 'kyoka', 'Permission / Approval', WordCategory.activities, DifficultyTier.advanced, '✅'),
  ('n3_021', '禁止', 'kinshi', 'Prohibition / Ban', WordCategory.activities, DifficultyTier.advanced, '🚫'),
  ('n3_022', '指示', 'shiji', 'Instruction / Direction', WordCategory.activities, DifficultyTier.advanced, '👉'),

  // ── Society & Politics ────────────────────────────────────────────────
  ('n3_023', '政治', 'seiji', 'Politics', WordCategory.activities, DifficultyTier.advanced, '🏛️'),
  ('n3_024', '経済', 'keizai', 'Economy', WordCategory.activities, DifficultyTier.advanced, '📈'),
  ('n3_025', '法律', 'houritsu', 'Law', WordCategory.activities, DifficultyTier.advanced, '⚖️'),
  ('n3_026', '国際', 'kokusai', 'International', WordCategory.activities, DifficultyTier.advanced, '🌐'),
  ('n3_027', '関係', 'kankei', 'Relationship / Connection', WordCategory.activities, DifficultyTier.advanced, '🔗'),
  ('n3_028', '影響', 'eikyou', 'Influence / Effect', WordCategory.activities, DifficultyTier.advanced, '〰️'),
  ('n3_029', '問題', 'mondai', 'Problem / Issue', WordCategory.activities, DifficultyTier.advanced, '❓'),
  ('n3_030', '解決', 'kaiketsu', 'Solution / Resolution', WordCategory.activities, DifficultyTier.advanced, '💡'),
  ('n3_031', '提案', 'teian', 'Proposal / Suggestion', WordCategory.activities, DifficultyTier.advanced, '💭'),
  ('n3_032', '議論', 'giron', 'Discussion / Debate', WordCategory.activities, DifficultyTier.advanced, '🗣️'),

  // ── Emotions & Psychology ─────────────────────────────────────────────
  ('n3_033', '感動', 'kandou', 'Deep emotion / Being moved', WordCategory.activities, DifficultyTier.advanced, '😭'),
  ('n3_034', '感謝', 'kansha', 'Gratitude / Appreciation', WordCategory.greetings, DifficultyTier.advanced, '🙏'),
  ('n3_035', '尊敬', 'sonkei', 'Respect / Esteem', WordCategory.activities, DifficultyTier.advanced, '🙌'),
  ('n3_036', '信頼', 'shinrai', 'Trust / Confidence', WordCategory.activities, DifficultyTier.advanced, '🤝'),
  ('n3_037', '希望', 'kibou', 'Hope / Wish', WordCategory.activities, DifficultyTier.advanced, '🌟'),
  ('n3_038', '絶望', 'zetsubou', 'Despair / Hopelessness', WordCategory.activities, DifficultyTier.expert, '😞'),
  ('n3_039', '後悔', 'koukai', 'Regret / Remorse', WordCategory.activities, DifficultyTier.advanced, '😔'),
  ('n3_040', '満足', 'manzoku', 'Satisfaction / Contentment', WordCategory.activities, DifficultyTier.advanced, '😊'),
  ('n3_041', '不満', 'fuman', 'Dissatisfaction / Complaint', WordCategory.activities, DifficultyTier.advanced, '😒'),
  ('n3_042', '勇気', 'yuuki', 'Courage / Bravery', WordCategory.activities, DifficultyTier.advanced, '🦁'),
  ('n3_043', '緊張', 'kinchou', 'Nervousness / Tension', WordCategory.activities, DifficultyTier.advanced, '😰'),

  // ── Media & Technology ────────────────────────────────────────────────
  ('n3_044', '放送', 'housou', 'Broadcast', WordCategory.activities, DifficultyTier.advanced, '📺'),
  ('n3_045', '通信', 'tsuushin', 'Communication / Telecommunications', WordCategory.activities, DifficultyTier.advanced, '📡'),
  ('n3_046', '広告', 'koukoku', 'Advertisement / Ad', WordCategory.activities, DifficultyTier.advanced, '📢'),
  ('n3_047', '記事', 'kiji', 'Article / News story', WordCategory.activities, DifficultyTier.advanced, '📰'),
  ('n3_048', '出版', 'shuppan', 'Publishing / Publication', WordCategory.activities, DifficultyTier.advanced, '📚'),
  ('n3_049', '印刷', 'insatsu', 'Printing', WordCategory.activities, DifficultyTier.advanced, '🖨️'),
  ('n3_050', '発明', 'hatsumei', 'Invention', WordCategory.activities, DifficultyTier.advanced, '💡'),
  ('n3_051', '開発', 'kaihatsu', 'Development', WordCategory.activities, DifficultyTier.advanced, '🛠️'),
  ('n3_052', '技術', 'gijutsu', 'Technology / Technique', WordCategory.activities, DifficultyTier.advanced, '🔬'),
  ('n3_053', '研究', 'kenkyuu', 'Research / Study', WordCategory.activities, DifficultyTier.advanced, '🔍'),

  // ── Advanced Verbs (suru-verbs) ───────────────────────────────────────
  ('n3_054', '確認する', 'kakunin suru', 'To confirm / To verify', WordCategory.activities, DifficultyTier.advanced, '✔️'),
  ('n3_055', '承知する', 'shouchi suru', 'To consent / To understand', WordCategory.activities, DifficultyTier.advanced, '👌'),
  ('n3_056', '連絡する', 'renraku suru', 'To contact / To get in touch', WordCategory.activities, DifficultyTier.advanced, '📞'),
  ('n3_057', '相談する', 'soudan suru', 'To consult / To discuss', WordCategory.activities, DifficultyTier.advanced, '💬'),
  ('n3_058', '協力する', 'kyouryoku suru', 'To cooperate / To collaborate', WordCategory.activities, DifficultyTier.advanced, '🤝'),
  ('n3_059', '参加する', 'sanka suru', 'To participate / To join', WordCategory.activities, DifficultyTier.advanced, '🙋'),
  ('n3_060', '出席する', 'shusseki suru', 'To attend / To be present', WordCategory.activities, DifficultyTier.advanced, '✅'),
  ('n3_061', '欠席する', 'kesseki suru', 'To be absent / To miss', WordCategory.activities, DifficultyTier.advanced, '❌'),
  ('n3_062', '到着する', 'touchaku suru', 'To arrive', WordCategory.places, DifficultyTier.advanced, '🛬'),
  ('n3_063', '出発する', 'shuppatsu suru', 'To depart / To leave', WordCategory.places, DifficultyTier.advanced, '🛫'),

  // ── Advanced Adjectives ───────────────────────────────────────────────
  ('n3_064', '有効', 'yuukou', 'Valid / Effective', WordCategory.activities, DifficultyTier.advanced, '✅'),
  ('n3_065', '無効', 'mukou', 'Invalid / Ineffective', WordCategory.activities, DifficultyTier.advanced, '❌'),
  ('n3_066', '可能', 'kanou', 'Possible / Feasible', WordCategory.activities, DifficultyTier.advanced, '👍'),
  ('n3_067', '不可能', 'fukanou', 'Impossible', WordCategory.activities, DifficultyTier.advanced, '👎'),
  ('n3_068', '正確', 'seikaku', 'Accurate / Precise', WordCategory.activities, DifficultyTier.advanced, '🎯'),
  ('n3_069', '確実', 'kakujitsu', 'Certain / Reliable', WordCategory.activities, DifficultyTier.advanced, '💯'),
  ('n3_070', '重大', 'juudai', 'Serious / Grave / Important', WordCategory.activities, DifficultyTier.advanced, '⚠️'),
  ('n3_071', '深刻', 'shinkoku', 'Serious / Severe / Grave', WordCategory.activities, DifficultyTier.expert, '🔴'),
  ('n3_072', '単純', 'tanjun', 'Simple / Plain', WordCategory.activities, DifficultyTier.advanced, '😶'),
  ('n3_073', '複雑', 'fukuzatsu', 'Complex / Complicated', WordCategory.activities, DifficultyTier.advanced, '🌀'),

  // ── More Abstract Concepts ────────────────────────────────────────────
  ('n3_074', '意識', 'ishiki', 'Awareness / Consciousness', WordCategory.activities, DifficultyTier.advanced, '🧠'),
  ('n3_075', '存在', 'sonzai', 'Existence / Presence', WordCategory.activities, DifficultyTier.advanced, '👤'),
  ('n3_076', '価値', 'kachi', 'Value / Worth', WordCategory.activities, DifficultyTier.advanced, '💎'),
  ('n3_077', '立場', 'tachiba', 'Position / Standpoint', WordCategory.activities, DifficultyTier.advanced, '🧍'),
  ('n3_078', '傾向', 'keikou', 'Tendency / Trend', WordCategory.activities, DifficultyTier.expert, '📈'),
  ('n3_079', '状態', 'joutai', 'State / Condition', WordCategory.activities, DifficultyTier.advanced, '📊'),
  ('n3_080', '環境', 'kankyou', 'Environment / Surroundings', WordCategory.nature, DifficultyTier.advanced, '🌍'),
  ('n3_081', '資源', 'shigen', 'Resource', WordCategory.nature, DifficultyTier.advanced, '⛏️'),
  ('n3_082', '制度', 'seido', 'System / Institution', WordCategory.activities, DifficultyTier.advanced, '🏛️'),
  ('n3_083', '組織', 'soshiki', 'Organisation', WordCategory.activities, DifficultyTier.advanced, '🏢'),

  // ── Economy & Trade ───────────────────────────────────────────────────
  ('n3_084', '企業', 'kigyou', 'Enterprise / Corporation', WordCategory.activities, DifficultyTier.advanced, '🏢'),
  ('n3_085', '産業', 'sangyou', 'Industry', WordCategory.activities, DifficultyTier.advanced, '🏭'),
  ('n3_086', '貿易', 'boueki', 'Trade (foreign)', WordCategory.activities, DifficultyTier.advanced, '🚢'),
  ('n3_087', '輸入', 'yunyuu', 'Import', WordCategory.activities, DifficultyTier.advanced, '📥'),
  ('n3_088', '輸出', 'yushutsu', 'Export', WordCategory.activities, DifficultyTier.advanced, '📤'),
  ('n3_089', '消費', 'shouhi', 'Consumption', WordCategory.activities, DifficultyTier.advanced, '🛒'),
  ('n3_090', '生産', 'seisan', 'Production', WordCategory.activities, DifficultyTier.advanced, '🏭'),
  ('n3_091', '需要', 'juyou', 'Demand', WordCategory.activities, DifficultyTier.expert, '📊'),
  ('n3_092', '供給', 'kyoukyuu', 'Supply', WordCategory.activities, DifficultyTier.expert, '📦'),
  ('n3_093', '経営', 'keiei', 'Management / Administration', WordCategory.activities, DifficultyTier.advanced, '📋'),

  // ── Work & Formal Settings ────────────────────────────────────────────
  ('n3_094', '会議', 'kaigi', 'Meeting / Conference', WordCategory.activities, DifficultyTier.advanced, '👥'),
  ('n3_095', '報告', 'houkoku', 'Report', WordCategory.activities, DifficultyTier.advanced, '📄'),
  ('n3_096', '連絡', 'renraku', 'Contact / Communication', WordCategory.activities, DifficultyTier.advanced, '📧'),
  ('n3_097', '予約', 'yoyaku', 'Reservation / Booking', WordCategory.activities, DifficultyTier.advanced, '📅'),
  ('n3_098', '注文', 'chuumon', 'Order / Request', WordCategory.food, DifficultyTier.advanced, '📝'),
  ('n3_099', '支払い', 'shiharai', 'Payment', WordCategory.activities, DifficultyTier.advanced, '💳'),
  ('n3_100', '請求', 'seikyuu', 'Billing / Claim / Demand', WordCategory.activities, DifficultyTier.advanced, '🧾'),
  ('n3_101', '契約', 'keiyaku', 'Contract / Agreement', WordCategory.activities, DifficultyTier.advanced, '📜'),
  ('n3_102', '交渉', 'koushou', 'Negotiation', WordCategory.activities, DifficultyTier.expert, '🤝'),
  ('n3_103', '代表', 'daihyou', 'Representative / Delegate', WordCategory.people, DifficultyTier.advanced, '👔'),

  // ── Rights & Responsibilities ─────────────────────────────────────────
  ('n3_104', '責任', 'sekinin', 'Responsibility', WordCategory.activities, DifficultyTier.advanced, '⚖️'),
  ('n3_105', '権利', 'kenri', 'Right (entitlement)', WordCategory.activities, DifficultyTier.advanced, '✊'),
  ('n3_106', '義務', 'gimu', 'Duty / Obligation', WordCategory.activities, DifficultyTier.advanced, '📋'),
  ('n3_107', '自由', 'jiyuu', 'Freedom / Liberty', WordCategory.activities, DifficultyTier.advanced, '🕊️'),
  ('n3_108', '平等', 'byoudou', 'Equality', WordCategory.activities, DifficultyTier.advanced, '⚖️'),
  ('n3_109', '安全', 'anzen', 'Safety / Security', WordCategory.activities, DifficultyTier.advanced, '🛡️'),
  ('n3_110', '危険', 'kiken', 'Danger / Hazard', WordCategory.activities, DifficultyTier.advanced, '⚠️'),
  ('n3_111', '成功', 'seikou', 'Success', WordCategory.activities, DifficultyTier.advanced, '🏆'),
  ('n3_112', '失敗', 'shippai', 'Failure', WordCategory.activities, DifficultyTier.advanced, '💥'),
  ('n3_113', '挑戦', 'chousen', 'Challenge', WordCategory.activities, DifficultyTier.advanced, '⚔️'),

  // ── More N3 Verbs ─────────────────────────────────────────────────────
  ('n3_114', '含む', 'fukumu', 'To include / To contain', WordCategory.activities, DifficultyTier.advanced, '📦'),
  ('n3_115', '減る', 'heru', 'To decrease / To diminish', WordCategory.activities, DifficultyTier.advanced, '📉'),
  ('n3_116', '増える', 'fueru', 'To increase / To grow', WordCategory.activities, DifficultyTier.advanced, '📈'),
  ('n3_117', '進む', 'susumu', 'To advance / To progress', WordCategory.activities, DifficultyTier.advanced, '➡️'),
  ('n3_118', '遅れる', 'okureru', 'To be late / To fall behind', WordCategory.activities, DifficultyTier.advanced, '⏰'),
  ('n3_119', '間に合う', 'ma ni au', 'To be in time / To make it', WordCategory.activities, DifficultyTier.advanced, '⏱️'),
  ('n3_120', '比べる', 'kuraberu', 'To compare', WordCategory.activities, DifficultyTier.advanced, '⚖️'),
  ('n3_121', '届く', 'todoku', 'To reach / To arrive', WordCategory.activities, DifficultyTier.advanced, '📬'),
  ('n3_122', '伝える', 'tsutaeru', 'To convey / To tell', WordCategory.activities, DifficultyTier.advanced, '💬'),
  ('n3_123', '訳す', 'yakusu', 'To translate', WordCategory.activities, DifficultyTier.advanced, '🌐'),

  // ── More N3 Adverbs & Expressions ─────────────────────────────────────
  ('n3_124', '突然', 'totsuzen', 'Suddenly / Abruptly', WordCategory.activities, DifficultyTier.advanced, '⚡'),
  ('n3_125', '徐々に', 'jojo ni', 'Gradually / Little by little', WordCategory.activities, DifficultyTier.advanced, '🐢'),
  ('n3_126', 'ますます', 'masumasu', 'Increasingly / More and more', WordCategory.activities, DifficultyTier.advanced, '📈'),
  ('n3_127', 'やはり', 'yahari', 'As expected / After all', WordCategory.activities, DifficultyTier.advanced, '🤷'),
  ('n3_128', '例えば', 'tatoeba', 'For example', WordCategory.activities, DifficultyTier.advanced, '💡'),
  ('n3_129', '実際', 'jissai', 'Actually / In reality', WordCategory.activities, DifficultyTier.advanced, '🔍'),
  ('n3_130', '一体', 'ittai', 'What on earth / In the world', WordCategory.activities, DifficultyTier.advanced, '❓'),
  ('n3_131', '結局', 'kekkyoku', 'In the end / After all', WordCategory.activities, DifficultyTier.advanced, '🏁'),
  ('n3_132', '一応', 'ichiou', 'For now / Tentatively / Just in case', WordCategory.activities, DifficultyTier.advanced, '🤞'),
  ('n3_133', '少なくとも', 'sukunakutomo', 'At least', WordCategory.activities, DifficultyTier.advanced, '📏'),
];

final n3Words = _n3Raw
    .map((r) => Word(
          id: r.$1,
          japanese: r.$2,
          romaji: r.$3,
          english: r.$4,
          category: r.$5,
          tier: r.$6,
          emoji: r.$7,
        ))
    .toList();
